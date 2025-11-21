# Distributor Integration

The Altium MCP Server includes distributor integration capabilities powered by the Nexar API, enabling real-time component availability checking, pricing information, and alternative part recommendations directly within your Claude-powered Altium workflow.

## Overview

The distributor integration feature connects your Altium projects to major electronic component distributors through Nexar's unified API. This allows you to:

- **Check component availability** across multiple distributors in real-time
- **Get current pricing** for components in your BOM
- **Find alternative parts** when components are out of stock or discontinued
- **Validate your BOM** before ordering or starting production
- **Optimize costs** by comparing prices across distributors
- **Track lead times** to plan your project timeline

### Supported Distributors

Through the Nexar API, you can access data from major distributors including:
- Digi-Key
- Mouser Electronics
- Newark/Farnell
- Arrow Electronics
- RS Components
- And many more

## Getting Started

### Prerequisites

- Altium MCP Server installed and configured
- A Nexar account (free registration available)
- Internet connection for API access

### Step 1: Get Your Nexar API Keys

Before you can use the distributor integration features, you need to obtain API credentials from Nexar. Follow the detailed guide in [API_SETUP_GUIDE.md](./API_SETUP_GUIDE.md) for step-by-step instructions.

**Quick summary:**
1. Create a free account at [nexar.com](https://nexar.com)
2. Navigate to the Applications section in your account dashboard
3. Create a new application to get your Client ID and Client Secret
4. Save these credentials for the next step

### Step 2: Configure Your Environment

1. **Locate the environment configuration:**

   Navigate to your Altium MCP installation directory. If you installed via the Claude Desktop extension, this is typically within the extension's folder structure.

2. **Copy the example environment file:**

   ```bash
   # Look for .env.example in the server directory
   cp server/.env.example server/.env
   ```

3. **Add your API credentials:**

   Open `server/.env` in a text editor and add your Nexar credentials:

   ```env
   # Nexar API Configuration
   NEXAR_CLIENT_ID=your_client_id_here
   NEXAR_CLIENT_SECRET=your_client_secret_here

   # Optional: Configure cache duration (in seconds, default: 3600)
   NEXAR_CACHE_DURATION=3600

   # Optional: Default currency for pricing (default: USD)
   NEXAR_CURRENCY=USD
   ```

4. **Restart Claude Desktop** to load the new configuration.

### Step 3: Verify the Configuration

Once configured, you can verify that the integration is working by asking Claude:

```
"Check if the distributor integration is configured correctly"
```

Or test with a simple query:

```
"What's the current availability for manufacturer part number LM358N?"
```

## Available Tools

The distributor integration provides several tools accessible through Claude:

### Component Availability Checking

**Tool:** `check_component_availability`

Check stock levels and lead times for components across multiple distributors.

**Example usage:**
```
"Check availability for all resistors in my current BOM"
"What's the stock status for U1 (LM358)?"
"Show me lead times for all ICs in the design"
```

**Returns:**
- In-stock quantities at each distributor
- Lead times for out-of-stock items
- Minimum order quantities (MOQ)
- Packaging information

### Pricing Information

**Tool:** `get_component_pricing`

Retrieve current pricing information including quantity breaks.

**Example usage:**
```
"What's the price for 100 units of manufacturer part LM358N?"
"Compare prices for component R1 across distributors"
"Get pricing for my entire BOM at quantity 50"
```

**Returns:**
- Unit prices at different quantities
- Quantity break pricing (1, 10, 100, 1000, etc.)
- Extended pricing for BOM quantities
- Total BOM cost estimates

### Alternative Part Recommendations

**Tool:** `find_component_alternatives`

Find drop-in replacements or similar components when your original choice is unavailable.

**Example usage:**
```
"Component U5 is out of stock. Find me alternatives."
"What are some alternatives to the STM32F103C8T6?"
"Find a cheaper alternative to R10 with similar specs"
```

**Returns:**
- Functionally equivalent parts
- Availability status of alternatives
- Price comparisons
- Key specification differences

### BOM Validation

**Tool:** `validate_bom`

Comprehensive check of your entire Bill of Materials against distributor databases.

**Example usage:**
```
"Validate my current BOM for availability and pricing"
"Check if all components in my design are in stock"
"Generate a BOM validation report"
```

**Returns:**
- Overall BOM health score
- List of at-risk components (low stock, high lead time)
- Obsolescence warnings
- Recommended actions (find alternatives, etc.)

### Distributor Search

**Tool:** `search_distributor_parts`

Search for components by specifications, description, or category.

**Example usage:**
```
"Find 0805 10k resistors with 1% tolerance"
"Search for buck converters with 5V output and 2A current"
"Find USB-C connectors available at Digi-Key"
```

**Returns:**
- Matching component listings
- Stock availability
- Pricing information
- Datasheets and specifications

## Example Usage Scenarios

### Scenario 1: Pre-Production BOM Check

Before ordering components for production:

```
User: "I'm ready to order components for my power supply board.
       Can you validate the BOM and check availability?"

Claude: [Runs validate_bom on current design]
        "I've checked your 45-component BOM. Here's the status:

        Good news:
        - 42 components are in stock with sufficient quantities
        - Total estimated cost: $127.50 for qty 50

        Attention needed:
        - U3 (LM2596): Only 15 units available at Mouser, lead time 8 weeks
        - C5 (100uF/25V): Discontinued, alternative needed

        Would you like me to find alternatives for these components?"
```

### Scenario 2: Finding Alternatives

When a component is out of stock:

```
User: "Component U3 is showing long lead times. Find me an alternative."

Claude: [Runs find_component_alternatives for U3]
        "I found 3 suitable alternatives for the LM2596 buck converter:

        1. TPS54360 (Texas Instruments)
           - In stock: 5,247 units at Digi-Key
           - Price: $2.45 (vs $3.10 for LM2596)
           - Same footprint (TO-263)
           - Better efficiency (95% vs 90%)

        2. MP1584EN (Monolithic Power)
           - In stock: 12,000+ units
           - Price: $0.85
           - Requires layout changes (different footprint)

        Would you like me to update the schematic with option 1?"
```

### Scenario 3: Cost Optimization

Optimizing BOM costs:

```
User: "Can you help me reduce the cost of this BOM?"

Claude: [Analyzes BOM pricing and suggests alternatives]
        "I've analyzed your BOM and found several cost-saving opportunities:

        Current total: $127.50 (qty 50)

        Recommendations:
        1. Switch R1-R8 to Yageo resistors: Save $4.20
           (Currently using Vishay, Yageo has same specs)

        2. C10-C15 capacitors: Use Samsung instead of Murata: Save $8.40
           (Both are X7R, same voltage rating)

        3. Consolidate resistor values: Save $2.10
           R15 (9.1k) and R16 (9.3k) could both use 10k for this application

        Potential savings: $14.70 (11.5%)
        New total: $112.80

        Would you like me to implement these changes?"
```

## Board Respin Workflow Integration

The distributor integration is particularly valuable during board respins. See [BOM_VALIDATION_WORKFLOW.md](./BOM_VALIDATION_WORKFLOW.md) for a complete workflow guide that includes:

- Pre-respin component verification checklist
- Availability checking procedures
- Alternative part selection criteria
- Cost optimization strategies
- Documentation and tracking

## Troubleshooting

### API Connection Issues

**Problem:** "Unable to connect to Nexar API"

**Solutions:**
1. Verify your internet connection
2. Check that API credentials are correctly set in `.env`
3. Ensure there are no typos in `NEXAR_CLIENT_ID` or `NEXAR_CLIENT_SECRET`
4. Check Nexar's status page for service disruptions
5. Restart Claude Desktop to reload environment variables

### Authentication Errors

**Problem:** "Authentication failed" or "Invalid credentials"

**Solutions:**
1. Verify credentials are from an active Nexar application
2. Regenerate API keys in your Nexar dashboard if they're old
3. Check for extra spaces or quotes in the `.env` file
4. Ensure the application isn't suspended in your Nexar account

### Rate Limiting

**Problem:** "Rate limit exceeded"

**Solutions:**
1. Wait a few minutes before making more requests
2. The server implements automatic request throttling
3. Consider caching results for repeated queries
4. Contact Nexar support to discuss rate limit increases for your use case

### Missing or Incorrect Data

**Problem:** "Component not found" or incorrect information

**Solutions:**
1. Verify the manufacturer part number is correct
2. Try searching by partial part number or description
3. Check if the component is very new or very old
4. Some specialized components may not be in distributor databases
5. Try searching with different distributors

### Cache Issues

**Problem:** Seeing outdated availability or pricing data

**Solutions:**
1. Clear the cache by asking Claude: "Clear the distributor data cache"
2. Adjust `NEXAR_CACHE_DURATION` in `.env` to refresh more frequently
3. Restart the MCP server to clear all cached data

## Best Practices

### Query Optimization

- **Be specific:** Use manufacturer part numbers when possible
- **Batch queries:** Check multiple components at once instead of one by one
- **Cache awareness:** Understand that data may be cached for up to an hour by default

### Component Selection

- **Verify specifications:** Always double-check that alternatives meet your requirements
- **Consider second sources:** Select components with multiple manufacturers
- **Check lifecycle status:** Avoid components marked as "Not Recommended for New Designs"

### BOM Management

- **Regular validation:** Check BOM status periodically throughout the design process
- **Document changes:** Keep track of why alternatives were selected
- **Version control:** Save BOM snapshots before and after making changes

## Privacy and Data

### What Data is Sent to Nexar?

When using the distributor integration, the following data is sent to Nexar's API:

- Manufacturer part numbers from your BOM
- Component quantities for pricing calculations
- Generic component specifications for searches

### What Data is NOT Sent?

- Your complete schematic or PCB design files
- Proprietary circuit topologies
- Project names or internal designators (unless you explicitly include them)
- Customer or company information

### Data Caching

The MCP server caches distributor responses locally to improve performance and reduce API calls. Cached data includes:

- Component availability snapshots
- Pricing information
- Search results

Cached data is stored temporarily in memory and cleared when:
- The cache duration expires (default: 1 hour)
- Claude Desktop is restarted
- You explicitly clear the cache

## Advanced Configuration

### Custom Cache Duration

Adjust how long data is cached:

```env
# Check availability every 30 minutes
NEXAR_CACHE_DURATION=1800

# Very fresh data (10 minutes)
NEXAR_CACHE_DURATION=600

# Long cache for stable designs (4 hours)
NEXAR_CACHE_DURATION=14400
```

### Preferred Distributors

Configure which distributors to prioritize:

```env
# Comma-separated list of preferred distributors
NEXAR_PREFERRED_DISTRIBUTORS=DigiKey,Mouser,Newark
```

### Currency Settings

Get pricing in your preferred currency:

```env
# Options: USD, EUR, GBP, JPY, etc.
NEXAR_CURRENCY=EUR
```

### Debug Mode

Enable detailed logging for troubleshooting:

```env
NEXAR_DEBUG=true
```

## Support and Resources

### Getting Help

- **Documentation:** Check [API_SETUP_GUIDE.md](./API_SETUP_GUIDE.md) for setup issues
- **Workflows:** See [BOM_VALIDATION_WORKFLOW.md](./BOM_VALIDATION_WORKFLOW.md) for usage examples
- **Issues:** Report bugs on the GitHub repository
- **Community:** Join discussions in the project's GitHub Discussions

### External Resources

- [Nexar API Documentation](https://nexar.com/api)
- [Nexar Support Portal](https://support.nexar.com)
- [Altium MCP GitHub Repository](https://github.com/coffeenmusic/altium-mcp)

## Limitations

### Current Limitations

- API rate limits apply (typically 1000 requests/hour for free tier)
- Some specialized or very new components may not be in the database
- Pricing and availability can change rapidly
- Not all distributors may be available in all regions
- Datasheets are links only, not downloaded automatically

### Planned Enhancements

- Automatic BOM optimization suggestions
- Historical pricing trend analysis
- Stock alert notifications
- Direct integration with distributor APIs for ordering
- Enhanced alternative part matching algorithms
- Inventory management integration

## License and Terms

Use of the Nexar API integration is subject to:
- Nexar's Terms of Service
- Your Nexar API subscription level
- This project's MIT License

Always ensure compliance with all applicable terms when using the distributor integration features.
