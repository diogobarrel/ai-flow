# Local RAG Pipeline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a local Retrieval-Augmented Generation (RAG) pipeline using LlamaIndex and ChromaDB to index the `/Dev` folder, and expose it as a searchable tool in the Open Interpreter environment.

**Architecture:** A Python package `src/rag_pipeline` containing `indexer.py` (builds the ChromaDB vector store) and `query.py` (exposes a `search_codebase` function). `open-interpreter/dev.py` is updated to inject this function into the assistant's environment.

**Tech Stack:** Python 3.9+, LlamaIndex, ChromaDB, Pytest, Ollama (`nomic-embed-text`).

---

### Task 1: Setup RAG Environment and Dependencies

**Files:**
- Create: `requirements-rag.txt`
- Create: `tests/rag/conftest.py`

- [ ] **Step 1: Write `requirements-rag.txt`**

```txt
llama-index
llama-index-embeddings-ollama
llama-index-vector-stores-chroma
chromadb
pytest
```

- [ ] **Step 2: Create tests directory and conftest**

```python
# tests/rag/conftest.py
import os
import sys

# Add src to python path for testing
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../../src')))
```

- [ ] **Step 3: Install dependencies**

```bash
pip install -r requirements-rag.txt
```

- [ ] **Step 4: Commit**

```bash
git add requirements-rag.txt tests/rag/conftest.py
git commit -m "chore: setup dependencies and test environment for RAG pipeline"
```

---

### Task 2: Implement Indexer Module

**Files:**
- Create: `src/rag_pipeline/indexer.py`
- Create: `tests/rag/test_indexer.py`

- [ ] **Step 1: Write the failing test**

```python
# tests/rag/test_indexer.py
import os
import chromadb
from rag_pipeline.indexer import build_index

def test_build_index_creates_collection(tmp_path):
    # Create a dummy project structure
    test_dir = tmp_path / "Dev" / "projectA"
    test_dir.mkdir(parents=True)
    (test_dir / "main.py").write_text("def hello():\n    print('world')\n")
    
    db_path = tmp_path / "chroma_db"
    
    # Build index
    build_index(source_dir=str(test_dir), db_dir=str(db_path))
    
    # Verify chroma DB has the document
    client = chromadb.PersistentClient(path=str(db_path))
    collection = client.get_collection("codebase")
    assert collection.count() > 0
```

- [ ] **Step 2: Run test to verify it fails**

```bash
pytest tests/rag/test_indexer.py -v
```

- [ ] **Step 3: Write minimal implementation**

```python
# src/rag_pipeline/indexer.py
import os
import chromadb
from llama_index.core import VectorStoreIndex, SimpleDirectoryReader, StorageContext, Settings
from llama_index.core.node_parser import SentenceSplitter
from llama_index.vector_stores.chroma import ChromaVectorStore
from llama_index.embeddings.ollama import OllamaEmbedding

def build_index(source_dir: str, db_dir: str):
    # Configure Ollama Embeddings
    Settings.embed_model = OllamaEmbedding(model_name="nomic-embed-text")
    Settings.llm = None # We only need embeddings for indexing
    
    # Use SentenceSplitter (Fallback for complex AST splitters to ensure cross-platform safety)
    Settings.text_splitter = SentenceSplitter(chunk_size=1024, chunk_overlap=200)
    
    # Load documents
    reader = SimpleDirectoryReader(
        input_dir=source_dir,
        recursive=True,
        exclude=["*.git*", "node_modules/*", "dist/*", "__pycache__/*", "*.pyc"]
    )
    documents = reader.load_data()
    
    if not documents:
        print("No documents found to index.")
        return
        
    # Setup ChromaDB
    db = chromadb.PersistentClient(path=db_dir)
    chroma_collection = db.get_or_create_collection("codebase")
    vector_store = ChromaVectorStore(chroma_collection=chroma_collection)
    storage_context = StorageContext.from_defaults(vector_store=vector_store)
    
    # Build Index
    VectorStoreIndex.from_documents(
        documents, 
        storage_context=storage_context
    )
    print(f"Successfully indexed {len(documents)} files into {db_dir}")

if __name__ == "__main__":
    # Default execution for local indexing
    dev_dir = os.path.expanduser("~\\Dev")
    db_dir = os.path.expanduser("~\\.ai_flow_chroma")
    build_index(dev_dir, db_dir)
```

- [ ] **Step 4: Run test to verify it passes**

```bash
pytest tests/rag/test_indexer.py -v
```

- [ ] **Step 5: Commit**

```bash
git add src/rag_pipeline/indexer.py tests/rag/test_indexer.py
git commit -m "feat: implement RAG indexer using LlamaIndex and ChromaDB"
```

---

### Task 3: Implement Query Interface

