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
        db_dir = os.environ.get("CHROMA_DB_DIR", os.path.expanduser("~\\.ai_flow_chroma"))
        
    if not os.path.exists(db_dir):
        return f"Error: Database directory '{db_dir}' not found. Please run indexer.py first."
        
    # Configure Ollama Embeddings (must match indexer)
    Settings.embed_model = OllamaEmbedding(model_name="nomic-embed-text")
    Settings.llm = None # Disable LLM during retrieval
    
    try:
        db = chromadb.PersistentClient(path=db_dir)
        # Check if collection exists
        try:
            chroma_collection = db.get_collection("codebase")
        except Exception:
            return "Error: Collection 'codebase' not found in database. Run indexer.py."
            
        vector_store = ChromaVectorStore(chroma_collection=chroma_collection)
        
        index = VectorStoreIndex.from_vector_store(vector_store=vector_store)
        query_engine = index.as_query_engine(similarity_top_k=3)
        
        response = query_engine.query(query)
        return str(response)
    except Exception as e:
        return f"Search failed: {str(e)}"

if __name__ == "__main__":
    import sys
    if len(sys.argv) > 1:
        print(search_codebase(sys.argv[1]))
    else:
        print("Usage: python query.py 'your search query'")
