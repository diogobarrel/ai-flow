# Workflow Intuition Fine-tuning Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a high-quality dataset of workflow Instruction/Response pairs and fine-tune a Qwen2.5-Coder-7B model using Unsloth to teach it the user's specific development "intuition".

**Architecture:** A series of Python scripts in `src/fine_tuning` to generate synthetic data, collect logs, and format the final dataset. The training is performed using a dedicated script that leverages Unsloth for QLoRA.

**Tech Stack:** Python, OpenAI/Anthropic API (for synthetic generation), Unsloth (for training), HuggingFace Datasets, Ollama.

---

### Task 1: Synthetic Dataset Generator

**Files:**
- Create: `src/fine_tuning/synthetic_gen.py`
- Create: `tests/fine_tuning/test_synthetic.py`

- [ ] **Step 1: Write the failing test**

```python
# tests/fine_tuning/test_synthetic.py
import pytest
from fine_tuning.synthetic_gen import generate_scenario

def test_generate_scenario_structure():
    # Test that it returns a dict with instruction and response
    scenario = generate_scenario("bootstrap a project")
    assert "instruction" in scenario
    assert "response" in scenario
    assert len(scenario["instruction"]) > 0
```

- [ ] **Step 2: Run test to verify it fails**

```bash
.venv\Scripts\pytest tests/fine_tuning/test_synthetic.py -v
```

- [ ] **Step 3: Write minimal implementation**

```python
# src/fine_tuning/synthetic_gen.py
import os
import json

def generate_scenario(topic: str) -> dict:
    # In a real run, this would call Claude 3.5 Sonnet
    # For the minimal implementation/test, we return a mock structure
    return {
        "instruction": f"How do I {topic}?",
        "response": f"According to WORKFLOW.md, you should use the relevant playbook for {topic}."
    }

if __name__ == "__main__":
    # Placeholder for the actual generation loop
    topics = ["bootstrap React", "cleanup old project", "commit branch"]
    dataset = [generate_scenario(t) for topic in topics]
    with open("data/synthetic_raw.jsonl", "w") as f:
        for entry in dataset:
            f.write(json.dumps(entry) + "\n")
```

- [ ] **Step 4: Run test to verify it passes**

```bash
.venv\Scripts\pytest tests/fine_tuning/test_synthetic.py -v
```

- [ ] **Step 5: Commit**

```bash
git add src/fine_tuning/synthetic_gen.py tests/fine_tuning/test_synthetic.py
git commit -m "feat: add synthetic dataset generator skeleton"
```

---

### Task 2: Golden Log Formatter

**Files:**
- Create: `src/fine_tuning/log_formatter.py`

- [ ] **Step 1: Implement log cleaning and formatting**

```python
# src/fine_tuning/log_formatter.py
import json
import re

def clean_log(text: str) -> str:
    # Remove secrets like API keys or identifiable hashes
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
```

- [ ] **Step 2: Commit**

```bash
git add src/fine_tuning/log_formatter.py
git commit -m "feat: add golden log formatter with basic cleaning"
```

---

### Task 3: Unsloth Training Script

**Files:**
- Create: `src/fine_tuning/train.py`

- [ ] **Step 1: Write training script using Unsloth**

```python
# src/fine_tuning/train.py
from unsloth import FastLanguageModel
import torch
from datasets import load_dataset
from trl import SFTTrainer
from transformers import TrainingArguments

def run_training(dataset_path: str, output_dir: str):
    model, tokenizer = FastLanguageModel.from_pretrained(
        model_name = "unsloth/Qwen2.5-Coder-7B-Instruct-bnb-4bit",
        max_seq_length = 2048,
        load_in_4bit = True,
    )

    model = FastLanguageModel.get_peft_model(
        model,
        r = 16,
        target_modules = ["q_proj", "k_proj", "v_proj", "o_proj"],
        lora_alpha = 16,
        lora_dropout = 0,
        bias = "none",
    )

    dataset = load_dataset("json", data_files=dataset_path, split="train")

    trainer = SFTTrainer(
        model = model,
        tokenizer = tokenizer,
        train_dataset = dataset,
        dataset_text_field = "text",
        max_seq_length = 2048,
        args = TrainingArguments(
            per_device_train_batch_size = 2,
            gradient_accumulation_steps = 4,
            warmup_steps = 5,
            max_steps = 60,
            learning_rate = 2e-4,
            fp16 = not torch.cuda.is_bf16_supported(),
            bf16 = torch.cuda.is_bf16_supported(),
            logging_steps = 1,
            output_dir = output_dir,
        ),
    )

    trainer.train()
    model.save_pretrained_gguf(output_dir, tokenizer, quantization_method = "q4_k_m")

if __name__ == "__main__":
    run_training("data/final_dataset.jsonl", "models/flow-orchestrator")
```

- [ ] **Step 2: Commit**

```bash
git add src/fine_tuning/train.py
git commit -m "feat: add Unsloth training script for QLoRA"
```

---

### Task 4: Ollama Integration

**Files:**
- Create: `models/orchestrator.Modelfile`

- [ ] **Step 1: Create the Modelfile**

```dockerfile
FROM ./flow-orchestrator.Q4_K_M.gguf

SYSTEM """You are the AI Dev Flow Orchestrator. 
You follow the rules in WORKFLOW.md and playbooks meticulously.
You decide when to delegate tasks to Claude, Gemini, or Local Helpers."""

PARAMETER temperature 0.2
PARAMETER stop "<|im_start|>"
PARAMETER stop "<|im_end|>"
```

- [ ] **Step 2: Create the model in Ollama**

```bash
ollama create flow-orchestrator -f models/orchestrator.Modelfile
```

- [ ] **Step 3: Commit**

```bash
git add models/orchestrator.Modelfile
git commit -m "feat: add Ollama Modelfile for the fine-tuned orchestrator"
```
