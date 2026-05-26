import os
import sys

# Ensure src/ is on the path when run as a subprocess by Hermes
sys.path.insert(0, os.path.dirname(__file__))

from mcp.server.fastmcp import FastMCP
from rag_pipeline.query import search_codebase
from rag_pipeline.indexer import build_index

mcp = FastMCP("ai-flow-rag")


@mcp.tool()
def search_dev_codebase(query: str) -> str:
    """
    Search the indexed ~/dev codebase for relevant code, patterns, and project context.
    Use this before answering any question about existing projects or code structure.
    """
    return search_codebase(query)


@mcp.tool()
def reindex_dev_codebase(source_dir: str = "") -> str:
    """
    Rebuild the codebase vector index. Run after adding new projects or major refactors.
    Optionally specify a source_dir; defaults to the DEV_ROOT environment variable (~/.dev).
    """
    if not source_dir:
        source_dir = os.environ.get("DEV_ROOT", os.path.expanduser("~/dev"))
    db_dir = os.environ.get("CHROMA_DB_DIR", os.path.expanduser("~/.ai_flow_chroma"))

    if not os.path.exists(source_dir):
        return f"Error: source directory '{source_dir}' not found."

    build_index(source_dir=source_dir, db_dir=db_dir)
    return f"Indexing complete. Source: {source_dir}, DB: {db_dir}"


if __name__ == "__main__":
    mcp.run()
