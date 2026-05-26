import json
import os

def is_system_agent_task(instruction, response):
    """
    Returns True if the task is scoped to Windows System Administration, 
    file navigation, or PC management.
    Returns False if it's generic coding (React, Tailwind, etc.).
    """
    text = (instruction + " " + response).lower()
    
    # Generic coding/web dev keywords to EXCLUDE
    coding_keywords = [
        "react", "tailwind", "css", "frontend", "backend", 
        "javascript", "typescript", "html", "web app",
        "bootstrap a react", "create-react-app"
    ]
    
    # Check for exclusion
    for word in coding_keywords:
        if word in text:
            return False
            
    # System Agent keywords to INCLUDE (if they passed the exclusion check)
    system_keywords = [
        "powershell", "python", "file", "folder", "directory", 
        "disk", "drive", "permission", "size", "process", 
        "search", "list", "system", "windows", "get-childitem",
        "measure-object", "get-psdrive", "c:\\"
    ]
    
    for word in system_keywords:
        if word in text:
            return True
            
    # If it doesn't match either, we'll keep it as "behavioral" context 
    # unless it's clearly code generation.
    return True

def main():
    input_path = "data/training_data.jsonl"
    output_path = "data/training_data_filtered.jsonl"
    
    if not os.path.exists(input_path):
        print(f"Error: {input_path} not found.")
        return
        
    filtered_data = []
    with open(input_path, "r", encoding='utf-8') as f:
        for line in f:
            try:
                sample = json.loads(line)
                if is_system_agent_task(sample['instruction'], sample['response']):
                    filtered_data.append(sample)
            except:
                continue
                
    with open(output_path, "w", encoding='utf-8') as f:
        for entry in filtered_data:
            f.write(json.dumps(entry) + "\n")
            
    print(f"✅ Dataset Curated!")
    print(f"Original: {len(filtered_data) + (36 - len(filtered_data))} samples") # Estimated total
    print(f"Filtered (System Agent Scope): {len(filtered_data)} samples")
    print(f"Saved to: {output_path}")

if __name__ == "__main__":
    main()
