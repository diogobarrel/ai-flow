from unsloth import FastLanguageModel
import torch
from datasets import load_dataset
from trl import SFTTrainer
from transformers import TrainingArguments
import os

def run_training(dataset_path: str, output_dir: str):
    print(f"Loading model: unsloth/Qwen2.5-Coder-7B-Instruct-bnb-4bit")
    model, tokenizer = FastLanguageModel.from_pretrained(
        model_name = "unsloth/Qwen2.5-Coder-7B-Instruct-bnb-4bit",
        max_seq_length = 2048,
        load_in_4bit = True,
    )

    print("Adding LoRA adapters...")
    model = FastLanguageModel.get_peft_model(
        model,
        r = 16,
        target_modules = ["q_proj", "k_proj", "v_proj", "o_proj", "gate_proj", "up_proj", "down_proj"],
        lora_alpha = 16,
        lora_dropout = 0,
        bias = "none",
        use_gradient_checkpointing = "unsloth",
    )

    print(f"Loading dataset from {dataset_path}...")
    dataset = load_dataset("json", data_files=dataset_path, split="train")

    print("Starting trainer...")
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
            # For 21 samples, 60 steps is about 5-10 epochs
            max_steps = 100, # Increased steps for better retention of PowerShell patterns
            learning_rate = 2e-4,
            fp16 = not torch.cuda.is_bf16_supported(),
            bf16 = torch.cuda.is_bf16_supported(),
            logging_steps = 1,
            output_dir = output_dir,
            save_strategy = "no", # We'll save manually at the end
        ),
    )

    trainer.train()

    print(f"Saving fine-tuned model to {output_dir}...")
    model.save_pretrained(output_dir)
    tokenizer.save_pretrained(output_dir)

    print("Exporting to GGUF (this will take some time and VRAM)...")
    # Exporting for Ollama
    model.save_pretrained_gguf(
        output_dir, 
        tokenizer, 
        quantization_method = "q4_k_m"
    )

if __name__ == "__main__":
    os.makedirs("models/flow-orchestrator", exist_ok=True)
    dataset_file = "data/training_data_filtered.jsonl"
    if os.path.exists(dataset_file):
        run_training(dataset_file, "models/flow-orchestrator")
    else:
        print(f"Error: Dataset file not found at {dataset_file}")
