# Nexar API Implementation Guide
## What Python Work Needs to Be Done

---

## Current State

**File:** `server/nexar_client.py` (358 lines, ends at `_graphql_query()`)

**✅ Already Working:**
- OAuth2 authentication (`authenticate()`)
- Token management with auto-refresh
- Rate limiting (10 requests/sec)
- GraphQL query executor (`_graphql_query()`)
- All dataclasses defined
- HTTP client configured

**❌ Missing - 5 Methods:**
All methods are called by `distributor_tools.py` but not implemented in `nexar_client.py`:

1. `search_component(query, limit=10)` - Called at line 62
2. `get_component_availability(mpn)` - Called at lines 140, 279, 395
3. `find_alternatives(mpn, limit=5)` - Called at line 405
4. `check_lifecycle_status(mpn)` - Called at line 540
5. `compare_distributor_pricing(mpn)` - Called at line 637

---

## What You Need to Add

Add these 5 methods to `server/nexar_client.py` after line 357 (after the `_graphql_query` method):

---

### Method 1: `search_component(query, limit=10)`

**Purpose:** Search for components by MPN or keyword

**Add to `nexar_client.py`:**

```python
    async def search_component(self, query: str, limit: int = 10) -> dict:
        """
        Search for components by MPN or keyword

        Args:
            query: Part number or search term
            limit: Maximum results to return

        Returns:
            Dict with {"results": [...]} structure containing parts
        """
        graphql_query = """
        query SearchComponents($query: String!, $limit: Int!) {
          supSearch(q: $query, limit: $limit) {
            results {
              part {
                id
                mpn
                manufacturer {
                  name
                }
                shortDescription
                category {
                  name
                }
                medianPrice1000 {
                  price
                  currency
                }
                sellers(authorizedOnly: false) {
                  company {
                    name
                  }
                  offers {
                    inventoryLevel
                    prices {
                      quantity
                      price
                      currency
                    }
                  }
                }
              }
            }
          }
        }
        """

        variables = {"query": query, "limit": limit}

        try:
            data = await self._graphql_query(graphql_query, variables)
            return data.get("supSearch", {})
        except Exception as e:
            logger.error(f"Error searching components: {e}")
            return {"results": []}
```

**Expected Call:**
```python
results = await nexar_client.search_component("STM32F407", limit=10)
# Returns: {"results": [{"part": {...}}, ...]}
```

---

### Method 2: `get_component_availability(mpn)`

**Purpose:** Get detailed pricing and stock for a specific part

**Add to `nexar_client.py`:**

```python
    async def get_component_availability(self, mpn: str) -> dict:
        """
        Get detailed availability and pricing for a specific MPN

        Args:
            mpn: Manufacturer part number

        Returns:
            Dict with part details, distributors, pricing, and stock
        """
        graphql_query = """
        query GetAvailability($mpn: String!) {
          supSearch(q: $mpn, limit: 1) {
            results {
              part {
                id
                mpn
                manufacturer {
                  name
                }
                shortDescription
                category {
                  name
                }
                specs {
                  attribute {
                    name
                  }
                  displayValue
                }
                sellers(authorizedOnly: false) {
                  company {
                    name
                  }
                  offers {
                    sku
                    inventoryLevel
                    moq
                    packaging
                    prices {
                      quantity
                      price
                      currency
                    }
                    clickUrl
                    updated
                  }
                }
              }
            }
          }
        }
        """

        variables = {"mpn": mpn}

        try:
            data = await self._graphql_query(graphql_query, variables)
            results = data.get("supSearch", {}).get("results", [])

            if not results:
                return {"error": f"Part not found: {mpn}"}

            return results[0].get("part", {})
        except Exception as e:
            logger.error(f"Error getting availability for {mpn}: {e}")
            return {"error": str(e)}
```

**Expected Call:**
```python
part_data = await nexar_client.get_component_availability("STM32F407VGT6")
# Returns: {"mpn": "...", "manufacturer": {...}, "sellers": [...]}
```

---

### Method 3: `find_alternatives(mpn, limit=5)`

**Purpose:** Find alternative/replacement parts

**Add to `nexar_client.py`:**