**Files:**
- Create: `src/rag_pipeline/query.py`
- Create: `tests/rag/test_query.py`

- [ ] **Step 1: Write the failing test**

```python
# tests/rag/test_query.py
import pytest
from rag_pipeline.query import search_codebase

def test_search_codebase_returns_string(monkeypatch):
    # Mock the ChromaDB/LlamaIndex internals to avoid actual DB hits in unit tests
    class MockEngine:
        def query(self, text):
            class MockResponse:
                def __str__(self):
                    return "Mocked context result: auth token is secret"
            return MockResponse()

    class MockIndex:
        @classmethod
        def from_vector_store(cls, vector_store):
            return cls()
        def as_query_engine(self, similarity_top_k):
            return MockEngine()

    monkeypatch.setattr("rag_pipeline.query.VectorStoreIndex", MockIndex)
    monkeypatch.setattr("rag_pipeline.query.chromadb.PersistentClient", lambda path: "mock_client")
    monkeypatch.setattr("rag_pipeline.query.ChromaVectorStore", lambda chroma_collection: "mock_store")
    
    result = search_codebase("where is the auth logic?", db_dir="mock_path")
    assert "Mocked context result" in result
```

- [ ] **Step 2: Run test to verify it fails**

```bash
pytest tests/rag/test_query.py -v
```

- [ ] **Step 3: Write minimal implementation**

```python
# src/rag_pipeline/query.py
import os
import chromadb
from llama_index.core import VectorStoreIndex, Settings
from llama_index.vector_stores.chroma import ChromaVectorStore
from llama_index.embeddings.ollama import OllamaEmbedding

def search_codebase(query: str, db_dir: str = None) -> str:
    """
    Searches the local indexed codebase for relevant context.
    Call this function when you need to know about the user's projects.
    """
    if db_dir is None:
        db_dir = os.path.expanduser("~\\.ai_flow_chroma")
        
    if not os.path.exists(db_dir):
        return "Error: Database not found. Please run indexer.py first."
        
    Settings.embed_model = OllamaEmbedding(model_name="nomic-embed-text")
    Settings.llm = None # Disable LLM during retrieval
    
    try:
        db = chromadb.PersistentClient(path=db_dir)
        chroma_collection = db.get_collection("codebase")
        vector_store = ChromaVectorStore(chroma_collection=chroma_collection)
        
        index = VectorStoreIndex.from_vector_store(vector_store=vector_store)
        query_engine = index.as_query_engine(similarity_top_k=3)
        
        response = query_engine.query(query)
        return str(response)
    except Exception as e:
        return f"Search failed: {str(e)}"
```

- [ ] **Step 4: Run test to verify it passes**

```bash
pytest tests/rag/test_query.py -v
```

- [ ] **Step 5: Commit**

```bash
git add src/rag_pipeline/query.py tests/rag/test_query.py
git commit -m "feat: implement RAG query interface for codebase search"
```

---

### Task 4: Integrate RAG into Open Interpreter

**Files:**
- Modify: `open-interpreter/dev.py`
- Create: `scripts/update_interpreter.py` (Script to safely patch the file)

- [ ] **Step 1: Create a patch script to update dev.py safely**

```python
# scripts/update_interpreter.py
import os

dev_py_path = "open-interpreter/dev.py"

with open(dev_py_path, "r") as f:
    content = f.read()

# Add sys.path injection at the top if not present
import_injection = """from interpreter import interpreter
import sys
import os

# Ensure the src directory is in the path
src_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '../src'))
if src_path not in sys.path:
    sys.path.append(src_path)
"""
if "import sys" not in content:
    content = content.replace("from interpreter import interpreter", import_injection)

# Add instructions to the SYSTEM MESSAGE if not present
rules_injection = """RULES:
- Prefer modular code.
- NEVER run recursive scans on the root 'C:\\' drive.

AVAILABLE TOOLS:
- Codebase Search (RAG): You can search the user's entire 'Dev' folder context.
  Use it by running this python block:
  ```python
  from rag_pipeline.query import search_codebase
  print(search_codebase("search query"))
  ```"""
if "AVAILABLE TOOLS:" not in content:
    content = content.replace(
        "RULES:\n- Prefer modular code.\n- NEVER run recursive scans on the root 'C:\\\\' drive.", 
        rules_injection
    )

with open(dev_py_path, "w") as f:
    f.write(content)
print("Successfully patched open-interpreter/dev.py")
```

- [ ] **Step 2: Run the patch script**

```bash
python scripts/update_interpreter.py
```

- [ ] **Step 3: Commit**

```bash
git add open-interpreter/dev.py scripts/update_interpreter.py
git commit -m "feat: integrate RAG codebase search tool into local orchestrator"
```
