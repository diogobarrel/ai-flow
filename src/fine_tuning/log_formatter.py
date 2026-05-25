import json
import re

def clean_log(text: str) -> str:
    # Remove secrets like API keys or identifiable hashes
    # Example: sk- followed by 32+ chars
    text = re.sub(r'sk-[a-zA-Z0-9]{32,}', '[SECRET_KEY]', text)
    return text

def format_log_to_pair(user_msg: str, assistant_msg: str) -> dict:
    return {
        "instruction": clean_log(user_msg),
        "response": clean_log(assistant_msg)
    }

if __name__ == "__main__":
    # Example usage for manual extraction
    print(json.dumps(format_log_to_pair("hi", "hello")))
