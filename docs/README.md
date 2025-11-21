# Altium MCP Documentation

Welcome to the Altium MCP Server documentation!

## Documentation Overview

This directory contains comprehensive guides for using the Altium MCP Server features.

### Distributor Integration

Complete documentation for the Nexar API-powered distributor integration feature:

1. **[API Setup Guide](API_SETUP_GUIDE.md)** - Start here!
   - Step-by-step instructions to create a Nexar account
   - How to obtain API credentials
   - Configuration instructions
   - Troubleshooting common setup issues
   - **Estimated time:** 5-10 minutes

2. **[Distributor Integration Guide](DISTRIBUTOR_INTEGRATION.md)**
   - Complete feature overview
   - Available tools and commands
   - Example usage scenarios
   - Configuration options
   - Troubleshooting guide

3. **[BOM Validation Workflow](BOM_VALIDATION_WORKFLOW.md)**
   - Practical workflows for real-world scenarios
   - Pre-respin checklist
   - Component availability checking procedures
   - Finding and evaluating alternative parts
   - Cost optimization strategies
   - Production planning
   - Documentation best practices

## Quick Start

If you're new to the distributor integration:

1. Follow the [API Setup Guide](API_SETUP_GUIDE.md) to get your API keys
2. Read the [Distributor Integration Guide](DISTRIBUTOR_INTEGRATION.md) overview
3. Try the example commands from the guide
4. Explore the [BOM Validation Workflow](BOM_VALIDATION_WORKFLOW.md) for advanced usage

## Common Use Cases

### Checking Component Availability
```
"Check availability for all components in my BOM"
```
See: [Distributor Integration Guide - Component Availability](DISTRIBUTOR_INTEGRATION.md#component-availability-checking)

### Finding Alternatives
```
"Component U3 is out of stock. Find me alternatives."
```
See: [BOM Validation Workflow - Finding Alternatives](BOM_VALIDATION_WORKFLOW.md#finding-alternative-components)

### BOM Validation
```
"Validate my BOM for a production run of 100 boards"
```
See: [BOM Validation Workflow - Pre-Respin Checklist](BOM_VALIDATION_WORKFLOW.md#pre-respin-checklist)

### Cost Optimization
```
"Analyze my BOM and suggest cost reduction opportunities"
```
See: [BOM Validation Workflow - Cost Optimization](BOM_VALIDATION_WORKFLOW.md#cost-optimization)

## Getting Help

If you encounter issues:

1. Check the [Troubleshooting section](DISTRIBUTOR_INTEGRATION.md#troubleshooting) in the Distributor Integration Guide
2. Review the [API Setup Guide](API_SETUP_GUIDE.md) troubleshooting section
3. Search [GitHub Issues](https://github.com/coffeenmusic/altium-mcp/issues)
4. Open a new issue if your problem isn't covered

## Contributing

Found an error or want to improve the documentation? Contributions are welcome!

- Report documentation issues on [GitHub](https://github.com/coffeenmusic/altium-mcp/issues)
- Submit pull requests with improvements
- Share your workflows and use cases

## Additional Resources

- [Main README](../README.md) - Project overview and installation
- [Nexar API Documentation](https://nexar.com/docs) - Official Nexar API docs
- [Altium MCP GitHub](https://github.com/coffeenmusic/altium-mcp) - Source code and issues

---

**Note:** The distributor integration feature requires a free Nexar account and API credentials. See the [API Setup Guide](API_SETUP_GUIDE.md) for details.
