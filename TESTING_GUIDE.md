# Testing Guide: Distributor Integration

## Quick Setup Checklist

### 1. Get Nexar API Keys (5-10 minutes)

**Step 1: Create Account**
- Go to https://nexar.com/api
- Click "Sign Up" or "Get Started"
- Use your email or GitHub to create account

**Step 2: Create Application**
- Once logged in, go to Developer Dashboard
- Click "Create Application" or "New Application"
- Name it something like "Altium MCP Server"
- Choose application type (Web Application recommended)

**Step 3: Get Credentials**
- After creating app, you'll see:
  - **Client ID** (looks like: `abc123def456...`)
  - **Client Secret** (looks like: `secret_xyz789...`)
- **IMPORTANT**: Copy both immediately - you won't see the secret again!

### 2. Configure MCP Server (2 minutes)

**Step 1: Create .env file**
```bash
cd C:\Users\geoff\Desktop\projects\altium-mcp\server
copy .env.example .env
```

**Step 2: Edit .env file**
Open `server/.env` in a text editor and add your credentials:
```
NEXAR_CLIENT_ID=your_actual_client_id_here
NEXAR_CLIENT_SECRET=your_actual_client_secret_here
```

Save and close.

### 3. Install Dependencies

```bash
# Activate your conda environment
conda activate altium-mcp-v2

# Install GraphQL package
pip install gql[all]
```

### 4. Restart MCP Server

If the server is running, restart it to load the new environment variables.

For Claude Code CLI, the server will restart automatically on next use.

---

## Testing the Features

### Test 1: Component Search
**What it does:** Search for components across multiple distributors

**Command:**
```
"Search for STM32F407VGT6"
```

**Expected result:**
- List of matching components
- Manufacturer info
- Stock levels across distributors
- Pricing information

---

### Test 2: Check BOM Availability
**What it does:** Automatically extracts your BOM and checks availability

**Prerequisites:**
- Open an Altium project with schematic
- Schematic should have components with part numbers

**Command:**
```
"Check my BOM availability"
```

**Expected result:**
- Summary of components checked
- Total cost estimate
- Availability breakdown (in stock / limited / out of stock)
- List of any problematic components
- Distributor comparison

---

### Test 3: Find Component Alternatives
**What it does:** Find replacement components

**Command:**
```
"Find alternatives for MAX3232CDR because it's out of stock"
```

**Expected result:**
- Original component info
- List of alternative components with:
  - Part numbers
  - Pricing at different quantities
  - Stock levels
  - Compatibility notes
  - Datasheet links

---

### Test 4: Validate BOM Lifecycle
**What it does:** Check for obsolete/NRND parts

**Command:**
```
"Validate my BOM lifecycle status"
```

**Expected result:**
- BOM health score
- List of active components
- List of NRND (Not Recommended for New Design) components
- List of obsolete components
- Recommendations for replacements

---

### Test 5: Price Comparison
**What it does:** Compare pricing across distributors

**Command:**
```
"Compare pricing for STM32F407VGT6 across distributors"
```

**Expected result:**
- Pricing from DigiKey, Mouser, LCSC, Arrow
- Price breaks (1, 10, 100, 1000+ quantities)
- Stock availability
- Lead times
- Direct purchase links

---

## Troubleshooting

### Error: "Nexar API not configured"
**Cause:** API keys not set or server not restarted
**Solution:**
1. Check `server/.env` file exists and has credentials
2. Restart MCP server
3. Verify credentials are correct (no extra spaces, quotes, etc.)

### Error: "Failed to get component data"
**Cause:** No Altium project open or schematic doesn't have components
**Solution:**
1. Open an Altium project
2. Make sure schematic has components with part numbers
3. Ensure project is compiled (Project → Compile)

### Error: No results found
**Cause:** Component doesn't exist or wrong part number
**Solution:**
1. Verify part number spelling
2. Try searching with partial name
3. Check if component is very old/obscure

### Server doesn't restart
**Cause:** Environment variable not loaded
**Solution:**
1. Make sure `.env` is in `server/` directory (not root)
2. Completely close Claude Code and restart
3. Verify conda environment is activated

---

## Expected Output Examples

### Successful Component Search
```json
{
  "success": true,
  "query": "STM32F407VGT6",
  "results_count": 5,
  "results": [
    {
      "mpn": "STM32F407VGT6",
      "manufacturer": "STMicroelectronics",
      "description": "ARM Cortex-M4 MCU, 168MHz, 1MB Flash",
      "category": "Microcontrollers",
      "total_stock": 15420,
      "distributors_count": 4
    }
  ]
}
```

### Successful BOM Check
```json
{
  "success": true,
  "components_checked": 15,
  "total_cost_estimate": "$127.45",
  "availability_summary": {
    "in_stock": 12,
    "limited_stock": 2,
    "out_of_stock": 1
  },
  "issues": [
    {
      "designator": "U5",
      "mpn": "MAX3232CDR",
      "status": "out_of_stock"
    }
  ]
}
```

---

## API Rate Limits

**Nexar Free Tier:**
- Typically allows several hundred requests per day
- Sufficient for normal BOM validation workflows
- If you hit limits, results will show rate limit error

**Best Practices:**
- Don't spam component searches
- Use `check_bom_availability()` once per design iteration
- Cache results mentally for repeated queries

---

## Next Steps After Testing

Once testing is successful:

1. **Use for your board respin:**
   - Check availability before ordering
   - Identify obsolete parts early
   - Find cost optimization opportunities

2. **Integrate into workflow:**
   - Add to pre-production checklist
   - Use during design review
   - Check before committing design changes

3. **Explore advanced features:**
   - Try the `/validate-bom` workflow prompt
   - Export BOM with pricing
   - Set up automated checks

---

## Documentation

- **Feature Overview:** `docs/DISTRIBUTOR_INTEGRATION.md`
- **API Setup Details:** `docs/API_SETUP_GUIDE.md`
- **Workflow Examples:** `docs/BOM_VALIDATION_WORKFLOW.md`

---

## Support

If you encounter issues:
1. Check this guide's troubleshooting section
2. Review `docs/API_SETUP_GUIDE.md`
3. Verify Nexar API status at https://status.nexar.com
4. Check environment variables are loaded correctly
