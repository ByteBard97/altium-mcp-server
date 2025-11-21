# Component Availability Integration Plan
## Digi-Key and Nexar/Octopart API Implementation

---

## Executive Summary

**Good News:** You're 70% of the way there!

You already have:
- ✅ Component data extraction (fully working)
- ✅ BOM parameter extraction including MPNs (fully working)
- ✅ Nexar/Octopart API infrastructure (70% complete)
- ✅ Tool interfaces defined and registered
- ✅ OAuth2 authentication and rate limiting
- ✅ Configuration system for API credentials

**What's Missing:**
- ⚠️ 5 GraphQL query implementations in `nexar_client.py`
- ❌ Digi-Key client implementation

---

## Current State Analysis

### ✅ What Already Works

#### 1. Component Data Extraction
**Tool:** `get_schematic_components_with_parameters()`
- **Location:** `server/tools/schematic_tools.py:172`
- **Backend:** `server/AltiumScript/schematic_utils.pas:565`
- **Returns:** All components with parameters including:
  ```json
  {
    "designator": "U1",
    "lib_reference": "STM32F407",
    "description": "MCU ARM Cortex-M4",
    "footprint": "LQFP-100",
    "parameters": {
      "Manufacturer": "STMicroelectronics",
      "Part Number": "STM32F407VGT6",
      "MPN": "STM32F407VGT6",
      "Value": "STM32F407VGT6"
    }
  }
  ```

#### 2. Distributor Tools Framework
**File:** `server/tools/distributor_tools.py`

**Already Defined (Need Backend):**
1. `search_component(query)` - Line 36
2. `get_component_availability(mpn)` - Line 113
3. `check_bom_availability()` - Line 215
4. `find_component_alternatives(mpn, reason)` - Line 367
5. `validate_bom_lifecycle()` - Line 475
6. `compare_distributor_pricing(mpn)` - Line 611

All tools are **registered** and **callable** - they just need backend implementation!

#### 3. Nexar API Client (70% Complete)
**File:** `server/nexar_client.py`

**Working:**
- ✅ OAuth2 authentication (`authenticate()`)
- ✅ Token management and refresh
- ✅ Rate limiting (1 request per second)
- ✅ GraphQL query executor (`_graphql_query()`)
- ✅ Configuration loading

**Missing (Need to Add):**
- ❌ `search_component()` GraphQL query
- ❌ `get_component_availability()` GraphQL query
- ❌ `find_alternatives()` GraphQL query
- ❌ `check_lifecycle_status()` GraphQL query
- ❌ `compare_distributor_pricing()` GraphQL query

#### 4. Configuration System
**File:** `server/distributor_config.py`

Already supports:
```python
NEXAR_CLIENT_ID = os.getenv("NEXAR_CLIENT_ID")
NEXAR_CLIENT_SECRET = os.getenv("NEXAR_CLIENT_SECRET")
DIGIKEY_CLIENT_ID = os.getenv("DIGIKEY_CLIENT_ID")  # Stub ready
DIGIKEY_CLIENT_SECRET = os.getenv("DIGIKEY_CLIENT_SECRET")
```

---

## Implementation Options

### Option A: Complete Nexar Integration (FASTER - 2-3 days)

**Why Nexar?**
- Infrastructure 70% complete
- Already has OAuth2 working
- Octopart has excellent data (includes Digi-Key pricing!)
- GraphQL API is well-documented
- Just need to add 5 GraphQL queries

**What to Build:**
1. Complete `nexar_client.py` with GraphQL queries
2. Test with your actual BOM
3. All tools immediately work

**Effort:** 2-3 days
- Day 1: Implement 5 GraphQL queries (2-3 hours each)
- Day 2: Test with real BOM, fix issues
- Day 3: Polish error handling, add caching

---

### Option B: Implement Digi-Key Direct (MODERATE - 4-5 days)

**Why Digi-Key Direct?**
- Direct relationship with Digi-Key
- Potentially more accurate stock levels
- More control over data sources
- Digi-Key has official Python SDK

**What to Build:**
1. Create `digikey_client.py` (following nexar_client.py pattern)
2. Use Digi-Key Python SDK or REST API
3. Implement same 5 methods
4. Register in distributor_tools.py

**Effort:** 4-5 days
- Day 1-2: Set up Digi-Key API authentication
- Day 3: Implement search and availability
- Day 4: Implement alternatives and lifecycle
- Day 5: Testing and polish

---

### Option C: Both (COMPREHENSIVE - 5-7 days)

