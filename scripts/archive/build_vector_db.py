#!/usr/bin/env python3
"""
Build a ChromaDB vector database from Altium API documentation
Enables semantic search for API methods, types, and examples
"""
import json
from pathlib import Path
from typing import List, Dict
import chromadb
from chromadb.config import Settings
import logging
import sys
import time

# Setup logging
logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)
# Add stderr handler
stderr_handler = logging.StreamHandler(sys.stderr)
stderr_handler.setLevel(logging.DEBUG)
stderr_handler.setFormatter(logging.Formatter('%(asctime)s [%(name)s] %(levelname)s: %(message)s'))
logger.addHandler(stderr_handler)


class AltiumAPIVectorDB:
    """Build and query vector database for Altium API"""

    def __init__(self, db_path: str = "./chroma_db"):
        logger.info(f"[VectorDB] Initializing with db_path={db_path}")
        init_start = time.time()

        self.db_path = Path(db_path)
        logger.debug(f"[VectorDB] Resolved path: {self.db_path.absolute()}")

        # Initialize ChromaDB
        logger.info("[VectorDB] Creating ChromaDB PersistentClient...")
        client_start = time.time()
        self.client = chromadb.PersistentClient(
            path=str(self.db_path),
            settings=Settings(anonymized_telemetry=False)
        )
        client_time = time.time() - client_start
        logger.info(f"[VectorDB] PersistentClient created in {client_time:.2f}s")

        # Create or get collection
        logger.info("[VectorDB] Getting or creating 'altium_api' collection...")
        collection_start = time.time()
        self.collection = self.client.get_or_create_collection(
            name="altium_api",
            metadata={"description": "Altium DelphiScript API documentation"}
        )
        collection_time = time.time() - collection_start
        logger.info(f"[VectorDB] Collection ready in {collection_time:.2f}s")

        total_time = time.time() - init_start
        logger.info(f"[VectorDB] Initialization complete in {total_time:.2f}s")

    def ingest_json_api(self, json_file: str = "altium_api_enhanced.json"):
        """Ingest Altium API from JSON"""
        print(f"Loading {json_file}...")
        with open(json_file, 'r') as f:
            api_data = json.load(f)

        documents = []
        metadatas = []
        ids = []

        doc_id = 0

        # Ingest each type
        for type_name, obj in api_data['objects'].items():

            # Create document for the type overview
            type_doc = f"# {type_name}\n\n"
            type_doc += f"Type: {self._categorize_type(type_name)}\n"
            type_doc += f"Methods: {len(obj['methods'])}, Properties: {len(obj['properties'])}\n\n"

            if obj['methods']:
                type_doc += "Methods: " + ", ".join(obj['methods']) + "\n"
            if obj['properties']:
                type_doc += "Properties: " + ", ".join(obj['properties'][:20])  # Limit
                if len(obj['properties']) > 20:
                    type_doc += f"... and {len(obj['properties']) - 20} more"
                type_doc += "\n"

            documents.append(type_doc)
            metadatas.append({
                'type': 'api_type',
                'name': type_name,
                'category': self._categorize_type(type_name),
                'method_count': len(obj['methods']),
                'property_count': len(obj['properties'])
            })
            ids.append(f"type_{doc_id}")
            doc_id += 1

            # Create document for each method
            for method in obj['methods']:
                method_doc = f"{type_name}.{method}()\n\n"
                method_doc += f"Type: {type_name}\n"
                method_doc += f"Category: Method\n"
                method_doc += f"Description: Method on {type_name}\n"

                documents.append(method_doc)
                metadatas.append({
                    'type': 'method',
                    'name': method,
                    'parent_type': type_name,
                    'category': self._categorize_type(type_name),
                    'full_name': f"{type_name}.{method}"
                })
                ids.append(f"method_{doc_id}")
                doc_id += 1

            # Create document for each property
            for prop in obj['properties']:
                prop_doc = f"{type_name}.{prop}\n\n"
                prop_doc += f"Type: {type_name}\n"
                prop_doc += f"Category: Property\n"
                prop_doc += f"Description: Property on {type_name}\n"

                documents.append(prop_doc)
                metadatas.append({
                    'type': 'property',
                    'name': prop,
                    'parent_type': type_name,
                    'category': self._categorize_type(type_name),
                    'full_name': f"{type_name}.{prop}"
                })
                ids.append(f"prop_{doc_id}")
                doc_id += 1

        # Add to ChromaDB
        print(f"Adding {len(documents)} documents to ChromaDB...")

        # ChromaDB has a limit on batch size, so we'll chunk it
        batch_size = 5000
        for i in range(0, len(documents), batch_size):
            end_idx = min(i + batch_size, len(documents))
            print(f"  Adding batch {i//batch_size + 1}: documents {i} to {end_idx}")

            self.collection.add(
                documents=documents[i:end_idx],
                metadatas=metadatas[i:end_idx],
                ids=ids[i:end_idx]
            )

        print(f"Added {len(documents)} documents successfully")

    def ingest_delphi_stdlib(self, json_file: str = "delphi_stdlib.json"):
        """Ingest Delphi standard library from JSON"""
        print(f"\nLoading {json_file}...")

        with open(json_file, 'r') as f:
            stdlib_data = json.load(f)

        documents = []
        metadatas = []
        ids = []

        doc_id = 10000  # Offset to avoid conflicts

        # Ingest functions
        for func_name, usage_count in stdlib_data['functions'].items():
            func_doc = f"{func_name}()\n\n"
            func_doc += f"Type: Delphi Built-in Function\n"
            func_doc += f"Usage count: {usage_count}\n"
            func_doc += f"Category: {self._categorize_stdlib_func(func_name)}\n"

            documents.append(func_doc)
            metadatas.append({
                'type': 'stdlib_function',
                'name': func_name,
                'category': 'delphi_stdlib',
                'subcategory': self._categorize_stdlib_func(func_name),
                'usage_count': usage_count
            })
            ids.append(f"stdlib_func_{doc_id}")
            doc_id += 1

        # Ingest types
        for type_name, data in stdlib_data['types'].items():
            type_doc = f"{type_name}\n\n"
            type_doc += f"Type: Delphi Built-in Type\n"
            type_doc += f"Usage count: {data['usage_count']}\n"

            if data['methods']:
                type_doc += "Common methods: " + ", ".join(list(data['methods'].keys())[:10]) + "\n"

            documents.append(type_doc)
            metadatas.append({
                'type': 'stdlib_type',
                'name': type_name,
                'category': 'delphi_stdlib',
                'usage_count': data['usage_count']
            })
            ids.append(f"stdlib_type_{doc_id}")
            doc_id += 1

            # Add methods for stdlib types
            for method, count in data['methods'].items():
                method_doc = f"{type_name}.{method}()\n\n"
                method_doc += f"Type: {type_name} method\n"
                method_doc += f"Usage count: {count}\n"

                documents.append(method_doc)
                metadatas.append({
                    'type': 'stdlib_method',
                    'name': method,
                    'parent_type': type_name,
                    'category': 'delphi_stdlib',
                    'usage_count': count,
                    'full_name': f"{type_name}.{method}"
                })
                ids.append(f"stdlib_method_{doc_id}")
                doc_id += 1

        print(f"Adding {len(documents)} Delphi stdlib documents to ChromaDB...")

        batch_size = 5000
        for i in range(0, len(documents), batch_size):
            end_idx = min(i + batch_size, len(documents))
            self.collection.add(
                documents=documents[i:end_idx],
                metadatas=metadatas[i:end_idx],
                ids=ids[i:end_idx]
            )

        print(f"Added {len(documents)} stdlib documents successfully")

    def _categorize_type(self, type_name: str) -> str:
        """Categorize API type"""
        if type_name.startswith('IPCB_'):
            return 'PCB'
        elif type_name.startswith('ISch_'):
            return 'Schematic'
        elif type_name in ['PCBServer', 'SCHServer', 'SchServer']:
            return 'Server'
        else:
            return 'Common'

    def _categorize_stdlib_func(self, func_name: str) -> str:
        """Categorize stdlib function"""
        string_funcs = ['IntToStr', 'StrToInt', 'FloatToStr', 'StrToFloat',
                       'Format', 'StringReplace', 'Copy', 'Insert', 'Trim']
        math_funcs = ['Round', 'Trunc', 'Sqrt', 'Sin', 'Cos', 'DegToRad']
        ui_funcs = ['ShowMessage', 'MessageDlg']

        if func_name in string_funcs:
            return 'String'
        elif func_name in math_funcs:
            return 'Math'
        elif func_name in ui_funcs:
            return 'UI'
        else:
            return 'Other'

    def query(self, query_text: str, n_results: int = 10,
              filter_dict: Dict = None) -> Dict:
        """Query the vector database"""
        logger.info(f"[VectorDB] Query starting: '{query_text}' (n_results={n_results}, filter={filter_dict})")
        query_start = time.time()

        try:
            results = self.collection.query(
                query_texts=[query_text],
                n_results=n_results,
                where=filter_dict
            )
            query_time = time.time() - query_start
            num_results = len(results.get('documents', [[]])[0]) if results.get('documents') else 0
            logger.info(f"[VectorDB] Query completed in {query_time:.2f}s, found {num_results} results")
            return results
        except Exception as e:
            query_time = time.time() - query_start
            logger.error(f"[VectorDB] Query failed after {query_time:.2f}s: {e}", exc_info=True)
            raise

    def get_stats(self) -> Dict:
        """Get database statistics"""
        count = self.collection.count()
        return {
            'total_documents': count,
            'collection_name': self.collection.name
        }


