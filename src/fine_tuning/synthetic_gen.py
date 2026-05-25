import os
import json

def generate_scenario(topic: str) -> dict:
    return {
        "instruction": f"How do I {topic}?",
        "response": f"According to WORKFLOW.md, you should use the relevant playbook for {topic}."
    }

if __name__ == "__main__":
    # Ensure data directory exists
    os.makedirs("data", exist_ok=True)
    topics = ["bootstrap React", "cleanup old project", "commit branch"]
    dataset = [generate_scenario(t) for t in topics]
    with open("data/synthetic_raw.jsonl", "w") as f:
        for entry in dataset:
            f.write(json.dumps(entry) + "\n")