```python
    async def find_alternatives(self, mpn: str, limit: int = 5) -> list:
        """
        Find alternative parts based on specifications

        Args:
            mpn: Original manufacturer part number
            limit: Maximum alternatives to return

        Returns:
            List of alternative parts with similar specs
        """
        # First, get the original part to understand its specs
        original = await self.get_component_availability(mpn)

        if "error" in original:
            return []

        # Extract category for searching alternatives
        category_name = original.get("category", {}).get("name", "")
        manufacturer_name = original.get("manufacturer", {}).get("name", "")

        if not category_name:
            return []

        # Search for similar parts in the same category
        graphql_query = """
        query FindAlternatives($category: String!, $limit: Int!) {
          supSearch(
            q: $category,
            limit: $limit
          ) {
            results {
              part {
                mpn
                manufacturer {
                  name
                }
                shortDescription
                category {
                  name
                }
                medianPrice1000 {
                  price
                  currency
                }
                sellers {
                  offers {
                    inventoryLevel
                  }
                }
              }
            }
          }
        }
        """

        variables = {"category": category_name, "limit": limit * 3}

        try:
            data = await self._graphql_query(graphql_query, variables)
            results = data.get("supSearch", {}).get("results", [])

            # Filter out the original part and parts from the same manufacturer
            alternatives = []
            for result in results:
                part = result.get("part", {})
                part_mpn = part.get("mpn", "")
                part_mfr = part.get("manufacturer", {}).get("name", "")

                # Skip original and same manufacturer
                if part_mpn != mpn and part_mfr != manufacturer_name:
                    alternatives.append(part)

                if len(alternatives) >= limit:
                    break

            return alternatives
        except Exception as e:
            logger.error(f"Error finding alternatives for {mpn}: {e}")
            return []
```

**Expected Call:**
```python
alternatives = await nexar_client.find_alternatives("STM32F407VGT6", limit=5)
# Returns: [{"mpn": "...", "manufacturer": {...}, ...}, ...]
```

---

### Method 4: `check_lifecycle_status(mpn)`

**Purpose:** Check if part is active, NRND, or obsolete

**Add to `nexar_client.py`:**

```python
    async def check_lifecycle_status(self, mpn: str) -> str:
        """
        Check the lifecycle status of a component

        Args:
            mpn: Manufacturer part number

        Returns:
            Lifecycle status string: "Active", "NRND", "Obsolete", or "Unknown"
        """
        graphql_query = """
        query CheckLifecycle($mpn: String!) {
          supSearch(q: $mpn, limit: 1) {
            results {
              part {
                mpn
                lifecycle {
                  status
                }
              }
            }
          }
        }
        """

        variables = {"mpn": mpn}

        try:
            data = await self._graphql_query(graphql_query, variables)
            results = data.get("supSearch", {}).get("results", [])

            if not results:
                return "Unknown"

            part = results[0].get("part", {})
            lifecycle = part.get("lifecycle", {})
            status = lifecycle.get("status", "Unknown")

            return status
        except Exception as e:
            logger.error(f"Error checking lifecycle for {mpn}: {e}")
            return "Unknown"
```

**Expected Call:**
```python
status = await nexar_client.check_lifecycle_status("STM32F407VGT6")
# Returns: "Active" | "NRND" | "Obsolete" | "Unknown"
```

---

### Method 5: `compare_distributor_pricing(mpn)`

**Purpose:** Compare prices across all distributors

**Add to `nexar_client.py`:**

```python
    async def compare_distributor_pricing(self, mpn: str) -> dict:
        """
        Compare pricing across all distributors

        Args:
            mpn: Manufacturer part number

        Returns:
            Dict with distributor names as keys and pricing info as values
        """
        part_data = await self.get_component_availability(mpn)

        if "error" in part_data:
            return {"error": part_data["error"]}

        distributors = {}
        sellers = part_data.get("sellers", [])

        for seller in sellers:
            company_name = seller.get("company", {}).get("name", "Unknown")

            for offer in seller.get("offers", []):
                sku = offer.get("sku", "N/A")
                stock = offer.get("inventoryLevel", 0)
                prices = offer.get("prices", [])

                # Format pricing tiers
                pricing_tiers = []
                for price_info in prices:
                    pricing_tiers.append({
                        "quantity": price_info.get("quantity", 0),
                        "price": price_info.get("price", 0),
                        "currency": price_info.get("currency", "USD")
                    })

                # Store under distributor name
                if company_name not in distributors:
                    distributors[company_name] = []

                distributors[company_name].append({
                    "sku": sku,
                    "stock": stock,
                    "pricing": pricing_tiers,
                    "url": offer.get("clickUrl", "")
                })

        return {
            "mpn": mpn,
            "manufacturer": part_data.get("manufacturer", {}).get("name", "Unknown"),
            "distributors": distributors
        }
```

**Expected Call:**
```python
pricing = await nexar_client.compare_distributor_pricing("STM32F407VGT6")
# Returns: {"mpn": "...", "distributors": {"Digi-Key": [...], "Mouser": [...]}}
```

---

## Installation Steps

### 1. Add Methods to `nexar_client.py`

Open `server/nexar_client.py` and add all 5 methods after line 357 (after the `_graphql_query` method).