Complete Nexar (2-3 days) + Add Digi-Key (3-4 more days)

**Advantages:**
- Fallback if one API is down
- Compare pricing across sources
- More comprehensive data

---

## Recommended Approach: Complete Nexar First

### Why Start with Nexar?

1. **70% Done** - Just need GraphQL queries
2. **Faster to Market** - 2-3 days vs 4-5 days
3. **Includes Digi-Key Data** - Nexar aggregates Digi-Key pricing
4. **Already Authenticated** - OAuth2 working
5. **GraphQL is Elegant** - One query gets everything

### Implementation Steps

#### Day 1: Implement Core GraphQL Queries

**File:** `server/nexar_client.py`

**Method 1: search_component()**
```python
async def search_component(self, query: str, limit: int = 10) -> List[Component]:
    """Search for components by MPN or keyword"""
    graphql_query = '''
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
            specs {
              attribute {
                name
              }
              displayValue
            }
          }
        }
      }
    }
    '''

    variables = {"query": query, "limit": limit}
    result = await self._graphql_query(graphql_query, variables)

    # Parse response into Component dataclasses
    components = []
    for item in result.get("data", {}).get("supSearch", {}).get("results", []):
        part = item.get("part", {})
        components.append(Component(
            mpn=part.get("mpn"),
            manufacturer=part.get("manufacturer", {}).get("name"),
            description=part.get("shortDescription"),
            category=part.get("category", {}).get("name"),
            specs={spec["attribute"]["name"]: spec["displayValue"]
                   for spec in part.get("specs", [])}
        ))

    return components
```

**Method 2: get_component_availability()**
```python
async def get_component_availability(self, mpn: str) -> ComponentAvailability:
    """Get pricing and stock for a specific MPN"""
    graphql_query = '''
    query GetAvailability($mpn: String!) {
      supSearch(q: $mpn, limit: 1) {
        results {
          part {
            mpn
            manufacturer {
              name
            }
            sellers(authorizedOnly: false) {
              company {
                name
              }
              offers {
                sku
                inventoryLevel
                prices {
                  quantity
                  price
                  currency
                }
                clickUrl
              }
            }
          }
        }
      }
    }
    '''

    result = await self._graphql_query(graphql_query, {"mpn": mpn})

    # Parse sellers and pricing
    part = result["data"]["supSearch"]["results"][0]["part"]

    distributors = []
    for seller in part.get("sellers", []):
        for offer in seller.get("offers", []):
            pricing = []
            for price in offer.get("prices", []):
                pricing.append(PricingTier(
                    quantity=price["quantity"],
                    price=price["price"],
                    currency=price["currency"]
                ))

            distributors.append(DistributorInfo(
                name=seller["company"]["name"],
                sku=offer["sku"],
                stock=offer.get("inventoryLevel"),
                pricing=pricing,
                url=offer.get("clickUrl")
            ))

    return ComponentAvailability(
        mpn=mpn,
        manufacturer=part["manufacturer"]["name"],
        distributors=distributors
    )
```

**Method 3: find_alternatives()**
```python
async def find_alternatives(self, mpn: str, reason: str = "cost") -> List[Component]:
    """Find alternative parts based on specs"""

    # First, get the original part specs
    original = await self.search_component(mpn, limit=1)
    if not original:
        return []

    # Build query based on key specs
    graphql_query = '''
    query FindAlternatives($category: String!, $specs: [SpecInput!]) {
      supSearch(
        filters: {
          category: $category,
          specs: $specs
        }
        limit: 20
      ) {
        results {
          part {
            mpn
            manufacturer { name }
            shortDescription
            specs {
              attribute { name }
              displayValue
            }
          }
        }
      }
    }
    '''

    # Extract key specs from original part
    variables = {
        "category": original[0].category,
        "specs": original[0].specs  # Filter by matching specs
    }

    result = await self._graphql_query(graphql_query, variables)

    # Parse and return alternatives
    alternatives = []
    for item in result["data"]["supSearch"]["results"]:
        part = item["part"]
        if part["mpn"] != mpn:  # Exclude original
            alternatives.append(Component(
                mpn=part["mpn"],
                manufacturer=part["manufacturer"]["name"],
                description=part["shortDescription"],
                specs={s["attribute"]["name"]: s["displayValue"]
                       for s in part["specs"]}
            ))

    return alternatives
```

