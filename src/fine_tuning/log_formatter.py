import json
import os
import re

def clean_content(content):
    if not content:
        return ""
    if isinstance(content, list):
        # Extract text from list of content blocks (Gemini CLI format)
        text = " ".join([block.get("text", "") for block in content if isinstance(block, dict)])
        return text.strip()
    return str(content).strip()

def process_session_file(file_path):
    pairs = []
    current_user_msg = None
    
    if not os.path.exists(file_path):
        return []

    with open(file_path, 'r', encoding='utf-8') as f:
        for line in f:
            try:
                data = json.loads(line)
                msg_type = data.get("type")
                
                if msg_type == "user":
                    current_user_msg = clean_content(data.get("content"))
                
                elif msg_type == "gemini" and current_user_msg:
                    # Capture the assistant response
                    # We prioritize 'content' if it exists, otherwise maybe summarize tool calls or thoughts
                    # For fine-tuning "intuition", we want the textual response or the intent.
                    assistant_msg = data.get("content", "")
                    
                    # If content is empty but there are tool calls, the "response" for fine-tuning 
                    # should ideally reflect the action taken.
                    if not assistant_msg and "toolCalls" in data:
                        tools = [tc.get("name") for tc in data["toolCalls"]]
                        assistant_msg = f"I will use the following tools: {', '.join(tools)}"
                    
                    if assistant_msg:
                        pairs.append({
                            "instruction": current_user_msg,
                            "response": assistant_msg
                        })
                        current_user_msg = None # Reset for next pair
            except json.JSONDecodeError:
                continue
                
    return pairs

def main():
    input_files = [
        "data/golden_santo_session.jsonl",
        "data/golden_claw_session.jsonl"
    ]
    
    final_dataset = []
    for file in input_files:
        print(f"Processing {file}...")
        final_dataset.extend(process_session_file(file))
        
    os.makedirs("data", exist_ok=True)
    output_path = "data/final_dataset.jsonl"
    with open(output_path, "w", encoding='utf-8') as f:
        for pair in final_dataset:
            # Format for Unsloth/SFT (Instruction-Response)
            # We can also wrap in a template here if needed
            f.write(json.dumps(pair) + "\n")
            
    print(f"Extraction complete. {len(final_dataset)} pairs saved to {output_path}")

if __name__ == "__main__":
    main()
