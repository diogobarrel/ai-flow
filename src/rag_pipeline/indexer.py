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
    # Use environment variables or defaults
    dev_dir = os.environ.get("DEV_ROOT", os.path.expanduser("~\\Dev"))
    db_dir = os.environ.get("CHROMA_DB_DIR", os.path.expanduser("~\\.ai_flow_chroma"))
    
    if not os.path.exists(dev_dir):
        print(f"Error: {dev_dir} does not exist.")
    else:
        build_index(dev_dir, db_dir)
