"""
Nexar/Octopart API Client for Component Search and Availability

This module provides a comprehensive client for interacting with the Nexar GraphQL API
to search for electronic components, retrieve specifications, pricing, availability,
and find alternative/replacement components.

Authentication:
    Requires NEXAR_CLIENT_ID and NEXAR_CLIENT_SECRET environment variables.
    Uses OAuth2 client credentials flow.

Example Usage:
    ```python
    import asyncio
    from nexar_client import NexarClient

    async def main():
        client = NexarClient()
        await client.authenticate()

        # Search for a component
        results = await client.search_components("STM32F407VGT6")

        # Get detailed component info
        details = await client.get_component_details("LM358")

        # Check multi-distributor availability
        availability = await client.get_component_availability("ATMEGA328P-PU")

        # Find alternatives
        alternatives = await client.find_alternatives("2N2222")

    asyncio.run(main())
    ```

References:
    - Nexar API Documentation: https://nexar.com/api
    - GraphQL Explorer: https://api.nexar.com/graphql
"""

import asyncio
import os
import time
from typing import Any, Dict, List, Optional, Union
from dataclasses import dataclass, field
from datetime import datetime, timedelta
import logging

try:
    import httpx
except ImportError:
    raise ImportError("httpx is required. Install with: pip install httpx")

logger = logging.getLogger(__name__)



@dataclass
class AuthToken:
    """OAuth2 access token with expiration tracking"""
    access_token: str
    token_type: str
    expires_at: datetime

    @property
    def is_expired(self) -> bool:
        """Check if token is expired or will expire in the next 60 seconds"""
        return datetime.now() >= (self.expires_at - timedelta(seconds=60))


@dataclass
class ComponentSearchResult:
    """Search result for a component"""
    mpn: str  # Manufacturer Part Number
    manufacturer: str
    description: str
    category: Optional[str] = None
    lifecycle_status: Optional[str] = None
    image_url: Optional[str] = None
    datasheet_url: Optional[str] = None
    median_price_1000: Optional[float] = None

    def __repr__(self):
        return f"ComponentSearchResult(mpn='{self.mpn}', manufacturer='{self.manufacturer}')"


@dataclass
class PriceBreak:
    """Price break for a specific quantity"""
    quantity: int
    price: float
    currency: str = "USD"
    converted_price: Optional[float] = None
    converted_currency: Optional[str] = None

    def __repr__(self):
        return f"PriceBreak(qty={self.quantity}, price=${self.price:.4f})"


@dataclass
class DistributorOffer:
    """Pricing and availability from a distributor"""
    distributor: str
    sku: str
    in_stock: int
    moq: int  # Minimum Order Quantity
    packaging: Optional[str] = None
    prices: List[PriceBreak] = field(default_factory=list)
    link: Optional[str] = None
    updated_at: Optional[str] = None
    authorized: bool = False

    def get_price_at_quantity(self, quantity: int) -> Optional[float]:
        """Get the price for a given quantity"""
        if not self.prices:
            return None

        # Find the applicable price break
        applicable_price = None
        for price_break in sorted(self.prices, key=lambda x: x.quantity, reverse=True):
            if quantity >= price_break.quantity:
                applicable_price = price_break.price
                break

        # If no exact match, use the lowest quantity price break
        if applicable_price is None and self.prices:
            applicable_price = min(self.prices, key=lambda x: x.quantity).price

        return applicable_price

    def __repr__(self):
        return f"DistributorOffer(distributor='{self.distributor}', sku='{self.sku}', stock={self.in_stock})"


@dataclass
class ComponentSpecification:
    """Component specification attribute"""
    name: str
    value: str
    unit: Optional[str] = None

    def __repr__(self):
        if self.unit:
            return f"{self.name}: {self.value} {self.unit}"
        return f"{self.name}: {self.value}"


@dataclass
class ComponentDetails:
    """Detailed component information"""
    mpn: str
    manufacturer: str
    description: str
    category: Optional[str] = None
    lifecycle_status: Optional[str] = None
    specifications: List[ComponentSpecification] = field(default_factory=list)
    datasheets: List[str] = field(default_factory=list)
    images: List[str] = field(default_factory=list)
    offers: List[DistributorOffer] = field(default_factory=list)
    total_stock: int = 0

    def get_lowest_price(self, quantity: int = 1) -> Optional[float]:
        """Get the lowest price across all distributors for a given quantity"""
        prices = []
        for offer in self.offers:
            price = offer.get_price_at_quantity(quantity)
            if price is not None:
                prices.append(price)
        return min(prices) if prices else None

    def get_total_stock(self) -> int:
        """Calculate total stock across all distributors"""
        return sum(offer.in_stock for offer in self.offers)

    def __repr__(self):
        return f"ComponentDetails(mpn='{self.mpn}', manufacturer='{self.manufacturer}', offers={len(self.offers)})"