**File structure after adding:**
```
server/nexar_client.py (lines 1-357 = existing)
├── Classes and dataclasses (lines 1-177)
├── RateLimiter (lines 179-212)
├── NexarClient class (lines 214-357)
│   ├── __init__()
│   ├── is_configured()
│   ├── authenticate()
│   ├── _graphql_query()
│   ├── search_component()          ← ADD THIS (Method 1)
│   ├── get_component_availability() ← ADD THIS (Method 2)
│   ├── find_alternatives()         ← ADD THIS (Method 3)
│   ├── check_lifecycle_status()    ← ADD THIS (Method 4)
│   └── compare_distributor_pricing() ← ADD THIS (Method 5)
```

### 2. Set Environment Variables

Create/edit `.env` file in `server/` directory:

```bash
NEXAR_CLIENT_ID=your_client_id_here
NEXAR_CLIENT_SECRET=your_client_secret_here
```

Or set in your system:

**Windows:**
```powershell
$env:NEXAR_CLIENT_ID="your_client_id"
$env:NEXAR_CLIENT_SECRET="your_client_secret"
```

**Linux/Mac:**
```bash
export NEXAR_CLIENT_ID="your_client_id"
export NEXAR_CLIENT_SECRET="your_client_secret"
```

### 3. Test the Implementation

Create `server/test_nexar.py`:

```python
import asyncio
from nexar_client import NexarClient

async def test():
    client = NexarClient()

    print("1. Testing search...")
    results = await client.search_component("STM32F407", limit=3)
    print(f"Found {len(results.get('results', []))} parts")

    print("\n2. Testing availability...")
    availability = await client.get_component_availability("STM32F407VGT6")
    print(f"MPN: {availability.get('mpn')}")
    print(f"Distributors: {len(availability.get('sellers', []))}")

    print("\n3. Testing lifecycle...")
    status = await client.check_lifecycle_status("STM32F407VGT6")
    print(f"Lifecycle: {status}")

    print("\n4. Testing alternatives...")
    alternatives = await client.find_alternatives("STM32F407VGT6", limit=3)
    print(f"Found {len(alternatives)} alternatives")

    print("\n5. Testing pricing comparison...")
    pricing = await client.compare_distributor_pricing("STM32F407VGT6")
    print(f"Distributors: {list(pricing.get('distributors', {}).keys())}")

if __name__ == "__main__":
    asyncio.run(test())
```

Run test:
```bash
cd server
python test_nexar.py
```

### 4. Restart Claude Desktop

After adding the methods, restart Claude Desktop to reload the MCP server.

---

## Using the Tools

Once implemented, you can use these tools in Claude Desktop:

### Tool 1: Search for Components
```
"Search for STM32F407 microcontrollers"
```

### Tool 2: Check Component Availability
```
"Check availability and pricing for STM32F407VGT6"
```

### Tool 3: Check BOM Availability
```
"Check if all my BOM components are in stock"
```

### Tool 4: Find Alternatives
```
"Find cheaper alternatives for U3 (STM32F407VGT6)"
```

### Tool 5: Validate Lifecycle
```
"Are any of my components obsolete or NRND?"
```

### Tool 6: Compare Pricing
```
"Compare Digi-Key vs Mouser pricing for STM32F407VGT6"
```

---

## Summary

**Total Work Required:**

1. **Add 5 methods** to `server/nexar_client.py` (~200 lines of code)
2. **Set environment variables** (2 lines)
3. **Test** the implementation
4. **Restart** Claude Desktop

**Estimated Time:** 1-2 hours

**Lines of Code to Add:** ~250 lines (5 methods @ ~50 lines each)

**Dependencies:** None (httpx already installed)

---

## Expected Results

After implementation, all 6 distributor tools will work:

| Tool | Status |
|------|--------|
| `search_component()` | ✅ Will Work |
| `get_component_availability()` | ✅ Will Work |
| `check_bom_availability()` | ✅ Will Work |
| `find_component_alternatives()` | ✅ Will Work |
| `validate_bom_lifecycle()` | ✅ Will Work |
| `compare_distributor_pricing()` | ✅ Will Work |

All tools are **already registered** in `distributor_tools.py` - they just need the backend methods in `nexar_client.py`!

---

## Getting Nexar API Credentials

1. Go to https://nexar.com
2. Sign up for free account
3. Navigate to Developer Portal
4. Create new application
5. Copy Client ID and Client Secret
6. Add to environment variables

No credit card required - free tier includes:
- 1000 requests/day
- Full component database access
- Multi-distributor pricing
- Lifecycle status

---

## Next Steps

1. Get your Nexar API credentials
2. Copy the 5 methods into `nexar_client.py`
3. Set environment variables
4. Run test script
5. Restart Claude Desktop
6. Try: "Check if all my BOM components are in stock"

That's it! Let me know when you have your API key and I can add the methods for you.
