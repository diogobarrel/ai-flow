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
    
    # Mock the os.path.exists to return True
    monkeypatch.setattr("os.path.exists", lambda path: True)
    
    # Mock the db.get_collection
    class MockClient:
        def get_collection(self, name):
            return "mock_collection"
    
    monkeypatch.setattr("rag_pipeline.query.chromadb.PersistentClient", lambda path: MockClient())

    result = search_codebase("where is the auth logic?", db_dir="mock_path")
    assert "Mocked context result" in result
