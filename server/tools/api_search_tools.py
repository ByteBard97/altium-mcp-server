"""
API Search tool handlers
Provides semantic search over Altium DelphiScript API documentation
"""
import json
from typing import TYPE_CHECKING, Optional, List, Dict
from pathlib import Path
import sys
import asyncio
from functools import wraps
import logging
import time

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

if TYPE_CHECKING:
    from mcp.server.fastmcp import FastMCP

# Setup logging (configuration already done in main.py)
logger = logging.getLogger(__name__)
# Force debug level for this module
logger.setLevel(logging.DEBUG)
# Add stderr handler to ensure we see logs
stderr_handler = logging.StreamHandler(sys.stderr)
stderr_handler.setLevel(logging.DEBUG)
stderr_handler.setFormatter(logging.Formatter('%(asctime)s [%(name)s] %(levelname)s: %(message)s'))
logger.addHandler(stderr_handler)
logger.info("[INIT] API search tools module loaded")

# Initialize ChromaDB lazily
_vector_db = None
_init_time = None

# Timeout for database operations (in seconds)
# Init timeout is high because importing ChromaDB can take 30-120s on first load
DB_INIT_TIMEOUT = 180.0
DB_QUERY_TIMEOUT = 10.0


async def run_with_timeout(func, timeout_seconds, *args, **kwargs):
    """Run a blocking function with timeout"""
    func_name = getattr(func, '__name__', str(func))
    logger.info(f"[TIMEOUT] Starting {func_name} with {timeout_seconds}s timeout")
    start_time = time.time()

    loop = asyncio.get_event_loop()
    try:
        result = await asyncio.wait_for(
            loop.run_in_executor(None, lambda: func(*args, **kwargs)),
            timeout=timeout_seconds
        )
        elapsed = time.time() - start_time
        logger.info(f"[TIMEOUT] {func_name} completed in {elapsed:.2f}s")
        return result
    except asyncio.TimeoutError:
        elapsed = time.time() - start_time
        logger.error(f"[TIMEOUT] {func_name} timed out after {elapsed:.2f}s")
        raise TimeoutError(f"Operation timed out after {timeout_seconds} seconds")


def get_vector_db():
    """Get or initialize the vector database"""
    global _vector_db, _init_time

    if _vector_db is None:
        logger.info("[DB] Vector database not initialized, starting initialization...")
        init_start = time.time()

        try:
            logger.debug("[DB] Importing AltiumAPIVectorDB...")
            from build_vector_db import AltiumAPIVectorDB

            logger.debug("[DB] Determining database path...")
            db_path = Path(__file__).parent.parent / "chroma_db"
            logger.info(f"[DB] Database path: {db_path}")

            if not db_path.exists():
                logger.error(f"[DB] Database path does not exist: {db_path}")
                raise RuntimeError(f"ChromaDB directory not found at {db_path}")

            logger.info("[DB] Creating AltiumAPIVectorDB instance...")
            _vector_db = AltiumAPIVectorDB(db_path=str(db_path))

            _init_time = time.time() - init_start
            logger.info(f"[DB] Vector database initialized successfully in {_init_time:.2f}s")

        except ImportError as e:
            logger.error(f"[DB] Import error: {e}")
            raise RuntimeError(
                f"ChromaDB is not installed or incompatible with this Python version. "
                f"API search tools require ChromaDB with numpy<2.0, but Python 3.14 only supports numpy>=2.3. "
                f"Original error: {e}"
            )
        except Exception as e:
            logger.error(f"[DB] Initialization error: {e}", exc_info=True)
            raise
    else:
        logger.debug(f"[DB] Using cached vector database (initialized {_init_time:.2f}s ago)")

    return _vector_db


