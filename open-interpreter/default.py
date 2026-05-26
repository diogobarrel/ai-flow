from interpreter import interpreter

# 1. Disable the Computer API (which often triggers JSON tool calling mode)
interpreter.computer.import_computer_api = False

# 2. Force Markdown execution and disable JSON function calling
interpreter.llm.supports_functions = False
interpreter.llm.execution_instructions = "To execute code on the user's machine, write a markdown code block. Specify the language after the ```. You will receive the output. Use any programming language."

# 3. Use a template to force the model into the right "mode" for every message
interpreter.user_message_template = "Write a markdown code snippet that would answer this query: `{content}`"

# 4. LLM Configuration
interpreter.llm.model = "ollama/qwen2.5-coder:7b"
interpreter.llm.api_base = "http://localhost:11434"
interpreter.llm.context_window = 16000
interpreter.llm.temperature = 0.0

# 5. System Message
interpreter.system_message = """You are a helpful AI assistant.
# MANDATORY: NO JSON. NO TOOL CALLS. 
# ONLY USE MARKDOWN CODE BLOCKS.

You help with general tasks, answering questions, and writing code to automate simple things.

EXECUTION:
- Provide the code in a markdown block.
- Wait for user approval.
""".strip()

# 6. Response handling
interpreter.code_output_template = "I executed your code snippet. This was the output: \n\n{content}\n\nWhat's next (if anything, or are we done?)"
interpreter.empty_code_output_template = "I executed your code snippet. It produced no text output. What's next (if anything, or are we done?)"
interpreter.code_output_sender = "user"

# 7. Misc
interpreter.auto_run = False
interpreter.offline = True

# 8. Display message
interpreter.display_message("> Profile `default` loaded with Markdown enforcement.\n")
