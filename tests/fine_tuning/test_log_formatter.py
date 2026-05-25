import pytest
from src.fine_tuning.log_formatter import clean_log, format_log_to_pair

def test_clean_log_removes_secrets():
    raw_text = "Here is my secret: sk-1234567890abcdef1234567890abcdef"
    expected = "Here is my secret: [SECRET_KEY]"
    assert clean_log(raw_text) == expected

def test_clean_log_removes_multiple_secrets():
    raw_text = "Key1: sk-11111111111111111111111111111111, Key2: sk-22222222222222222222222222222222"
    expected = "Key1: [SECRET_KEY], Key2: [SECRET_KEY]"
    assert clean_log(raw_text) == expected

def test_format_log_to_pair_creates_dict():
    user_msg = "Show me the key sk-abc123abc123abc123abc123abc123abc123"
    assistant_msg = "The key is sk-abc123abc123abc123abc123abc123abc123, don't share it."
    
    result = format_log_to_pair(user_msg, assistant_msg)
    
    assert result["instruction"] == "Show me the key [SECRET_KEY]"
    assert result["response"] == "The key is [SECRET_KEY], don't share it."
