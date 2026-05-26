import json
import os

def format_alpaca(instruction, response):
    return f"### Instruction:\n{instruction}\n\n### Response:\n{response}"

def main():
    merged_data = []
    
    # Sources
    sources = [
        ("data/final_dataset.jsonl", "gemini_cli"),
        ("data/synthetic_pc_aware.jsonl", "synthetic"),
        ("data/claude_expert_data.jsonl", "claude_code")
    ]
    
    for path, source_name in sources:
        if os.path.exists(path):
            count = 0
            with open(path, "r", encoding='utf-8') as f:
                for line in f:
                    try:
                        pair = json.loads(line)
                        # Ensure 'text' field is present and correctly formatted
                        if "text" not in pair:
                            pair["text"] = format_alpaca(pair["instruction"], pair["response"])
                        pair["source"] = source_name
                        merged_data.append(pair)
                        count += 1
                    except:
                        continue
            print(f"Loaded {count} samples from {path} ({source_name})")
    
    # Save Final Dataset
    output_path = "data/training_data.jsonl"
    with open(output_path, "w", encoding='utf-8') as f:
        for entry in merged_data:
            f.write(json.dumps(entry) + "\n")
            
    print(f"\n🚀 Continuous Learning Dataset Ready!")
    print(f"Total samples: {len(merged_data)}")
    print(f"Location: {output_path}")

if __name__ == "__main__":
    main()