**Method 4: check_lifecycle_status()**
```python
async def check_lifecycle_status(self, mpn: str) -> str:
    """Check if part is active, NRND, or obsolete"""
    graphql_query = '''
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
    '''

    result = await self._graphql_query(graphql_query, {"mpn": mpn})

    try:
        status = result["data"]["supSearch"]["results"][0]["part"]["lifecycle"]["status"]
        return status  # "Active", "NRND", "Obsolete", etc.
    except (KeyError, IndexError):
        return "Unknown"
```

**Method 5: compare_distributor_pricing()**
```python
async def compare_distributor_pricing(self, mpn: str) -> Dict[str, List[PricingTier]]:
    """Get pricing comparison across all distributors"""

    availability = await self.get_component_availability(mpn)

    # Organize by distributor
    pricing_by_distributor = {}
    for dist in availability.distributors:
        pricing_by_distributor[dist.name] = dist.pricing

    return pricing_by_distributor
```

---

#### Day 2: Testing and BOM Integration

**Test Script:** `server/tests/test_nexar_integration.py`

```python
import asyncio
from nexar_client import NexarClient

async def test_nexar():
    client = NexarClient()

    # Test 1: Search
    print("Test 1: Searching for STM32F407...")
    results = await client.search_component("STM32F407VGT6")
    print(f"Found {len(results)} results")

    # Test 2: Availability
    print("\nTest 2: Getting availability...")
    availability = await client.get_component_availability("STM32F407VGT6")
    for dist in availability.distributors:
        print(f"{dist.name}: {dist.stock} in stock")
        for price in dist.pricing[:3]:
            print(f"  {price.quantity}+ @ ${price.price}")

    # Test 3: Lifecycle
    print("\nTest 3: Checking lifecycle...")
    status = await client.check_lifecycle_status("STM32F407VGT6")
    print(f"Lifecycle status: {status}")

    # Test 4: Alternatives
    print("\nTest 4: Finding alternatives...")
    alternatives = await client.find_alternatives("STM32F407VGT6")
    print(f"Found {len(alternatives)} alternatives:")
    for alt in alternatives[:5]:
        print(f"  {alt.mpn} by {alt.manufacturer}")

if __name__ == "__main__":
    asyncio.run(test_nexar())
```

**Run against your actual BOM:**
```python
# Test with real project
async def test_with_bom():
    # Get BOM from Altium
    response = await altium_bridge.call_script(
        "get_schematic_components_with_parameters",
        {}
    )

    components = response.data

    # Check availability for each component
    client = NexarClient()
    for comp in components:
        mpn = comp["parameters"].get("MPN") or comp["parameters"].get("Part Number")
        if mpn:
            availability = await client.get_component_availability(mpn)
            print(f"{comp['designator']} ({mpn}): {availability}")
```

---

#### Day 3: Polish and Error Handling

**Add:**
1. Caching (save API calls)
2. Batch processing (check multiple MPNs at once)
3. Graceful degradation (handle missing data)
4. Cost calculations
5. Low stock warnings

**File:** `server/nexar_client.py` (add caching)

```python
from functools import lru_cache
from datetime import datetime, timedelta

class NexarClient:
    def __init__(self):
        self.cache = {}
        self.cache_ttl = timedelta(hours=1)

    async def get_component_availability(self, mpn: str) -> ComponentAvailability:
        # Check cache
        cache_key = f"availability_{mpn}"
        if cache_key in self.cache:
            cached_data, cached_time = self.cache[cache_key]
            if datetime.now() - cached_time < self.cache_ttl:
                return cached_data

        # Fetch fresh data
        data = await self._fetch_availability(mpn)

        # Cache it
        self.cache[cache_key] = (data, datetime.now())

        return data
```

---

## What You Get After 3 Days

### Working MCP Tools:

1. **`search_component(query)`**
   ```
   User: "Search for STM32F407"
   Claude: Found 15 matching components:
   - STM32F407VGT6 by STMicroelectronics
   - STM32F407VET6 by STMicroelectronics
   ...
   ```

2. **`get_component_availability(mpn)`**
   ```
   User: "Check availability of STM32F407VGT6"
   Claude: STM32F407VGT6 Availability:
   - Digi-Key: 1,245 in stock, $10.50 @ 1+
   - Mouser: 892 in stock, $10.85 @ 1+
   - Newark: 543 in stock, $11.20 @ 1+
   ```

3. **`check_bom_availability()`**
   ```
   User: "Check my BOM availability"
   Claude: BOM Analysis (45 components):
   ✅ 42 components in stock
   ⚠️ 2 components low stock (<100 units)
   ❌ 1 component obsolete (U12: LM358)

   Total BOM cost (qty 100): $1,247.50
   ```