def main():
    print("="*70)
    print("Building Altium API Vector Database (ChromaDB)")
    print("="*70)

    # Check if required files exist
    if not Path("altium_api_enhanced.json").exists():
        print("ERROR: altium_api_enhanced.json not found!")
        print("Run: python enhanced_api_parser.py")
        return

    if not Path("delphi_stdlib.json").exists():
        print("ERROR: delphi_stdlib.json not found!")
        print("Run: python extract_delphi_stdlib.py")
        return

    # Build database
    db = AltiumAPIVectorDB()

    print("\n1. Ingesting Altium API...")
    db.ingest_json_api()

    print("\n2. Ingesting Delphi Standard Library...")
    db.ingest_delphi_stdlib()

    # Show stats
    stats = db.get_stats()
    print(f"\n{'='*70}")
    print("Vector Database Built Successfully!")
    print("="*70)
    print(f"Total documents: {stats['total_documents']}")
    print(f"Database location: ./chroma_db/")
    print(f"\nYou can now use semantic search for Altium API!")

    # Test queries
    print(f"\n{'='*70}")
    print("Testing semantic search...")
    print("="*70)

    test_queries = [
        "move component position",
        "iterate over all components",
        "convert integer to string",
        "get current PCB board"
    ]

    for query in test_queries:
        print(f"\nQuery: '{query}'")
        results = db.query(query, n_results=3)

        if results['documents'] and results['documents'][0]:
            print("Top results:")
            for i, (doc, meta) in enumerate(zip(results['documents'][0], results['metadatas'][0])):
                print(f"  {i+1}. {meta.get('full_name', meta.get('name', 'Unknown'))}")
                print(f"     Type: {meta.get('type')}, Category: {meta.get('category')}")


if __name__ == "__main__":
    main()