class RateLimiter:
    """Simple rate limiter to avoid hitting API limits"""

    def __init__(self, max_requests: int = 10, time_window: float = 1.0):
        """
        Initialize rate limiter

        Args:
            max_requests: Maximum number of requests allowed in the time window
            time_window: Time window in seconds
        """
        self.max_requests = max_requests
        self.time_window = time_window
        self.requests: List[float] = []
        self._lock = asyncio.Lock()

    async def acquire(self):
        """Wait if necessary to respect rate limits"""
        async with self._lock:
            now = time.time()
            # Remove requests outside the time window
            self.requests = [req_time for req_time in self.requests
                           if now - req_time < self.time_window]

            if len(self.requests) >= self.max_requests:
                # Wait until the oldest request falls outside the window
                sleep_time = self.time_window - (now - self.requests[0])
                if sleep_time > 0:
                    logger.debug(f"Rate limit reached, sleeping for {sleep_time:.2f}s")
                    await asyncio.sleep(sleep_time)
                    self.requests.pop(0)

            self.requests.append(now)


class NexarClient:
    """
    Client for interacting with the Nexar/Octopart GraphQL API

    Provides methods for:
    - Component search by part number or keyword
    - Retrieving detailed component specifications
    - Multi-distributor pricing and availability
    - Finding alternative/replacement components

    Attributes:
        client_id: OAuth2 client ID from environment variable
        client_secret: OAuth2 client secret from environment variable
        auth_url: OAuth2 token endpoint
        api_url: GraphQL API endpoint
    """

    AUTH_URL = "https://identity.nexar.com/connect/token"
    API_URL = "https://api.nexar.com/graphql"

    def __init__(
        self,
        client_id: Optional[str] = None,
        client_secret: Optional[str] = None,
        max_requests_per_second: int = 10
    ):
        """
        Initialize Nexar API client

        Args:
            client_id: OAuth2 client ID (defaults to NEXAR_CLIENT_ID env var)
            client_secret: OAuth2 client secret (defaults to NEXAR_CLIENT_SECRET env var)
            max_requests_per_second: Maximum API requests per second for rate limiting

        Raises:
            ValueError: If credentials are not provided
        """
        self.client_id = client_id or os.getenv("NEXAR_CLIENT_ID")
        self.client_secret = client_secret or os.getenv("NEXAR_CLIENT_SECRET")

        if not self.client_id or not self.client_secret:
            logger.warning(
                "Nexar credentials not found. Set NEXAR_CLIENT_ID and "
                "NEXAR_CLIENT_SECRET environment variables or pass them to constructor."
            )

        self._token: Optional[AuthToken] = None
        self._http_client = httpx.AsyncClient(timeout=30.0)
        self._rate_limiter = RateLimiter(max_requests=max_requests_per_second, time_window=1.0)

        logger.info("NexarClient initialized")

    def is_configured(self) -> bool:
        """Check if API credentials are configured"""
        return bool(self.client_id and self.client_secret)

    async def authenticate(self) -> None:
        """
        Authenticate with Nexar using OAuth2 client credentials flow

        Raises:
            httpx.HTTPError: If authentication fails
            ValueError: If credentials are not configured
        """
        if not self.is_configured():
            raise ValueError(
                "Nexar credentials not configured. Set NEXAR_CLIENT_ID and "
                "NEXAR_CLIENT_SECRET environment variables."
            )

        if self._token and not self._token.is_expired:
            logger.debug("Using existing valid token")
            return

        logger.info("Authenticating with Nexar API...")

        response = await self._http_client.post(
            self.AUTH_URL,
            data={
                "grant_type": "client_credentials",
                "client_id": self.client_id,
                "client_secret": self.client_secret,
                "scope": "supply.domain"  # Required scope for component search
            },
            headers={
                "Content-Type": "application/x-www-form-urlencoded"
            }
        )

        response.raise_for_status()
        data = response.json()

        self._token = AuthToken(
            access_token=data["access_token"],
            token_type=data["token_type"],
            expires_at=datetime.now() + timedelta(seconds=data["expires_in"])
        )

        logger.info("Successfully authenticated with Nexar API")

    async def _graphql_query(self, query: str, variables: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        """
        Execute a GraphQL query against the Nexar API

        Args:
            query: GraphQL query string
            variables: Optional variables for the query

        Returns:
            Response data from the API

        Raises:
            httpx.HTTPError: If the request fails
            ValueError: If the response contains errors
        """
        await self.authenticate()
        await self._rate_limiter.acquire()

        headers = {
            "Authorization": f"Bearer {self._token.access_token}",
            "Content-Type": "application/json"
        }

        payload = {
            "query": query,
            "variables": variables or {}
        }

        logger.debug(f"Executing GraphQL query: {query[:100]}...")

        response = await self._http_client.post(
            self.API_URL,
            json=payload,
            headers=headers
        )

        response.raise_for_status()
        data = response.json()

        if "errors" in data:
            error_messages = [err.get("message", str(err)) for err in data["errors"]]
            raise ValueError(f"GraphQL errors: {'; '.join(error_messages)}")

        return data.get("data", {})