4. **`find_component_alternatives(mpn, reason)`**
   ```
   User: "Find cheaper alternative for STM32F407VGT6"
   Claude: Found 8 alternatives:
   1. STM32F405RGT6 - $8.50 (20% cheaper, pin-compatible)
   2. STM32F407VET6 - $9.75 (8% cheaper, less flash)
   ...
   ```

5. **`validate_bom_lifecycle()`**
   ```
   User: "Check if any parts are obsolete"
   Claude: Lifecycle Analysis:
   - 40 Active parts ✅
   - 3 NRND (Not Recommended for New Designs) ⚠️
     • U3: LM358N (suggest: TLV2372)
     • R14: RC0402FR-071ML (suggest: RC0402FR-071K0L)
     • C7: CL10B104KB8NNNC (suggest: CL10B104KB8NNWC)
   - 2 Obsolete ❌
     • U12: MC34063 (suggest: TPS5430)
   ```

---

## Alternative: Digi-Key Direct Implementation

If you prefer Digi-Key direct, here's the plan:

### Digi-Key API Setup

**Official Python SDK:**
```bash
pip install digikey-api
```

**Configuration:**
```python
# .env file
DIGIKEY_CLIENT_ID=your_client_id
DIGIKEY_CLIENT_SECRET=your_client_secret
DIGIKEY_REDIRECT_URI=https://localhost:8080/callback
```

**Client Implementation:** `server/digikey_client.py`

```python
import digikey
from digikey.v3.productinformation import KeywordSearchRequest

class DigiKeyClient:
    def __init__(self):
        self.client_id = os.getenv("DIGIKEY_CLIENT_ID")
        self.client_secret = os.getenv("DIGIKEY_CLIENT_SECRET")

    async def search_component(self, query: str):
        search_request = KeywordSearchRequest(
            keywords=query,
            record_count=10
        )
        result = digikey.keyword_search(body=search_request)
        return result.products

    async def get_component_availability(self, mpn: str):
        # Use part search
        result = digikey.product_details(mpn)
        return {
            "mpn": result.manufacturer_part_number,
            "manufacturer": result.manufacturer.value,
            "stock": result.quantity_available,
            "pricing": [
                {"qty": tier.break_quantity, "price": tier.unit_price}
                for tier in result.standard_pricing
            ]
        }
```

**Effort:** 4-5 days (from scratch, including auth setup)

---

## My Recommendation

### Phase 1: Complete Nexar (2-3 days) ⭐⭐⭐⭐⭐

**Why:**
- 70% done already
- Fastest path to working availability checking
- Includes Digi-Key data anyway
- All tool interfaces already exist

**Deliverable:**
- Working BOM availability checking
- Part search
- Lifecycle validation
- Alternative suggestions
- Pricing comparison

### Phase 2: Add Digi-Key Direct (Optional, +3 days)

**Why:**
- More control
- Direct Digi-Key relationship
- Can compare Nexar vs Digi-Key data

**When:**
After Nexar is working and you've used it for a few weeks

---

## Implementation Priority

**This Week (High Priority):**
1. Complete `nexar_client.py` GraphQL queries (Day 1)
2. Test with your actual BOM (Day 2)
3. Polish and add caching (Day 3)

**Next Week (Medium Priority):**
4. Add batch processing for large BOMs
5. Cost optimization suggestions
6. Low stock alerts

**Future (Low Priority):**
7. Digi-Key direct integration
8. Mouser integration
9. Historical pricing trends
10. Lead time predictions

---

## Success Metrics

After implementation, you should be able to:

1. ✅ Ask "Check if all my BOM components are in stock"
2. ✅ Ask "What's the total cost for 100 boards?"
3. ✅ Ask "Are any components obsolete?"
4. ✅ Ask "Find a cheaper alternative for U3"
5. ✅ Ask "Which components have low stock?"
6. ✅ Ask "Compare Digi-Key vs Mouser pricing"

---

## Next Steps

**Option 1: I Complete Nexar Now (Recommended)**
- I implement all 5 GraphQL queries in `nexar_client.py`
- You set up Nexar API credentials
- We test with your actual BOM
- **Time: 2-3 days**

**Option 2: You Want Digi-Key Direct First**
- I implement `digikey_client.py` from scratch
- You set up Digi-Key API credentials
- We test with your BOM
- **Time: 4-5 days**

**Option 3: Do Both in Sequence**
- Nexar first (2-3 days), then Digi-Key (3-4 days)
- **Time: 5-7 days total**

Which option would help your current design most?
