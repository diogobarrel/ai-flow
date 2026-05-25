from interpreter import interpreter
import sys
import os

# Ensure the src directory is in the path
src_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '../src'))
if src_path not in sys.path:
    sys.path.append(src_path)


# Force markdown execution and disable JSON function calling
interpreter.llm.supports_functions = False
interpreter.llm.execution_instructions = "To execute code on the user's machine, write a markdown code block. Specify the language after the ```. You will receive the output. Use any programming language."
interpreter.user_message_template = "Generate a code snippet in markdown to answer this: {content}"

# LLM Configuration
interpreter.llm.model = "ollama/qwen2.5-coder:14b"
interpreter.llm.api_base = "http://localhost:11434"
interpreter.llm.context_window = 16000
interpreter.llm.temperature = 0.0

# System Message
interpreter.system_message = """You are an expert Software Engineer assistant.
# MANDATORY: NO JSON. NO TOOL CALLS. 
# ONLY USE MARKDOWN CODE BLOCKS (```powershell or ```python).

WORKSPACE:
- Primary Dev Folder: C:\\Users\\santo\\Dev
- Default to C:\\Users\\santo\\Dev for all new projects.

TOOLSET:
- Git: 2.45.2.windows.1
- Node: v24.16.0
- Python: 3.9.13

AVAILABLE TOOLS:
- Codebase Search (RAG): You can search the user's entire 'Dev' folder context.
  Use it by running this python block:
  ```python
  from rag_pipeline.query import search_codebase
  print(search_codebase("search query"))
  ```
RULES:
- Prefer modular code.
- NEVER run recursive scans on the root 'C:\\' drive.
""".strip()

# Computer settings
interpreter.computer.import_computer_api = True

# Misc
interpreter.auto_run = False
interpreter.offline = True
