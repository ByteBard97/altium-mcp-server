"""
Helper utilities for handling large MCP responses
"""
import json
from pathlib import Path
from typing import Any, Dict, Optional, Union
from datetime import datetime

# Threshold for large responses (in tokens, roughly 4 chars per token)
LARGE_RESPONSE_TOKEN_THRESHOLD = 8000  # ~32KB of text
LARGE_RESPONSE_CHAR_THRESHOLD = LARGE_RESPONSE_TOKEN_THRESHOLD * 4


def estimate_tokens(content: str) -> int:
    """Estimate token count from character count (rough approximation)"""
    return len(content) // 4


def handle_large_response(
    data: Any,
    output_dir: Path,
    function_name: str,
    threshold: Optional[int] = None
) -> Dict[str, Any]:
    """
    Handle potentially large responses by writing to disk if over threshold

    Args:
        data: The response data (will be JSON serialized)
        output_dir: Directory to write large response files
        function_name: Name of the function (used for filename)
        threshold: Custom token threshold (default: LARGE_RESPONSE_TOKEN_THRESHOLD)

    Returns:
        Either the original data (if small) or metadata pointing to disk file (if large)
    """
    if threshold is None:
        threshold = LARGE_RESPONSE_TOKEN_THRESHOLD

    # Serialize to JSON to check size
    json_str = json.dumps(data, indent=2)
    estimated_tokens = estimate_tokens(json_str)
    size_bytes = len(json_str.encode('utf-8'))

    # If under threshold, return data directly
    if estimated_tokens < threshold:
        return data

    # Over threshold - write to disk and return metadata
    output_dir.mkdir(parents=True, exist_ok=True)

    # Create filename with timestamp
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"{function_name}_{timestamp}.json"
    file_path = output_dir / filename

    # Write to disk
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(json_str)

    # Calculate item count if it's a list
    item_count = len(data) if isinstance(data, list) else None

    # Return metadata
    return {
        "large_response": True,
        "file_path": str(file_path),
        "size_bytes": size_bytes,
        "size_kb": round(size_bytes / 1024, 2),
        "estimated_tokens": estimated_tokens,
        "threshold_tokens": threshold,
        "item_count": item_count,
        "message": (
            f"Response is large ({estimated_tokens:,} tokens, {size_bytes:,} bytes). "
            f"Data has been written to disk. Use the Read tool to access the file: {file_path}"
        ),
        "usage_hint": (
            "Use Read tool with offset/limit parameters to view specific portions, "
            "or read the entire file if needed for analysis."
        )
    }


def format_large_response_summary(
    data: Any,
    output_dir: Path,
    function_name: str,
    threshold: Optional[int] = None
) -> str:
    """
    Handle large response and return formatted JSON string

    Args:
        data: The response data
        output_dir: Directory to write large response files
        function_name: Name of the function
        threshold: Custom token threshold

    Returns:
        JSON string (either full data or metadata)
    """
    result = handle_large_response(data, output_dir, function_name, threshold)
    return json.dumps(result, indent=2)
