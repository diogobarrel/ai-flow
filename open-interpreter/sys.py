from interpreter import interpreter

# 1. Disable the Computer API (which often triggers JSON tool calling mode)
interpreter.computer.import_computer_api = False

# 2. Force Markdown execution and disable JSON function calling
interpreter.llm.supports_functions = False
# In 0.4.3, we can set execution_instructions to False or custom text
interpreter.llm.execution_instructions = "To execute code on the user's machine, write a markdown code block. Specify the language after the ```. You will receive the output. Use any programming language."

# 3. Use a template to force the model into the right "mode" for every message
# This is a powerful override used in the official qwen profile
interpreter.user_message_template = "Write a markdown code snippet that would answer this query: `{content}`"

# 4. LLM Configuration
interpreter.llm.model = "ollama/qwen2.5-coder:7b"
interpreter.llm.api_base = "http://localhost:11434"
interpreter.llm.context_window = 16000
interpreter.llm.temperature = 0.0

# System Message (High-priority instructions)
interpreter.system_message = """You are a Windows System Administrator assistant.
# MANDATORY: ALWAYS PREFER NATIVE POWERSHELL.
# DO NOT use Python for file system analysis or system administration unless PowerShell is impossible.
# NO JSON. NO TOOL CALLS. 
# ONLY USE MARKDOWN CODE BLOCKS (```powershell).

SYSTEM INFO:
- OS: Windows 11 Home (25H2)
- Shell: PowerShell 5.1
- Hardware: i5-11400 / RTX 5060 Ti

SAFETY & PERFORMANCE RULES:
1. ALWAYS use `-ErrorAction SilentlyContinue` in PowerShell to handle permission denied issues without hanging.
2. For directory sizes, NEVER use recursive loops. Use:
   ```powershell
   Get-ChildItem -Path $PATH -Directory | ForEach-Object { $s = (Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum; [PSCustomObject]@{ Name=$_.Name; SizeGB="{0:N2}" -f ($s/1GB) } }
   ```
3. NEVER run recursive scans on 'C:\\'.

EXECUTION:
- Provide the code in a markdown block.
- Wait for user approval.
""".strip()

# 6. Response handling to keep the model focused
interpreter.code_output_template = "I executed your code snippet. This was the output: \n\n{content}\n\nWhat's next (if anything, or are we done?)"
interpreter.empty_code_output_template = "I executed your code snippet. It produced no text output. What's next (if anything, or are we done?)"
interpreter.code_output_sender = "user"

# 7. Misc
interpreter.auto_run = False
interpreter.offline = True

# 8. Display message to confirm loading
interpreter.display_message("> Profile `sys` loaded with Markdown enforcement.\n")
