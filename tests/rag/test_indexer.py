# tests/rag/test_indexer.py
import os
import chromadb
import pytest
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