def register_api_search_tools(mcp: "FastMCP"):
    """Register API search tools"""

    @mcp.tool()
    async def search_delphiscript_api(
        query: str,
        n_results: int = 10,
        filter_category: Optional[str] = None
    ) -> str:
        """
        Search Altium DelphiScript API using semantic search

        This tool searches the complete Altium API documentation extracted from
        128 verified working examples. Use this before writing DelphiScript code
        to find the correct methods, properties, and built-in functions.

        Args:
            query: Natural language query (e.g., "how to move a component",
                   "iterate over all components", "convert integer to string")
            n_results: Number of results to return (default: 10)
            filter_category: Optional filter - "PCB", "Schematic", "Server",
                            "delphi_stdlib", or "Common"

        Returns:
            JSON string with search results including:
            - name: Method/property/function name
            - full_name: Full qualified name (e.g., "IPCB_Component.MoveToXY")
            - type: "method", "property", "api_type", "stdlib_function", etc.
            - category: API category (PCB, Schematic, Server, etc.)
            - parent_type: For methods/properties, the type they belong to
            - distance: Similarity score (lower is better)

        Examples:
            - "move component to coordinates" → IPCB_Component.MoveToXY
            - "iterate all components on board" → IPCB_BoardIterator
            - "convert number to text" → IntToStr, FloatToStr
            - "get current PCB" → PCBServer.GetCurrentPCBBoard
        """
        logger.info(f"[TOOL] search_delphiscript_api called with query='{query}', n_results={n_results}, filter_category={filter_category}")
        tool_start = time.time()

        try:
            logger.info("[TOOL] Step 1: Initializing database...")
            # Initialize database with timeout
            db = await run_with_timeout(get_vector_db, DB_INIT_TIMEOUT)
            logger.info("[TOOL] Database initialized successfully")

            # Build filter if category specified
            logger.debug("[TOOL] Step 2: Building filter...")
            filter_dict = None
            if filter_category:
                filter_dict = {"category": filter_category}
                logger.debug(f"[TOOL] Filter: {filter_dict}")

            # Query the database with timeout
            logger.info(f"[TOOL] Step 3: Querying database for '{query}'...")
            results = await run_with_timeout(
                db.query, DB_QUERY_TIMEOUT,
                query, n_results, filter_dict=filter_dict
            )
            logger.info("[TOOL] Query completed successfully")

            # Format results
            formatted_results = []
            if results['documents'] and results['documents'][0]:
                for i, (doc, meta, distance) in enumerate(zip(
                    results['documents'][0],
                    results['metadatas'][0],
                    results['distances'][0]
                )):
                    result_entry = {
                        'rank': i + 1,
                        'name': meta.get('name', 'Unknown'),
                        'full_name': meta.get('full_name', meta.get('name', 'Unknown')),
                        'type': meta.get('type', 'unknown'),
                        'category': meta.get('category', 'unknown'),
                        'distance': round(distance, 4)
                    }

                    # Add parent type for methods/properties
                    if 'parent_type' in meta:
                        result_entry['parent_type'] = meta['parent_type']

                    # Add counts for api_type
                    if meta.get('type') == 'api_type':
                        if 'method_count' in meta:
                            result_entry['method_count'] = meta['method_count']
                        if 'property_count' in meta:
                            result_entry['property_count'] = meta['property_count']

                    formatted_results.append(result_entry)

            result_dict = {
                'query': query,
                'num_results': len(formatted_results),
                'results': formatted_results
            }

            elapsed = time.time() - tool_start
            logger.info(f"[TOOL] search_delphiscript_api completed successfully in {elapsed:.2f}s")
            return json.dumps(result_dict, indent=2)

        except TimeoutError as e:
            elapsed = time.time() - tool_start
            logger.error(f"[TOOL] search_delphiscript_api timed out after {elapsed:.2f}s: {e}")
            return json.dumps({
                'error': str(e),
                'query': query,
                'suggestion': 'The database operation timed out. Check if ChromaDB is properly initialized.'
            }, indent=2)
        except Exception as e:
            elapsed = time.time() - tool_start
            logger.error(f"[TOOL] search_delphiscript_api failed after {elapsed:.2f}s: {e}", exc_info=True)
            return json.dumps({
                'error': str(e),
                'query': query
            }, indent=2)

    @mcp.tool()
    async def get_api_type_details(type_name: str) -> str:
        """
        Get detailed information about a specific Altium API type

        This tool retrieves all methods and properties for a given API type.
        Use this after finding a type with search_delphiscript_api to see
        all available operations.

        Args:
            type_name: API type name (e.g., "IPCB_Component", "ISch_Sheet",
                      "PCBServer", "TStringList")

        Returns:
            JSON string with:
            - type_name: The API type name
            - category: API category
            - methods: List of all methods on this type
            - properties: List of all properties on this type
            - total_methods: Count of methods
            - total_properties: Count of properties

        Examples:
            - "IPCB_Component" → All component methods and properties
            - "PCBServer" → All server methods
            - "TStringList" → Delphi stdlib list methods
        """
        try:
            # Initialize database with timeout
            db = await run_with_timeout(get_vector_db, DB_INIT_TIMEOUT)

            # Search for the type and its members with timeout
            results = await run_with_timeout(
                db.query, DB_QUERY_TIMEOUT,
                type_name, 200, filter_dict=None
            )

            methods = []
            properties = []
            category = None

            if results['metadatas'] and results['metadatas'][0]:
                for meta in results['metadatas'][0]:
                    # Methods belonging to this type
                    if (meta.get('type') == 'method' and
                          meta.get('parent_type') == type_name):
                        methods.append({
                            'name': meta.get('name'),
                            'full_name': meta.get('full_name')
                        })
                        if not category:
                            category = meta.get('category', 'unknown')

                    # Properties belonging to this type
                    elif (meta.get('type') == 'property' and
                          meta.get('parent_type') == type_name):
                        properties.append({
                            'name': meta.get('name'),
                            'full_name': meta.get('full_name')
                        })
                        if not category:
                            category = meta.get('category', 'unknown')

            if not methods and not properties:
                return json.dumps({
                    'error': f'Type "{type_name}" not found in API database',
                    'type_name': type_name,
                    'suggestion': 'Try searching for it with search_delphiscript_api first'
                }, indent=2)

            type_info = {
                'type_name': type_name,
                'category': category or 'unknown',
                'total_methods': len(methods),
                'total_properties': len(properties),
                'methods': methods[:50],  # Limit to first 50
                'properties': properties[:50]
            }

            if len(methods) > 50:
                type_info['methods_truncated'] = True
            if len(properties) > 50:
                type_info['properties_truncated'] = True

            return json.dumps(type_info, indent=2)

        except TimeoutError as e:
            return json.dumps({
                'error': str(e),
                'type_name': type_name,
                'suggestion': 'The database operation timed out. Check if ChromaDB is properly initialized.'
            }, indent=2)
        except Exception as e:
            return json.dumps({
                'error': str(e),
                'type_name': type_name
            }, indent=2)

    @mcp.tool()
    async def list_delphi_stdlib_functions() -> str:
        """
        List all Delphi standard library built-in functions

        Returns all built-in functions available in DelphiScript including:
        - String functions (IntToStr, Format, StringReplace, etc.)
        - Math functions (Round, Sqrt, Sin, Cos, etc.)
        - Conversion functions (StrToInt, StrToFloat, etc.)
        - UI functions (ShowMessage, MessageDlg)
        - File/Path functions (FileExists, ExtractFileName, etc.)

        Returns:
            JSON string with:
            - total_functions: Count of built-in functions
            - categories: Functions grouped by category
        """
        try:
            # Initialize database with timeout
            db = await run_with_timeout(get_vector_db, DB_INIT_TIMEOUT)

            # Query for all stdlib functions with timeout
            results = await run_with_timeout(
                db.query, DB_QUERY_TIMEOUT,
                "Delphi built-in function", 100, filter_dict=None
            )

            functions_by_category = {
                'String': [],
                'Math': [],
                'UI': [],
                'Other': []
            }

            if results['metadatas'] and results['metadatas'][0]:
                for meta in results['metadatas'][0]:
                    if meta.get('type') == 'stdlib_function':
                        name = meta.get('name')
                        subcategory = meta.get('subcategory', 'Other')
                        usage_count = meta.get('usage_count', 0)

                        if subcategory not in functions_by_category:
                            functions_by_category[subcategory] = []

                        functions_by_category[subcategory].append({
                            'name': name,
                            'usage_count': usage_count
                        })

            # Sort each category by usage count
            for category in functions_by_category:
                functions_by_category[category].sort(
                    key=lambda x: x['usage_count'],
                    reverse=True
                )

            total = sum(len(funcs) for funcs in functions_by_category.values())

            return json.dumps({
                'total_functions': total,
                'categories': functions_by_category
            }, indent=2)

        except TimeoutError as e:
            return json.dumps({
                'error': str(e),
                'suggestion': 'The database operation timed out. Check if ChromaDB is properly initialized.'
            }, indent=2)
        except Exception as e:
            return json.dumps({
                'error': str(e)
            }, indent=2)
