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
    # Ensure output directories exist
    import os
    os.makedirs("models/flow-orchestrator", exist_ok=True)
    # Note: This requires a dataset file to exist at 'data/final_dataset.jsonl' to run.
    # run_training("data/final_dataset.jsonl", "models/flow-orchestrator")
