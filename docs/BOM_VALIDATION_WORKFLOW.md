# BOM Validation Workflow Guide

This guide provides practical workflows for using the distributor integration features in Altium MCP to validate your Bill of Materials (BOM), check component availability, find alternatives, and optimize costs.

## Table of Contents

- [Pre-Respin Checklist](#pre-respin-checklist)
- [Component Availability Workflow](#component-availability-workflow)
- [Finding Alternative Components](#finding-alternative-components)
- [Cost Optimization](#cost-optimization)
- [Production Planning](#production-planning)
- [Documentation and Tracking](#documentation-and-tracking)

## Pre-Respin Checklist

Before ordering a board respin or going into production, use this checklist to ensure your BOM is production-ready.

### Phase 1: Initial Validation

**Step 1: Generate Current BOM Status**

Ask Claude:
```
"Generate a complete BOM validation report for my current design"
```

This will check:
- Total component count
- Overall availability status
- Components with availability issues
- Estimated total cost
- Components flagged for review

**Step 2: Review Critical Components**

Identify and verify your most important components:

```
"Show me availability and pricing for all ICs in my design"
```

```
"Check lead times for U1, U2, U3, and U4"
```

Critical components to prioritize:
- Microcontrollers and processors
- Power management ICs
- Specialty components
- Long-lead-time parts (connectors, transformers, inductors)

**Step 3: Check for Obsolete or NRND Parts**

```
"Are any components in my BOM obsolete or not recommended for new designs?"
```

NRND = "Not Recommended for New Designs" - a warning that the part may be discontinued soon.

### Phase 2: Availability Assessment

**Step 4: Identify At-Risk Components**

Components that need attention:
- Out of stock at all distributors
- Low stock (< your required quantity)
- Long lead times (> 12 weeks)
- Only available at one distributor
- Marked as obsolete or NRND

```
"Which components have less than 100 units available?"
```

```
"Show me all components with lead times longer than 8 weeks"
```

**Step 5: Multi-Sourcing Check**

Ensure critical components have multiple supply options:

```
"For each IC in my design, show me which distributors have stock"
```

Best practices:
- Critical components should be available from 2+ distributors
- Check for authorized vs. unauthorized distributors
- Verify you're looking at genuine parts

### Phase 3: Pricing Verification

**Step 6: Get Pricing at Your Production Quantity**

```
"What's the total BOM cost for quantity 100?"
```

```
"Show me quantity break pricing for all components"
```

**Step 7: Identify Cost Drivers**

Find which components are most expensive:

```
"Which components contribute most to the total BOM cost?"
```

```
"Show me the top 10 most expensive components"
```

### Pre-Respin Checklist Summary

Use this checklist before finalizing your design:

- [ ] All components are available from at least one distributor
- [ ] Critical components (ICs, specialized parts) have multiple sources
- [ ] No components are obsolete or NRND without approved alternatives
- [ ] Lead times are acceptable for your timeline
- [ ] BOM cost is within budget at target production quantity
- [ ] Quantity breaks align with planned production volumes
- [ ] All components are from authorized distributors
- [ ] High-value components have alternatives identified
- [ ] Custom/special order parts have been flagged for advance ordering

## Component Availability Workflow

### Workflow 1: Checking Availability for Entire BOM

**Goal:** Verify that all components can be ordered with acceptable lead times.

**Step-by-step process:**

1. **Initial scan**
   ```
   "Check availability for all components in my current BOM"
   ```

2. **Review the report**

   Claude will provide a summary like:
   ```
   BOM Availability Report
   =======================
   Total components: 47

   In Stock (good): 42 components
   Low Stock (warning): 3 components
   Out of Stock (critical): 2 components

   Components needing attention:
   - U5 (STM32F103): Only 8 units at Mouser, you need 50
   - C12 (47uF/50V): Out of stock everywhere, 12-week lead time
   - L1 (100uH): Only available at one distributor
   ```

3. **Drill down into problem components**
   ```
   "Show me detailed availability for U5 across all distributors"
   ```

4. **Check lead times**
   ```
   "What are the lead times for out-of-stock components?"
   ```

5. **Make decisions**

   For each at-risk component:
   - Can you reduce quantity required?
   - Is there enough stock if you split the order?
   - Should you find an alternative?
   - Can you accept the lead time?

### Workflow 2: Proactive Availability Monitoring

**Goal:** Catch availability issues early in the design process.

**When to check:**

- **During component selection** (before adding to schematic):
  ```
  "Check availability for LM2596 before I add it to my design"
  ```

- **After schematic is complete** (before starting layout):
  ```
  "Validate component availability for my schematic"
  ```

- **Before generating Gerbers**:
  ```
  "Final BOM availability check before I send to fabrication"
  ```

- **Before ordering components**:
  ```
  "Real-time availability check for my BOM - I'm ready to order"
  ```

**Early warning benefits:**
- Catch issues before investing time in layout
- Alternative components may fit the same footprint
- More time to find and validate replacements
- Avoid emergency redesigns

### Workflow 3: Setting Up Stock Alerts

Ask Claude to flag components proactively:

```
"Alert me if any component in my BOM drops below 100 units available"
```

```
"Notify me if the lead time for any component exceeds 8 weeks"
```

## Finding Alternative Components

### Workflow 4: Finding Drop-In Replacements

**Goal:** Replace an unavailable component with minimal design changes.

**Process:**

1. **Request alternatives**
   ```
   "Component U3 (LM2596) is out of stock. Find me drop-in replacements."
   ```

2. **Review suggestions**

   Claude will provide alternatives with:
   - Availability status
   - Pricing comparison
   - Key specifications
   - Footprint compatibility
   - Advantages/disadvantages

   Example response:
   ```
   Alternatives for LM2596 (Buck Converter):

   1. TPS54360 (Texas Instruments) ⭐ RECOMMENDED
      - Availability: 5,247 @ Digi-Key, 3,120 @ Mouser
      - Price: $2.45 (vs $3.10 for LM2596)
      - Same footprint: TO-263
      - Better efficiency: 95% vs 90%
      - Higher switching frequency: 500kHz vs 150kHz
      - Pros: Better performance, lower cost, high stock
      - Cons: Different compensation network may be needed

   2. MP1584EN (Monolithic Power)
      - Availability: 12,000+ units
      - Price: $0.85 (73% cheaper!)
      - ⚠️ Different footprint: SOIC-8 vs TO-263
      - Pros: Very low cost, high availability
      - Cons: Requires layout changes
   ```

3. **Evaluate alternatives**

   Key questions:
   - Does it fit the existing footprint?
   - Are electrical specifications compatible?
   - Will support components (caps, resistors) need changes?
   - Is the pricing acceptable?
   - Is there sufficient stock?

4. **Make informed decision**
   ```
   "Compare the datasheets for LM2596 and TPS54360 to highlight key differences"
   ```

5. **Update design**
   ```
   "Update U3 in my schematic from LM2596 to TPS54360"
   ```

### Workflow 5: Finding Alternatives by Specification

**Goal:** Find components matching specific requirements when you don't have a part number.

**Example scenario:** You need a buck converter with specific specs.

```
"Find buck converter ICs with:
 - Input voltage: 12V
 - Output voltage: 5V
 - Output current: at least 2A
 - Efficiency: > 90%
 - Package: Surface mount
 - Available stock: > 1000 units"
```

Claude will search and return matching components with availability and pricing.

### Workflow 6: Emergency Component Substitution

**When:** A component becomes unavailable after design is finalized.

**Fast-track process:**

1. **Immediate alternatives check**
   ```
   "URGENT: U5 (STM32F103C8T6) is unavailable. Find me the closest
   alternative that's in stock and pin-compatible."
   ```

2. **Quick decision matrix**

   Evaluate alternatives on:
   - ✅ Pin-compatible (highest priority)
   - ✅ Available immediately
   - ✅ Software compatible (for microcontrollers)
   - ⚠️ Price difference acceptable
   - ⚠️ Performance meets requirements

3. **Risk assessment**
   ```
   "What are the risks of switching from STM32F103C8T6 to STM32F103CBT6?"
   ```

4. **Validation testing plan**

   If you switch components:
   - Test prototype with new component
   - Verify all functionality
   - Check thermal performance
   - Validate any firmware changes

## Cost Optimization

### Workflow 7: Overall BOM Cost Reduction

**Goal:** Reduce BOM cost while maintaining design integrity.

**Process:**

1. **Baseline cost analysis**
   ```
   "What's my current BOM cost at quantity 100, and which components
   are the most expensive?"
   ```

2. **Request optimization suggestions**
   ```
   "Analyze my BOM and suggest cost reduction opportunities"
   ```

3. **Review suggestions**

   Claude will identify:
   - Overspecified components (using 1% resistor where 5% is fine)
   - Premium brands where generic equivalents work
   - Quantity break opportunities
   - Consolidation opportunities (using same value instead of two similar ones)

   Example:
   ```
   Cost Optimization Opportunities:

   1. Resistor consolidation (R1-R20)
      - Currently using: Vishay CRCW series
      - Alternative: Yageo RC series
      - Savings: $0.15/unit × 20 = $3.00 per board
      - Same specs: 0805, 1/8W, 1% tolerance

   2. Capacitor substitution (C5-C8)
      - Currently: Murata GRM21 (X7R, 25V)
      - Alternative: Samsung CL21 (X7R, 25V)
      - Savings: $0.22/unit × 4 = $0.88 per board
      - Performance: Equivalent for this application

   3. Resistor value consolidation
      - R15: 9.1kΩ, R16: 9.3kΩ
      - Both could use: 10kΩ (< 10% difference)
      - Simplifies BOM and reduces cost

   Total potential savings: $4.38/board (8.5%)
   ```

4. **Validate each change**

   Before implementing:
   - Verify electrical equivalence
   - Check component specifications
   - Review circuit requirements
   - Consider quality and reliability needs

5. **Implement approved changes**
   ```
   "Update all Vishay resistors to Yageo RC series in my BOM"
   ```

### Workflow 8: Quantity Break Optimization

**Goal:** Determine optimal order quantity based on pricing breaks.

**Process:**

1. **Get quantity break analysis**
   ```
   "Show me quantity break pricing for my entire BOM at 25, 50, 100,
   and 250 units"
   ```

2. **Review the analysis**

   Example output:
   ```
   BOM Cost Analysis by Quantity:

   Qty 25:  $145.50/board = $3,637.50 total
   Qty 50:  $128.75/board = $6,437.50 total (11% savings)
   Qty 100: $112.30/board = $11,230.00 total (23% savings)
   Qty 250: $98.50/board = $24,625.00 total (32% savings)

   Key components driving breaks:
   - U1 (STM32): $8.50 → $6.20 at qty 100
   - U2 (Regulator): $3.40 → $2.15 at qty 250
   ```

3. **Calculate optimal quantity**

   Consider:
   - Storage costs for excess inventory
   - Time value of money
   - Obsolescence risk
   - Demand forecast
   - Minimum order quantities (MOQs)

### Workflow 9: Strategic Component Selection

**When designing a new board:**

1. **Check pricing trends early**
   ```
   "Compare pricing for these three buck converters: LM2596, TPS54360, MP2315"
   ```

2. **Evaluate total cost of ownership**

   Consider:
   - Component unit cost
   - PCB space (smaller = lower fab cost)
   - Efficiency (heat management costs)
   - Assembly complexity
   - Testing requirements

3. **Design for manufacturability**
   ```
   "Which of these components has the best availability and pricing
   for production runs of 500 units?"
   ```

## Production Planning

### Workflow 10: Production Run Planning

**Goal:** Plan component ordering for a production run.

**Process:**

1. **Verify current availability**
   ```
   "I need to build 250 units. Check if there's sufficient stock
   of all components."
   ```

2. **Get lead time analysis**
   ```
   "What's the longest lead time for any component in my BOM at qty 250?"
   ```

3. **Create ordering timeline**

   Example:
   ```
   Production Timeline for 250 Units:

   Week 1:
   - Order long-lead items: L1 (12-week lead), U7 (8-week lead)

   Week 6:
   - Order medium-lead items: Connectors (4-week lead)

   Week 10:
   - Order short-lead items: Resistors, capacitors (1-2 week lead)
   - Order PCBs (2-week lead)

   Week 12:
   - All components arrive
   - Begin assembly
   ```

4. **Safety stock calculation**
   ```
   "Calculate 10% safety stock for my production run of 250 units"
   ```

5. **Multi-distributor sourcing strategy**
   ```
   "Create a component sourcing plan that splits the order across
   Digi-Key, Mouser, and Newark for best pricing and availability"
   ```

### Workflow 11: Just-In-Time Inventory Check

**For ongoing production:**

1. **Regular availability checks**
   ```
   "Weekly availability check for my production BOM"
   ```

2. **Reorder point monitoring**
   ```
   "Alert me when any component drops below 2 weeks of inventory
   for my current production rate"
   ```

3. **Spot availability issues**
   ```
   "Check current lead times for components I need to order next month"
   ```

## Documentation and Tracking

### Workflow 12: BOM Change Documentation

**Goal:** Track and document component changes with justification.

**Process:**

1. **Document baseline**
   ```
   "Export current BOM with pricing and availability snapshot dated [today]"
   ```

2. **Track changes**

   Before making any component change:
   ```
   "Document why I'm changing U3 from LM2596 to TPS54360:
   - Original component out of stock
   - TPS54360 offers better availability
   - Lower cost: $2.45 vs $3.10
   - Improved efficiency: 95% vs 90%
   - Pin-compatible, same footprint
   - Requires minor compensation network changes"
   ```

3. **Version control integration**

   Include in commit messages:
   ```
   Update U3 buck converter to TPS54360

   Reason: LM2596 availability issues (12-week lead time)
   Cost impact: -$0.65 per unit
   Technical impact: Higher efficiency, same footprint
   Validation: Tested with prototype, all specs met
   Distributor: Digi-Key part# TPS54360DDA, 5000+ in stock
   ```

### Workflow 13: Pre-Production Review

**Create a comprehensive pre-production report:**

```
"Generate a pre-production report including:
1. Complete BOM with quantities
2. Current availability at top 3 distributors
3. Pricing at my production quantity (100 units)
4. Lead times for all components
5. Any availability risks
6. Recommended alternates for at-risk parts
7. Total estimated cost
8. Suggested ordering timeline"
```

**Review checklist:**
- [ ] All components available or alternates identified
- [ ] Lead times compatible with production schedule
- [ ] Pricing within budget
- [ ] Critical components have backup sources
- [ ] No obsolete or NRND parts without approved plan
- [ ] Assembly notes documented for any last-minute changes

### Workflow 14: Production Learnings Documentation

**After each production run:**

1. **Document what worked well**
   ```
   - Which components had excellent availability?
   - Which distributors were most reliable?
   - Which quantity breaks were optimal?
   ```

2. **Document issues encountered**
   ```
   - Which components had availability surprises?
   - What lead times were longer than expected?
   - Which components should be replaced in next revision?
   ```

3. **Update design guidelines**
   ```
   "Based on this production run, update our component selection
   guidelines to prefer components with > 5000 units stock and
   multiple distributor sources"
   ```

## Advanced Workflows

### Workflow 15: Design for Supply Chain Resilience

**Build robustness into your design:**

1. **Multi-source from the start**
   ```
   "For each IC in my design, show me at least 2 pin-compatible
   alternatives from different manufacturers"
   ```

2. **Avoid single-source components**
   ```
   "Identify any components in my BOM that are only available
   from one manufacturer"
   ```

3. **Design with parametric search**

   Instead of:
   ```
   "I need a 10kΩ 0805 resistor"
   ```

   Ask:
   ```
   "Find the 10kΩ 0805 resistor with the highest availability
   across the most distributors"
   ```

### Workflow 16: Lifecycle Planning

**Think long-term:**

1. **Check product lifecycle status**
   ```
   "What's the lifecycle status of all ICs in my BOM?"
   ```

2. **Plan for longevity**
   ```
   "Which components are most likely to become obsolete in the
   next 2-5 years based on current status?"
   ```

3. **Future-proof critical components**
   ```
   "For my microcontroller, show me the manufacturer's product
   roadmap and recommended alternatives"
   ```

## Quick Reference: Common Commands

### Availability Checks
```
"Check availability for all components"
"What's the stock status for U1, U2, U3?"
"Show me components with < 100 units available"
"Which components have lead times > 8 weeks?"
```

### Pricing Queries
```
"What's the total BOM cost at quantity 100?"
"Show quantity break pricing for all components"
"Which components are most expensive?"
"Compare pricing across Digi-Key, Mouser, and Newark"
```

### Finding Alternatives
```
"Find alternatives for U5"
"Component R10 is out of stock, suggest replacements"
"Find a cheaper alternative to C12 with same specs"
"Show me pin-compatible replacements for this microcontroller"
```

### BOM Validation
```
"Validate my BOM for production"
"Generate a pre-production report"
"Check for obsolete components"
"Identify components with availability risks"
```

### Optimization
```
"Suggest cost reduction opportunities"
"Can I consolidate any component values?"
"Find cheaper alternatives without compromising quality"
"Optimize my BOM for 100-unit production run"
```

## Best Practices Summary

1. **Check early, check often** - Validate availability throughout the design process
2. **Document everything** - Track why components were changed
3. **Build in redundancy** - Have backup sources for critical components
4. **Think long-term** - Consider component lifecycle and future availability
5. **Balance cost and risk** - Don't sacrifice reliability for small savings
6. **Learn from experience** - Document lessons from each production run
7. **Stay informed** - Monitor availability of components even after design is complete
8. **Plan ahead** - Order long-lead-time components early
9. **Communicate with suppliers** - Build relationships with distributors
10. **Test alternatives** - Validate replacement components before committing

## Conclusion

The distributor integration in Altium MCP transforms BOM validation from a manual, error-prone process into an efficient, AI-assisted workflow. By following these workflows and best practices, you can:

- Reduce the risk of component shortages
- Optimize costs without compromising quality
- Shorten time to production
- Build more resilient designs
- Make data-driven component selection decisions

For more information, see:
- [DISTRIBUTOR_INTEGRATION.md](./DISTRIBUTOR_INTEGRATION.md) - Feature overview
- [API_SETUP_GUIDE.md](./API_SETUP_GUIDE.md) - Configuration instructions
- [README.md](../README.md) - Main project documentation
