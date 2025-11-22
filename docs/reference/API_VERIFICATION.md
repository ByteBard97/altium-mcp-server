# API Verification - get_whole_design_json

## PROVEN WORKING (from examples):

### From GetPinData.pas:
```pascal
project := GetWorkspace.DM_FocusedProject;           // ✓ VERIFIED
project.DM_Compile;                                   // ✓ VERIFIED
for i := 0 to project.DM_LogicalDocumentCount - 1    // ✓ VERIFIED
    document := project.DM_LogicalDocuments(i);      // ✓ VERIFIED
    for j := 0 to document.DM_NetCount - 1           // ✓ VERIFIED
        net := document.DM_Nets(j);                  // ✓ VERIFIED
        for k := 0 to net.DM_PinCount - 1            // ✓ VERIFIED
            pin := net.DM_Pins(k);                   // ✓ VERIFIED
            pin.DM_NetName                           // ✓ VERIFIED
            pin.DM_PinNumber                         // ✓ VERIFIED
            pin.DM_PinName                           // ✓ VERIFIED
            pin.DM_LogicalPartDesignator             // ✓ VERIFIED
```

### From FindUnmatchedPorts.pas:
```pascal
for i := 0 to CurrentDocument.DM_ComponentCount - 1  // ✓ VERIFIED
    Comp := CurrentDocument.DM_Components(i);        // ✓ VERIFIED
    Comp.DM_PinCount                                  // ✓ VERIFIED
    Comp.DM_Pins(PinIdx)                             // ✓ VERIFIED
    Comp.DM_SubPartCount                             // ✓ VERIFIED
    Comp.DM_SubParts(PartIdx)                        // ✓ VERIFIED
    Pin.DM_FlattenedNetName                          // ✓ VERIFIED
```

## CURRENT CODE PROBLEMS:

### Line 999: UNDECLARED VARIABLE
```pascal
DMComp := Doc.DM_Components(j);  // ❌ DMComp never declared!
```

### Line 1001-1114: WRONG VARIABLE
```pascal
While (Component <> Nil) Do      // ❌ Should use DMComp, not Component
    Designator := Component.Designator.Text;   // ❌ ISch_Component, not IComponent
    LibReference := Component.LibReference;    // ❌ Wrong API
    // ... all of this is wrong
```

### Line 1117: REFERENCES NON-EXISTENT ITERATOR
```pascal
CurrentSch.SchIterator_Destroy(Iterator);  // ❌ Iterator never created in this loop
```

## WHAT NEEDS TO BE FIXED:

1. **Remove all ISch_Component code** (Component, Iterator, CurrentSch)
2. **Use ONLY DM (Design Manager) interface**
3. **Declare DMComp variable properly**
4. **Use correct DM properties:**
   - `DMComp.DM_LogicalDesignator` (not `Component.Designator.Text`)
   - `DMComp.DM_LibraryReference` (not `Component.LibReference`)
   - `DMComp.DM_Description` (verify this exists)
   - `DMComp.DM_Footprint` (verify this exists)
   - `DMComp.DM_PinCount` / `DMComp.DM_Pins(i)`
   - `DMPin.DM_PinNumber`, `DMPin.DM_FlattenedNetName`

## CORRECT APPROACH:

Use the DM interface exclusively like the working examples do.
