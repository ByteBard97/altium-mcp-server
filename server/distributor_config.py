"""
Distributor API Configuration Module

This module handles loading and validating API credentials for various
distributor services (Nexar/Octopart, DigiKey, etc.) from environment variables.
"""

import os
from pathlib import Path
from typing import Optional, Dict, Any
from dotenv import load_dotenv

# Determine the server directory path
SERVER_DIR = Path(__file__).parent

# Load environment variables from .env file in server directory
ENV_FILE = SERVER_DIR / ".env"
load_dotenv(dotenv_path=ENV_FILE)


class DistributorConfig:
    """Configuration manager for distributor API credentials."""

    def __init__(self):
        """Initialize configuration by loading environment variables."""
        # Nexar/Octopart API credentials
        self.nexar_client_id: Optional[str] = os.getenv("NEXAR_CLIENT_ID")
        self.nexar_client_secret: Optional[str] = os.getenv("NEXAR_CLIENT_SECRET")

        # DigiKey API credentials (for future use)
        self.digikey_client_id: Optional[str] = os.getenv("DIGIKEY_CLIENT_ID")
        self.digikey_client_secret: Optional[str] = os.getenv("DIGIKEY_CLIENT_SECRET")

    def is_nexar_configured(self) -> bool:
        """
        Check if Nexar/Octopart API credentials are configured.

        Returns:
            bool: True if both client ID and secret are set
        """
        return bool(
            self.nexar_client_id
            and self.nexar_client_secret
            and self.nexar_client_id != "your_client_id_here"
            and self.nexar_client_secret != "your_client_secret_here"
        )

    def is_digikey_configured(self) -> bool:
        """
        Check if DigiKey API credentials are configured.

        Returns:
            bool: True if both client ID and secret are set
        """
        return bool(
            self.digikey_client_id
            and self.digikey_client_secret
        )

    def get_nexar_credentials(self) -> Optional[Dict[str, str]]:
        """
        Get Nexar/Octopart API credentials.

        Returns:
            Dict with 'client_id' and 'client_secret' keys, or None if not configured
        """
        if not self.is_nexar_configured():
            return None

        return {
            "client_id": self.nexar_client_id,
            "client_secret": self.nexar_client_secret
        }

    def get_digikey_credentials(self) -> Optional[Dict[str, str]]:
        """
        Get DigiKey API credentials.

        Returns:
            Dict with 'client_id' and 'client_secret' keys, or None if not configured
        """
        if not self.is_digikey_configured():
            return None

        return {
            "client_id": self.digikey_client_id,
            "client_secret": self.digikey_client_secret
        }

    def get_available_distributors(self) -> list[str]:
        """
        Get list of distributors with configured API credentials.

        Returns:
            List of distributor names that have valid credentials
        """
        distributors = []

        if self.is_nexar_configured():
            distributors.append("nexar")

        if self.is_digikey_configured():
            distributors.append("digikey")

        return distributors

    def validate_configuration(self) -> Dict[str, Any]:
        """
        Validate the current configuration and return status.

        Returns:
            Dict containing validation status for each distributor
        """
        return {
            "env_file_exists": ENV_FILE.exists(),
            "env_file_path": str(ENV_FILE),
            "nexar": {
                "configured": self.is_nexar_configured(),
                "client_id_set": bool(self.nexar_client_id),
                "client_secret_set": bool(self.nexar_client_secret)
            },
            "digikey": {
                "configured": self.is_digikey_configured(),
                "client_id_set": bool(self.digikey_client_id),
                "client_secret_set": bool(self.digikey_client_secret)
            },
            "available_distributors": self.get_available_distributors()
        }


# Create a global configuration instance
config = DistributorConfig()


# Export commonly used functions and constants
def is_nexar_configured() -> bool:
    """Check if Nexar API is configured."""
    return config.is_nexar_configured()


def is_digikey_configured() -> bool:
    """Check if DigiKey API is configured."""
    return config.is_digikey_configured()


def get_nexar_credentials() -> Optional[Dict[str, str]]:
    """Get Nexar API credentials."""
    return config.get_nexar_credentials()


def get_digikey_credentials() -> Optional[Dict[str, str]]:
    """Get DigiKey API credentials."""
    return config.get_digikey_credentials()


def get_available_distributors() -> list[str]:
    """Get list of configured distributors."""
    return config.get_available_distributors()


# Export constants
NEXAR_CLIENT_ID = config.nexar_client_id
NEXAR_CLIENT_SECRET = config.nexar_client_secret
DIGIKEY_CLIENT_ID = config.digikey_client_id
DIGIKEY_CLIENT_SECRET = config.digikey_client_secret


if __name__ == "__main__":
    """Display current configuration status when run as a script."""
    import json

    print("Distributor API Configuration Status")
    print("=" * 50)
    print(json.dumps(config.validate_configuration(), indent=2))

    if not config.get_available_distributors():
        print("\nWarning: No distributor APIs are configured!")
        print(f"Please copy {SERVER_DIR}/.env.example to {SERVER_DIR}/.env")
        print("and add your API credentials.")
