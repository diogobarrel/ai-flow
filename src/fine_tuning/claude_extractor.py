import json
import os
import glob

def clean_text(text):
    if not text: return ""
    return text.strip()

def process_claude_project_log(file_path):
    pairs = []
    current_user_msg = None
    
    if not os.path.exists(file_path):
        return []

    with open(file_path, 'r', encoding='utf-8') as f:
        for line in f:
            try:
                data = json.loads(line)
                
                # Claude Code JSONL structure:
                # User messages usually have type: "user"
                if data.get("type") == "user":
                    msg = data.get("message", {})
                    content = msg.get("content", "")
                    if content:
                        current_user_msg = clean_text(content)
                
                # Responses are often in attachments or subsequent blocks
                # We look for "assistant" responses or tool usage that implies a response
                elif current_user_msg and data.get("type") == "assistant":
                    # This is a simplified extraction
                    assistant_content = data.get("message", {}).get("content", "")
                    if assistant_content:
                        pairs.append({
                            "instruction": current_user_msg,
                            "response": assistant_content,
                            "source": "claude_code"
                        })
                        current_user_msg = None # Reset
            except:
                continue
    return pairs

def main():
    claude_project_dir = r"C:\Users\santo\.claude\projects\C--Users-santo-Dev-ai-flow"
    output_path = "data/claude_expert_data.jsonl"
    
    all_pairs = []
    
    # Process all session logs in the project folder
    log_files = glob.glob(os.path.join(claude_project_dir, "*.jsonl"))
    print(f"Found {len(log_files)} Claude session logs.")
    
    for log_file in log_files:
        print(f"Processing {os.path.basename(log_file)}...")
        pairs = process_claude_project_log(log_file)
        all_pairs.extend(pairs)
        
    os.makedirs("data", exist_ok=True)
    with open(output_path, "w", encoding='utf-8') as f:
        for pair in all_pairs:
            # Format for Alpaca/Unsloth
            pair["text"] = f"### Instruction:\n{pair['instruction']}\n\n### Response:\n{pair['response']}"
            f.write(json.dumps(pair) + "\n")
            
    print(f"Extraction complete. {len(all_pairs)} expert pairs saved to {output_path}")

if __name__ == "__main__":
    main()
