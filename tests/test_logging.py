#!/usr/bin/env python3
"""Test that logging is working properly"""
import sys
from pathlib import Path

# Add server directory to path
sys.path.insert(0, str(Path(__file__).parent / "server"))

print("=" * 70)
print("Testing API Search Logging")
print("=" * 70)
print("\nYou should see detailed logs below:\n")

# Import modules (this will trigger the logging setup)
from server.tools import api_search_tools
from build_vector_db import AltiumAPIVectorDB

print("\nIf you see '[INIT] API search tools module loaded' above, logging is working!")
print("\n" + "=" * 70)
