# ALTIUM DELPHISCRIPT API - COMPLETE REFERENCE

*This is a consolidated, LLM-optimized reference extracted from 128 working DelphiScript examples*

*All methods, properties, and signatures have been verified in production code*


====================================================================================================


## TABLE OF CONTENTS


1. [Overview](#overview)

2. [Quick Reference](#quick-reference)

3. [PCB API](#pcb-api)

4. [Schematic API](#schematic-api)

5. [Common Patterns](#common-patterns)

6. [Complete Type Reference](#complete-type-reference)


====================================================================================================


## OVERVIEW



## Overview


- **89** API Types

- **241** Methods

- **1290** Properties

- **All verified** from working examples




## QUICK REFERENCE


### Most Common Operations


```pascal

// Get current board/schematic

Board := PCBServer.GetCurrentPCBBoard;

Sheet := SCHServer.GetCurrentSchDocument;


// Move component

Component.MoveToXY(x, y);  // NOT SetPosition()!

Component.Rotation := 90.0;


// Iterate objects

Iterator := Board.BoardIterator_Create;

Iterator.AddFilter_ObjectSet(MkSet(eComponentObject));

Obj := Iterator.FirstPCBObject;

while Obj <> nil do

begin

    // Process Obj

    Obj := Iterator.NextPCBObject;

end;

Board.BoardIterator_Destroy(Iterator);

```


====================================================================================================


## PCB API


# PCB API


API for working with PCB layouts, components, routing, and board objects.


---


## Key Types


### [PCBServer](types/PCBServer.md)

Main server interface for PCB operations


*7 methods, 12 properties*


### [IPCB_Board](types/IPCB_Board.md)

PCB board object - main container


*21 methods, 39 properties*


### [IPCB_Component](types/IPCB_Component.md)

Component on the board


*14 methods, 38 properties*


### [IPCB_Track](types/IPCB_Track.md)

Routing track/trace


*1 methods, 32 properties*


### [IPCB_Via](types/IPCB_Via.md)

Via object


*6 methods, 33 properties*


### [IPCB_Pad](types/IPCB_Pad.md)

Component pad


*10 methods, 45 properties*


### [IPCB_Polygon](types/IPCB_Polygon.md)

Polygon/copper pour


*2 methods, 16 properties*


### [IPCB_Text](types/IPCB_Text.md)

Text object


*9 methods, 61 properties*



====================================================================================================


## SCHEMATIC API


# Schematic API


API for working with schematics, components, pins, nets, and sheets.


---


## Key Types


### [SCHServer](types/SCHServer.md)

Main server interface for schematic operations


*1 methods, 1 properties*


### [ISch_Sheet](types/ISch_Sheet.md)

Schematic sheet object


*1 methods, 4 properties*


### [ISch_Component](types/ISch_Component.md)

Component on schematic


*5 methods, 23 properties*


### [ISch_Pin](types/ISch_Pin.md)

Component pin


*0 methods, 7 properties*


### [ISch_Iterator](types/ISch_Iterator.md)

Iterator for traversing schematic objects


*4 methods, 8 properties*


### [ISch_Wire](types/ISch_Wire.md)

Wire/connection


*1 methods, 3 properties*


### [ISch_Port](types/ISch_Port.md)

Port object


*0 methods, 2 properties*



====================================================================================================


## COMMON PATTERNS


# Common Patterns


Frequently used code patterns extracted from working scripts.


---


## Get Current PCB Board


---


## Get Current Schematic


---


## Move Component


```pascal
Y := Distance * sin(DegToRad(DestinRot + Angle));

            Destin.MoveToXY(DestinX + X, DestinY + Y);
            Destin.Layer := Source.Layer;
```


*From: Scripts - PCB\ComponentPlacement\ComponentPlacement.pas*


---


## Iterate Board Objects


---


## Iterate Schematic Objects


---



====================================================================================================


## COMPLETE TYPE REFERENCE


*All types listed alphabetically with complete API details*


====================================================================================================


# Board


**Category:** General


**API Surface:** 0 methods, 1 properties


---


## Properties (1)


### `BoardIterator_Create`


---



====================================================================================================


# Component


**Category:** General


**API Surface:** 5 methods, 10 properties


---


## Methods (5)


### `ChangeCommentAutoposition()`


---


### `ChangeNameAutoposition()`


---


### `DM_Pins()`


**Observed signatures:**

```pascal
Component.DM_Pins(k)
```

**Examples:**


*From: Scripts - SCH\FindFloatingPorts\FindFloatingPorts.pas*

```pascal
for k := 0 to Comp.DM_PinCount - 1 do
            begin
                Pin := Comp.DM_Pins(k);
                ComponentNets.Add(Pin.DM_FlattenedNetName);
            end;
```


---


### `DM_SubParts()`


**Observed signatures:**

```pascal
Component.DM_SubParts(j)
```

**Examples:**


*From: Scripts - SCH\FindFloatingPorts\FindFloatingPorts.pas*

```pascal
begin
                ComponentNets := TStringList.Create;
                MultiPart := Comp.DM_SubParts(j);
                for k := 0 to MultiPart.DM_PinCount - 1 do
                begin
```


---


### `GroupIterator_Destroy()`


---


## Properties (10)


### `BeginModify`


---


### `Comment`


---


### `EndModify`


---


### `GroupIterator_Create`


---


### `Name`


---


### `Pattern`


---


### `Rotation`


---


### `Selected`


---


### `x`


---


### `y`


---



====================================================================================================


# Document


**Category:** General


**API Surface:** 1 methods, 0 properties


---


## Methods (1)


### `DM_Ports()`


---



====================================================================================================


# IDocument


**Category:** General


**API Surface:** 5 methods, 3 properties


---


## Methods (5)


### `DM_Components()`


**Observed signatures:**

```pascal
IDocument.DM_Components(ComponentNum)
```

```pascal
IDocument.DM_Components(DocIdx)
```

```pascal
IDocument.DM_Components(DocCompNum)
```

**Examples:**


*From: Scripts - SCH\FindFloatingPorts\FindFloatingPorts.pas*

```pascal
for i := 0 to CurrentDocument.DM_ComponentCount - 1 do
    begin
        Comp := CurrentDocument.DM_Components(i);

        // For Single Part Components, get net info for just the one
```


*From: Scripts - SCH\FindUnmatchedPorts\FindUnmatchedPorts.pas*

```pascal
for DocIdx := 0 to CurrentDocument.DM_ComponentCount - 1 do
    begin
        Comp := CurrentDocument.DM_Components(DocIdx);
        ComponentList.Add(Comp);
    end;
```


---


### `DM_Nets()`


**Observed signatures:**

```pascal
IDocument.DM_Nets(NetNum)
```

```pascal
IDocument.DM_Nets(FlatNetNum)
```

```pascal
IDocument.DM_Nets(j)
```

**Examples:**


*From: Scripts - SCH\GetPinData\GetPinData.pas*

```pascal
for j := 0 to document.DM_NetCount - 1 do
        begin
            net := document.DM_Nets(j);

            // for each DM_Pins in nets...
```


*From: Scripts - Outputs\SinglePinNets\SinglePinNets.pas*

```pascal
For NetNum := 0 to FlatHierarchy.DM_NetCount - 1 do
   begin
      Net  := FlatHierarchy.DM_Nets(NetNum);

      if ((Net.DM_PinCount = 1) and ((Net.DM_NetLabelCount <> 0) or (Net.DM_PortCount <> 0) or (Net.DM_PowerObjectCount <> 0) )) then
```


---


### `DM_Ports()`


**Observed signatures:**

```pascal
IDocument.DM_Ports(DocIdx)
```

```pascal
IDocument.DM_Ports(i)
```

**Examples:**


*From: Scripts - SCH\FindFloatingPorts\FindFloatingPorts.pas*

```pascal
for i := 0 to CurrentDocument.DM_PortCount - 1 do
    begin
        Port := CurrentDocument.DM_Ports(i);
        if (Port.DM_FlattenedNetName <> '') then
            PortInfo.Add(Port);
```


*From: Scripts - SCH\FindUnmatchedPorts\FindUnmatchedPorts.pas*

```pascal
for DocIdx := 0 to Document.DM_PortCount - 1 do
    begin
        Port := Document.DM_Ports(DocIdx);
        if (Port.DM_FlattenedNetName <> '') then PortList.Add(Port);
    end;
```


---


### `DM_SheetSymbols()`


**Observed signatures:**

```pascal
IDocument.DM_SheetSymbols(DocSheetSymbolNum)
```

```pascal
IDocument.DM_SheetSymbols(i)
```

```pascal
IDocument.DM_SheetSymbols(SheetIdx)
```

**Examples:**


*From: Scripts - SCH\FindFloatingPorts\FindFloatingPorts.pas*

```pascal
for i := 0 to CurrentDocument.DM_SheetSymbolCount - 1 do
    begin
        SheetSymbol := CurrentDocument.DM_SheetSymbols(i);

        // Get all nets on symbol
```


*From: Scripts - SCH\FindUnmatchedPorts\FindUnmatchedPorts.pas*

```pascal
for SheetIdx := 0 to CurrentDocument.DM_SheetSymbolCount - 1 do
    begin
        SheetSymbol := CurrentDocument.DM_SheetSymbols(SheetIdx);
        SheetSymbolList.Add(SheetSymbol);
    end;
```


---


### `GetComponentByName()`


---


## Properties (3)


### `Board`


---


### `CurrentComponent`


---


### `RefreshView`


---



====================================================================================================


# INet


**Category:** General


**API Surface:** 2 methods, 0 properties


---


## Methods (2)


### `DM_NetLabels()`


**Observed signatures:**

```pascal
INet.DM_NetLabels(LabelNum)
```

**Examples:**


*From: Scripts - General\DesignReuse\DesignReuse.pas*

```pascal
for LabelNum := 0 to DocNet.DM_NetLabelCount - 1 do
      begin
         NetLabel := DocNet.DM_NetLabels(LabelNum);

         // is net label inside rectangle
```


---


### `DM_Pins()`


**Observed signatures:**

```pascal
INet.DM_Pins(j)
```

```pascal
INet.DM_Pins(PinNum)
```

```pascal
INet.DM_Pins(0)
```

**Examples:**


*From: Scripts - SCH\GetPinData\GetPinData.pas*

```pascal
for k := 0 to net.DM_PinCount - 1 do
            begin
                pin := net.DM_Pins(k);

                // if DM_LogicalPartDesignator matches our target designator
```


*From: Scripts - Outputs\SinglePinNets\SinglePinNets.pas*

```pascal
if ((Net.DM_PinCount = 1) and ((Net.DM_NetLabelCount <> 0) or (Net.DM_PortCount <> 0) or (Net.DM_PowerObjectCount <> 0) )) then
         SinglePinsFile.Add('Net ' + Net.DM_NetName + ' has only one pin (Pin ' + Net.DM_Pins(0).DM_Part.DM_LogicalDesignator + '-' + Net.DM_Pins(0).DM_PinNumber + ')');    
   end;
```


---



====================================================================================================


# IPCB_Arc


**Category:** PCB


**API Surface:** 2 methods, 22 properties


---


## Methods (2)


### `Replicate()`


**Examples:**


*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Cleanup_LPW_Footprint.pas*

```pascal
{ Replicate the queued arc and operate on that arc. }
         arcNew := arcDst.Replicate();

         { Add new object to PcbLib footprint. }
```


---


### `SetState_Selected()`


**Observed signatures:**

```pascal
IPCB_Arc.SetState_Selected(false)
```

**Examples:**


*From: Scripts - PCB\Fillet\Fillet.pas*

```pascal
// Delete Arc
    AnArc.SetState_Selected(false);
    Board.BeginModify;
    Board.RemovePCBObject(AnArc);
```


---


## Properties (22)


### `BeginModify`


---


### `BoundingRectangle`


---


### `Descriptor`


---


### `EndAngle`


**Common values:**

- `tempA`

- `180 + tempA`

- `180`



**Example:**

```pascal
Arc2.EndAngle :=  tempA;
```

---


### `EndModify`


---


### `EndX`


**Common values:**

- `(arcSrc.EndX - boardXorigin)`



**Example:**

```pascal
//   arcDst.EndX                := (arcSrc.EndX - boardXorigin);
```

---


### `EndY`


**Common values:**

- `(arcSrc.EndY - boardYorigin)`



**Example:**

```pascal
//   arcDst.EndY                := (arcSrc.EndY - boardYorigin);
```

---


### `I_ObjectAddress`


---


### `Index`


---


### `IsKeepout`


**Common values:**

- `arcSrc.IsKeepout`

- `isKeepout`



**Example:**

```pascal
arcDst.IsKeepout     := isKeepout;
```

---


### `Layer`


**Common values:**

- `LayerObj.LayerID`

- `layer`

- `arcSrc.Layer`



**Example:**

```pascal
AnArc.Layer := FirstTrack.Layer;
```

---


### `LineWidth`


**Common values:**

- `MMsToCoord(StrToFloat(EditSize.Text)) / 2`

- `FirstTrack.Width`

- `arcSrc.LineWidth`



**Example:**

```pascal
AnArc.LineWidth := FirstTrack.Width;
```

---


### `Net`


**Common values:**

- `FirstTrack.Net`



**Example:**

```pascal
if FirstTrack.InNet then AnArc.Net := FirstTrack.Net;
```

---


### `ObjectId`


---


### `Radius`


**Common values:**

- `arcSrc.Radius`

- `NewPad.LineWidth / 2`

- `0`



**Example:**

```pascal
Arc2.Radius := 0;
```

---


### `Selected`


**Common values:**

- `false`

- `True`

- `False`



**Example:**

```pascal
Arc1.Selected := false;
```

---


### `StartAngle`


**Common values:**

- `tempA`

- `180 + tempA`

- `180`



**Example:**

```pascal
Arc1.StartAngle := tempA;
```

---


### `StartX`


**Common values:**

- `(arcSrc.StartX - boardXorigin)`



**Example:**

```pascal
//   arcDst.StartX          := (arcSrc.StartX - boardXorigin);
```

---


### `StartY`


**Common values:**

- `(arcSrc.StartY - boardYorigin)`



**Example:**

```pascal
//   arcDst.StartY          := (arcSrc.StartY - boardYorigin);
```

---


### `XCenter`


**Common values:**

- `PosX`

- `ViaPad.x`

- `(arcSrc.XCenter - boardXorigin)`



**Example:**

```pascal
Arc2.XCenter := ViaPad.x;
```

---


### `YCenter`


**Common values:**

- `Int(Yc)`

- `Y - Radius`

- `MMsToCoord(YCenterMm)`



**Example:**

```pascal
Arc2.YCenter := ViaPad.y;
```

---


### `layer`


**Common values:**

- `Prim.Layer`



**Example:**

```pascal
Arc.layer := Prim.Layer;
```

---



====================================================================================================


# IPCB_Board


**Category:** PCB


**API Surface:** 21 methods, 39 properties


---


## Methods (21)


### `AddObjectToHighlightObjectList()`


**Observed signatures:**

```pascal
IPCB_Board.AddObjectToHighlightObjectList(Via)
```

```pascal
IPCB_Board.AddObjectToHighlightObjectList(Prim)
```

```pascal
IPCB_Board.AddObjectToHighlightObjectList(CurrentVia)
```

**Examples:**


*From: Scripts - PCB\ReturnViaCheck\ReturnViaCheck.pas*

```pascal
begin
                CurrentVia := FailedViaList[i];
                Board.AddObjectToHighlightObjectList(CurrentVia);
            end;
```


*From: Scripts - PCB\ReturnViaCheck\ReturnViaCheck.pas*

```pascal
CurrentVia := FailedViaList[i];
            CurrentVia.Selected := True;
            //Board.AddObjectToHighlightObjectList(CurrentVia);
            SetDRCAndAddToHighlight(CurrentVia);
            //CurrentVia.GraphicallyInvalidate;
```


---


### `AddPCBObject()`


**Observed signatures:**

```pascal
IPCB_Board.AddPCBObject(Prim1)
```

```pascal
IPCB_Board.AddPCBObject(PcbObj)
```

```pascal
IPCB_Board.AddPCBObject(Text)
```

**Examples:**


*From: Scripts - PCB\AddDatumPointToArcs\AddDatumPointToArcs.pas*

```pascal
Tr1.x2 := Arc.XCenter + Arc.Radius * 1.3;
            Tr1.y2 := Arc.YCenter;
            Board.AddPCBObject(Tr1);

            Tr2 := Tr1.Replicate;
```


*From: Scripts - PCB\AddDatumPointToArcs\AddDatumPointToArcs.pas*

```pascal
Tr2.x2 := Arc.XCenter;
            Tr2.y2 := Arc.YCenter + Arc.Radius * 1.3;
            Board.AddPCBObject(Tr2);

            Tr3 := Tr1.Replicate;
```


---


### `BoardIterator_Destroy()`


**Observed signatures:**

```pascal
IPCB_Board.BoardIterator_Destroy(ComponentIterator)
```

```pascal
IPCB_Board.BoardIterator_Destroy(Iterator)
```

```pascal
IPCB_Board.BoardIterator_Destroy(Iter)
```

**Examples:**


*From: Scripts - PCB\AdjustDesignators2\AdjustDesignators2.pas*

```pascal
end;
    // Destroy the component iterator
    Board.BoardIterator_Destroy(ComponentIterator);

    // Notify the pcbserver that all changes have been made
```


*From: Scripts - PCB\AssemblyTextPrep\AssemblyTextPrep.pas*

```pascal
Comp := Iter.NextPCBObject;
    end;
    Board.BoardIterator_Destroy(Iter);
end;
```


---


### `ChooseLocation()`


**Observed signatures:**

```pascal
IPCB_Board.ChooseLocation(x, y, sPrompt)
```

```pascal
IPCB_Board.ChooseLocation(X,Y,'Choose Component')
```

```pascal
IPCB_Board.ChooseLocation(P2X, P2Y, 'Pick corner or End')
```

**Examples:**


*From: Scripts - PCB\PlaceDashedLines\PlaceDashedLine.pas*

```pascal
// SetPattern_DashDot(MyDashLen));

    While Board.ChooseLocation(P1X, P1Y, 'Pick Start Point') do
    begin
        TrackLayer := Board.CurrentLayer;
```


*From: Scripts - PCB\PlaceDashedLines\PlaceDashedLine.pas*

```pascal
Pcbserver.PreProcess;
        while Board.ChooseLocation(P2X, P2Y, 'Pick corner or End') do
        begin
            AddDashes(P1X, P1Y, P2X, P2Y, tRemainder, UnionIndex);
```


---


### `ChooseRectangleByCorners()`


**Observed signatures:**

```pascal
IPCB_Board.ChooseRectangleByCorners('Choose first corner (Touching Area)
```

```pascal
IPCB_Board.ChooseRectangleByCorners('Choose first corner', 'Choose second corner', x1,y1,x2,y2)
```

**Examples:**


*From: Scripts - PCB\CreateRegionQuery\CreateRegionQuery.pas*

```pascal
RegionQueryForm.Hide;
    (* The ChooseRectangleByCorners fn is an interactive function where you are prompted to choose two points on a PCB document.*)
    if not (Board.ChooseRectangleByCorners( 'Choose first corner', 'Choose second corner', x1,y1,x2,y2)) then
    begin
         RegionQueryForm.Show;
```


*From: Scripts - PCB\ReturnViaCheck\ReturnViaCheck.pas*

```pascal
begin
    // The ChooseRectangleByCorners fn is an interactive function where you are prompted to choose two points on a PCB document.
    if not (Board.ChooseRectangleByCorners( 'Choose first corner (Touching Area)', 'Choose second corner (Touching Area)', X1,Y1,X2,Y2)) then exit;

    // find all vias touching this area using iterator
```


---


### `DispatchMessage()`


**Observed signatures:**

```pascal
IPCB_Board.DispatchMessage(Board.I_ObjectAddress, c_BroadCast, PCBM_BoardRegisteration, Violation.I_ObjectAddress)
```

```pascal
IPCB_Board.DispatchMessage(Board.I_ObjectAddress, c_Broadcast, PCBM_BoardRegisteration, Arc.I_ObjectAddress)
```

```pascal
IPCB_Board.DispatchMessage(Board.I_ObjectAddress, c_Broadcast, PCBM_BoardRegisteration, AnArc.I_ObjectAddress)
```

**Examples:**


*From: Scripts - PCB\Distribute\Distribute.pas*

```pascal
Prim2.EndModify;
            Prim2.GraphicallyInvalidate;
            Board.DispatchMessage(Board.I_ObjectAddress, c_Broadcast, PCBM_BoardRegisteration, Prim2.I_ObjectAddress);
        end;
    end
```


*From: Scripts - PCB\Distribute\Distribute.pas*

```pascal
Prim2.EndModify;
            Prim2.GraphicallyInvalidate;
            Board.DispatchMessage(Board.I_ObjectAddress, c_Broadcast, PCBM_BoardRegisteration, Prim2.I_ObjectAddress);
        end;
    end
```


---


### `FindDominantRuleForObject()`


**Observed signatures:**

```pascal
IPCB_Board.FindDominantRuleForObject(Track,eRule_MaxMinWidth)
```

```pascal
IPCB_Board.FindDominantRuleForObject(Via, eRule_RoutingViaStyle)
```

**Examples:**


*From: Scripts - PCB\LengthTuningHelper\LengthTuningHelper.pas*

```pascal
Net.AddPCBObject(Track);
      Rule := Board.FindDominantRuleForObject(Track,eRule_MaxMinWidth);
      Track.Width := Rule.FavoredWidth(eTopLayer);
```


*From: Scripts - PCB\MoveToLayer\MoveToLayer.pas*

```pascal
// now we need to get the rule, to figure out via size and hole size
   Rule := Board.FindDominantRuleForObject(Via, eRule_RoutingViaStyle);

   Via.Size     := Rule.PreferedWidth;
```


---


### `FindDominantRuleForObjectPair()`


**Observed signatures:**

```pascal
IPCB_Board.FindDominantRuleForObjectPair(Via, Primitive, eRule_Clearance)
```

```pascal
IPCB_Board.FindDominantRuleForObjectPair(Prim1, Prim2, eRule_Clearance)
```

**Examples:**


*From: Scripts - PCB\MoveToLayer\MoveToLayer.pas*

```pascal
if Via.IntersectLayer(Primitive.Layer) then
      Begin
         Rule := Board.FindDominantRuleForObjectPair(Via, Primitive, eRule_Clearance);

         if Rule <> nil then
```


*From: Scripts - PCB\MoveToLayer\MoveToLayer.pas*

```pascal
if Via.IntersectLayer(Primitive.Layer) then
         Begin
            Rule := Board.FindDominantRuleForObjectPair(Via, Primitive, eRule_Clearance);

            if Rule <> nil then
```


---


### `GetObjectAtCursor()`


**Observed signatures:**

```pascal
IPCB_Board.GetObjectAtCursor(MkSet(eTrackObject, eArcObject, eViaObject)
```

```pascal
IPCB_Board.GetObjectAtCursor(MkSet(SourcePrim.ObjectId)
```

```pascal
IPCB_Board.GetObjectAtCursor(MkSet(eTrackObject, eArcObject)
```

**Examples:**


*From: Scripts - PCB\ComponentPlacement\ComponentPlacement.pas*

```pascal
While Destin = nil do
   begin
      Source := Board.GetObjectAtCursor(MkSet(eComponentObject),AllLayers, 'Choose Source Orientational Component');
      if Source = nil then exit;
```


*From: Scripts - PCB\ComponentPlacement\ComponentPlacement.pas*

```pascal
if Source = nil then exit;

      Destin := Board.GetObjectAtCursor(MkSet(eComponentObject),AllLayers, 'Choose Destination Orientational Component');
   end;
```


---


### `GetObjectAtXYAskUserIfAmbiguous()`


**Observed signatures:**

```pascal
IPCB_Board.GetObjectAtXYAskUserIfAmbiguous(x, y, MkSet(eComponentObject)
```

**Examples:**


*From: Scripts - PCB\QuickSilk\QuickSilk.pas*

```pascal
//if ShiftKeyDown   then CompKeySet := SetUnion(CompKeySet, MkSet(cShiftKey));

            Result := Board.GetObjectAtXYAskUserIfAmbiguous(x, y, MkSet(eComponentObject), VisibleLayerSet, eEditAction_Focus);         // eEditAction_DontCare
            if (Result = Nil) then Result := eNoObject;
```


---


### `LayerIsDisplayed()`


**Observed signatures:**

```pascal
IPCB_Board.LayerIsDisplayed(eBottomLayer)
```

```pascal
IPCB_Board.LayerIsDisplayed(eTopLayer)
```

**Examples:**


*From: Scripts - PCB\QuickSilk\QuickSilk.pas*

```pascal
VisibleLayerSet := MkSet();
    if Board.LayerIsDisplayed(eTopLayer) then VisibleLayerSet := SetUnion(VisibleLayerSet, MkSet(eTopLayer));
    if Board.LayerIsDisplayed(eBottomLayer) then VisibleLayerSet := SetUnion(VisibleLayerSet, MkSet(eBottomLayer));
```


*From: Scripts - PCB\QuickSilk\QuickSilk.pas*

```pascal
VisibleLayerSet := MkSet();
    if Board.LayerIsDisplayed(eTopLayer) then VisibleLayerSet := SetUnion(VisibleLayerSet, MkSet(eTopLayer));
    if Board.LayerIsDisplayed(eBottomLayer) then VisibleLayerSet := SetUnion(VisibleLayerSet, MkSet(eBottomLayer));

    //Application.ProcessMessages; // doesn't appear to be necessary
```


---


### `LayerIsUsed()`


**Observed signatures:**

```pascal
IPCB_Board.LayerIsUsed(layer)
```

**Examples:**


*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Cleanup_LPW_Footprint.pas*

```pascal
{ Retrieve whether this layer is enabled or not. }
      enabled := PCBBoard.LayerIsUsed(layer);
      
      WriteToDebugFile(' ' + Layer2String(layer) + ' enabled: ' + BoolToStr(enabled) + '.');
```


---


### `LayerName()`


**Observed signatures:**

```pascal
IPCB_Board.LayerName(ILayer.MechanicalLayer(i)
```

```pascal
IPCB_Board.LayerName(ILayer.MechanicalLayer(j)
```

```pascal
IPCB_Board.LayerName(ML2)
```

**Examples:**


*From: Scripts - PCB\AdjustDesignators2\AdjustDesignators2.pas*

```pascal
if MechLayerPairs.PairDefined(ML1, ML2) then
                    begin
                        If (ansipos(cBottomSide, Board.LayerName(ML1)) > 0) or
                           (ansipos(cTopSide, Board.LayerName(ML2)) > 0) then IntSwap(ML1, ML2);
```


*From: Scripts - PCB\AdjustDesignators2\AdjustDesignators2.pas*

```pascal
begin
                        If (ansipos(cBottomSide, Board.LayerName(ML1)) > 0) or
                           (ansipos(cTopSide, Board.LayerName(ML2)) > 0) then IntSwap(ML1, ML2);

                        slMechPairs.Add(Board.LayerName(ML1) + cSeparator + Board.LayerName(ML2));
```


---


### `LayerPair()`


**Observed signatures:**

```pascal
IPCB_Board.LayerPair(i)
```

**Examples:**


*From: Scripts - PCB\ReturnViaCheck\ReturnViaCheck.pas*

```pascal
for i := 0 to Board.DrillLayerPairsCount - 1 do
    begin
        DrillPairObj := Board.LayerPair(i);
        DrillPairsList.Add(DrillPairObj);
    end;
```


---


### `NewUndo()`


**Examples:**


*From: Scripts - PCB\CopyAngleToComponent\CopyAngleToComponent.pas*

```pascal
Component.GraphicallyInvalidate;
                Component.EndModify;
                Board.NewUndo();    // Update the Undo System

            finally
```


*From: Scripts - PCB\LockNetRouting\LockNetRouting.pas*

```pascal
End;

    Board.NewUndo();
    PCBServer.PostProcess;            // finish board change with Undo option
    RefTrack := Board.GetObjectAtCursor(MkSet(eTrackObject, eArcObject, eViaObject)
```


---


### `PrimPrimDistance()`


**Observed signatures:**

```pascal
IPCB_Board.PrimPrimDistance(Primitive, Pad)
```

```pascal
IPCB_Board.PrimPrimDistance(Prim1,Prim2)
```

```pascal
IPCB_Board.PrimPrimDistance(Track, Pad)
```

**Examples:**


*From: Scripts - PCB\FixConnections\FixConnections.pas*

```pascal
begin
            // I moved this here since this sounds like complex function
            if Board.PrimPrimDistance(Prim1,Prim2) = 0 then
            begin
```


*From: Scripts - PCB\FixConnections\FixConnections.pas*

```pascal
if ((Prim2.ObjectId = ePadObject) or ((Prim2.ObjectId = eViaObject) and Prim2.IntersectLayer(Prim1.Layer))) and
         (Prim2.InNet) and (Prim2.Net.Name = Prim1.Net.Name) and (Board.PrimPrimDistance(Prim1,Prim2) = 0) then
      begin
```


---


### `RemovePCBObject()`


**Observed signatures:**

```pascal
IPCB_Board.RemovePCBObject(Prim1)
```

```pascal
IPCB_Board.RemovePCBObject(ATrack)
```

```pascal
IPCB_Board.RemovePCBObject(NewPad)
```

**Examples:**


*From: Scripts - PCB\AutoRouter_Interface\AutoRouter_Interface.pas*

```pascal
begin
      Prim1 := TempSList.GetObject(i);
      Board.RemovePCBObject(Prim1);
   end;
```


*From: Scripts - PCB\DeleteInvalidPCBObjects\DeleteInvalidPCBObjects.pas*

```pascal
Begin
                    Prim := PrimList.items[i];
                    CurrentPCBBoard.RemovePCBObject(Prim);
                End;
            Finally
```


---


### `SelectecObject()`


**Observed signatures:**

```pascal
IPCB_Board.SelectecObject(idx)
```

```pascal
IPCB_Board.SelectecObject(SecondIdx)
```

```pascal
IPCB_Board.SelectecObject(FirstIdx)
```

**Examples:**


*From: Scripts - PCB\Fillet\Fillet.pas*

```pascal
begin
        IncrementLoop := True;
        Prim := Board.SelectecObject(ObjIdx);

        // Primitive is Track
```


*From: Scripts - PCB\Fillet\Fillet.pas*

```pascal
for Obj2Idx := 0 to Board.SelectecObjectCount - 1 do
            begin
                SecondTrack := Board.SelectecObject(Obj2Idx);
                if (Obj2Idx = ObjIdx) or (RadioArcsRelative.Checked) then
                begin
```


---


### `SetState_Navigate_HighlightObjectList()`


**Observed signatures:**

```pascal
IPCB_Board.SetState_Navigate_HighlightObjectList(MkSet(eHighlight_Dim, eHighlight_Zoom, eHighlight_Select)
```

```pascal
IPCB_Board.SetState_Navigate_HighlightObjectList(MkSet(eHighlight_Dim)
```

**Examples:**


*From: Scripts - PCB\ReturnViaCheck\ReturnViaCheck.pas*

```pascal
// set of THighlightMethod = (eHighlight_Filter, eHighlight_Zoom, eHighlight_Select, eHighlight_Graph, eHighlight_Dim, eHighlight_Thicken, eHighlight_ZoomCursor, eHighlight_ForceSmooth)
            Board.SetState_Navigate_HighlightObjectList(MkSet(eHighlight_Dim), True);
        end;
```


*From: Scripts - PCB\ReturnViaCheck\ReturnViaCheck.pas*

```pascal
// set of THighlightMethod = (eHighlight_Filter, eHighlight_Zoom, eHighlight_Select, eHighlight_Graph, eHighlight_Dim, eHighlight_Thicken, eHighlight_ZoomCursor, eHighlight_ForceSmooth)
        Board.SetState_Navigate_HighlightObjectList(MkSet(eHighlight_Dim, eHighlight_Zoom, eHighlight_Select), True);

        if bUseCustomViolations then Board.EndModify;
```


---


### `SpatialIterator_Destroy()`


**Observed signatures:**

```pascal
IPCB_Board.SpatialIterator_Destroy(Iterator)
```

```pascal
IPCB_Board.SpatialIterator_Destroy(Spatial)
```

```pascal
IPCB_Board.SpatialIterator_Destroy(SpatialIterator)
```

**Examples:**


*From: Scripts - PCB\AssemblyTextPrep\AssemblyTextPrep.pas*

```pascal
Obj := SIter.NextPCBObject;
    end;
    Board.SpatialIterator_Destroy(SIter);

    if (Obj <> nil) and (iDebugLevel > 0) then
```


*From: Scripts - PCB\AutoPlaceSilkscreen\AutoPlaceSilkscreen.pas*

```pascal
else
    begin
        Board.SpatialIterator_Destroy(Iterator);
    end;
```


---


### `ViewManager_GraphicallyInvalidatePrimitive()`


**Observed signatures:**

```pascal
IPCB_Board.ViewManager_GraphicallyInvalidatePrimitive(Via)
```

```pascal
IPCB_Board.ViewManager_GraphicallyInvalidatePrimitive(Comp)
```

```pascal
IPCB_Board.ViewManager_GraphicallyInvalidatePrimitive(Board.SelectecObject[i])
```

**Examples:**


*From: Scripts - PCB\StitchingVias\StitchingVias.pas*

```pascal
Comp.PrimitiveLock := False;
   Comp.Moveable := False;
   Board.ViewManager_GraphicallyInvalidatePrimitive(Comp);
                                                        
   ResetParameters;
```


*From: Scripts - PCB\TentingVias\TentingVias.pas*

```pascal
Inc(ViaCount);

        Board.ViewManager_GraphicallyInvalidatePrimitive(Via);

        Via := Iterator.NextPCBObject;
```


---


## Properties (39)


### `BeginModify`


---


### `BoardIterator_Create`


---


### `BoardOutline`


---


### `BoundingRectangle`


---


### `BoundingRectangleChildren`


---


### `CurrentLayer`


**Common values:**

- `MechLayer.LayerID`

- `String2Layer('Top Solder Mask')`

- `MechLayer.V7_LayerID`



**Example:**

```pascal
Board.CurrentLayer := LayerObj.LayerID;
```

---


### `DisplayUnit`


**Common values:**

- `eImperial`



**Example:**

```pascal
newPcbLib.Board.DisplayUnit := eImperial; //eMetric;
```

---


### `Displayunit`


---


### `DrillLayerPairsCount`


---


### `EndModify`


---


### `FileName`


---


### `GraphicalView_ZoomRedraw`


---


### `I_ObjectAddress`


---


### `Identifier`


---


### `LayerColor`


---


### `LayerIsDisplayed`


---


### `LayerIterator`


---


### `LayerPair`


---


### `LayerStack`


---


### `LayerStack_V7`


---


### `Layerstack`


---


### `MasterLayerStack`


---


### `MechanicalLayerIterator`


---


### `MechanicalPairs`


---


### `NewUndo`


---


### `SelectecObject`


---


### `SelectecObjectCount`


---


### `SnapGridSize`


**Common values:**

- `MMsToCoord(constGridSpacingMm)`

- `50000 else Board.SnapGridSize := 39370`



**Example:**

```pascal
if (Board.DisplayUnit xor 1) = eImperial then Board.SnapGridSize := 50000 else Board.SnapGridSize := 39370; // don't believe the SDK, SnapGridSize takes TCoord, not double
```

---


### `SnapGridSizeX`


**Common values:**

- `OldSnapX`



**Example:**

```pascal
Board.SnapGridSizeX := OldSnapX;
```

---


### `SnapGridSizeY`


**Common values:**

- `OldSnapY`



**Example:**

```pascal
Board.SnapGridSizeY := OldSnapY;
```

---


### `SpatialIterator_Create`


---


### `ViewManager_FullUpdate`


---


### `ViewManager_UpdateLayerTabs`


---


### `XCursor`


---


### `XOrigin`


---


### `Xorigin`


---


### `YCursor`


---


### `YOrigin`


---


### `Yorigin`


---



====================================================================================================


# IPCB_Boarditerator


**Category:** PCB


**API Surface:** 3 methods, 2 properties


---


## Methods (3)


### `AddFilter_LayerSet()`


**Observed signatures:**

```pascal
IPCB_Boarditerator.AddFilter_LayerSet(AllLayers)
```

**Examples:**


*From: Scripts - PCB\RoomFromPoly\RoomFromPoly.pas*

```pascal
Iterator := Board.BoardIterator_Create;
    Iterator.AddFilter_ObjectSet(MkSet(ePolyObject));
    Iterator.AddFilter_LayerSet(AllLayers);
    Iterator.AddFilter_Method(eProcessAll);
```


*From: Scripts - PCB\RoomFromPoly\RoomFromPoly.pas*

```pascal
Iterator := Board.BoardIterator_Create;
       Iterator.AddFilter_ObjectSet(MkSet(ePolyObject));
       Iterator.AddFilter_LayerSet(AllLayers);
       Iterator.AddFilter_Method(eProcessAll);
```


---


### `AddFilter_Method()`


**Observed signatures:**

```pascal
IPCB_Boarditerator.AddFilter_Method(eProcessAll)
```

**Examples:**


*From: Scripts - PCB\RoomFromPoly\RoomFromPoly.pas*

```pascal
Iterator.AddFilter_ObjectSet(MkSet(ePolyObject));
    Iterator.AddFilter_LayerSet(AllLayers);
    Iterator.AddFilter_Method(eProcessAll);

    flag := 0;
```


*From: Scripts - PCB\RoomFromPoly\RoomFromPoly.pas*

```pascal
Iterator.AddFilter_ObjectSet(MkSet(ePolyObject));
       Iterator.AddFilter_LayerSet(AllLayers);
       Iterator.AddFilter_Method(eProcessAll);
```


---


### `AddFilter_ObjectSet()`


**Observed signatures:**

```pascal
IPCB_Boarditerator.AddFilter_ObjectSet(MkSet(ePolyObject)
```

**Examples:**


*From: Scripts - PCB\RoomFromPoly\RoomFromPoly.pas*

```pascal
Iterator := Board.BoardIterator_Create;
    Iterator.AddFilter_ObjectSet(MkSet(ePolyObject));
    Iterator.AddFilter_LayerSet(AllLayers);
    Iterator.AddFilter_Method(eProcessAll);
```


*From: Scripts - PCB\RoomFromPoly\RoomFromPoly.pas*

```pascal
Iterator := Board.BoardIterator_Create;
       Iterator.AddFilter_ObjectSet(MkSet(ePolyObject));
       Iterator.AddFilter_LayerSet(AllLayers);
       Iterator.AddFilter_Method(eProcessAll);
```


---


## Properties (2)


### `FirstPCBObject`


---


### `NextPCBObject`


---



====================================================================================================


# IPCB_ClearanceConstraint


**Category:** PCB


**API Surface:** 1 methods, 6 properties


---


## Methods (1)


### `ActualCheck()`


**Observed signatures:**

```pascal
IPCB_ClearanceConstraint.ActualCheck(Primitive, NewPad)
```

```pascal
IPCB_ClearanceConstraint.ActualCheck(Primitive, NewVia)
```

**Examples:**


*From: Scripts - PCB\StitchingVias\StitchingVias.pas*

```pascal
if not Primitive.InPolygon then
            begin
                Violation := RuleElectrical.ActualCheck(Primitive, NewVia);
                if Violation <> nil then ViolationFlag := 1;
```


*From: Scripts - PCB\StitchingVias\StitchingVias.pas*

```pascal
if Violation <> nil then ViolationFlag := 1;

                Violation := RuleOutline.ActualCheck(Primitive, NewVia);
                if Violation <> nil then ViolationFlag := 1;
            end;
```


---


## Properties (6)


### `Comment`


**Common values:**

- `'Clearance between Stitching Vias and Electrical Objects'`

- `'Clearance between Venting Pads'`

- `'Clearance between Venting Pads and Board Outline'`



**Example:**

```pascal
RuleOutline.Comment := 'Clearance between Stitching Vias and Board Outline';
```

---


### `Gap`


**Common values:**

- `MMsToCoord(StrToFloat(EditElectrical.Text))`

- `MilsToCoord(StrToFloat(EditOutline.Text))`

- `TempInt`



**Example:**

```pascal
if RadioButtonMM.Checked then RuleOutline.Gap := MMsToCoord(StrToFloat(EditOutline.Text))
```

---


### `Name`


**Common values:**

- `'StitchingVias-Board'`

- `'StitchingVias-Internal'`

- `'StitchingVias-Electrical'`



**Example:**

```pascal
RuleOutline.Name    := 'StitchingVias-Board';
```

---


### `NetScope`


**Common values:**

- `eNetScope_AnyNet`



**Example:**

```pascal
RuleOutline.NetScope  := eNetScope_AnyNet;
```

---


### `Scope1Expression`


**Common values:**

- `'InComponent(''StitchingVias'')'`

- `'InComponent(''Venting'')'`



**Example:**

```pascal
RuleOutline.Scope1Expression := 'InComponent(''StitchingVias'')';
```

---


### `Scope2Expression`


**Common values:**

- `'OnSignal'`

- `'InComponent(''Venting'')'`

- `'OnLayer(''Keep-Out Layer'')'`



**Example:**

```pascal
RuleOutline.Scope2Expression := 'OnLayer(''Keep-Out Layer'')';
```

---



====================================================================================================


# IPCB_Component


**Category:** PCB


**API Surface:** 14 methods, 38 properties


---


## Methods (14)


### `AddPCBObject()`


**Observed signatures:**

```pascal
IPCB_Component.AddPCBObject(NewPad)
```

```pascal
IPCB_Component.AddPCBObject(Text)
```

```pascal
IPCB_Component.AddPCBObject(NewVia)
```

**Examples:**


*From: Scripts - PCB\AssemblyTextPrep\AssemblyTextPrep.pas*

```pascal
if Text.InComponent then exit;
    Comp.BeginModify;
    Comp.AddPCBObject(Text);
    Comp.EndModify;
    Comp.GraphicallyInvalidate;
```


*From: Scripts - PCB\CopyDesignatorsToMechLayerPair\CopyDesignatorsToMechLayerPair.pas*

```pascal
Board.AddPCBObject(NewPrim);
            Component.AddPCBObject(NewPrim);

            if CheckBoxOverlayPrims.Checked then
```


---


### `ChangeCommentAutoPosition()`


**Observed signatures:**

```pascal
IPCB_Component.ChangeCommentAutoPosition(eAutoPos_Manual)
```

**Examples:**


*From: Scripts - PCB\QuickSilk\QuickSilk.pas*

```pascal
begin
                Comp.BeginModify;
                if bDesignator then Comp.ChangeNameAutoPosition(eAutoPos_Manual) else Comp.ChangeCommentAutoPosition(eAutoPos_Manual);
                Comp.EndModify;
                Comp.GraphicallyInvalidate;
```


---


### `ChangeCommentAutoposition()`


**Observed signatures:**

```pascal
IPCB_Component.ChangeCommentAutoposition(eAutoPos_Manual)
```

```pascal
IPCB_Component.ChangeCommentAutoposition(DesAutoPosComment)
```

```pascal
IPCB_Component.ChangeCommentAutoposition(SourcePrim.Component.CommentAutoPosition)
```

**Examples:**


*From: Scripts - PCB\AdjustDesignators2\AdjustDesignators2.pas*

```pascal
//     Set the Designator AutoPosition to the center-center but stop comment being moved.
            Component.ChangeCommentAutoposition( eAutoPos_Manual );
            Component.ChangeNameAutoposition(eAutoPos_CenterCenter);
            Component.SetState_NameAutoPos(eAutoPos_CenterCenter);
```


*From: Scripts - PCB\AdjustDesignators2\AdjustDesignators2.pas*

```pascal
end;
            end;
            Component.ChangeCommentAutoposition(DesAutoPosComment);

        end;
```


---


### `ChangeNameAutoPosition()`


**Observed signatures:**

```pascal
IPCB_Component.ChangeNameAutoPosition(eAutoPos_Manual)
```

**Examples:**


*From: Scripts - PCB\QuickSilk\QuickSilk.pas*

```pascal
begin
                Comp.BeginModify;
                if bDesignator then Comp.ChangeNameAutoPosition(eAutoPos_Manual) else Comp.ChangeCommentAutoPosition(eAutoPos_Manual);
                Comp.EndModify;
                Comp.GraphicallyInvalidate;
```


*From: Scripts - PCB\QuickSilk\QuickSilk.pas*

```pascal
begin
                    // set autoposition mode to Manual so it doesn't snap back to default position if component is rotated, etc.
                    Component.ChangeNameAutoPosition(eAutoPos_Manual);
                end
                else if bLazyAutoMove then
```


---


### `ChangeNameAutoposition()`


**Observed signatures:**

```pascal
IPCB_Component.ChangeNameAutoposition(tc_Autopos)
```

```pascal
IPCB_Component.ChangeNameAutoposition(SourcePrim.Component.NameAutoPosition)
```

```pascal
IPCB_Component.ChangeNameAutoposition(eAutoPos_Manual)
```

**Examples:**


*From: Scripts - PCB\AdjustDesignators2\AdjustDesignators2.pas*

```pascal
//     Set the Designator AutoPosition to the center-center but stop comment being moved.
            Component.ChangeCommentAutoposition( eAutoPos_Manual );
            Component.ChangeNameAutoposition(eAutoPos_CenterCenter);
            Component.SetState_NameAutoPos(eAutoPos_CenterCenter);
```


*From: Scripts - PCB\QuickSilk\QuickSilk.pas*

```pascal
CopyTextFormatFromTo(SourceNameOrComment, TargetNameOrComment, False);

        if bDesignator then TargetComp.ChangeNameAutoposition(eAutoPos_Manual) else TargetComp.ChangeCommentAutoposition(eAutoPos_Manual);

        TargetNameOrComment.Rotation := SourceNameOrComment.Rotation;
```


---


### `GroupIterator_Destroy()`


**Observed signatures:**

```pascal
IPCB_Component.GroupIterator_Destroy(GroupIterator)
```

```pascal
IPCB_Component.GroupIterator_Destroy(PadIteratorHandle)
```

```pascal
IPCB_Component.GroupIterator_Destroy(OverlayIterator)
```

**Examples:**


*From: Scripts - PCB\AdjustDesignators\AdjustDesignators.pas*

```pascal
// Destroy the track interator
            Component.GroupIterator_Destroy(TrackIteratorHandle);
           // Get the next component handle
            Component := ComponentIteratorHandle.NextPCBObject;
```


*From: Scripts - PCB\AdjustDesignators2\AdjustDesignators2.pas*

```pascal
Track := GroupIterator.NextPCBObject;
        end;
        Component.GroupIterator_Destroy(GroupIterator);

        // Calculate the width and heigth of the bounding rectangle
```


---


### `LoadFromLibrary()`


**Observed signatures:**

```pascal
IPCB_Component.LoadFromLibrary('SourceLibReference=103PP-303|FootPrint=2EDG2X6P-3R81-TH-W|SourceComponentLibrary=YourDBLIB.Dblib')
```

**Examples:**


*From: Scripts - Examples\PlacePartFromDbLibToPCB\PlacePartFromDbLibToPCB.pas*

```pascal
begin
    Component.Board := Board;
    Component.LoadFromLibrary('SourceLibReference=103PP-303|FootPrint=2EDG2X6P-3R81-TH-W|SourceComponentLibrary=YourDBLIB.Dblib');
    Component.Layer := eV7_TopLayer;
    Component.SetState_XLocation(18500000);
```


---


### `MoveByXY()`


**Observed signatures:**

```pascal
IPCB_Component.MoveByXY(X1 - X2, Y1 - Y2)
```

**Examples:**


*From: Scripts - PCB\FlipComponents\FlipComponents.pas*

```pascal
Y2 := BoundRect.Bottom;

      Component.MoveByXY(X1 - X2, Y1 - Y2);

      // we will modify tekst placement for this kind of rotation
```


*From: Scripts - PCB\FlipComponents\FlipComponents.pas*

```pascal
Y2 := BoundRect.Bottom;

      Component.MoveByXY(X1 - X2, Y1 - Y2);
   end;
end;
```


---


### `MoveToXY()`


**Observed signatures:**

```pascal
IPCB_Component.MoveToXY(DestinX + X, DestinY + Y)
```

```pascal
IPCB_Component.MoveToXY(DestinX - X, DestinY - Y)
```

**Examples:**


*From: Scripts - PCB\ComponentPlacement\ComponentPlacement.pas*

```pascal
Y := Distance * sin(DegToRad(DestinRot + Angle));

            Destin.MoveToXY(DestinX + X, DestinY + Y);
            Destin.Layer := Source.Layer;
```


*From: Scripts - PCB\ComponentPlacement\ComponentPlacement.pas*

```pascal
Y := Distance * sin(DegToRad(180 + DestinRot - Angle));

            Destin.MoveToXY(DestinX - X, DestinY - Y);

            if Source.Layer = eTopLayer then
```


---


### `SetState_NameAutoPos()`


**Observed signatures:**

```pascal
IPCB_Component.SetState_NameAutoPos(DesAutoPosition)
```

```pascal
IPCB_Component.SetState_NameAutoPos(eAutoPos_CenterCenter)
```

**Examples:**


*From: Scripts - PCB\AdjustDesignators2\AdjustDesignators2.pas*

```pascal
Component.ChangeCommentAutoposition( eAutoPos_Manual );
            Component.ChangeNameAutoposition(eAutoPos_CenterCenter);
            Component.SetState_NameAutoPos(eAutoPos_CenterCenter);

            if (ModMechText) then
```


*From: Scripts - PCB\AdjustDesignators2\AdjustDesignators2.pas*

```pascal
Designator.FontID     := DesFontID;
                Designator.Rotation   := DesRotation;
                Component.SetState_NameAutoPos(DesAutoPosition);

                Designator.MultilineTextHeight := DesMultilineTH;
```


---


### `SetState_PrimitiveLock()`


**Observed signatures:**

```pascal
IPCB_Component.SetState_PrimitiveLock(False)
```

**Examples:**


*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Cleanup_LPW_Footprint.pas*

```pascal
{ Attempt to unlock primitives for our one component. }
   component.SetState_PrimitiveLock(False);

end; { end CLF_ExplodeComponent() }
```


*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Cleanup_PcbDoc_Layout.pas*

```pascal
{ Attempt to unlock primitives for our one component. }
//   component.SetState_PrimitiveLock(False);
```


---


### `SetState_Selected()`


**Observed signatures:**

```pascal
IPCB_Component.SetState_Selected(True)
```

**Examples:**


*From: Scripts - PCB\AssemblyTextPrep\AssemblyTextPrep.pas*

```pascal
if Comp <> nil then
            begin
                Comp.SetState_Selected(True);
                if Comp.GetState_Selected = True then CompCount := CompCount + 1;
            end;
```


*From: Scripts - PCB\QuickSilk\QuickSilk.pas*

```pascal
if Comp <> nil then
            begin
                Comp.SetState_Selected(True);
                if Comp.GetState_Selected = True then CompCount := CompCount + 1;
            end;
```


---


### `SetState_XLocation()`


**Observed signatures:**

```pascal
IPCB_Component.SetState_XLocation(18500000)
```

**Examples:**


*From: Scripts - Examples\PlacePartFromDbLibToPCB\PlacePartFromDbLibToPCB.pas*

```pascal
Component.LoadFromLibrary('SourceLibReference=103PP-303|FootPrint=2EDG2X6P-3R81-TH-W|SourceComponentLibrary=YourDBLIB.Dblib');
    Component.Layer := eV7_TopLayer;
    Component.SetState_XLocation(18500000);
    Component.SetState_YLocation(13100000);
```


---


### `SetState_YLocation()`


**Observed signatures:**

```pascal
IPCB_Component.SetState_YLocation(13100000)
```

**Examples:**


*From: Scripts - Examples\PlacePartFromDbLibToPCB\PlacePartFromDbLibToPCB.pas*

```pascal
Component.Layer := eV7_TopLayer;
    Component.SetState_XLocation(18500000);
    Component.SetState_YLocation(13100000);

    Board.AddPCBObject(Component);
```


---


## Properties (38)


### `BeginModify`


---


### `Board`


**Common values:**

- `Board`



**Example:**

```pascal
Component.Board := Board;
```

---


### `BoundingRectangle`


---


### `BoundingRectangleNoNameComment`


---


### `BoundingRectangleNoNameCommentForSignals`


---


### `ChangeNameAutoposition`


**Common values:**

- `eAutoPos_Manual`

- `eAutoPos_CenterCenter`

- `NextAutoP`



**Example:**

```pascal
Component.ChangeNameAutoposition  :=  eAutoPos_CenterCenter;
```

---


### `Comment`


---


### `CommentAutoPosition`


**Common values:**

- `LogicalComp.CommentAutoPosition`



**Example:**

```pascal
PhysicalComp.CommentAutoPosition          :=LogicalComp.CommentAutoPosition;
```

---


### `CommentOn`


**Common values:**

- `commenton`

- `SourceComp.CommentOn`

- `True`



**Example:**

```pascal
TargetComp.CommentOn := SourceComp.CommentOn;
```

---


### `ComponentKind`


**Common values:**

- `eComponentKind_Graphical`



**Example:**

```pascal
Comp.ComponentKind := eComponentKind_Graphical;
```

---


### `EndModify`


---


### `FootprintDescription`


---


### `GetState_CommentAutoPos`


---


### `GetState_NameAutoPos`


---


### `GetState_Selected`


---


### `GraphicallyInvalidate`


---


### `GroupIterator_Create`


---


### `I_ObjectAddress`


---


### `Layer`


**Common values:**

- `Source.Layer`

- `eTopLayer`

- `LogicalComp.Layer`



**Example:**

```pascal
Component.Layer := eTopLayer
```

---


### `LockStrings`


**Common values:**

- `true`



**Example:**

```pascal
Component.LockStrings := true;
```

---


### `Moveable`


**Common values:**

- `Not(Lock)`

- `False`



**Example:**

```pascal
Component.Moveable := Not(Lock); // lock/unlock component
```

---


### `Name`


---


### `NameAutoPosition`


**Common values:**

- `LogicalComp.NameAutoPosition`



**Example:**

```pascal
PhysicalComp.NameAutoPosition             :=LogicalComp.NameAutoPosition;
```

---


### `NameOn`


**Common values:**

- `False else Comp.CommentOn := False`

- `SourceComp.NameOn`

- `True`



**Example:**

```pascal
Component.NameOn := true;
```

---


### `ObjectId`


---


### `Pattern`


---


### `PrimitiveLock`


**Common values:**

- `False`



**Example:**

```pascal
Comp.PrimitiveLock := False;
```

---


### `Rotation`


**Common values:**

- `OldRotation`

- `DestinRot + SourceRot - Source.Rotation`

- `TempRotation`



**Example:**

```pascal
Comp.Rotation := 0;         // rotate component to zero to calculate bounding box
```

---


### `Selected`


**Common values:**

- `true`

- `True`

- `False`



**Example:**

```pascal
Comp.Selected := False;
```

---


### `SetState_XSizeYSize`


---


### `SourceDesignator`


---


### `SourceFootprintLibrary`


---


### `SourceLibReference`


---


### `SourceUniqueId`


---


### `X`


**Common values:**

- `Board.XOrigin`

- `BoardShapeRect.Left`



**Example:**

```pascal
Comp.X := Board.XOrigin;
```

---


### `Y`


**Common values:**

- `Board.YOrigin`

- `BoardShapeRect.Bottom`



**Example:**

```pascal
Comp.Y := Board.YOrigin;
```

---


### `x`


**Common values:**

- `StrToInt(TempLine) * Resolution`

- `X + Int(Ratio * (Component.x - X))`

- `LogicalComp.x`



**Example:**

```pascal
Component.x := StrToInt(TempLine) * Resolution;
```

---


### `y`


**Common values:**

- `StrToInt(TempLine) * Resolution`

- `Y + Int(Ratio * (Component.y - Y))`

- `LogicalComp.y`



**Example:**

```pascal
Component.y := StrToInt(TempLine) * Resolution;
```

---



====================================================================================================


# IPCB_ComponentBody


**Category:** PCB


**API Surface:** 6 methods, 15 properties


---


## Methods (6)


### `ModelFactory_CreateCylinder()`


**Observed signatures:**

```pascal
IPCB_ComponentBody.ModelFactory_CreateCylinder(MMsToCoord(radiusMm)
```

**Examples:**


*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Cleanup_LPW_Footprint.pas*

```pascal
{ Create a new model of a cylinder. }
   model := bodyDst.ModelFactory_CreateCylinder(MMsToCoord(radiusMm), MMsToCoord(ZheightMm-ZoffsetMm), 0);
   bodyDst.SetState_FromModel;
```


---


### `ModelFactory_CreateSphere()`


**Observed signatures:**

```pascal
IPCB_ComponentBody.ModelFactory_CreateSphere(MMsToCoord(radiusMm)
```

**Examples:**


*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Cleanup_LPW_Footprint.pas*

```pascal
{ Create a new model of a sphere. }
   model := bodyDst.ModelFactory_CreateSphere(MMsToCoord(radiusMm), 0);
   bodyDst.SetState_FromModel;
```


---


### `ModelFactory_FromFilename()`


**Observed signatures:**

```pascal
IPCB_ComponentBody.ModelFactory_FromFilename(STEPFileName, false)
```

```pascal
IPCB_ComponentBody.ModelFactory_FromFilename(stepFileName, false)
```

**Examples:**


*From: Scripts - PCB\AutoSTEPplacer\AutoSTEPplacer.pas*

```pascal
// So now I do have the STEP file and component it needs to go to
                           STEPmodel := PcbServer.PCBObjectFactory(eComponentBodyObject,eNoDimension,eCreate_Default);
                           Model := STEPmodel.ModelFactory_FromFilename(STEPFileName, false);
                           STEPmodel.SetState_FromModel;
                           if ComboBoxTop.Text = 'Y' then
```


*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Cleanup_LPW_Footprint.pas*

```pascal
{ Create a new model from specified STEP model. }
   model := bodyDst.ModelFactory_FromFilename(stepFileName, false);
   bodyDst.SetState_FromModel;
```


---


### `MoveToXY()`


**Observed signatures:**

```pascal
IPCB_ComponentBody.MoveToXY(MMsToCoord(borderWestMm)
```

**Examples:**


*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Cleanup_LPW_Footprint.pas*

```pascal
{ Set x,y coordinates for sphere. }
   { Note:  The MoveToXY() wants the south west coordinate, use that. }
   bodyDst.MoveToXY(MMsToCoord(borderWestMm), MMsToCoord(borderSouthMm));

   { Queue new body for new library component. }
```


*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Cleanup_LPW_Footprint.pas*

```pascal
{ Set x,y coordinates for cylinder. }
   { Note:  The MoveToXY() wants the south west coordinate, use that. }
   bodyDst.MoveToXY(MMsToCoord(borderWestMm), MMsToCoord(borderSouthMm));

   { Queue new body for new library component. }
```


---


### `SetOutlineContour()`


**Observed signatures:**

```pascal
IPCB_ComponentBody.SetOutlineContour(bodyContour)
```

```pascal
IPCB_ComponentBody.SetOutlineContour(contour)
```

**Examples:**


*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Cleanup_LPW_Footprint.pas*

```pascal
bodyContour.AddPoint(MMsToCoord(borderEastMm), MMsToCoord(borderNorthMm));
   
   bodyDst.SetOutlineContour(bodyContour);

   { Queue new body for new library component. }
```


*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Cleanup_LPW_Footprint.pas*

```pascal
{ Set the new 3D body object to use the current contour as its outline contour. }
         bodyDst.SetOutlineContour(contour);

         { Report contour points. }
```


---


### `SetState_Identifier()`


**Observed signatures:**

```pascal
IPCB_ComponentBody.SetState_Identifier(identifier + '-' + IntToStr(i)
```

```pascal
IPCB_ComponentBody.SetState_Identifier(ChangeFileExt(ExtractFileName(stepFileName)
```

```pascal
IPCB_ComponentBody.SetState_Identifier(identifier)
```

**Examples:**


*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Cleanup_LPW_Footprint.pas*

```pascal
bodyDst.BodyColor3D    := color;
   bodyDst.BodyOpacity3D  := opacity;
   bodyDst.SetState_Identifier(identifier);
//   bodyDst.Locked := True;
```


*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Cleanup_LPW_Footprint.pas*

```pascal
bodyDst.BodyColor3D    := colorText;
         bodyDst.BodyOpacity3D  := opacity;
         bodyDst.SetState_Identifier(identifier + '-' + IntToStr(i));
         //   bodyDst.Locked := True;
```


---


## Properties (15)


### `BodyColor3D`


**Common values:**

- `colorBackground`

- `colorText`

- `color`



**Example:**

```pascal
bodyDst.BodyColor3D    := color;
```

---


### `BodyOpacity3D`


**Common values:**

- `0.0`

- `opacity`



**Example:**

```pascal
bodyDst.BodyOpacity3D  := opacity;
```

---


### `BodyProjection`


**Common values:**

- `boardSide`



**Example:**

```pascal
bodyDst.BodyProjection := boardSide;
```

---


### `BoundingRectangle`


---


### `GeometricPolygon`


---


### `I_ObjectAddress`


---


### `Kind`


**Common values:**

- `eRegionKind_Copper`



**Example:**

```pascal
bodyDst.Kind           := eRegionKind_Copper;
```

---


### `Layer`


**Common values:**

- `layer`



**Example:**

```pascal
bodyDst.Layer          := layer;
```

---


### `MainContour`


---


### `Model`


**Common values:**

- `Model`

- `model`



**Example:**

```pascal
STEPmodel.Model := Model;
```

---


### `OverallHeight`


**Common values:**

- `MMsToCoord(overallHeightMm)`

- `(MMsToCoord(overallHeightMm) + 1)`



**Example:**

```pascal
bodyDst.OverallHeight  := MMsToCoord(overallHeightMm);
```

---


### `Selected`


---


### `SetState_FromModel`


---


### `StandoffHeight`


**Common values:**

- `MMsToCoord(ZoffsetMm)`

- `MMsToCoord(overallHeightMm)`

- `MMsToCoord(standoffHeightMm)`



**Example:**

```pascal
bodyDst.StandoffHeight := MMsToCoord(standoffHeightMm);
```

---


### `identifier`


---



====================================================================================================


# IPCB_ComponentClearanceConstraint


**Category:** PCB


**API Surface:** 0 methods, 7 properties


---


## Properties (7)


### `Comment`


**Common values:**

- `'Clearance between "Venting" Component and other Components'`

- `'Clearance between "StitchingVias" Component and other Components'`



**Example:**

```pascal
RuleCompClear.Comment  := 'Clearance between "StitchingVias" Component and other Components';
```

---


### `Gap`


**Common values:**

- `0`



**Example:**

```pascal
RuleCompClear.Gap         := 0;
```

---


### `Name`


**Common values:**

- `'StitchingVias-Comp'`

- `'Venting-Comp'`



**Example:**

```pascal
RuleCompClear.Name     := 'StitchingVias-Comp';
```

---


### `NetScope`


**Common values:**

- `eNetScope_AnyNet`



**Example:**

```pascal
RuleCompClear.NetScope := eNetScope_AnyNet;
```

---


### `Scope1Expression`


**Common values:**

- `'InComponent(''StitchingVias'')'`

- `'InComponent(''Venting'')'`



**Example:**

```pascal
RuleCompClear.Scope1Expression := 'InComponent(''StitchingVias'')';
```

---


### `Scope2Expression`


**Common values:**

- `'All'`



**Example:**

```pascal
RuleCompClear.Scope2Expression := 'All';
```

---


### `VerticalGap`


**Common values:**

- `0`



**Example:**

```pascal
RuleCompClear.VerticalGap := 0;
```

---



====================================================================================================


# IPCB_ConfinementConstraint


**Category:** PCB


**API Surface:** 0 methods, 8 properties


---


## Properties (8)


### `Comment`


**Common values:**

- `'Custom room definition (confinement constraint) rule.'`



**Example:**

```pascal
NewRoom.Comment := 'Custom room definition (confinement constraint) rule.';
```

---


### `ConstraintLayer`


**Common values:**

- `eTopLayer`



**Example:**

```pascal
NewRoom.ConstraintLayer := eTopLayer;
```

---


### `Kind`


**Common values:**

- `eConfineOut`



**Example:**

```pascal
NewRoom.Kind := eConfineOut;
```

---


### `LayerKind`


**Common values:**

- `eRuleLayerKind_SameLayer`



**Example:**

```pascal
NewRoom.LayerKind := eRuleLayerKind_SameLayer;
```

---


### `Name`


**Common values:**

- `'Room_From_Poly'`



**Example:**

```pascal
NewRoom.Name := 'Room_From_Poly';
```

---


### `NetScope`


**Common values:**

- `eNetScope_AnyNet`



**Example:**

```pascal
NewRoom.NetScope  := eNetScope_AnyNet;
```

---


### `PointCount`


**Common values:**

- `Polygon.PointCount`

- `Polygon.PointCount + IncPoint`



**Example:**

```pascal
NewRoom.PointCount := Polygon.PointCount;
```

---


### `Segments`


---



====================================================================================================


# IPCB_Contour


**Category:** PCB


**API Surface:** 4 methods, 4 properties


---


## Methods (4)


### `AddPoint()`


**Observed signatures:**

```pascal
IPCB_Contour.AddPoint(OldRect.Right, OldRect.Bottom)
```

```pascal
IPCB_Contour.AddPoint(OldRect.Left, OldRect.Top)
```

```pascal
IPCB_Contour.AddPoint(PVPrim.x - (PVPrim.HoleSize div 2)
```

**Examples:**


*From: Scripts - PCB\AssemblyTextPrep\AssemblyTextPrep.pas*

```pascal
NewContour := PCBServer.PCBContourFactory;
        // Procedure   AddPoint(x : Integer; y : Integer);
        NewContour.AddPoint(OldRect.Left, OldRect.Bottom);
        NewContour.AddPoint(OldRect.Right, OldRect.Bottom);
        NewContour.AddPoint(OldRect.Right, OldRect.Top);
```


*From: Scripts - PCB\AssemblyTextPrep\AssemblyTextPrep.pas*

```pascal
// Procedure   AddPoint(x : Integer; y : Integer);
        NewContour.AddPoint(OldRect.Left, OldRect.Bottom);
        NewContour.AddPoint(OldRect.Right, OldRect.Bottom);
        NewContour.AddPoint(OldRect.Right, OldRect.Top);
        NewContour.AddPoint(OldRect.Left, OldRect.Top);
```


---


### `RotateAboutPoint()`


**Observed signatures:**

```pascal
IPCB_Contour.RotateAboutPoint(Angle, Xc, Yc)
```

**Examples:**


*From: Scripts - PCB\PCBObjectInspector\PCBObjectInspector.pas*

```pascal
for idx := 0 to POINTCOUNT - 1 do
    begin
        if idx > 0 then PVPrimContour.RotateAboutPoint(Angle, Xc, Yc); // use built-in rotation method for simplicity

        //if not PCBServer.PCBContourUtilities.PointInContour(RegionPrimGeoPoly.Contour(0), X, Y) then exit; // no guarantee that Contour(0) is the correct contour to evaluate
```


*From: Scripts - PCB\ReturnViaCheck\ReturnViaCheck.pas*

```pascal
for idx := 0 to POINTCOUNT - 1 do
    begin
        if idx > 0 then PVPrimContour.RotateAboutPoint(Angle, Xc, Yc); // use built-in rotation method for simplicity

        //if not PCBServer.PCBContourUtilities.PointInContour(RegionPrimGeoPoly.Contour(0), X, Y) then exit; // no guarantee that Contour(0) is the correct contour to evaluate
```


---


### `x()`


**Observed signatures:**

```pascal
IPCB_Contour.x(PointIdx)
```

```pascal
IPCB_Contour.x(iPoint)
```

**Examples:**


*From: Scripts - PCB\AssemblyTextPrep\AssemblyTextPrep.pas*

```pascal
for iPoint := 0 to contour.Count - 1 do
    begin
        xRunningSum := xRunningSum + (contour.x(iPoint) - xRunningSum) / (iPoint + 1);
        yRunningSum := yRunningSum + (contour.y(iPoint) - yRunningSum) / (iPoint + 1);
    end;
```


*From: Scripts - PCB\AssemblyTextPrep\AssemblyTextPrep.pas*

```pascal
for iPoint := 0 to contour.Count - 1 do
    begin
        if contour.x(iPoint) < minX then minX := contour.x(iPoint);
        if contour.y(iPoint) < minY then minY := contour.y(iPoint);
        if contour.x(iPoint) > maxX then maxX := contour.x(iPoint);
```


---


### `y()`


**Observed signatures:**

```pascal
IPCB_Contour.y(PointIdx)
```

```pascal
IPCB_Contour.y(iPoint)
```

**Examples:**


*From: Scripts - PCB\AssemblyTextPrep\AssemblyTextPrep.pas*

```pascal
begin
        xRunningSum := xRunningSum + (contour.x(iPoint) - xRunningSum) / (iPoint + 1);
        yRunningSum := yRunningSum + (contour.y(iPoint) - yRunningSum) / (iPoint + 1);
    end;
```


*From: Scripts - PCB\AssemblyTextPrep\AssemblyTextPrep.pas*

```pascal
for iPoint := 0 to contour.Count - 1 do
        begin
            PointList.Add(Format('%d:%s,%s', [iPoint, CoordToX(contour.x(iPoint)), CoordToY(contour.y(iPoint))]));
        end;
    end
```


---


## Properties (4)


### `Clear`


---


### `Count`


---


### `X`


---


### `Y`


---



====================================================================================================


# IPCB_ContourMaker2


**Category:** PCB


**API Surface:** 1 methods, 0 properties


---


## Methods (1)


### `MakeContour()`


**Observed signatures:**

```pascal
IPCB_ContourMaker2.MakeContour(Obj, Expansion, Obj.Layer)
```

```pascal
IPCB_ContourMaker2.MakeContour(Obj, Expansion - (Obj.Width / 2)
```

**Examples:**


*From: Scripts - PCB\AutoPlaceSilkscreen\AutoPlaceSilkscreen.pas*

```pascal
begin
        // Function  MakeContour(APrim : IPCB_Primitive; AExpansion : Integer; ALayer : TV6_Layer) : IPCB_GeometricPolygon;
        Poly := ContourMaker.MakeContour(Obj, Expansion, Obj.Layer);
    end
    else if ObjID = eTrackObject then
```


*From: Scripts - PCB\AutoPlaceSilkscreen\AutoPlaceSilkscreen.pas*

```pascal
begin
        // Function  MakeContour(APrim : IPCB_Primitive; AExpansion : Integer; ALayer : TV6_Layer) : IPCB_GeometricPolygon;
        Poly := ContourMaker.MakeContour(Obj, Expansion, Obj.Layer);
    end
    else if ObjID = eRegionObject then
```


---



====================================================================================================


# IPCB_DielectricObject


**Category:** PCB


**API Surface:** 0 methods, 9 properties


---


## Properties (9)


### `CopperThickness`


---


### `DielectricConstant`


---


### `DielectricHeight`


---


### `DielectricMaterial`


---


### `DielectricType`


---


### `I_ObjectAddress`


---


### `LayerID`


---


### `Name`


---


### `V7_LayerID`


---



====================================================================================================


# IPCB_DrillLayerPair


**Category:** PCB


**API Surface:** 0 methods, 5 properties


---


## Properties (5)


### `Description`


---


### `HighLayer`


---


### `LowLayer`


---


### `StartLayer`


---


### `StopLayer`


---



====================================================================================================


# IPCB_EmbeddedBoard


**Category:** PCB


**API Surface:** 0 methods, 1 properties


---


## Properties (1)


### `BoundingRectangle`


---



====================================================================================================


# IPCB_Fill


**Category:** PCB


**API Surface:** 1 methods, 11 properties


---


## Methods (1)


### `Replicate()`


**Examples:**


*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Cleanup_LPW_Footprint.pas*

```pascal
{ Replicate the queued fill and operate on that fill. }
         fillNew := fillDst.Replicate();

         { Add new object to PcbLib footprint. }
```


---


## Properties (11)


### `I_ObjectAddress`


---


### `IsKeepout`


---


### `Layer`


**Common values:**

- `constNewLayerSolderPasteRegion`

- `regionSrc.Layer`

- `layer`



**Example:**

```pascal
Fill.Layer := eTopPaste;
```

---


### `Net`


---


### `Rotation`


**Common values:**

- `0`



**Example:**

```pascal
Fill.Rotation := 0;
```

---


### `X1Location`


**Common values:**

- `fill_x1 + xorigin`

- `MMsToCoord(boundaryWestMm)`

- `(rectSrc.left - boardXorigin)`



**Example:**

```pascal
Fill.X1Location := fill_x1 + xorigin;
```

---


### `X2Location`


**Common values:**

- `fill_x2 + xorigin`

- `MMsToCoord(boundaryEastMm)`

- `(rectSrc.right - boardXorigin)`



**Example:**

```pascal
Fill.X2Location := fill_x2 + xorigin;
```

---


### `XLocation`


---


### `Y1Location`


**Common values:**

- `MMsToCoord(boundarySouthMm)`

- `fill_y1 + yorigin`

- `(rectSrc.bottom - boardYorigin)`



**Example:**

```pascal
Fill.Y1Location := fill_y1 + yorigin;
```

---


### `Y2Location`


**Common values:**

- `MMsToCoord(boundaryNorthMm)`

- `(rectSrc.top - boardYorigin)`

- `fill_y2 + yorigin`



**Example:**

```pascal
Fill.Y2Location := fill_y2 + yorigin;
```

---


### `YLocation`


---



====================================================================================================


# IPCB_GeometricPolygon


**Category:** PCB


**API Surface:** 2 methods, 3 properties


---


## Methods (2)


### `AddContour()`


**Observed signatures:**

```pascal
IPCB_GeometricPolygon.AddContour(PixelContour)
```

```pascal
IPCB_GeometricPolygon.AddContour(NewContour)
```

**Examples:**


*From: Scripts - PCB\AssemblyTextPrep\AssemblyTextPrep.pas*

```pascal
// Function  AddContour(AContour : IPCB_Contour) : IPCB_Contour;
        Poly := PCBServer.PCBGeometricPolygonFactory;
        Poly.AddContour(NewContour);
    end;
```


*From: Scripts - PCB\AutoPlaceSilkscreen\AutoPlaceSilkscreen.pas*

```pascal
// Function  AddContour(AContour : IPCB_Contour) : IPCB_Contour;
        Poly := PCBServer.PCBGeometricPolygonFactory;
        Poly.AddContour(NewContour);
    end;
```


---


### `Contour()`


**Observed signatures:**

```pascal
IPCB_GeometricPolygon.Contour(0)
```

```pascal
IPCB_GeometricPolygon.Contour(iPoly)
```

**Examples:**


*From: Scripts - PCB\AssemblyTextPrep\AssemblyTextPrep.pas*

```pascal
for iPoly := 0 to poly.Count - 1 do
        begin
            contour := poly.Contour(iPoly);
            PointList.AddStrings(DebugContourInfo(contour));
        end;
```


*From: Scripts - PCB\AssemblyTextPrep\AssemblyTextPrep.pas*

```pascal
poly := PCBServer.PCBContourMaker.MakeContour(Pad, 0, ALayer);
    if (poly = nil) or (poly.Count < 1) then exit;
    contour := poly.Contour(0);
    if contour.Count < 3 then exit; // less than 3 points is not valid contour
```


---


## Properties (3)


### `AddEmptyContour`


---


### `Contour`


---


### `Count`


---



====================================================================================================


# IPCB_GroupIterator


**Category:** PCB


**API Surface:** 4 methods, 5 properties


---


## Methods (4)


### `AddFilter_IPCB_LayerSet()`


**Observed signatures:**

```pascal
IPCB_GroupIterator.AddFilter_IPCB_LayerSet(LayerSetUtils.Factory(Layer)
```

```pascal
IPCB_GroupIterator.AddFilter_IPCB_LayerSet(ASetOfLayers)
```

```pascal
IPCB_GroupIterator.AddFilter_IPCB_LayerSet(LayerSet.SignalLayers)
```

**Examples:**


*From: Scripts - PCB\AdjustDesignators2\AdjustDesignators2.pas*

```pascal
GroupIterator := Component.GroupIterator_Create;
        GroupIterator.AddFilter_ObjectSet(MkSet(eTrackObject));
        GroupIterator.AddFilter_IPCB_LayerSet(ASetOfLayers);     // Group filter DNW

        Track := GroupIterator.FirstPCBObject;
```


*From: Scripts - PCB\AdjustDesignators2\AdjustDesignators2.pas*

```pascal
GroupIterator := Component.GroupIterator_Create;
                GroupIterator.AddFilter_ObjectSet(MkSet(eTextObject));
                GroupIterator.AddFilter_IPCB_LayerSet(ASetOfLayers);

                MechDesignator := GroupIterator.FirstPCBObject;
```


---


### `AddFilter_LayerSet()`


**Observed signatures:**

```pascal
IPCB_GroupIterator.AddFilter_LayerSet(AllLayers)
```

```pascal
IPCB_GroupIterator.AddFilter_LayerSet(GetLayerSet(Text.Layer, ObjID)
```

```pascal
IPCB_GroupIterator.AddFilter_LayerSet(GetComponentBodyLayerSet(Text.Component)
```

**Examples:**


*From: Scripts - PCB\AssemblyTextPrep\AssemblyTextPrep.pas*

```pascal
// use group iterator to loop through all primitives on Text layer
    GIter := Text.Component.GroupIterator_Create;
    GIter.AddFilter_LayerSet(MkSet(Text.Layer));
    GIter.AddFilter_ObjectSet(MkSet(eTextObject, eTrackObject, eArcObject, eFillObject, eRegionObject));
```


*From: Scripts - PCB\QuickSilk\QuickSilk.pas*

```pascal
Iterator := Board.BoardIterator_Create;
        Iterator.AddFilter_ObjectSet(MkSet(ObjID));
        Iterator.AddFilter_LayerSet(GetLayerSet(Text.Layer, ObjID));
        Iterator.AddFilter_Method(eProcessAll);
        RegIter := True;
```


---


### `AddFilter_ObjectSet()`


**Observed signatures:**

```pascal
IPCB_GroupIterator.AddFilter_ObjectSet(MkSet(eTrackObject, eArcObject)
```

```pascal
IPCB_GroupIterator.AddFilter_ObjectSet(MkSet(eRegionObject)
```

```pascal
IPCB_GroupIterator.AddFilter_ObjectSet(mkset(eTrackObject)
```

**Examples:**


*From: Scripts - PCB\AdjustDesignators\AdjustDesignators.pas*

```pascal
TrackIteratorHandle := Component.GroupIterator_Create;
             TrackIteratorHandle.AddFilter_ObjectSet(MkSet(eTrackObject));

             Track := TrackIteratorHandle.FirstPCBObject;
```


*From: Scripts - PCB\AdjustDesignators2\AdjustDesignators2.pas*

```pascal
if Layer4 <> 0 then ASetOfLayers.Include(Layer4);
        GroupIterator := Component.GroupIterator_Create;
        GroupIterator.AddFilter_ObjectSet(MkSet(eTrackObject));
        GroupIterator.AddFilter_IPCB_LayerSet(ASetOfLayers);     // Group filter DNW
```


---


### `Addfilter_ObjectSet()`


**Observed signatures:**

```pascal
IPCB_GroupIterator.Addfilter_ObjectSet(MkSet(eComponentBodyObject)
```

**Examples:**


*From: Scripts - Parts library\DeleteAllSelectedItemsInPCBLib\DeleteAllSelectedItemsInPCBLib.pas*

```pascal
// Use a line such as the following if you would like to limit the type of items you are allowed to delete, in the example line below,
                       // this would limit the script to Component Body Objects
                       // Iterator.Addfilter_ObjectSet(MkSet(eComponentBodyObject));
                       MyModel := Iterator.FirstPCBObject;
                       DeleteList := TInterfaceList.Create;
```


*From: Scripts - Parts library\UpdateFootprintHeightFrom3dModelHeight\UpdateFootprintHeightFrom3dModelHeight.pas*

```pascal
// Use a line such as the following if you would like to limit the type of items you are allowed to delete, in the example line below,
                       // this would limit the script to Component Body Objects
                       Iterator.Addfilter_ObjectSet(MkSet(eComponentBodyObject));
                       MyModel := Iterator.FirstPCBObject;
                       While MyModel <> Nil Do
```


---


## Properties (5)


### `AddFilter_AllLayers`


---


### `FirstPCBObject`


---


### `NextPCBObject`


---


### `SetState_FilterAll`


---


### `firstPCBObject`


---



====================================================================================================


# IPCB_LayerIterator


**Category:** PCB


**API Surface:** 2 methods, 7 properties


---


## Methods (2)


### `AddFilter_IPCB_LayerSet()`


---


### `AddFilter_ObjectSet()`


---


## Properties (7)


### `AddFilter_ElectricalLayers`


---


### `FirstPCBObject`


---


### `Layer`


---


### `Next`


---


### `NextPCBObject`


---


### `SetBeforeFirst`


---


### `SetState_FilterAll`


---



====================================================================================================


# IPCB_LayerObject


**Category:** PCB


**API Surface:** 1 methods, 10 properties


---


## Methods (1)


### `GetState_LayerDisplayName()`


**Observed signatures:**

```pascal
IPCB_LayerObject.GetState_LayerDisplayName(e)
```

```pascal
IPCB_LayerObject.GetState_LayerDisplayName(eLayerNameDisplay_Long)
```

**Examples:**


*From: Scripts - PCB\CopyDesignatorsToMechLayerPair\CopyDesignatorsToMechLayerPair.pas*

```pascal
//        Layer     := LayerObj.V7_LayerID.ID;
        Layer     := LIterator.Layer;
// Board.LayerName(Layer) == LayerObj.Name == LayerObj.GetState_LayerDisplayName(eLayerNameDisplay_Long)
        LayerName := LayerObj.Name;
```


*From: Scripts - Examples\AddText\AddText.pas*

```pascal
//IPCB_LayerOBJECT.LayerStack.StateID

            //ShowMessage(Layer.GetState_LayerDisplayName(e));

            //ShowMessage(Layer.Name);
```


---


## Properties (10)


### `CopperThickness`


---


### `Copperthickness`


---


### `Dielectric`


---


### `IsDisplayed`


---


### `Kind`


---


### `LayerID`


---


### `Name`


**Common values:**

- `layerName`



**Example:**

```pascal
layerObj.Name := layerName;
```

---


### `ObjectIDString`


---


### `V6_LayerID`


---


### `V7_LayerID`


---



====================================================================================================


# IPCB_LayerObject_V7


**Category:** PCB


**API Surface:** 0 methods, 3 properties


---


## Properties (3)


### `I_ObjectAddress`


---


### `LayerID`


---


### `Name`


---



====================================================================================================


# IPCB_LayerObjectIterator


**Category:** PCB


**API Surface:** 0 methods, 6 properties


---


## Properties (6)


### `AddFilter_MechanicalLayers`


---


### `First`


---


### `Layer`


---


### `LayerObject`


---


### `Next`


---


### `SetBeforeFirst`


---



====================================================================================================


# IPCB_Layerset


**Category:** PCB


**API Surface:** 2 methods, 0 properties


---


## Methods (2)


### `Contains()`


**Observed signatures:**

```pascal
IPCB_Layerset.Contains(Prim.Layer)
```

**Examples:**


*From: Scripts - PCB\UpdateNetOnClick\UpdateNetOnClick.pas*

```pascal
if Prim.InPolygon then Prim := Prim.Polygon;

      if LSet.Contains(Prim.Layer) then
      Begin
         if (Prim.ObjectId = ePolyObject) then
```


---


### `Include()`


**Observed signatures:**

```pascal
IPCB_Layerset.Include(String2Layer('Multi Layer')
```

**Examples:**


*From: Scripts - PCB\UpdateNetOnClick\UpdateNetOnClick.pas*

```pascal
LSet := LayerSet.SignalLayers;
   LSet.Include(String2Layer('Multi Layer'));

   for i := 0 to Board.SelectecObjectCount - 1 do
```


---



====================================================================================================


# IPCB_LayerStack


**Category:** PCB


**API Surface:** 2 methods, 9 properties


---


## Methods (2)


### `LayerObject()`


**Observed signatures:**

```pascal
IPCB_LayerStack.LayerObject(layer2)
```

```pascal
IPCB_LayerStack.LayerObject(layer1)
```

```pascal
IPCB_LayerStack.LayerObject(layer)
```

**Examples:**


*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Setup_PCB_Layers.pas*

```pascal
{ Configure layer name. }
   layerObj := layerStack.LayerObject(layer);
   layerObj.Name := layerName;
```


*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Setup_PCB_Layers.pas*

```pascal
{ Enable mech layer 1. }
   layerObj := layerStack.LayerObject(layer1);
   layerObj.SetState_MechLayerEnabled(True);
```


---


### `NextLayer()`


**Observed signatures:**

```pascal
IPCB_LayerStack.NextLayer(LayerObj)
```

**Examples:**


*From: Scripts - PCB\IsPadCenterConnected\IsPadCenterConnected.pas*

```pascal
end;

                     LayerObj := TheLayerStack.NextLayer(LayerObj);
                  end;
```


*From: Scripts - PCB\LayersAndObjects\LayersAndObjects.pas*

```pascal
Inc(i);
         LayerObj := TheLayerStack.NextLayer(LayerObj);
      end;
```


---


## Properties (9)


### `DielectricBottom`


---


### `DielectricTop`


---


### `FirstLayer`


---


### `LayerObject`


---


### `LayerObject_V7`


---


### `LayersInStackCount`


---


### `ShowDielectricBottom`


---


### `ShowDielectricTop`


---


### `SignalLayerCount`


---



====================================================================================================


# IPCB_LayerStack_V7


**Category:** PCB


**API Surface:** 1 methods, 2 properties


---


## Methods (1)


### `NextLayer()`


---


## Properties (2)


### `FirstLayer`


---


### `SignalLayerCount`


---



====================================================================================================


# IPCB_Lib


**Category:** PCB


**API Surface:** 1 methods, 1 properties


---


## Methods (1)


### `LibraryIterator_Destroy()`


---


## Properties (1)


### `LibraryIterator_Create`


---



====================================================================================================


# IPCB_LibComponent


**Category:** PCB


**API Surface:** 3 methods, 8 properties


---


## Methods (3)


### `AddPCBObject()`


**Observed signatures:**

```pascal
IPCB_LibComponent.AddPCBObject(STEPmodel)
```

```pascal
IPCB_LibComponent.AddPCBObject(fillNew)
```

```pascal
IPCB_LibComponent.AddPCBObject(regionNew)
```

**Examples:**


*From: Scripts - PCB\AutoSTEPplacer\AutoSTEPplacer.pas*

```pascal
Model.SetState(90,0,0,0);
                           STEPmodel.Model := Model;
                           Component.AddPCBObject(STEPmodel);
                           ModelFound := True;
                           break;
```


*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Cleanup_LPW_Footprint.pas*

```pascal
{ Add new object to PcbLib footprint. }
         newLibComp.AddPCBObject(trackNew);
         PCBServer.SendMessageToRobots(newLibComp.I_ObjectAddress,c_Broadcast,PCBM_BoardRegisteration,trackNew.I_ObjectAddress);
```


---


### `GroupIterator_Destroy()`


**Observed signatures:**

```pascal
IPCB_LibComponent.GroupIterator_Destroy(Iterator)
```

**Examples:**


*From: Scripts - Parts library\DeleteAllSelectedItemsInPCBLib\DeleteAllSelectedItemsInPCBLib.pas*

```pascal
DeleteList.Free;
                       End;
                       Footprint.GroupIterator_Destroy(Iterator);
                       Footprint := FootprintIterator.NextPCBObject;
                  End;
```


---


### `RemovePCBObject()`


**Observed signatures:**

```pascal
IPCB_LibComponent.RemovePCBObject(MyModel)
```

```pascal
IPCB_LibComponent.RemovePCBObject(STEPmodel)
```

**Examples:**


*From: Scripts - PCB\AutoSTEPplacer\AutoSTEPplacer.pas*

```pascal
begin
                                 STEPmodel := ExistingModels.GetObject(k);
                                 Component.RemovePCBObject(STEPmodel);
                              end;
                           // So now I do have the STEP file and component it needs to go to
```


*From: Scripts - Parts library\DeleteAllSelectedItemsInPCBLib\DeleteAllSelectedItemsInPCBLib.pas*

```pascal
Begin
                                MyModel := DeleteList.items[i];
                                Footprint.RemovePCBObject(MyModel);
                           End;
                       PCBServer.PostProcess;
```


---


## Properties (8)


### `Description`


**Common values:**

- `libDescription`



**Example:**

```pascal
newLibComp.Description := libDescription;
```

---


### `GroupIterator_Create`


---


### `Height`


**Common values:**

- `MMsToCoord(libHeightMm)`



**Example:**

```pascal
newLibComp.Height := MMsToCoord(libHeightMm);
```

---


### `I_ObjectAddress`


---


### `ItemGUID`


**Common values:**

- `itemGUID`



**Example:**

```pascal
newLibComp.ItemGUID                := itemGUID;
```

---


### `ItemRevisionGUID`


**Common values:**

- `itemRevisionGUID`



**Example:**

```pascal
newLibComp.ItemRevisionGUID        := itemRevisionGUID;
```

---


### `Name`


**Common values:**

- `'FOO'`

- `libFileName`



**Example:**

```pascal
newLibComp.Name := 'FOO';
```

---


### `name`


**Common values:**

- `CSPL_RemoveIllegalVaultCharsFromSymbolOrFootprintName(footprint.name)`

- `newSymbolFootprintName`



**Example:**

```pascal
footprint.name := newSymbolFootprintName;
```

---



====================================================================================================


# IPCB_Library


**Category:** PCB


**API Surface:** 5 methods, 10 properties


---


## Methods (5)


### `GetComponent()`


**Observed signatures:**

```pascal
IPCB_Library.GetComponent(0)
```

```pascal
IPCB_Library.GetComponent(j)
```

**Examples:**


*From: Scripts - PCB\AutoSTEPplacer\AutoSTEPplacer.pas*

```pascal
for j := 0 to PCBLibrary.ComponentCount - 1 do
            begin
               Component := PCBLibrary.GetComponent(j);
               CompName := Component.Name;
               ModelFound := False;
```


*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Cleanup_LPW_Footprint.pas*

```pascal
{ Retrieve footprint level Vault info. }
      { TODO:  Here we assume/hope/pray that there is only 1 footprint in existing PcbLib file. }
      oldLibComp               := oldPcbLib.GetComponent(0);
      itemGUID                 := oldLibComp.ItemGUID;
      itemRevisionGUID         := oldLibComp.ItemRevisionGUID;
```


---


### `LibraryIterator_Destroy()`


**Observed signatures:**

```pascal
IPCB_Library.LibraryIterator_Destroy(LibIterator)
```

```pascal
IPCB_Library.LibraryIterator_Destroy(footprintIterator)
```

```pascal
IPCB_Library.LibraryIterator_Destroy(FootprintIterator)
```

**Examples:**


*From: Scripts - Parts library\DeleteAllSelectedItemsInPCBLib\DeleteAllSelectedItemsInPCBLib.pas*

```pascal
CurrentLib.CurrentComponent := Footprint;
      CurrentLib.Board.ViewManager_FullUpdate;
      CurrentLib.LibraryIterator_Destroy(FootprintIterator);
      //Set to first component, refresh screen and destroy final iterators
```


*From: Scripts - Parts library\OpenLib\libUtils.pas*

```pascal
end;
    finally
        PCBLibDoc.LibraryIterator_Destroy(LibIterator);
        PCBServer.ProcessControl.PostProcess(PCBLibDoc, ''); 
    end; {try}
```


---


### `RegisterComponent()`


**Observed signatures:**

```pascal
IPCB_Library.RegisterComponent(TempPCBLibComp)
```

```pascal
IPCB_Library.RegisterComponent(newLibComp)
```

**Examples:**


*From: Scripts - Parts library\DeleteAllSelectedItemsInPCBLib\DeleteAllSelectedItemsInPCBLib.pas*

```pascal
TempPcbLibComp.Name := FP;
    // Create a temporary component to hold focus while we delete items
    CurrentLib.RegisterComponent(TempPCBLibComp);
    CurrentLib.CurrentComponent := TempPcbLibComp;
    CurrentLib.Board.ViewManager_FullUpdate;
```


*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Cleanup_LPW_Footprint.pas*

```pascal
newLibComp := PCBServer.CreatePCBLibComp;
   newLibComp.Name := 'FOO';
   newPcbLib.RegisterComponent(newLibComp);

end; { end CLF_CreateNewLibComp() }
```


---


### `RemoveComponent()`


**Observed signatures:**

```pascal
IPCB_Library.RemoveComponent(Footprint)
```

**Examples:**


*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Cleanup_LPW_Footprint.pas*

```pascal
FootprintIterator.SetState_FilterAll;
   Footprint  :=  FootprintIterator.FirstPCBObject;
   newPcbLib.RemoveComponent(Footprint);
   
   { Create new footprint in new PCB library. }
```


---


### `SetBoardToComponentByName()`


**Observed signatures:**

```pascal
IPCB_Library.SetBoardToComponentByName(FP)
```

**Examples:**


*From: Scripts - Parts library\DeleteAllSelectedItemsInPCBLib\DeleteAllSelectedItemsInPCBLib.pas*

```pascal
HowMany := IntToStr(HowManyInt);
      Showmessage('Deleted ' + HowMany + ' Items');
      CurrentLib.SetBoardToComponentByName(FP);
      Client.SendMessage('PCB:Zoom', 'Action=All' , 255, Client.CurrentView);
      Client.SendMessage('PCB:DeleteComponentFromLibrary',FP,255,client.CurrentView);
```


---


## Properties (10)


### `Board`


---


### `ComponentCount`


---


### `CurrentComponent`


**Common values:**

- `CurrentFootprint`

- `footprint`

- `Footprint`



**Example:**

```pascal
CurrentLib.CurrentComponent := TempPcbLibComp;
```

---


### `FolderGUID`


**Common values:**

- `folderGUID`



**Example:**

```pascal
newPcbLib.FolderGUID               := folderGUID;
```

---


### `GetState_CurrentSchComponentPartId`


---


### `GetState_Current_SchComponent`


---


### `LibraryIterator_Create`


---


### `LifeCycleDefinitionGUID`


**Common values:**

- `lifeCycleDefinitionGUID`



**Example:**

```pascal
newPcbLib.LifeCycleDefinitionGUID  := lifeCycleDefinitionGUID;
```

---


### `RevisionNamingSchemeGUID`


**Common values:**

- `revisionNamingSchemeGUID`



**Example:**

```pascal
newPcbLib.RevisionNamingSchemeGUID := revisionNamingSchemeGUID;
```

---


### `VaultGUID`


**Common values:**

- `vaultGUID`



**Example:**

```pascal
newPcbLib.VaultGUID                := vaultGUID;
```

---



====================================================================================================


# IPCB_LibraryIterator


**Category:** PCB


**API Surface:** 0 methods, 3 properties


---


## Properties (3)


### `FirstPCBObject`


---


### `NextPCBObject`


---


### `SetState_FilterAll`


---



====================================================================================================


# IPCB_MasterLayerStack


**Category:** PCB


**API Surface:** 4 methods, 3 properties


---


## Methods (4)


### `First()`


**Observed signatures:**

```pascal
IPCB_MasterLayerStack.First(eLayerClass_Electrical)
```

**Examples:**


*From: Scripts - PCB\PCBObjectInspector\PCBObjectInspector.pas*

```pascal
Result := CreateObject(TInterfaceList);

    LayerObject := LayerStack.First(eLayerClass_Electrical);
    while LayerObject <> nil do
    begin
```


*From: Scripts - PCB\ReturnViaCheck\ReturnViaCheck.pas*

```pascal
Result := CreateObject(TInterfaceList);

    LayerObject := LayerStack.First(eLayerClass_Electrical);
    while LayerObject <> nil do
    begin
```


---


### `GetMechanicalLayer()`


**Observed signatures:**

```pascal
IPCB_MasterLayerStack.GetMechanicalLayer(i)
```

**Examples:**


*From: Scripts - PCB\AdjustDesignators2\AdjustDesignators2.pas*

```pascal
end else
    begin
        Result := LS.GetMechanicalLayer(i);
        MLID := Result.V7_LayerID.ID;
    end;
```


*From: Scripts - PCB\AssemblyTextPrep\AssemblyTextPrep.pas*

```pascal
if IsAtLeastAD19 then
    begin
        Result := MLS.GetMechanicalLayer(i);
        MLID   := Result.V7_LayerID.ID;
    end else
```


---


### `LayerObject_V7()`


**Observed signatures:**

```pascal
IPCB_MasterLayerStack.LayerObject_V7(Obj2.Layer)
```

```pascal
IPCB_MasterLayerStack.LayerObject_V7(Obj1.Layer)
```

```pascal
IPCB_MasterLayerStack.LayerObject_V7(ASSY_LAYER_TOP)
```

**Examples:**


*From: Scripts - PCB\AdjustDesignators2\AdjustDesignators2.pas*

```pascal
begin
        MLID := LayerUtils.MechanicalLayer(i);
        Result := LS.LayerObject_V7(MLID)
    end else
    begin
```


*From: Scripts - PCB\AssemblyTextPrep\AssemblyTextPrep.pas*

```pascal
begin
        MLID   := LayerUtils.MechanicalLayer(i);
        Result := MLS.LayerObject_V7(MLID);
    end;
end;
```


---


### `Next()`


**Observed signatures:**

```pascal
IPCB_MasterLayerStack.Next(eLayerClass_Electrical, LayerObject)
```

**Examples:**


*From: Scripts - PCB\PCBObjectInspector\PCBObjectInspector.pas*

```pascal
if IsConnectedToLayer(PVPrim, LayerObject.V7_LayerID.ID) then Result.Add(LayerObject);

        LayerObject := LayerStack.Next(eLayerClass_Electrical, LayerObject);
    end;
```


*From: Scripts - PCB\ReturnViaCheck\ReturnViaCheck.pas*

```pascal
if ConnectedLayers_IsConnected(PVPrim, LayerObject.V7_LayerID.ID) then Result.Add(LayerObject);

        LayerObject := LayerStack.Next(eLayerClass_Electrical, LayerObject);
    end;
```


---


## Properties (3)


### `FirstLayer`


---


### `Iterator`


---


### `LastLayer`


---



====================================================================================================


# IPCB_MaxMinWidthConstraint


**Category:** PCB


**API Surface:** 0 methods, 7 properties


---


## Properties (7)


### `Comment`


**Common values:**

- `'Width Constraint for Arcs in "Venting" Component'`



**Example:**

```pascal
RuleWidth.Comment  := 'Width Constraint for Arcs in "Venting" Component';
```

---


### `FavoredWidth`


---


### `MaxWidth`


---


### `MinWidth`


---


### `Name`


**Common values:**

- `'Venting-Width'`



**Example:**

```pascal
RuleWidth.Name     := 'Venting-Width';
```

---


### `NetScope`


**Common values:**

- `eNetScope_AnyNet`



**Example:**

```pascal
RuleWidth.NetScope := eNetScope_AnyNet;
```

---


### `Scope1Expression`


**Common values:**

- `'InComponent(''Venting'')'`



**Example:**

```pascal
RuleWidth.Scope1Expression := 'InComponent(''Venting'')';
```

---



====================================================================================================


# IPCB_MechanicalLayer


**Category:** PCB


**API Surface:** 2 methods, 7 properties


---


## Methods (2)


### `GetState_LayerDisplayName()`


**Observed signatures:**

```pascal
IPCB_MechanicalLayer.GetState_LayerDisplayName(eLayerNameDisplay_Long)
```

**Examples:**


*From: Scripts - PCB\AssemblyTextPrep\AssemblyTextPrep.pas*

```pascal
begin
                ASSY_LAYER_TOP := MLID;
                LayerNameTop := MechLayer.GetState_LayerDisplayName(eLayerNameDisplay_Long);
                break;
            end;
```


*From: Scripts - PCB\AssemblyTextPrep\AssemblyTextPrep.pas*

```pascal
begin
                ASSY_LAYER_BOT := MLID;
                LayerNameBot := MechLayer.GetState_LayerDisplayName(eLayerNameDisplay_Long);
                break;
            end;
```


---


### `SetState_MechLayerEnabled()`


---


## Properties (7)


### `DisplayInSingleLayerMode`


**Common values:**

- `IniFile.ReadBool  ('MechLayer' + IntToStr(i), 'SLM',   False)`



**Example:**

```pascal
MechLayer.DisplayInSingleLayerMode  := IniFile.ReadBool  ('MechLayer' + IntToStr(i), 'SLM',   False);
```

---


### `IsDisplayed`


---


### `LayerID`


---


### `LinkToSheet`


**Common values:**

- `IniFile.ReadBool  ('MechLayer' + IntToStr(i), 'Sheet', False)`



**Example:**

```pascal
MechLayer.LinkToSheet               := IniFile.ReadBool  ('MechLayer' + IntToStr(i), 'Sheet', False);
```

---


### `MechanicalLayerEnabled`


**Common values:**

- `IniFile.ReadBool  ('MechLayer' + IntToStr(i), 'Enabled', True)`

- `True`



**Example:**

```pascal
MechLayerObj.MechanicalLayerEnabled := True;
```

---


### `Name`


**Common values:**

- `IniFile.ReadString('MechLayer' + IntToStr(i), 'Name',  '')`



**Example:**

```pascal
MechLayer.Name                      := IniFile.ReadString('MechLayer' + IntToStr(i), 'Name',  '');
```

---


### `V7_LayerID`


---



====================================================================================================


# IPCB_MechanicalLayerPairs


**Category:** PCB


**API Surface:** 2 methods, 2 properties


---


## Methods (2)


### `AddPair()`


---


### `PairDefined()`


**Observed signatures:**

```pascal
IPCB_MechanicalLayerPairs.PairDefined(ML1, ML2)
```

```pascal
IPCB_MechanicalLayerPairs.PairDefined(PCBServer.LayerUtils.MechanicalLayer(LayerM1)
```

```pascal
IPCB_MechanicalLayerPairs.PairDefined(ASSY_LAYER_TOP, MLID)
```

**Examples:**


*From: Scripts - PCB\AdjustDesignators2\AdjustDesignators2.pas*

```pascal
if MechLayer2.MechanicalLayerEnabled then
                    if MechLayerPairs.PairDefined(ML1, ML2) then
                    begin
                        If (ansipos(cBottomSide, Board.LayerName(ML1)) > 0) or
```


*From: Scripts - PCB\AssemblyTextPrep\AssemblyTextPrep.pas*

```pascal
MechLayer := GetMechLayerObject(MLS, i, MLID);

            if MLP.PairDefined(ASSY_LAYER_BOT, MLID) then
            begin
                ASSY_LAYER_TOP := MLID;
```


---


## Properties (2)


### `Clear`


---


### `Count`


---



====================================================================================================


# IPCB_Model


**Category:** PCB


**API Surface:** 1 methods, 0 properties


---


## Methods (1)


### `SetState()`


**Observed signatures:**

```pascal
IPCB_Model.SetState(Xrot, Yrot, Zrot, MMsToCoord(ZoffsetMm)
```

```pascal
IPCB_Model.SetState(90,0,0,0)
```

**Examples:**


*From: Scripts - PCB\AutoSTEPplacer\AutoSTEPplacer.pas*

```pascal
STEPmodel.SetState_FromModel;
                           if ComboBoxTop.Text = 'Y' then
                              Model.SetState(90,0,0,0);
                           STEPmodel.Model := Model;
                           Component.AddPCBObject(STEPmodel);
```


*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Cleanup_LPW_Footprint.pas*

```pascal
{ Set x,y,z rotation and z offset from board surface. }
   model.SetState(Xrot, Yrot, Zrot, MMsToCoord(ZoffsetMm));
   bodyDst.Model := model;
```


---



====================================================================================================


# IPCB_Net


**Category:** PCB


**API Surface:** 3 methods, 3 properties


---


## Methods (3)


### `AddPCBObject()`


**Observed signatures:**

```pascal
IPCB_Net.AddPCBObject(NewTestPoint)
```

```pascal
IPCB_Net.AddPCBObject(Prim)
```

```pascal
IPCB_Net.AddPCBObject(Track)
```

**Examples:**


*From: Scripts - PCB\LengthTuningHelper\LengthTuningHelper.pas*

```pascal
if Net = nil then continue;

      Net.AddPCBObject(Track);
      Rule := Board.FindDominantRuleForObject(Track,eRule_MaxMinWidth);
      Track.Width := Rule.FavoredWidth(eTopLayer);
```


*From: Scripts - PCB\TestPointMaker\TestPointMaker.pas*

```pascal
Board.AddPCBObject(NewTestPoint);
            Net.AddPCBObject(NewTestPoint);
            PCBServer.SendMessageToRobots(
               NewTestPoint.I_ObjectAddress,
```


---


### `GroupIterator_Destroy()`


**Observed signatures:**

```pascal
IPCB_Net.GroupIterator_Destroy(GrIter)
```

```pascal
IPCB_Net.GroupIterator_Destroy(Iterator)
```

**Examples:**


*From: Scripts - PCB\FixConnections\FixConnections.pas*

```pascal
Prim := GrIter.NextPCBObject;
           End;
           Net.GroupIterator_Destroy(GrIter);
        end;
```


*From: Scripts - PCB\FixConnections\FixConnections.pas*

```pascal
Prim := GrIter.NextPCBObject;
           End;
           Net.GroupIterator_Destroy(GrIter);
        end;
```


---


### `RemovePCBObject()`


**Observed signatures:**

```pascal
IPCB_Net.RemovePCBObject(Prim)
```

**Examples:**


*From: Scripts - PCB\UpdateNetOnClick\UpdateNetOnClick.pas*

```pascal
Prim.Net := Net
         else if (Net = nil) and Board.SelectecObject[i].InNet then
            Prim.Net.RemovePCBObject(Prim)
         else if (Net <> nil) and (Prim.ObjectId <> ePolyObject) then
            Net.AddPCBObject(Prim)
```


---


## Properties (3)


### `GroupIterator_Create`


---


### `I_ObjectAddress`


---


### `Name`


---



====================================================================================================


# IPCB_OBjectClass


**Category:** PCB


**API Surface:** 1 methods, 0 properties


---


## Methods (1)


### `IsMember()`


**Observed signatures:**

```pascal
IPCB_OBjectClass.IsMember(Net)
```

**Examples:**


*From: Scripts - PCB\ReturnViaCheck\ReturnViaCheck.pas*

```pascal
while Net <> nil do
    begin
        if NetClass.IsMember(Net) then NetList.Add(Net);
        Net := Iterator.NextPCBObject;
    end;
```


---



====================================================================================================


# IPCB_Pad


**Category:** PCB


**API Surface:** 10 methods, 45 properties


---


## Methods (10)


### `BoundingRectangleOnLayer()`


**Observed signatures:**

```pascal
IPCB_Pad.BoundingRectangleOnLayer(Comp.Layer)
```

```pascal
IPCB_Pad.BoundingRectangleOnLayer(ALayer)
```

**Examples:**


*From: Scripts - PCB\AssemblyTextPrep\AssemblyTextPrep.pas*

```pascal
if Pad = nil then exit;

    Result := Pad.BoundingRectangleOnLayer(ALayer);

    poly := PCBServer.PCBContourMaker.MakeContour(Pad, 0, ALayer);
```


*From: Scripts - PCB\AssemblyTextPrep\AssemblyTextPrep.pas*

```pascal
case Pad.ShapeOnLayer(Comp.Layer) of
                eRectangular: begin
                    PadBoundary := Pad.BoundingRectangleOnLayer(Comp.Layer);
                    if PadBoundary.Left < minX then minX := PadBoundary.Left;
                    if PadBoundary.Bottom < minY then minY := PadBoundary.Bottom;
```


---


### `GetState_StackCRPctOnLayer()`


**Observed signatures:**

```pascal
IPCB_Pad.GetState_StackCRPctOnLayer(eTopLayer)
```

**Examples:**


*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Cleanup_LPW_Footprint.pas*

```pascal
if ( (padDst.X = 0) and (padDst.Y = 0) ) then
      CLF_ReportCsvPropertyInt      ({name} constCsvRptFieldPadCornerRadTop, {valueFloat} padDst.GetState_StackCRPctOnLayer(eTopLayer), {var} line);

   { FIXME:  Support lots and lots of other pad properties!  Support thru-hole pads!! }
```


*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Cleanup_LPW_Footprint.pas*

```pascal
{ Set the EP corner radius percentage to the value just calculated. }
            WriteToDebugFile('Old EP CR Pct: ' + FloatToStr(padDst.GetState_StackCRPctOnLayer(eTopLayer)));
            padDst.SetState_StackCRPctOnLayer(eTopLayer, cornerRadiusPct);
            WriteToDebugFile('New EP CR Pct: ' + FloatToStr(padDst.GetState_StackCRPctOnLayer(eTopLayer)));
```


---


### `Replicate()`


**Examples:**


*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Cleanup_LPW_Footprint.pas*

```pascal
//      { Replicate the source pad and assign this to the destination pad. }
//      padDst := Nil;
//      padDst := padSrc.Replicate();
//      if (padDst = Nil) then
//         CLF_Abort('Pad replication failed!');
```


*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Cleanup_LPW_Footprint.pas*

```pascal
{ Replicate the queued pad and operate on that pad. }
         padNew := padDst.Replicate();

         { Add new object to PcbLib footprint. }
```


---


### `SetState_StackCRPctOnLayer()`


**Observed signatures:**

```pascal
IPCB_Pad.SetState_StackCRPctOnLayer(eTopLayer, cornerRadiusPct)
```

**Examples:**


*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Cleanup_LPW_Footprint.pas*

```pascal
{ Set the EP corner radius percentage to the value just calculated. }
            WriteToDebugFile('Old EP CR Pct: ' + FloatToStr(padDst.GetState_StackCRPctOnLayer(eTopLayer)));
            padDst.SetState_StackCRPctOnLayer(eTopLayer, cornerRadiusPct);
            WriteToDebugFile('New EP CR Pct: ' + FloatToStr(padDst.GetState_StackCRPctOnLayer(eTopLayer)));
```


---


### `SetState_StackShapeOnLayer()`


**Observed signatures:**

```pascal
IPCB_Pad.SetState_StackShapeOnLayer(eTopLayer, eRectangular)
```

```pascal
IPCB_Pad.SetState_StackShapeOnLayer(eTopLayer, eRoundedRectangular)
```

**Examples:**


*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Cleanup_LPW_Footprint.pas*

```pascal
WriteToDebugFile('padDst.ShapeOnLayer [' + IntToStr(eTopLayer) + ']: ' + IntToStr(padDst.ShapeOnLayer[eTopLayer]));
            WriteToDebugFile('Changing pads to rectangular');
            padDst.SetState_StackShapeOnLayer(eTopLayer, eRectangular);
            WriteToDebugFile('padDst.ShapeOnLayer [' + IntToStr(eTopLayer) + ']: ' + IntToStr(padDst.ShapeOnLayer[eTopLayer]));
```


*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Cleanup_LPW_Footprint.pas*

```pascal
{ Set the EP shape to Rounded Rectangular. }
            padDst.SetState_StackShapeOnLayer(eTopLayer, eRoundedRectangular);

            { Set the change pkgDimsEpCornerRadius into a percentage (because Altium measures EP radii in this way. }
```


---


### `ShapeOnLayer()`


**Observed signatures:**

```pascal
IPCB_Pad.ShapeOnLayer(Comp.Layer)
```

**Examples:**


*From: Scripts - PCB\AssemblyTextPrep\AssemblyTextPrep.pas*

```pascal
while (Pad <> nil) do
        begin
            case Pad.ShapeOnLayer(Comp.Layer) of
                eRectangular: begin
                    PadBoundary := Pad.BoundingRectangleOnLayer(Comp.Layer);
```


---


### `StackCRPctOnLayer()`


---


### `StackShapeOnLayer()`


**Observed signatures:**

```pascal
IPCB_Pad.StackShapeOnLayer(Layer)
```

**Examples:**


*From: Scripts - General\FormatCopy\FormatCopy.pas*

```pascal
end;

                if Pad.StackShapeOnLayer(Layer) = eRoundedRectangular then  //TShape
                begin
//                    DestinPrim.CRPercentageOnLayer      := Pad.CRPercentageOnLayer;
```


---


### `XStackSizeOnLayer()`


**Observed signatures:**

```pascal
IPCB_Pad.XStackSizeOnLayer(Layer)
```

**Examples:**


*From: Scripts - General\FormatCopy\FormatCopy.pas*

```pascal
if  Pad.Mode = ePadMode_ExternalStack then
                begin
                    DestinPrim.XStackSizeOnLayer(Layer) := Pad.XStackSizeOnLayer(Layer);
                    DestinPrim.YStackSizeOnLayer(Layer) := Pad.YStackSizeOnLayer(Layer);
                end;
```


---


### `YStackSizeOnLayer()`


**Observed signatures:**

```pascal
IPCB_Pad.YStackSizeOnLayer(Layer)
```

**Examples:**


*From: Scripts - General\FormatCopy\FormatCopy.pas*

```pascal
begin
                    DestinPrim.XStackSizeOnLayer(Layer) := Pad.XStackSizeOnLayer(Layer);
                    DestinPrim.YStackSizeOnLayer(Layer) := Pad.YStackSizeOnLayer(Layer);
                end;
```


---


## Properties (45)


### `BotShape`


**Common values:**

- `eRounded`

- `eRectangular`

- `PadSrc.BotShape`



**Example:**

```pascal
Pad.BotShape := eRectangular;
```

---


### `BotXSize`


**Common values:**

- `PadSrc.BotXSize`



**Example:**

```pascal
padDst.BotXSize          := PadSrc.BotXSize;
```

---


### `BotYSize`


**Common values:**

- `PadSrc.BotYSize`



**Example:**

```pascal
padDst.BotYSize          := PadSrc.BotYSize;
```

---


### `Cache`


**Common values:**

- `PadSrc.Cache`



**Example:**

```pascal
padDst.Cache             := PadSrc.Cache;
```

---


### `DefinitionLayerIterator`


---


### `DrillType`


**Common values:**

- `PadSrc.DrillType`



**Example:**

```pascal
padDst.DrillType         := PadSrc.DrillType;
```

---


### `GetState_Cache`


---


### `HoleRotation`


**Common values:**

- `PadSrc.HoleRotation`



**Example:**

```pascal
padDst.HoleRotation      := PadSrc.HoleRotation;
```

---


### `HoleSize`


**Common values:**

- `PadSrc.HoleSize`



**Example:**

```pascal
padDst.HoleSize          := PadSrc.HoleSize;
```

---


### `HoleType`


**Common values:**

- `PadSrc.HoleType`



**Example:**

```pascal
padDst.HoleType          := PadSrc.HoleType;
```

---


### `HoleWidth`


**Common values:**

- `PadSrc.HoleWidth`



**Example:**

```pascal
padDst.HoleWidth         := PadSrc.HoleWidth;
```

---


### `I_ObjectAddress`


---


### `Index`


**Common values:**

- `padGroupNum`



**Example:**

```pascal
padDst.Index := padGroupNum;
```

---


### `IsTenting`


---


### `IsTenting_Bottom`


---


### `IsTenting_Top`


---


### `Layer`


**Common values:**

- `padSrc.Layer`



**Example:**

```pascal
padDst.Layer                 := padSrc.Layer;
```

---


### `MidShape`


**Common values:**

- `eRounded`

- `eRectangular`

- `PadSrc.MidShape`



**Example:**

```pascal
Pad.MidShape := eRectangular;
```

---


### `MidXSize`


**Common values:**

- `PadSrc.MidXSize`



**Example:**

```pascal
padDst.MidXSize          := PadSrc.MidXSize;
```

---


### `MidYSize`


**Common values:**

- `PadSrc.MidYSize`



**Example:**

```pascal
padDst.MidYSize          := PadSrc.MidYSize;
```

---


### `Mode`


**Common values:**

- `PadSrc.Mode`



**Example:**

```pascal
padDst.Mode              := PadSrc.Mode;
```

---


### `Moveable`


**Common values:**

- `Not(Lock)`



**Example:**

```pascal
Pad.Moveable := Not(Lock);
```

---


### `Name`


**Common values:**

- `constNewNameOfEp`

- `PadSrc.Name`

- `newPinName2`



**Example:**

```pascal
Pad.Name := Pad.Name + 'COUNT' + IntToStr(j);
```

---


### `Net`


---


### `ObjectId`


---


### `OwnerPart_ID`


**Common values:**

- `PadSrc.OwnerPart_ID`



**Example:**

```pascal
padDst.OwnerPart_ID      := PadSrc.OwnerPart_ID;
```

---


### `PasteMaskExpansion`


---


### `Plated`


**Common values:**

- `PadSrc.Plated`



**Example:**

```pascal
padDst.Plated            := PadSrc.Plated;
```

---


### `Rotation`


**Common values:**

- `PadSrc.Rotation`

- `0`



**Example:**

```pascal
padDst.Rotation          := PadSrc.Rotation;
```

---


### `SetState_Cache`


**Common values:**

- `padCache`



**Example:**

```pascal
pad.SetState_Cache                 := padCache;
```

---


### `ShapeOnLayer`


---


### `StackCRPctOnLayer`


---


### `StackShapeOnLayer`


---


### `TemplateLink`


---


### `TopShape`


**Common values:**

- `eRounded`

- `eRectangular`

- `PadSrc.TopShape`



**Example:**

```pascal
Pad.TopShape := eRectangular;
```

---


### `TopXSize`


**Common values:**

- `MMsToCoord(X1size)`

- `PadSrc.TopXSize`

- `Abs(rectDst.right - rectDst.left)`



**Example:**

```pascal
padDst.TopXSize          := PadSrc.TopXSize;
```

---


### `TopYSize`


**Common values:**

- `Abs(rectDst.top - rectDst.bottom)`

- `padB.TopYSize - (padBcornerDifferenceY / 2.0)`

- `MMsToCoord(epLengthRounded)`



**Example:**

```pascal
padDst.TopYSize          := PadSrc.TopYSize;
```

---


### `X`


**Common values:**

- `regionXcoord`

- `MMsToCoord(X2center)`

- `padA.X + (padAcornerDifferenceX / 4.0)`



**Example:**

```pascal
padDst.X                 := (padSrc.X - boardXorigin);
```

---


### `XPadOffset`


---


### `XStackSizeOnLayer`


---


### `Y`


**Common values:**

- `(padSrc.Y - boardYorigin)`

- `padB.Y - (padBcornerDifferenceY / 4.0)`

- `MMsToCoord(Y2center)`



**Example:**

```pascal
padDst.Y                 := (padSrc.Y - boardYorigin);
```

---


### `YPadOffset`


---


### `YStackSizeOnLayer`


---


### `x`


---


### `y`


---



====================================================================================================


# IPCB_Pad2


**Category:** PCB


**API Surface:** 2 methods, 36 properties


---


## Methods (2)


### `BoundingRectangleOnLayer()`


**Observed signatures:**

```pascal
IPCB_Pad2.BoundingRectangleOnLayer(LayerObj.LayerID)
```

```pascal
IPCB_Pad2.BoundingRectangleOnLayer(Pad.Layer_V6)
```

**Examples:**


*From: Scripts - PCB\IsPadCenterConnected\IsPadCenterConnected.pas*

```pascal
if ILayer.IsSignalLayer(LayerObj.V7_LayerID) then
                     begin
                        Rectangle := Pad.BoundingRectangleOnLayer(LayerObj.LayerID);

                        TrackIteratorHandle        := Board.SpatialIterator_Create;
```


*From: Scripts - PCB\IsPadCenterConnected\IsPadCenterConnected.pas*

```pascal
begin
                  Pad.Selected               := True;
                  Rectangle := Pad.BoundingRectangleOnLayer(Pad.Layer_V6);
                  TrackIteratorHandle        := Board.SpatialIterator_Create;
                  TrackIteratorHandle.AddFilter_ObjectSet(MkSet(eTrackObject));
```


---


### `PlaneConnectionStyleForLayer()`


**Observed signatures:**

```pascal
IPCB_Pad2.PlaneConnectionStyleForLayer(Split.Layer)
```

**Examples:**


*From: Scripts - Outputs\Hyperlynx Exporter\Hyperlynx_Exporter.pas*

```pascal
// holes can be slotted and rectangular, and can have rotation

                if Pad.PlaneConnectionStyleForLayer(Split.Layer) = ePlaneReliefConnect then
                begin
                   if Pad.HoleType = eRoundHole then
```


*From: Scripts - Outputs\Hyperlynx Exporter\Hyperlynx_Exporter.pas*

```pascal
// Direct
                if Pad.PlaneConnectionStyleForLayer(Split.Layer) = ePlaneDirectConnect then
                begin
                      // This Pad directly connected to this plane
```


---


## Properties (36)


### `BeginModify`


---


### `BoundingRectangle`


---


### `CRPercentage`


---


### `EndModify`


---


### `HoleRotation`


---


### `HoleSize`


**Common values:**

- `MilsToCoord(StrToFloat(EditHoleSize.Text))`

- `0`

- `MMsToCoord(StrToFloat(EditHoleSize.Text))`



**Example:**

```pascal
TestPoint.HoleSize  := 0;
```

---


### `HoleType`


---


### `HoleWidth`


---


### `I_ObjectAddress`


---


### `InNet`


---


### `Innet`


---


### `IsAssyTestpoint_Bottom`


**Common values:**

- `CheckBoxAssyBottom.Checked`



**Example:**

```pascal
NewTestPoint.IsAssyTestpoint_Bottom := CheckBoxAssyBottom.Checked;
```

---


### `IsAssyTestpoint_Top`


**Common values:**

- `CheckBoxAssyTop.Checked`



**Example:**

```pascal
NewTestPoint.IsAssyTestpoint_Top    := CheckBoxAssyTop.Checked;
```

---


### `IsTestpoint_Bottom`


**Common values:**

- `CheckBoxFabBottom.Checked`



**Example:**

```pascal
NewTestPoint.IsTestpoint_Bottom     := CheckBoxFabBottom.Checked;
```

---


### `IsTestpoint_Top`


**Common values:**

- `CheckBoxFabTop.Checked`



**Example:**

```pascal
NewTestPoint.IsTestpoint_Top        := CheckBoxFabTop.Checked;
```

---


### `Layer`


**Common values:**

- `eTopLayer`

- `eMultiLayer`



**Example:**

```pascal
TestPoint.Layer := eTopLayer
```

---


### `Layer_V6`


---


### `Mode`


**Common values:**

- `ePadMode_Simple`



**Example:**

```pascal
TestPoint.Mode := ePadMode_Simple;
```

---


### `Moveable`


**Common values:**

- `True`



**Example:**

```pascal
NewTestPoint.Moveable := True;
```

---


### `Name`


**Common values:**

- `DesignatorOld`

- `DesignatorNew`

- `'TestPoint'`



**Example:**

```pascal
TestPoint.Name      := 'TestPoint';
```

---


### `Net`


**Common values:**

- `Net`



**Example:**

```pascal
NewTestPoint.Net := Net;
```

---


### `PowerPlaneClearance`


---


### `PowerPlaneReliefExpansion`


---


### `ReliefAirGap`


---


### `ReliefConductorWidth`


---


### `ReliefEntries`


---


### `Replicate`


---


### `Rotation`


---


### `Selected`


**Common values:**

- `True`

- `False`



**Example:**

```pascal
Pad.Selected := False;
```

---


### `TopShape`


**Common values:**

- `eRounded`



**Example:**

```pascal
TestPoint.TopShape  := eRounded;
```

---


### `TopXSize`


**Common values:**

- `MilsToCoord(StrToFloat(EditSize.Text))`

- `MMsToCoord(StrToFloat(EditSize.Text))`



**Example:**

```pascal
if RadioButtonMM.Checked then TestPoint.TopXSize := MMsToCoord(StrToFloat(EditSize.Text))
```

---


### `TopYSize`


**Common values:**

- `MilsToCoord(StrToFloat(EditSize.Text))`

- `MMsToCoord(StrToFloat(EditSize.Text))`



**Example:**

```pascal
if RadioButtonMM.Checked then TestPoint.TopYSize := MMsToCoord(StrToFloat(EditSize.Text))
```

---


### `X`


**Common values:**

- `PosX`



**Example:**

```pascal
TestPoint.X    := PosX;
```

---


### `Y`


**Common values:**

- `PosY`



**Example:**

```pascal
TestPoint.Y    := PosY;
```

---


### `x`


**Common values:**

- `PosX`



**Example:**

```pascal
NewTestPoint.x := PosX;
```

---


### `y`


**Common values:**

- `PosY`



**Example:**

```pascal
NewTestPoint.y := PosY;
```

---



====================================================================================================


# IPCB_PasteMaskExpansionRule


**Category:** PCB


**API Surface:** 0 methods, 5 properties


---


## Properties (5)


### `Comment`


**Common values:**

- `'Disable paste'`



**Example:**

```pascal
RulePaste.Comment := 'Disable paste';
```

---


### `DRCEnabled`


**Common values:**

- `false`



**Example:**

```pascal
RulePaste.DRCEnabled := false;
```

---


### `Expansion`


**Common values:**

- `MMsToCoord(-2539)`



**Example:**

```pascal
RulePaste.Expansion := MMsToCoord(-2539);
```

---


### `Name`


**Common values:**

- `'Disable paste :' +Variant.DM_Description`



**Example:**

```pascal
RulePaste.Name := 'Disable paste :' +Variant.DM_Description;
```

---


### `Scope1Expression`


**Common values:**

- `filter`



**Example:**

```pascal
RulePaste.Scope1Expression := filter;
```

---



====================================================================================================


# IPCB_Polygon


**Category:** PCB


**API Surface:** 2 methods, 16 properties


---


## Methods (2)


### `GroupIterator_Destroy()`


**Observed signatures:**

```pascal
IPCB_Polygon.GroupIterator_Destroy(Iter)
```

```pascal
IPCB_Polygon.GroupIterator_Destroy(RegionIter)
```

```pascal
IPCB_Polygon.GroupIterator_Destroy(PolyIterator)
```

**Examples:**


*From: Scripts - PCB\CalculatePolyRegionArea\CalculatePolyRegionArea.pas*

```pascal
Region := Iter.NextPCBObject;
      end;
      Poly.GroupIterator_Destroy(Iter);

      ShowArea(Poly.AreaSize,CopperArea);
```


*From: Scripts - PCB\PCBScale\PCBscale.pas*

```pascal
Prim := Iter.NextPCBObject;
    end;
    Polygon.GroupIterator_Destroy(Iter);
    Polygon.GraphicallyInvalidate;
end;
```


---


### `SetState_Segments()`


**Observed signatures:**

```pascal
IPCB_Polygon.SetState_Segments(i, PolySeg)
```

```pascal
IPCB_Polygon.SetState_Segments(I1, PolySeg)
```

**Examples:**


*From: Scripts - PCB\RoundPolygonCorners\RoundPolygonCorners.pas*

```pascal
PolySeg.cx := ncx;
        PolySeg.cy := ncy;
        Polygon.SetState_Segments(i, PolySeg);

        nvx := Polygon.Segments[I1].vx;
```


*From: Scripts - PCB\RoundPolygonCorners\RoundPolygonCorners.pas*

```pascal
PolySeg.vx := nvx;
        PolySeg.vy := nvy;
        Polygon.SetState_Segments(I1, PolySeg);
      end;
      if (A1 = 0) and (A2 = 90) and (cp > 0) then
```


---


## Properties (16)


### `AreaSize`


---


### `BeginModify`


---


### `EndModify`


---


### `GraphicallyInvalidate`


---


### `GroupIterator_Create`


---


### `I_ObjectAddress`


---


### `Layer`


---


### `Name`


---


### `Net`


---


### `PointCount`


**Common values:**

- `Polygon.PointCount + 1`

- `Polygon.PointCount - 1`



**Example:**

```pascal
Polygon.PointCount := Polygon.PointCount + 1;
```

---


### `PolyHatchStyle`


---


### `PourIndex`


---


### `Poured`


---


### `Rebuild`


---


### `Segments`


---


### `Selected`


---



====================================================================================================


# IPCB_PolygonConnectStyleRule


**Category:** PCB


**API Surface:** 0 methods, 5 properties


---


## Properties (5)


### `Comment`


**Common values:**

- `'Polygon connect style rule for Stitching Vias'`



**Example:**

```pascal
RulePolyConn.Comment := 'Polygon connect style rule for Stitching Vias';
```

---


### `ConnectStyle`


**Common values:**

- `eDirectConnectToPlane`



**Example:**

```pascal
RulePolyConn.ConnectStyle := eDirectConnectToPlane;
```

---


### `Name`


**Common values:**

- `'StitchingVias-Poly'`



**Example:**

```pascal
RulePolyConn.Name    := 'StitchingVias-Poly';
```

---


### `NetScope`


**Common values:**

- `eNetScope_AnyNet`



**Example:**

```pascal
RulePolyConn.NetScope  := eNetScope_AnyNet;
```

---


### `Scope1Expression`


**Common values:**

- `'InComponent(''StitchingVias'')'`



**Example:**

```pascal
RulePolyConn.Scope1Expression := 'InComponent(''StitchingVias'')';
```

---



====================================================================================================


# IPCB_PowerPlaneConnectStyleRule


**Category:** PCB


**API Surface:** 0 methods, 5 properties


---


## Properties (5)


### `Comment`


**Common values:**

- `'Power plane connect style rule for Stitching Vias'`



**Example:**

```pascal
RulePlaneConn.Comment := 'Power plane connect style rule for Stitching Vias';
```

---


### `Name`


**Common values:**

- `'StitchingVias-Plane'`



**Example:**

```pascal
RulePlaneConn.Name    := 'StitchingVias-Plane';
```

---


### `NetScope`


**Common values:**

- `eNetScope_AnyNet`



**Example:**

```pascal
RulePlaneConn.NetScope  := eNetScope_AnyNet;
```

---


### `PlaneConnectStyle`


**Common values:**

- `eDirectConnectToPlane`



**Example:**

```pascal
RulePlaneConn.PlaneConnectStyle := eDirectConnectToPlane;
```

---


### `Scope1Expression`


**Common values:**

- `'InComponent(''StitchingVias'')'`



**Example:**

```pascal
RulePlaneConn.Scope1Expression := 'InComponent(''StitchingVias'')';
```

---



====================================================================================================


# IPCB_Prim


**Category:** PCB


**API Surface:** 0 methods, 14 properties


---


## Properties (14)


### `EndAngle`


---


### `EndX`


---


### `EndY`


---


### `IsFreePrimitive`


---


### `ObjectID`


---


### `Selected`


---


### `StartAngle`


---


### `StartX`


---


### `StartY`


---


### `TearDrop`


---


### `x1`


---


### `x2`


---


### `y1`


---


### `y2`


---



====================================================================================================


# IPCB_Primitive


**Category:** PCB


**API Surface:** 25 methods, 216 properties


---


## Methods (25)


### `GetState_IsConnectedToPlane()`


**Observed signatures:**

```pascal
IPCB_Primitive.GetState_IsConnectedToPlane(Layer)
```

**Examples:**


*From: Scripts - PCB\PCBObjectInspector\PCBObjectInspector.pas*

```pascal
{TempString := Format('HitPrimitive: %s; PrimitiveInsidePoly: %s; StrictHitTest: %s', [BoolToStr(SplitPlane.GetState_HitPrimitive(PVPrim), True), BoolToStr(SplitPlane.PrimitiveInsidePoly(PVPrim), True), BoolToStr(SplitPlane.GetState_StrictHitTest(PVPrim.x, PVPrim.y), True)]);
                TempString := TempString + sLineBreak + Format('PowerPlaneConnectStyle <> eNoConnect: %s', [BoolToStr(PVPrim.PowerPlaneConnectStyle <> eNoConnect, True)]);
                TempString := TempString + sLineBreak + Format('GetState_IsConnectedToPlane(%s): %s', [Layer2String(Layer), BoolToStr(PVPrim.GetState_IsConnectedToPlane(Layer), True)]);
                TempString := TempString + sLineBreak + Format('SplitPlaneRegion PrimPrimDistance: %s', [RoundCoordStr(Board.PrimPrimDistance(SplitPlaneRegion, PVPrim))]);
                Inspect_IPCB_Region(SplitPlaneRegion, TempString);}
```


*From: Scripts - PCB\PCBObjectInspector\PCBObjectInspector.pas*

```pascal
//end;

                if SplitPlane.GetState_HitPrimitive(PVPrim) and (PVPrim.PowerPlaneConnectStyle <> eNoConnect) and PVPrim.GetState_IsConnectedToPlane(Layer) then
                begin
                    bConnected := True;
```


---


### `GetState_IsTenting_Bottom()`


**Examples:**


*From: Scripts - PCB\TentingVias\TentingVias.pas*

```pascal
Inc(TopTenting);

            If Via.GetState_IsTenting_Bottom() Then
               Inc(BotTenting);
        End;
```


---


### `GetState_IsTenting_Top()`


**Examples:**


*From: Scripts - PCB\TentingVias\TentingVias.pas*

```pascal
Inc(ViaSelected);

            If Via.GetState_IsTenting_Top() Then
               Inc(TopTenting);
```


---


### `GroupIterator_Destroy()`


**Observed signatures:**

```pascal
IPCB_Primitive.GroupIterator_Destroy(Iter)
```

**Examples:**


*From: Scripts - PCB\ConnectionLinesOnSelection\ConnectonLinesOnSelection.pas*

```pascal
Pad := Iter.NextPCBObject;
          end;
          Prim.GroupIterator_Destroy(Iter);
       end;
    end;
```


*From: Scripts - PCB\ConnectionLinesOnSelection\ConnectonLinesOnSelection.pas*

```pascal
Pad := Iter.NextPCBObject;
          end;
          Prim.GroupIterator_Destroy(Iter);
       end;
    end;
```


---


### `IntersectLayer()`


**Observed signatures:**

```pascal
IPCB_Primitive.IntersectLayer(Layer)
```

```pascal
IPCB_Primitive.IntersectLayer(Prim1.Layer)
```

**Examples:**


*From: Scripts - PCB\FixConnections\FixConnections.pas*

```pascal
begin

      if ((Prim2.ObjectId = ePadObject) or ((Prim2.ObjectId = eViaObject) and Prim2.IntersectLayer(Prim1.Layer))) and
         (Prim2.InNet) and (Prim2.Net.Name = Prim1.Net.Name) and (Board.PrimPrimDistance(Prim1,Prim2) = 0) then
      begin
```


*From: Scripts - PCB\FixConnections\FixConnections.pas*

```pascal
else if Prim2.ObjectId = eViaObject then
         begin
            if Prim2.IntersectLayer(Prim1.Layer) and (PointToPointDistance(Prim2.x, Prim2.y, X, Y) < Tolerance) then
            begin
               Board.SpatialIterator_Destroy(SIter);
```


---


### `IsPadRemoved()`


**Observed signatures:**

```pascal
IPCB_Primitive.IsPadRemoved(Layer)
```

**Examples:**


*From: Scripts - PCB\PCBObjectInspector\PCBObjectInspector.pas*

```pascal
begin // arcs, tracks, fills, or standalone regions touching PVPrim
                case PVPrim.ObjectId of
                    ePadObject: if (PVPrim.Layer = Layer) or ((PVPrim.Layer = eMultiLayer) and (PVPrim.StackShapeOnLayer(Layer) <> eNoShape) and (not PVPrim.IsPadRemoved(Layer))) then bConnected := True;
                    eViaObject: if (ViaSizeOnLayer > PVPrim.HoleSize) then bConnected := True;
                end;
```


*From: Scripts - PCB\PCBObjectInspector\PCBObjectInspector.pas*

```pascal
begin // pads with a pad shape on the given layer touching PVPrim
                case PVPrim.ObjectId of
                    ePadObject: if (PVPrim.Layer = Layer) or ((PVPrim.Layer = eMultiLayer) and (PVPrim.StackShapeOnLayer(Layer) <> eNoShape) and (not PVPrim.IsPadRemoved(Layer))) then bConnected := True;
                    eViaObject: if (ViaSizeOnLayer > PVPrim.HoleSize) then bConnected := True;
                end;
```


---


### `IsSaveable()`


**Observed signatures:**

```pascal
IPCB_Primitive.IsSaveable(eAdvPCBFormat_Binary_V6)
```

**Examples:**


*From: Scripts - PCB\SelectAssyDesignators\SelectAssyDesignators.pas*

```pascal
Format('%s : %s', ['Handle',  Text.Handle]) + sLineBreak +
                Format('%s : %s', ['Identifier',  Text.Identifier]) + sLineBreak +
                Format('%s : %s', ['IsSaveable',  BoolToStr(Text.IsSaveable(eAdvPCBFormat_Binary_V6), True)]) + sLineBreak +
                Format('%s : %s', ['MiscFlag1',  BoolToStr(Text.MiscFlag1, True)]) + sLineBreak +
                Format('%s : %s', ['MiscFlag2',  BoolToStr(Text.MiscFlag2, True)]) + sLineBreak +
```


---


### `ModelFactory_UpdateModel()`


---


### `MoveByXY()`


**Observed signatures:**

```pascal
IPCB_Primitive.MoveByXY(PcbPosX - Rectangle.Left, PcbPosY - Rectangle.Bottom)
```

**Examples:**


*From: Scripts - General\DesignReuse\DesignReuse.pas*

```pascal
PcbObj.BeginModify;
            PcbObj.MoveByXY(PcbPosX - Rectangle.Left, PcbPosY - Rectangle.Bottom);
            PcbObj.Selected := True;
            PcbObj.EndModify;
```


---


### `RotateBy()`


**Observed signatures:**

```pascal
IPCB_Primitive.RotateBy(Rotation.Text)
```

**Examples:**


*From: Scripts - Examples\AddText\AddText.pas*

```pascal
end;

        Text.RotateBy(Rotation.Text);// Set the rotation of text

        Text.Text := TToAdd;// Set the text of the primitive
```


---


### `SetOutlineContour()`


---


### `SetState_IsTenting_Bottom()`


**Observed signatures:**

```pascal
IPCB_Primitive.SetState_IsTenting_Bottom(True)
```

```pascal
IPCB_Primitive.SetState_IsTenting_Bottom(chkBottom.Checked)
```

```pascal
IPCB_Primitive.SetState_IsTenting_Bottom(False)
```

**Examples:**


*From: Scripts - PCB\TentingVias\TentingVias.pas*

```pascal
//                Via.Setstate_PadCacheRobotFlag(true);
                Via.SetState_IsTenting_Top(chkTop.Checked);
                Via.SetState_IsTenting_Bottom(chkBottom.Checked);
                Via.EndModify;
            End;
```


*From: Scripts - PCB\ViaSoldermaskBarrelRelief\ViaSoldermaskBarrelRelief.pas*

```pascal
// Remove Complete Tenting from Both Sides for Barrel Relief
               Via.SetState_IsTenting_Top(False);
               Via.SetState_IsTenting_Bottom(False);

               Inc(ViaNumber);
```


---


### `SetState_IsTenting_Top()`


**Observed signatures:**

```pascal
IPCB_Primitive.SetState_IsTenting_Top(False)
```

```pascal
IPCB_Primitive.SetState_IsTenting_Top(True)
```

```pascal
IPCB_Primitive.SetState_IsTenting_Top(chkTop.Checked)
```

**Examples:**


*From: Scripts - PCB\TentingVias\TentingVias.pas*

```pascal
Via.SetState_Cache := PadCache;
//                Via.Setstate_PadCacheRobotFlag(true);
                Via.SetState_IsTenting_Top(chkTop.Checked);
                Via.SetState_IsTenting_Bottom(chkBottom.Checked);
                Via.EndModify;
```


*From: Scripts - PCB\ViaSoldermaskBarrelRelief\ViaSoldermaskBarrelRelief.pas*

```pascal
// Remove Complete Tenting from Both Sides for Barrel Relief
               Via.SetState_IsTenting_Top(False);
               Via.SetState_IsTenting_Bottom(False);
```


---


### `SetState_KeepoutRestrictions()`


**Observed signatures:**

```pascal
IPCB_Primitive.SetState_KeepoutRestrictions(KORS)
```

**Examples:**


*From: Scripts - General\FormatCopy\FormatCopy.pas*

```pascal
begin
        KORS := SourcePrim.GetState_KeepoutRestrictions;
        DestinPrim.SetState_KeepoutRestrictions(KORS);
    end;
```


---


### `SetState_Kind()`


**Observed signatures:**

```pascal
IPCB_Primitive.SetState_Kind(SourcePrim.Kind)
```

**Examples:**


*From: Scripts - General\FormatCopy\FormatCopy.pas*

```pascal
if boolLoc = mrYes then
                DestinPrim.Layer            := SourcePrim.Layer;
            DestinPrim.SetState_Kind (SourcePrim.Kind);
        //    DestinPrim.IsSimpleRegion       := SourcePrim.IsSimpleRegion;
            DestinPrim.IsKeepout            := SourcePrim.IsKeepout;
```


---


### `SetState_Selected()`


**Observed signatures:**

```pascal
IPCB_Primitive.SetState_Selected(false)
```

```pascal
IPCB_Primitive.SetState_Selected(True)
```

```pascal
IPCB_Primitive.SetState_Selected(False)
```

**Examples:**


*From: Scripts - PCB\Fillet\Fillet.pas*

```pascal
Prim := Board.SelectecObject(i);
        if (Prim.ObjectId = eTrackObject) or (Prim.ObjectId = eArcObject) then i := i + 1
        else Prim.SetState_Selected(false);
    end;
```


*From: Scripts - PCB\QuickSilk\QuickSilk.pas*

```pascal
begin
            Prim1 := Board.SelectecObject[i];
            if not ((Prim1.ObjectId = eComponentObject) or ((Prim1.ObjectId = eTextObject) and (Prim1.IsDesignator))) then Prim1.SetState_Selected(False)
            else i := i + 1; // advance iterator if current object remains selected
        end;
```


---


### `SetState_StackShapeOnLayer()`


**Observed signatures:**

```pascal
IPCB_Primitive.SetState_StackShapeOnLayer(Layer, Via.StackShapeOnLayer(Layer)
```

```pascal
IPCB_Primitive.SetState_StackShapeOnLayer(Layer, Pad.StackShapeOnLayer(Layer)
```

**Examples:**


*From: Scripts - General\FormatCopy\FormatCopy.pas*

```pascal
//                if DestinPrim.StackShapeOnLayer(Layer) = eNoShape then continue;

                DestinPrim.SetState_StackShapeOnLayer(Layer, Pad.StackShapeOnLayer(Layer) );
                if  Pad.Mode = ePadMode_ExternalStack then
                begin
```


*From: Scripts - General\FormatCopy\FormatCopy.pas*

```pascal
if DestinPrim.IntersectLayer(Layer) then
                begin
                    DestinPrim.SetState_StackShapeOnLayer(Layer, Via.StackShapeOnLayer(Layer) );
                    DestinPrim.SizeOnLayer(Layer) := Via.SizeOnLayer(Layer);
                    DestinPrim.Setstate_StackSizeOnLayer(Layer, Via.StackSizeOnLayer(Layer) );
```


---


### `Setstate_StackCRPctOnLayer()`


**Observed signatures:**

```pascal
IPCB_Primitive.Setstate_StackCRPctOnLayer(Layer, Pad.StackCRPctOnLayer(Layer)
```

**Examples:**


*From: Scripts - General\FormatCopy\FormatCopy.pas*

```pascal
begin
//                    DestinPrim.CRPercentageOnLayer      := Pad.CRPercentageOnLayer;
                    DestinPrim.Setstate_StackCRPctOnLayer(Layer, Pad.StackCRPctOnLayer(Layer) );
                end;
```


---


### `Setstate_StackSizeOnLayer()`


**Observed signatures:**

```pascal
IPCB_Primitive.Setstate_StackSizeOnLayer(Layer, Via.StackSizeOnLayer(Layer)
```

**Examples:**


*From: Scripts - General\FormatCopy\FormatCopy.pas*

```pascal
DestinPrim.SetState_StackShapeOnLayer(Layer, Via.StackShapeOnLayer(Layer) );
                    DestinPrim.SizeOnLayer(Layer) := Via.SizeOnLayer(Layer);
                    DestinPrim.Setstate_StackSizeOnLayer(Layer, Via.StackSizeOnLayer(Layer) );
                end;
            end;
```


---


### `ShapeOnLayer()`


**Observed signatures:**

```pascal
IPCB_Primitive.ShapeOnLayer(Layer)
```

**Examples:**


*From: Scripts - PCB\PCBObjectInspector\PCBObjectInspector.pas*

```pascal
if bConnected then break;
            end
            else if (SpatialPrim.ObjectId = ePadObject) and (SpatialPrim.InNet) and (SpatialPrim.ShapeOnLayer(Layer) <> eNoShape) and (Board.PrimPrimDistance(SpatialPrim, PVPrim) = 0) then
            begin // pads with a pad shape on the given layer touching PVPrim
                case PVPrim.ObjectId of
```


*From: Scripts - PCB\ReturnViaCheck\ReturnViaCheck.pas*

```pascal
if bConnected then break;
            end
            else if (SpatialPrim.ObjectId = ePadObject) and (SpatialPrim.InNet) and (SpatialPrim.ShapeOnLayer(Layer) <> eNoShape) and (Board.PrimPrimDistance(SpatialPrim, PVPrim) = 0) then
            begin // pads with a pad shape on the given layer touching PVPrim
                case PVPrim.ObjectId of
```


---


### `SizeOnLayer()`


**Observed signatures:**

```pascal
IPCB_Primitive.SizeOnLayer(Layer)
```

**Examples:**


*From: Scripts - General\FormatCopy\FormatCopy.pas*

```pascal
begin
                    DestinPrim.SetState_StackShapeOnLayer(Layer, Via.StackShapeOnLayer(Layer) );
                    DestinPrim.SizeOnLayer(Layer) := Via.SizeOnLayer(Layer);
                    DestinPrim.Setstate_StackSizeOnLayer(Layer, Via.StackSizeOnLayer(Layer) );
                end;
```


---


### `StackShapeOnLayer()`


**Observed signatures:**

```pascal
IPCB_Primitive.StackShapeOnLayer(Layer)
```

**Examples:**


*From: Scripts - PCB\PCBObjectInspector\PCBObjectInspector.pas*

```pascal
begin // arcs, tracks, fills, or standalone regions touching PVPrim
                case PVPrim.ObjectId of
                    ePadObject: if (PVPrim.Layer = Layer) or ((PVPrim.Layer = eMultiLayer) and (PVPrim.StackShapeOnLayer(Layer) <> eNoShape) and (not PVPrim.IsPadRemoved(Layer))) then bConnected := True;
                    eViaObject: if (ViaSizeOnLayer > PVPrim.HoleSize) then bConnected := True;
                end;
```


*From: Scripts - PCB\PCBObjectInspector\PCBObjectInspector.pas*

```pascal
begin // pads with a pad shape on the given layer touching PVPrim
                case PVPrim.ObjectId of
                    ePadObject: if (PVPrim.Layer = Layer) or ((PVPrim.Layer = eMultiLayer) and (PVPrim.StackShapeOnLayer(Layer) <> eNoShape) and (not PVPrim.IsPadRemoved(Layer))) then bConnected := True;
                    eViaObject: if (ViaSizeOnLayer > PVPrim.HoleSize) then bConnected := True;
                end;
```


---


### `StackSizeOnLayer()`


---


### `XStackSizeOnLayer()`


**Observed signatures:**

```pascal
IPCB_Primitive.XStackSizeOnLayer(Layer)
```

**Examples:**


*From: Scripts - General\FormatCopy\FormatCopy.pas*

```pascal
if  Pad.Mode = ePadMode_ExternalStack then
                begin
                    DestinPrim.XStackSizeOnLayer(Layer) := Pad.XStackSizeOnLayer(Layer);
                    DestinPrim.YStackSizeOnLayer(Layer) := Pad.YStackSizeOnLayer(Layer);
                end;
```


---


### `YStackSizeOnLayer()`


**Observed signatures:**

```pascal
IPCB_Primitive.YStackSizeOnLayer(Layer)
```

**Examples:**


*From: Scripts - General\FormatCopy\FormatCopy.pas*

```pascal
begin
                    DestinPrim.XStackSizeOnLayer(Layer) := Pad.XStackSizeOnLayer(Layer);
                    DestinPrim.YStackSizeOnLayer(Layer) := Pad.YStackSizeOnLayer(Layer);
                end;
```


---


## Properties (216)


### `AdvanceSnapping`


**Common values:**

- `True`



**Example:**

```pascal
Text.AdvanceSnapping := True;   // necessary for autoposition to work correctly (thanks, Brett Miller!)
```

---


### `AllowGlobalEdit`


---


### `ArcApproximation`


**Common values:**

- `SourcePrim.ArcApproximation`



**Example:**

```pascal
DestinPrim.ArcApproximation     := SourcePrim.ArcApproximation;
```

---


### `Area`


---


### `ArrowLength`


**Common values:**

- `SourcePrim.ArrowLength`



**Example:**

```pascal
DestinPrim.ArrowLength         := SourcePrim.ArrowLength;
```

---


### `ArrowLineWidth`


**Common values:**

- `SourcePrim.ArrowLineWidth`



**Example:**

```pascal
DestinPrim.ArrowLineWidth      := SourcePrim.ArrowLineWidth;
```

---


### `ArrowPosition`


**Common values:**

- `SourcePrim.ArrowPosition`



**Example:**

```pascal
DestinPrim.ArrowPosition       := SourcePrim.ArrowPosition;
```

---


### `ArrowSize`


**Common values:**

- `SourcePrim.ArrowSize`



**Example:**

```pascal
DestinPrim.ArrowSize           := SourcePrim.ArrowSize;
```

---


### `AvoidObsticles`


**Common values:**

- `SourcePrim.AvoidObsticles`



**Example:**

```pascal
DestinPrim.AvoidObsticles       := SourcePrim.AvoidObsticles;
```

---


### `BarCodeFontName`


**Common values:**

- `SourcePrim.BarCodeFontName`



**Example:**

```pascal
DestinPrim.BarCodeFontName      := SourcePrim.BarCodeFontName;
```

---


### `BarCodeFullHeight`


**Common values:**

- `SourcePrim.BarCodeFullHeight`



**Example:**

```pascal
DestinPrim.BarCodeFullHeight    := SourcePrim.BarCodeFullHeight;
```

---


### `BarCodeFullWidth`


**Common values:**

- `SourcePrim.BarCodeFullWidth`



**Example:**

```pascal
DestinPrim.BarCodeFullWidth     := SourcePrim.BarCodeFullWidth;
```

---


### `BarCodeInverted`


**Common values:**

- `SourcePrim.BarCodeInverted`



**Example:**

```pascal
DestinPrim.BarCodeInverted      := SourcePrim.BarCodeInverted;
```

---


### `BarCodeKind`


**Common values:**

- `SourcePrim.BarCodeKind`



**Example:**

```pascal
DestinPrim.BarCodeKind          := SourcePrim.BarCodeKind;
```

---


### `BarCodeMinWidth`


**Common values:**

- `SourcePrim.BarCodeMinWidth`



**Example:**

```pascal
DestinPrim.BarCodeMinWidth      := SourcePrim.BarCodeMinWidth;
```

---


### `BarCodeRenderMode`


**Common values:**

- `SourcePrim.BarCodeRenderMode`



**Example:**

```pascal
DestinPrim.BarCodeRenderMode    := SourcePrim.BarCodeRenderMode;
```

---


### `BarCodeShowText`


**Common values:**

- `SourcePrim.BarCodeShowText`



**Example:**

```pascal
DestinPrim.BarCodeShowText      := SourcePrim.BarCodeShowText;
```

---


### `BarCodeXMargin`


**Common values:**

- `SourcePrim.BarCodeXMargin`



**Example:**

```pascal
DestinPrim.BarCodeXMargin       := SourcePrim.BarCodeXMargin;
```

---


### `BarCodeYMargin`


**Common values:**

- `SourcePrim.BarCodeYMargin`



**Example:**

```pascal
DestinPrim.BarCodeYMargin       := SourcePrim.BarCodeYMargin;
```

---


### `BeginModify`


---


### `Board`


---


### `Bold`


**Common values:**

- `SourcePrim.Bold`



**Example:**

```pascal
DestinPrim.Bold                 := SourcePrim.Bold;
```

---


### `BotShape`


**Common values:**

- `SourcePrim.BotShape`

- `Pad.BotShape`



**Example:**

```pascal
DestinPrim.BotShape     := Pad.BotShape;
```

---


### `BotXSize`


**Common values:**

- `Pad.BotXSize`

- `SourcePrim.BotXSize`



**Example:**

```pascal
DestinPrim.BotXSize     := Pad.BotXSize;
```

---


### `BotYSize`


**Common values:**

- `Pad.BotYSize`

- `SourcePrim.BotYSize`



**Example:**

```pascal
DestinPrim.BotYSize     := Pad.BotYSize;
```

---


### `BoundingRectangle`


---


### `Cache`


---


### `Component`


---


### `Descriptor`


---


### `Detail`


---


### `DrillType`


**Common values:**

- `Pad.DrillType`



**Example:**

```pascal
DestinPrim.DrillType        := Pad.DrillType;
```

---


### `EnableDraw`


---


### `EndAngle`


---


### `EndModify`


---


### `EndX`


---


### `EndY`


---


### `ExtensionLineWidth`


**Common values:**

- `SourcePrim.ExtensionLineWidth`



**Example:**

```pascal
DestinPrim.ExtensionLineWidth  := SourcePrim.ExtensionLineWidth;
```

---


### `ExtensionOffset`


**Common values:**

- `SourcePrim.ExtensionOffset`



**Example:**

```pascal
DestinPrim.ExtensionOffset     := SourcePrim.ExtensionOffset;
```

---


### `ExtensionPickGap`


**Common values:**

- `SourcePrim.ExtensionPickGap`



**Example:**

```pascal
DestinPrim.ExtensionPickGap    := SourcePrim.ExtensionPickGap;
```

---


### `FontID`


**Common values:**

- `SourcePrim.FontID`



**Example:**

```pascal
DestinPrim.FontID               := SourcePrim.FontID;
```

---


### `FontName`


**Common values:**

- `SourcePrim.FontName`



**Example:**

```pascal
DestinPrim.FontName             := SourcePrim.FontName;
```

---


### `GeometricPolygon`


---


### `GetState_Cache`


---


### `GetState_KeepoutRestrictions`


---


### `GetState_Length`


---


### `GetState_Mirror`


---


### `GetState_Selected`


---


### `GraphicallyInvalidate`


---


### `Grid`


**Common values:**

- `SourcePrim.Grid`



**Example:**

```pascal
DestinPrim.Grid                 := SourcePrim.Grid;
```

---


### `GroupIterator_Create`


---


### `Handle`


---


### `HighLayer`


**Common values:**

- `SourcePrim.HighLayer`

- `Via.HighLayer`



**Example:**

```pascal
DestinPrim.HighLayer := Via.HighLayer;
```

---


### `HoleRotation`


**Common values:**

- `SourcePrim.HoleRotation`

- `Pad.HoleRotation`



**Example:**

```pascal
DestinPrim.HoleRotation     := Pad.HoleRotation;
```

---


### `HoleSize`


**Common values:**

- `SourcePrim.HoleSize`

- `Via.HoleSize`

- `Pad.HoleSize`



**Example:**

```pascal
DestinPrim.HoleSize     := Pad.HoleSize;
```

---


### `HoleType`


**Common values:**

- `SourcePrim.HoleType`

- `Pad.HoleType`



**Example:**

```pascal
DestinPrim.HoleType         := Pad.HoleType;
```

---


### `HoleWidth`


**Common values:**

- `Pad.HoleWidth`

- `SourcePrim.HoleWidth`



**Example:**

```pascal
DestinPrim.HoleWidth        := Pad.HoleWidth;
```

---


### `I_ObjectAddress`


---


### `Identifier`


---


### `IgnoreViolations`


**Common values:**

- `SourcePrim.IgnoreViolations`



**Example:**

```pascal
DestinPrim.IgnoreViolations     := SourcePrim.IgnoreViolations;
```

---


### `InComponent`


---


### `InCoordinate`


---


### `InDimension`


---


### `InNet`


**Common values:**

- `SourcePrim.InNet`



**Example:**

```pascal
DestinPrim.InNet                := SourcePrim.InNet;
```

---


### `InPolygon`


---


### `Index`


**Common values:**

- `primNames.Count`



**Example:**

```pascal
prim.Index               := primNames.Count;
```

---


### `InvRectHeight`


**Common values:**

- `SourcePrim.InvRectHeight`



**Example:**

```pascal
DestinPrim.InvRectHeight        := SourcePrim.InvRectHeight;
```

---


### `InvRectWidth`


**Common values:**

- `SourcePrim.InvRectWidth`



**Example:**

```pascal
DestinPrim.InvRectWidth         := SourcePrim.InvRectWidth;
```

---


### `InvalidateSizeShape`


---


### `Inverted`


**Common values:**

- `SourcePrim.Inverted`



**Example:**

```pascal
DestinPrim.Inverted             := SourcePrim.Inverted;
```

---


### `InvertedTTTextBorder`


**Common values:**

- `SourcePrim.InvertedTTTextBorder`



**Example:**

```pascal
DestinPrim.InvertedTTTextBorder := SourcePrim.InvertedTTTextBorder;
```

---


### `IsAssyTestpoint_Bottom`


---


### `IsAssyTestpoint_Top`


---


### `IsComment`


---


### `IsDesignator`


---


### `IsFreePrimitive`


---


### `IsHidden`


---


### `IsKeepout`


**Common values:**

- `SourcePrim.IsKeepout`



**Example:**

```pascal
DestinPrim.IsKeepout            := SourcePrim.IsKeepout;
```

---


### `IsTenting`


**Common values:**

- `SourcePrim.IsTenting`

- `Pad.IsTenting`

- `Via.IsTenting`



**Example:**

```pascal
DestinPrim.IsTenting            := Pad.IsTenting;
```

---


### `IsTenting_Bottom`


**Common values:**

- `SourcePrim.IsTenting_Bottom`

- `Pad.IsTenting_Bottom`

- `Via.IsTenting_Bottom`



**Example:**

```pascal
DestinPrim.IsTenting_Bottom     := Pad.IsTenting_Bottom;
```

---


### `IsTenting_Top`


**Common values:**

- `Via.IsTenting_Top`

- `SourcePrim.IsTenting_Top`

- `Pad.IsTenting_Top`



**Example:**

```pascal
DestinPrim.IsTenting_Top        := Pad.IsTenting_Top;
```

---


### `IsTestpoint_Bottom`


---


### `IsTestpoint_Top`


---


### `IslandAreaThreshold`


**Common values:**

- `SourcePrim.IslandAreaThreshold`



**Example:**

```pascal
DestinPrim.IslandAreaThreshold  := SourcePrim.IslandAreaThreshold;
```

---


### `Italic`


**Common values:**

- `SourcePrim.Italic`



**Example:**

```pascal
DestinPrim.Italic               := SourcePrim.Italic;
```

---


### `Kind`


---


### `Layer`


**Common values:**

- `LayerUtils.FromShortDisplayString(Layer.GetState_LayerDisplayName(0))`

- `String2Layer(FinalLayer)`

- `String2Layer(LayerObj.Name)`



**Example:**

```pascal
if Component.Layer = eTopLayer then NewPrim.Layer := MechTop
```

---


### `LineWidth`


**Common values:**

- `SourcePrim.LineWidth`



**Example:**

```pascal
DestinPrim.LineWidth           := SourcePrim.LineWidth;
```

---


### `LowLayer`


**Common values:**

- `Via.LowLayer`

- `SourcePrim.LowLayer`



**Example:**

```pascal
DestinPrim.LowLayer  := Via.LowLayer;
```

---


### `MainContour`


---


### `MidShape`


**Common values:**

- `Pad.MidShape`

- `SourcePrim.MidShape`



**Example:**

```pascal
DestinPrim.MidShape     := Pad.MidShape;
```

---


### `MidXSize`


**Common values:**

- `SourcePrim.MidXSize`

- `Pad.MidXSize`



**Example:**

```pascal
DestinPrim.MidXSize     := Pad.MidXSize;
```

---


### `MidYSize`


**Common values:**

- `SourcePrim.MidYSize`

- `Pad.MidYSize`



**Example:**

```pascal
DestinPrim.MidYSize     := Pad.MidYSize;
```

---


### `MinTrack`


**Common values:**

- `SourcePrim.MinTrack`



**Example:**

```pascal
DestinPrim.MinTrack             := SourcePrim.MinTrack;
```

---


### `MirrorFlag`


---


### `MiscFlag1`


---


### `MiscFlag2`


---


### `MiscFlag3`


---


### `Mode`


**Common values:**

- `Via.Mode`

- `SourcePrim.Mode`

- `Pad.Mode`



**Example:**

```pascal
DestinPrim.Mode             := Pad.Mode;   //simple local or full stack
```

---


### `Model`


---


### `Moveable`


---


### `MultiLine`


---


### `Multiline`


---


### `MultilineTextAutoPosition`


---


### `MultilineTextHeight`


---


### `MultilineTextResizeEnabled`


---


### `MultilineTextWidth`


---


### `Name`


---


### `NeckWidthThreshold`


**Common values:**

- `SourcePrim.NeckWidthThreshold`



**Example:**

```pascal
DestinPrim.NeckWidthThreshold   := SourcePrim.NeckWidthThreshold;
```

---


### `Net`


**Common values:**

- `SourcePrim.Net`

- `Net`



**Example:**

```pascal
Prim.Net := Net
```

---


### `ObjectID`


---


### `ObjectIDString`


---


### `ObjectId`


---


### `ObjectIdString`


---


### `OverallHeight`


---


### `PadCacheRobotFlag`


---


### `PasteMaskExpansion`


---


### `Plated`


**Common values:**

- `Pad.Plated`



**Example:**

```pascal
DestinPrim.Plated           := Pad.Plated;
```

---


### `PointCount`


---


### `PolyHatchStyle`


**Common values:**

- `SourcePrim.PolyHatchStyle`



**Example:**

```pascal
DestinPrim.PolyHatchStyle       := SourcePrim.PolyHatchStyle;
```

---


### `Polygon`


---


### `PolygonType`


**Common values:**

- `SourcePrim.PolygonType`



**Example:**

```pascal
DestinPrim.PolygonType          := SourcePrim.PolygonType;
```

---


### `PourOver`


**Common values:**

- `SourcePrim.PourOver`



**Example:**

```pascal
DestinPrim.PourOver             := SourcePrim.PourOver;
```

---


### `PowerPlaneConnectStyle`


---


### `PrimitiveLock`


**Common values:**

- `SourcePrim.PrimitiveLock`



**Example:**

```pascal
DestinPrim.PrimitiveLock        := SourcePrim.PrimitiveLock;
```

---


### `Radius`


---


### `ReValidateSizeShape`


---


### `Rebuild`


---


### `RemoveDead`


**Common values:**

- `SourcePrim.RemoveDead`



**Example:**

```pascal
DestinPrim.RemoveDead           := SourcePrim.RemoveDead;
```

---


### `RemoveIslandsByArea`


**Common values:**

- `SourcePrim.RemoveIslandsByArea`



**Example:**

```pascal
DestinPrim.RemoveIslandsByArea  := SourcePrim.RemoveIslandsByArea;
```

---


### `RemoveNarrowNecks`


**Common values:**

- `SourcePrim.RemoveNarrowNecks`



**Example:**

```pascal
DestinPrim.RemoveNarrowNecks    := SourcePrim.RemoveNarrowNecks;
```

---


### `Replicate`


---


### `ReplicateWithChildren`


---


### `Rotation`


**Common values:**

- `NewAngle`

- `(Angle + 180) mod 360`

- `Angle`



**Example:**

```pascal
Text.Rotation := NewAngle;
```

---


### `Segments`


---


### `Selected`


**Common values:**

- `True`

- `False`



**Example:**

```pascal
Prim.Selected := False;
```

---


### `SetState_Cache`


**Common values:**

- `padCache`

- `Padcache`

- `PadCache`



**Example:**

```pascal
Pad.SetState_Cache := Padcache;
```

---


### `SetState_CopperPourInvalid`


---


### `SetState_CopperPourValid`


---


### `SetState_XSizeYSize`


---


### `Size`


**Common values:**

- `MilsToCoord(TextHeight.Text)`

- `MilsToCoord(TextHeight.Text/0.0254)`

- `SourcePrim.Size`



**Example:**

```pascal
Text.Size := Max(TTF_min_height, planned_height);  // enforce a minimum height
```

---


### `SizeOnLayer`


---


### `SnapPointX`


**Common values:**

- `Comp.x`



**Example:**

```pascal
Text.SnapPointX := Comp.x;
```

---


### `SnapPointY`


**Common values:**

- `Comp.y`



**Example:**

```pascal
Text.SnapPointY := Comp.y;
```

---


### `StackCRPctOnLayer`


---


### `StackShapeOnLayer`


---


### `StackSizeOnLayer`


---


### `StandoffHeight`


---


### `StartAngle`


---


### `StartX`


---


### `StartY`


---


### `StartY1`


---


### `Style`


**Common values:**

- `SourcePrim.Style`



**Example:**

```pascal
DestinPrim.Style               := SourcePrim.Style;
```

---


### `TTFInvertedTextJustify`


**Common values:**

- `NewJustify`

- `SourcePrim.TTFInvertedTextJustify`

- `eAutoPos_CenterCenter`



**Example:**

```pascal
Text.TTFInvertedTextJustify := eAutoPos_CenterCenter;
```

---


### `TTFOffsetFromInvertedRect`


**Common values:**

- `SourcePrim.TTFOffsetFromInvertedRect`



**Example:**

```pascal
DestinPrim.TTFOffsetFromInvertedRect       := SourcePrim.TTFOffsetFromInvertedRect;
```

---


### `TTFTextHeight`


**Common values:**

- `SourcePrim.TTFTextHeight`



**Example:**

```pascal
DestinPrim.TTFTextHeight        := SourcePrim.TTFTextHeight;
```

---


### `TTFTextWidth`


**Common values:**

- `SourcePrim.TTFTextWidth`



**Example:**

```pascal
DestinPrim.TTFTextWidth         := SourcePrim.TTFTextWidth;
```

---


### `TearDrop`


---


### `TemplateLink`


---


### `Text`


**Common values:**

- `'.Designator'`

- `TToAdd`

- `'.Comment'`



**Example:**

```pascal
NewPrim.Text := '.Designator';
```

---


### `TextDimensionUnit`


**Common values:**

- `SourcePrim.TextDimensionUnit`



**Example:**

```pascal
DestinPrim.TextDimensionUnit   := SourcePrim.TextDimensionUnit;
```

---


### `TextFont`


**Common values:**

- `SourcePrim.TextFont`



**Example:**

```pascal
DestinPrim.TextFont            := SourcePrim.TextFont;
```

---


### `TextFormat`


**Common values:**

- `SourcePrim.TextFormat`



**Example:**

```pascal
DestinPrim.TextFormat          := SourcePrim.TextFormat;
```

---


### `TextGap`


**Common values:**

- `SourcePrim.TextGap`



**Example:**

```pascal
DestinPrim.TextGap             := SourcePrim.TextGap;
```

---


### `TextHeight`


**Common values:**

- `SourcePrim.TextHeight`



**Example:**

```pascal
DestinPrim.TextHeight          := SourcePrim.TextHeight;
```

---


### `TextKind`


**Common values:**

- `SourcePrim.TextKind`



**Example:**

```pascal
DestinPrim.TextKind             := SourcePrim.TextKind;
```

---


### `TextLineWidth`


**Common values:**

- `SourcePrim.TextLineWidth`



**Example:**

```pascal
DestinPrim.TextLineWidth       := SourcePrim.TextLineWidth;
```

---


### `TextPosition`


**Common values:**

- `SourcePrim.TextPosition`



**Example:**

```pascal
DestinPrim.TextPosition        := SourcePrim.TextPosition;
```

---


### `TextPrecision`


**Common values:**

- `SourcePrim.TextPrecision`



**Example:**

```pascal
DestinPrim.TextPrecision       := SourcePrim.TextPrecision;
```

---


### `TextPrefix`


**Common values:**

- `SourcePrim.TextPrefix`



**Example:**

```pascal
DestinPrim.TextPrefix          := SourcePrim.TextPrefix;
```

---


### `TextSuffix`


**Common values:**

- `SourcePrim.TextSuffix`



**Example:**

```pascal
DestinPrim.TextSuffix          := SourcePrim.TextSuffix;
```

---


### `TextValue`


**Common values:**

- `SourcePrim.TextValue`



**Example:**

```pascal
DestinPrim.TextValue           := SourcePrim.TextValue;
```

---


### `TextWidth`


**Common values:**

- `SourcePrim.TextWidth`



**Example:**

```pascal
DestinPrim.TextWidth           := SourcePrim.TextWidth;
```

---


### `TextX`


**Common values:**

- `DestinPrim.TextX + MilsToCoord(0.01)`

- `DestinPrim.TextX - MilsToCoord(0.01)`



**Example:**

```pascal
DestinPrim.TextX              := DestinPrim.TextX + MilsToCoord(0.01);
```

---


### `TopShape`


**Common values:**

- `Pad.TopShape`

- `SourcePrim.TopShape`



**Example:**

```pascal
DestinPrim.TopShape         := Pad.TopShape;
```

---


### `TopXSize`


**Common values:**

- `Pad.TopXSize`

- `SourcePrim.TopXSize`



**Example:**

```pascal
DestinPrim.TopXSize         := Pad.TopXSize;
```

---


### `TopYSize`


**Common values:**

- `SourcePrim.TopYSize`

- `Pad.TopYSize`



**Example:**

```pascal
DestinPrim.TopYSize         := Pad.TopYSize;
```

---


### `Track1`


---


### `Track2`


---


### `TrackSize`


**Common values:**

- `SourcePrim.TrackSize`



**Example:**

```pascal
DestinPrim.TrackSize            := SourcePrim.TrackSize;
```

---


### `UnderlyingString`


---


### `UnionIndex`


---


### `UseInvertedRectangle`


**Common values:**

- `SourcePrim.UseInvertedRectangle`



**Example:**

```pascal
DestinPrim.UseInvertedRectangle := SourcePrim.UseInvertedRectangle;
```

---


### `UseOctagons`


**Common values:**

- `SourcePrim.UseOctagons`



**Example:**

```pascal
DestinPrim.UseOctagons          := SourcePrim.UseOctagons;
```

---


### `UseTTFonts`


**Common values:**

- `SourcePrim.UseTTFonts`



**Example:**

```pascal
DestinPrim.UseTTFonts           := SourcePrim.UseTTFonts;
```

---


### `Used`


---


### `UserRouted`


---


### `ViewableObjectID`


---


### `Width`


**Common values:**

- `MilsToCoord(StrokeWidth.Text/0.0254)`

- `SourcePrim.Width`

- `MilsToCoord(StrokeWidth.Text)`



**Example:**

```pascal
Text.Width := Text.Size div 10;  // set stroke width to a tenth of the character height
```

---


### `WordWrap`


---


### `X`


**Common values:**

- `DestinPrim.X - MilsToCoord(0.01)`

- `DestinPrim.X + MilsToCoord(0.01)`



**Example:**

```pascal
DestinPrim.X     := DestinPrim.X + MilsToCoord(0.01);
```

---


### `X1`


---


### `X1Location`


---


### `X2`


---


### `X2Location`


---


### `XCenter`


---


### `XLocation`


**Common values:**

- `board.XOrigin+MilsToCoord((XPos.Text)/0.0254)`

- `board.XOrigin+MilsToCoord(XPos.Text)`



**Example:**

```pascal
Text.XLocation := board.XOrigin+MilsToCoord(XPos.Text);
```

---


### `XPadOffset`


---


### `XSizeOnLayer`


---


### `XStackSizeOnLayer`


---


### `Y`


---


### `Y1`


---


### `Y1Location`


---


### `Y2`


---


### `Y2Location`


---


### `YCenter`


---


### `YLocation`


**Common values:**

- `board.YOrigin+MilsToCoord((YPos.Text)/0.0254)`

- `board.YOrigin+MilsToCoord(YPos.Text)`



**Example:**

```pascal
Text.YLocation := board.YOrigin+MilsToCoord(YPos.Text);
```

---


### `YPadOffset`


---


### `YSizeOnLayer`


---


### `YStackSizeOnLayer`


---


### `net`


---


### `x`


---


### `x1`


**Common values:**

- `X + Radius`

- `FirstTrack.x1 + RemovedLength * cos(Angle[1])`

- `X`



**Example:**

```pascal
FirstTrack.x1 := FirstTrack.x1 + RemovedLength * cos(Angle[1]);
```

---


### `x2`


**Common values:**

- `X`

- `FirstTrack.x2 + RemovedLength * cos(Angle[1])`

- `X - Radius`



**Example:**

```pascal
FirstTrack.x2 := FirstTrack.x2 + RemovedLength * cos(Angle[1]);
```

---


### `y`


---


### `y1`


**Common values:**

- `Y + Radius`

- `Prim.y2`

- `FirstTrack.y1 + RemovedLength * sin(Angle[1])`



**Example:**

```pascal
FirstTrack.y1 := FirstTrack.y1 + RemovedLength * sin(Angle[1]);
```

---


### `y2`


**Common values:**

- `Y - Radius`

- `FirstTrack.y2 + RemovedLength * sin(Angle[1])`

- `Y`



**Example:**

```pascal
FirstTrack.y2 := FirstTrack.y2 + RemovedLength * sin(Angle[1]);
```

---



====================================================================================================


# IPCB_Region


**Category:** PCB


**API Surface:** 2 methods, 17 properties


---


## Methods (2)


### `Replicate()`


**Examples:**


*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Cleanup_LPW_Footprint.pas*

```pascal
{ Replicate the queued region and operate on that region. }
         regionNew := regionDst.Replicate();

         { Add new object to PcbLib footprint. }
```


---


### `SetOutlineContour()`


**Observed signatures:**

```pascal
IPCB_Region.SetOutlineContour(Contour)
```

```pascal
IPCB_Region.SetOutlineContour(regionOutlinePoints)
```

```pascal
IPCB_Region.SetOutlineContour(contour)
```

**Examples:**


*From: Scripts - PCB\DeleteSelectedSplit\DeleteSelectedSplit.pas*

```pascal
Contour := Region.MainContour.Replicate;
          NewRegion.SetOutlineContour(Contour);

          For I := 0 To Region.HoleCount - 1 Do
```


*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Cleanup_LPW_Footprint.pas*

```pascal
regionOutlinePoints.AddPoint(rectDst.right, rectDst.top);
   
   regionDst.SetOutlineContour(regionOutlinePoints);
```


---


## Properties (17)


### `Area`


---


### `BoundingRectangle`


---


### `Detail`


---


### `GeometricPolygon`


**Common values:**

- `textDst.TTTextOutlineGeometricPolygon()`



**Example:**

```pascal
regionFoo.GeometricPolygon := textDst.TTTextOutlineGeometricPolygon();
```

---


### `GetMainContour`


---


### `GraphicallyInvalidate`


---


### `HoleCount`


---


### `Holes`


---


### `I_ObjectAddress`


---


### `InNet`


---


### `InPolygon`


---


### `IsKeepout`


---


### `Kind`


---


### `Layer`


**Common values:**

- `Region.Layer`

- `regionSrc.Layer`

- `Layer`



**Example:**

```pascal
NewRegion.Layer := Region.Layer;
```

---


### `MainContour`


---


### `Net`


---


### `Polygon`


---



====================================================================================================


# IPCB_RoutingViaStyleRule


**Category:** PCB


**API Surface:** 0 methods, 10 properties


---


## Properties (10)


### `Comment`


**Common values:**

- `'Via style rule for Stitching Vias'`



**Example:**

```pascal
RuleViaStyle.Comment := 'Via style rule for Stitching Vias';
```

---


### `MaxHoleWidth`


**Common values:**

- `MilsToCoord(StrToFloat(EditHoleSize.Text))`

- `MMsToCoord(StrToFloat(EditHoleSize.Text))`



**Example:**

```pascal
RuleViaStyle.MaxHoleWidth      := MMsToCoord(StrToFloat(EditHoleSize.Text));
```

---


### `MaxWidth`


**Common values:**

- `MilsToCoord(StrToFloat(EditSize.Text))`

- `MMsToCoord(StrToFloat(EditSize.Text))`



**Example:**

```pascal
RuleViaStyle.MaxWidth          := MMsToCoord(StrToFloat(EditSize.Text));
```

---


### `MinHoleWidth`


**Common values:**

- `MilsToCoord(StrToFloat(EditHoleSize.Text))`

- `MMsToCoord(StrToFloat(EditHoleSize.Text))`



**Example:**

```pascal
RuleViaStyle.MinHoleWidth      := MMsToCoord(StrToFloat(EditHoleSize.Text));
```

---


### `MinWidth`


**Common values:**

- `MilsToCoord(StrToFloat(EditSize.Text))`

- `MMsToCoord(StrToFloat(EditSize.Text))`



**Example:**

```pascal
RuleViaStyle.MinWidth          := MMsToCoord(StrToFloat(EditSize.Text));
```

---


### `Name`


**Common values:**

- `'StitchingVias-ViaStyle'`



**Example:**

```pascal
RuleViaStyle.Name    := 'StitchingVias-ViaStyle';
```

---


### `NetScope`


**Common values:**

- `eNetScope_AnyNet`



**Example:**

```pascal
RuleViaStyle.NetScope  := eNetScope_AnyNet;
```

---


### `PreferedHoleWidth`


**Common values:**

- `MilsToCoord(StrToFloat(EditHoleSize.Text))`

- `MMsToCoord(StrToFloat(EditHoleSize.Text))`



**Example:**

```pascal
RuleViaStyle.PreferedHoleWidth := MMsToCoord(StrToFloat(EditHoleSize.Text));
```

---


### `PreferedWidth`


**Common values:**

- `MilsToCoord(StrToFloat(EditSize.Text))`

- `MMsToCoord(StrToFloat(EditSize.Text))`



**Example:**

```pascal
RuleViaStyle.PreferedWidth     := MMsToCoord(StrToFloat(EditSize.Text));
```

---


### `Scope1Expression`


**Common values:**

- `'InComponent(''StitchingVias'')'`



**Example:**

```pascal
RuleViaStyle.Scope1Expression := 'InComponent(''StitchingVias'')';
```

---



====================================================================================================


# IPCB_Rule


**Category:** PCB


**API Surface:** 3 methods, 9 properties


---


## Methods (3)


### `ActualCheck()`


**Observed signatures:**

```pascal
IPCB_Rule.ActualCheck(Via, Via)
```

```pascal
IPCB_Rule.ActualCheck(Via, nil)
```

**Examples:**


*From: Scripts - PCB\ReturnViaCheck\ReturnViaCheck.pas*

```pascal
if Rule = nil then exit;

    //if Rule.CheckUnaryScope(Via) then Violation := Rule.ActualCheck(Via, nil); // for unary rule types
    if Rule.CheckUnaryScope(Via) then Violation := Rule.ActualCheck(Via, Via); // for binary rule types
```


*From: Scripts - PCB\ReturnViaCheck\ReturnViaCheck.pas*

```pascal
//if Rule.CheckUnaryScope(Via) then Violation := Rule.ActualCheck(Via, nil); // for unary rule types
    if Rule.CheckUnaryScope(Via) then Violation := Rule.ActualCheck(Via, Via); // for binary rule types

    // if we got a violation to be created, configure it and add to the PCB
```


---


### `CheckUnaryScope()`


**Observed signatures:**

```pascal
IPCB_Rule.CheckUnaryScope(Via)
```

**Examples:**


*From: Scripts - PCB\ReturnViaCheck\ReturnViaCheck.pas*

```pascal
if Rule = nil then exit;

    //if Rule.CheckUnaryScope(Via) then Violation := Rule.ActualCheck(Via, nil); // for unary rule types
    if Rule.CheckUnaryScope(Via) then Violation := Rule.ActualCheck(Via, Via); // for binary rule types
```


*From: Scripts - PCB\ReturnViaCheck\ReturnViaCheck.pas*

```pascal
//if Rule.CheckUnaryScope(Via) then Violation := Rule.ActualCheck(Via, nil); // for unary rule types
    if Rule.CheckUnaryScope(Via) then Violation := Rule.ActualCheck(Via, Via); // for binary rule types

    // if we got a violation to be created, configure it and add to the PCB
```


---


### `FavoredWidth()`


**Observed signatures:**

```pascal
IPCB_Rule.FavoredWidth(eTopLayer)
```

**Examples:**


*From: Scripts - PCB\LengthTuningHelper\LengthTuningHelper.pas*

```pascal
Net.AddPCBObject(Track);
      Rule := Board.FindDominantRuleForObject(Track,eRule_MaxMinWidth);
      Track.Width := Rule.FavoredWidth(eTopLayer);

      Track.Selected := True;
```


---


## Properties (9)


### `DRCEnabled`


**Common values:**

- `True`

- `False`



**Example:**

```pascal
Rule.DRCEnabled := False; // turn off DRCEnabled
```

---


### `Enabled`


---


### `Gap`


**Common values:**

- `VIADISTANCEMAX`



**Example:**

```pascal
Rule.Gap := VIADISTANCEMAX; // Gap applies to eRule_HoleToHoleClearance
```

---


### `Name`


---


### `PreferedHoleWidth`


---


### `PreferedWidth`


---


### `RuleKind`


---


### `Scope1Expression`


---


### `Scope2Expression`


---



====================================================================================================


# IPCB_ServerInterface


**Category:** PCB


**API Surface:** 1 methods, 1 properties


---


## Methods (1)


### `PCBObjectFactory()`


**Observed signatures:**

```pascal
IPCB_ServerInterface.PCBObjectFactory(eComponentObject, eNoDimension,eCreate_Default)
```

**Examples:**


*From: Scripts - Examples\PlacePartFromDbLibToPCB\PlacePartFromDbLibToPCB.pas*

```pascal
Board:=_PCBServer.GetCurrentPCBBoard;
  if Board=nil then exit;
  component := _PCBServer.PCBObjectFactory(eComponentObject, eNoDimension,eCreate_Default);
  if component<>nil then
```


---


## Properties (1)


### `GetCurrentPCBBoard`


---



====================================================================================================


# IPCB_ShortCircuitConstraint


**Category:** PCB


**API Surface:** 0 methods, 6 properties


---


## Properties (6)


### `Allowed`


**Common values:**

- `True`

- `False`



**Example:**

```pascal
RuleCutout.Allowed := True
```

---


### `Comment`


**Common values:**

- `'Allow short between Board Cutout and Venting Pads'`



**Example:**

```pascal
RuleCutout.Comment := 'Allow short between Board Cutout and Venting Pads';
```

---


### `Name`


**Common values:**

- `'Venting-Cutout'`



**Example:**

```pascal
RuleCutout.Name    := 'Venting-Cutout';
```

---


### `NetScope`


**Common values:**

- `eNetScope_AnyNet`



**Example:**

```pascal
RuleCutout.NetScope := eNetScope_AnyNet;
```

---


### `Scope1Expression`


**Common values:**

- `'InComponent(''Venting'')'`



**Example:**

```pascal
RuleCutout.Scope1Expression := 'InComponent(''Venting'')';
```

---


### `Scope2Expression`


**Common values:**

- `'IsBoardCutoutRegion'`



**Example:**

```pascal
RuleCutout.Scope2Expression := 'IsBoardCutoutRegion';
```

---



====================================================================================================


# IPCB_SpatialIterator


**Category:** PCB


**API Surface:** 5 methods, 3 properties


---


## Methods (5)


### `AddFilter_Area()`


**Observed signatures:**

```pascal
IPCB_SpatialIterator.AddFilter_Area(SIterLeft, SIterBot, SIterRight, SIterTop)
```

```pascal
IPCB_SpatialIterator.AddFilter_Area(X,Y,X+1,Y+1)
```

```pascal
IPCB_SpatialIterator.AddFilter_Area(X - 1, Y - 1, X + 1, Y + 1)
```

**Examples:**


*From: Scripts - PCB\AssemblyTextPrep\AssemblyTextPrep.pas*

```pascal
SIterTop := Text.BoundingRectangle.Top + Expansion;

    SIter.AddFilter_Area(SIterLeft, SIterBot, SIterRight, SIterTop);

    Obj := SIter.FirstPCBObject;
```


*From: Scripts - PCB\AutoRouter_Interface\AutoRouter_Interface.pas*

```pascal
SpIter := Board.SpatialIterator_Create;
         SpIter.AddFilter_AllLayers;
         SpIter.AddFilter_Area(Prim1.BoundingRectangle.Left, Prim1.BoundingRectangle.Bottom, Prim1.BoundingRectangle.Right, Prim1.BoundingRectangle.Top);
         SpIter.AddFilter_ObjectSet(mkset(eViaObject));
```


---


### `AddFilter_IPCB_LayerSet()`


**Observed signatures:**

```pascal
IPCB_SpatialIterator.AddFilter_IPCB_LayerSet(String2Layer(FinalLayer)
```

```pascal
IPCB_SpatialIterator.AddFilter_IPCB_LayerSet(SetOfLayers)
```

```pascal
IPCB_SpatialIterator.AddFilter_IPCB_LayerSet(LayerSet.SignalLayers)
```

**Examples:**


*From: Scripts - PCB\MoveToLayer\MoveToLayer.pas*

```pascal
BoardIterator := Board.SpatialIterator_Create;
   BoardIterator.AddFilter_IPCB_LayerSet(LayerSet.SignalLayers);
   BoardIterator.AddFilter_ObjectSet(AllObjects);
   BoardIterator.AddFilter_Area(Rectangle.Left - MaxWidth, Rectangle.Bottom - MaxWidth, Rectangle.Right + MaxWidth, Rectangle.Top + MaxWidth);
```


*From: Scripts - PCB\MoveToLayer\MoveToLayer.pas*

```pascal
BoardIterator := Board.SpatialIterator_Create;
      BoardIterator.AddFilter_IPCB_LayerSet(LayerSet.SignalLayers);
      BoardIterator.AddFilter_ObjectSet(AllObjects);
      BoardIterator.AddFilter_Area(Rectangle.Left - MaxWidth, Rectangle.Bottom - MaxWidth, Rectangle.Right + MaxWidth, Rectangle.Top + MaxWidth);
```


---


### `AddFilter_LayerSet()`


**Observed signatures:**

```pascal
IPCB_SpatialIterator.AddFilter_LayerSet(MkSet(Prim1.Layer, String2Layer('Multi Layer')
```

```pascal
IPCB_SpatialIterator.AddFilter_LayerSet(MkSet(Prim1.Layer, eMultiLayer)
```

```pascal
IPCB_SpatialIterator.AddFilter_LayerSet(MkSet(Layer1)
```

**Examples:**


*From: Scripts - PCB\AssemblyTextPrep\AssemblyTextPrep.pas*

```pascal
// Create a spatial iterator to loop through free primitives on Text layer
    SIter := Board.SpatialIterator_Create;
    SIter.AddFilter_LayerSet(MkSet(Text.Layer));
    SIter.AddFilter_ObjectSet(MkSet(eTextObject, eTrackObject, eArcObject, eFillObject, eRegionObject));
```


*From: Scripts - PCB\AutoRouter_Interface\AutoRouter_Interface.pas*

```pascal
begin
         SpIter := Board.SpatialIterator_Create;
         SpIter.AddFilter_LayerSet(MkSet(Prim1.Layer));
         SpIter.AddFilter_Area(Prim1.BoundingRectangle.Left, Prim1.BoundingRectangle.Bottom, Prim1.BoundingRectangle.Right, Prim1.BoundingRectangle.Top);
         SpIter.AddFilter_ObjectSet(mkset(eTrackObject));
```


---


### `AddFilter_Method()`


**Observed signatures:**

```pascal
IPCB_SpatialIterator.AddFilter_Method(eProcessAll)
```

**Examples:**


*From: Scripts - PCB\SolderPasteGrid\SolderPasteGrid.pas*

```pascal
Iterator.AddFilter_ObjectSet(MkSet(ePadObject));
    Iterator.AddFilter_LayerSet(MkSet(eTopLayer));
    Iterator.AddFilter_Method(eProcessAll);

    xorigin := Board.XOrigin;
```


---


### `AddFilter_ObjectSet()`


**Observed signatures:**

```pascal
IPCB_SpatialIterator.AddFilter_ObjectSet(MkSet(eTrackObject, eArcObject)
```

```pascal
IPCB_SpatialIterator.AddFilter_ObjectSet(AllObjects)
```

```pascal
IPCB_SpatialIterator.AddFilter_ObjectSet(mkset(eTrackObject)
```

**Examples:**


*From: Scripts - PCB\AssemblyTextPrep\AssemblyTextPrep.pas*

```pascal
SIter := Board.SpatialIterator_Create;
    SIter.AddFilter_LayerSet(MkSet(Text.Layer));
    SIter.AddFilter_ObjectSet(MkSet(eTextObject, eTrackObject, eArcObject, eFillObject, eRegionObject));

    SIterLeft := Text.BoundingRectangle.Left - Expansion;
```


*From: Scripts - PCB\AutoRouter_Interface\AutoRouter_Interface.pas*

```pascal
SpIter.AddFilter_AllLayers;
         SpIter.AddFilter_Area(Prim1.BoundingRectangle.Left, Prim1.BoundingRectangle.Bottom, Prim1.BoundingRectangle.Right, Prim1.BoundingRectangle.Top);
         SpIter.AddFilter_ObjectSet(mkset(eViaObject));

         Prim2 := SpIter.FirstPCBObject;
```


---


## Properties (3)


### `AddFilter_AllLayers`


---


### `FirstPCBObject`


---


### `NextPCBObject`


---



====================================================================================================


# IPCB_SplitPlane


**Category:** PCB


**API Surface:** 2 methods, 7 properties


---


## Methods (2)


### `GetState_HitPrimitive()`


**Observed signatures:**

```pascal
IPCB_SplitPlane.GetState_HitPrimitive(PVPrim)
```

**Examples:**


*From: Scripts - PCB\PCBObjectInspector\PCBObjectInspector.pas*

```pascal
while SplitPlaneRegion <> nil do
            begin
                {TempString := Format('HitPrimitive: %s; PrimitiveInsidePoly: %s; StrictHitTest: %s', [BoolToStr(SplitPlane.GetState_HitPrimitive(PVPrim), True), BoolToStr(SplitPlane.PrimitiveInsidePoly(PVPrim), True), BoolToStr(SplitPlane.GetState_StrictHitTest(PVPrim.x, PVPrim.y), True)]);
                TempString := TempString + sLineBreak + Format('PowerPlaneConnectStyle <> eNoConnect: %s', [BoolToStr(PVPrim.PowerPlaneConnectStyle <> eNoConnect, True)]);
                TempString := TempString + sLineBreak + Format('GetState_IsConnectedToPlane(%s): %s', [Layer2String(Layer), BoolToStr(PVPrim.GetState_IsConnectedToPlane(Layer), True)]);
```


*From: Scripts - PCB\PCBObjectInspector\PCBObjectInspector.pas*

```pascal
//end;

                if SplitPlane.GetState_HitPrimitive(PVPrim) and (PVPrim.PowerPlaneConnectStyle <> eNoConnect) and PVPrim.GetState_IsConnectedToPlane(Layer) then
                begin
                    bConnected := True;
```


---


### `GroupIterator_Destroy()`


**Observed signatures:**

```pascal
IPCB_SplitPlane.GroupIterator_Destroy(GIter)
```

```pascal
IPCB_SplitPlane.GroupIterator_Destroy(PolyIterator)
```

**Examples:**


*From: Scripts - PCB\DeleteSelectedSplit\DeleteSelectedSplit.pas*

```pascal
Region := PolyIterator.FirstPCBObject;

          Split.GroupIterator_Destroy(PolyIterator);  

          NewRegion := PCBServer.PCBObjectFactory(eRegionObject, eNoDimension,eCreate_Default);
```


*From: Scripts - PCB\PCBObjectInspector\PCBObjectInspector.pas*

```pascal
SplitPlaneRegion := GIter.NextPCBObject;
            end;
            SplitPlane.GroupIterator_Destroy(GIter);
            SplitPlane := PIter.NextPCBObject;
```


---


## Properties (7)


### `GraphicallyInvalidate`


---


### `GroupIterator_Create`


---


### `Layer`


---


### `Net`


---


### `Selected`


---


### `V7_Layer`


---


### `x`


**Common values:**

- `I`

- `1`



**Example:**

```pascal
Split.x := 1;
```

---



====================================================================================================


# IPCB_SystemOptions


**Category:** PCB


**API Surface:** 0 methods, 1 properties


---


## Properties (1)


### `DoOnlineDRC`


**Common values:**

- `DRCSetting`

- `false`

- `False`



**Example:**

```pascal
PCBSystemOptions.DoOnlineDRC := false;
```

---



====================================================================================================


# IPCB_Text


**Category:** PCB


**API Surface:** 9 methods, 61 properties


---


## Methods (9)


### `MoveByXY()`


**Observed signatures:**

```pascal
IPCB_Text.MoveByXY(dx, dy)
```

```pascal
IPCB_Text.MoveByXY(2 * (X - Tekst.XLocation)
```

```pascal
IPCB_Text.MoveByXY(dx + MilsToCoord(X_offset)
```

**Examples:**


*From: Scripts - PCB\AutoPlaceSilkscreen\AutoPlaceSilkscreen.pas*

```pascal
end;
    end;
    Silk.MoveByXY(dx + MilsToCoord(X_offset), dy + MilsToCoord(Y_offset));
end;
```


*From: Scripts - PCB\FlipComponents\FlipComponents.pas*

```pascal
Begin
         Tekst.RotateBy(180);
         Tekst.MoveByXY(2 * (X - Tekst.XLocation), 2 * (Y - Tekst.YLocation));

         Tekst := CompIterator.NextPCBObject;
```


---


### `MoveToXY()`


**Observed signatures:**

```pascal
IPCB_Text.MoveToXY(Designator.XLocation, Designator.YLocation)
```

```pascal
IPCB_Text.MoveToXY(TargetComp.x + DeltaX, TargetComp.y + DeltaY)
```

```pascal
IPCB_Text.MoveToXY(Board.XOrigin - 1000000, Board.YOrigin - 1000000)
```

**Examples:**


*From: Scripts - PCB\AdjustDesignators2\AdjustDesignators2.pas*

```pascal
MechDesignator.SetState_XSizeYSize;
                        MechDesignator.MoveToXY(Designator.XLocation, Designator.YLocation);
                        BR  := MechDesignator.BoundingRectangle;
                        BRC := Point(BR.X1 + RectWidth(BR)/2, BR.Y1 + RectHeight(BR)/2 );
```


*From: Scripts - PCB\AdjustDesignators2\AdjustDesignators2.pas*

```pascal
//   size of bounding box effects the move location.
                Designator.SetState_XSizeYSize;
                Designator.MoveToXY(DesXLocation, DesYLocation);

                Designator.GraphicallyInvalidate;
```


---


### `Replicate()`


**Examples:**


*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Cleanup_LPW_Footprint.pas*

```pascal
{ Replicate the queued text and operate on that text. }
         textNew := textDst.Replicate();

         { Add new object to PcbLib footprint. }
```


---


### `RotateAroundXY()`


**Observed signatures:**

```pascal
IPCB_Text.RotateAroundXY(TargetComp.x, TargetComp.y, TargetComp.Rotation - SourceComp.Rotation)
```

```pascal
IPCB_Text.RotateAroundXY(BRC.X, BRC.Y, MechDesRotation)
```

**Examples:**


*From: Scripts - PCB\AdjustDesignators2\AdjustDesignators2.pas*

```pascal
MechDesRotation := MechDesRotation - MechDesignator.Rotation;
                        MechDesignator.RotateAroundXY(BRC.X, BRC.Y, MechDesRotation);

                        MechDesignator.GraphicallyInvalidate;
```


*From: Scripts - PCB\QuickSilk\QuickSilk.pas*

```pascal
TargetNameOrComment.SnapPointY := TargetComp.y + DeltaY;
        //RotateTextToAngle(TargetNameOrComment, TargetComp.Rotation + DeltaAngle, True, False);
        if bRelRotation then TargetNameOrComment.RotateAroundXY(TargetComp.x, TargetComp.y, TargetComp.Rotation - SourceComp.Rotation);
    finally
        TargetNameOrComment.EndModify;
```


---


### `RotateBy()`


**Observed signatures:**

```pascal
IPCB_Text.RotateBy(180)
```

**Examples:**


*From: Scripts - PCB\FlipComponents\FlipComponents.pas*

```pascal
While (Tekst <> Nil) Do
      Begin
         Tekst.RotateBy(180);
         Tekst.MoveByXY(2 * (X - Tekst.XLocation), 2 * (Y - Tekst.YLocation));
```


---


### `SetState_Multiline()`


**Observed signatures:**

```pascal
IPCB_Text.SetState_Multiline(true)
```

```pascal
IPCB_Text.SetState_Multiline(MechDesMultiline)
```

```pascal
IPCB_Text.SetState_Multiline(DesMultiline)
```

**Examples:**


*From: Scripts - PCB\AdjustDesignators2\AdjustDesignators2.pas*

```pascal
Designator.Size := Size;

            Designator.SetState_Multiline(true);
            Designator.MultilineTextHeight := 0;
            Designator.MultilineTextWidth  := 0;
```


*From: Scripts - PCB\AdjustDesignators2\AdjustDesignators2.pas*

```pascal
Designator.MultilineTextHeight := 0;
            Designator.MultilineTextWidth  := 0;
            Designator.SetState_Multiline(true);
            Designator.SetState_MultilineTextAutoPosition(eAutoPos_CenterCenter);   // CenterLeft
//            Designator.UpdateTextPosition;
```


---


### `SetState_MultilineTextAutoPosition()`


**Observed signatures:**

```pascal
IPCB_Text.SetState_MultilineTextAutoPosition(eAutoPos_CenterCenter)
```

```pascal
IPCB_Text.SetState_MultilineTextAutoPosition(DesMultilineAuto)
```

**Examples:**


*From: Scripts - PCB\AdjustDesignators2\AdjustDesignators2.pas*

```pascal
Designator.MultilineTextWidth  := 0;
            Designator.SetState_Multiline(true);
            Designator.SetState_MultilineTextAutoPosition(eAutoPos_CenterCenter);   // CenterLeft
//            Designator.UpdateTextPosition;
```


*From: Scripts - PCB\AdjustDesignators2\AdjustDesignators2.pas*

```pascal
MechDesignator.SetState_Multiline(true);
                         MechDesignator.SetState_MultilineTextAutoPosition(eAutoPos_CenterCenter);
                         MechDesignator.TTFInvertedTextJustify := Designator.TTFInvertedTextJustify;
                         MechDesignator.Size                   := Designator.Size;
```


---


### `SetState_UseTTFonts()`


**Observed signatures:**

```pascal
IPCB_Text.SetState_UseTTFonts(True)
```

**Examples:**


*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Cleanup_LPW_Footprint.pas*

```pascal
{ Set text to use true type fonts. }
   textDst.SetState_UseTTFonts(True);

   { Set text to use specified true type font. }
```


---


### `TTTextOutlineGeometricPolygon()`


**Examples:**


*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Cleanup_LPW_Footprint.pas*

```pascal
{ Convert text object to geometric region. }
      regionFoo.GeometricPolygon := textDst.TTTextOutlineGeometricPolygon();

      { Set identifier for regions that will be created. }
```


*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Cleanup_LPW_Footprint.pas*

```pascal
{ Convert text object to geometric region. }
   AGeometricPolygon := textDst.TTTextOutlineGeometricPolygon();
   
   { Unfortunately, we can't rotate in x,y,z even if we want to.  ;-( }
```


---


## Properties (61)


### `AdvanceSnapping`


**Common values:**

- `True`



**Example:**

```pascal
NewTextObj.AdvanceSnapping          := True;
```

---


### `BarCodeFontName`


**Common values:**

- `SourceText.BarCodeFontName`



**Example:**

```pascal
TargetText.BarCodeFontName              := SourceText.BarCodeFontName;
```

---


### `BarCodeFullHeight`


**Common values:**

- `SourceText.BarCodeFullHeight`



**Example:**

```pascal
TargetText.BarCodeFullHeight            := SourceText.BarCodeFullHeight;
```

---


### `BarCodeFullWidth`


**Common values:**

- `SourceText.BarCodeFullWidth`



**Example:**

```pascal
TargetText.BarCodeFullWidth             := SourceText.BarCodeFullWidth;
```

---


### `BarCodeInverted`


**Common values:**

- `SourceText.BarCodeInverted`



**Example:**

```pascal
TargetText.BarCodeInverted              := SourceText.BarCodeInverted;
```

---


### `BarCodeKind`


**Common values:**

- `SourceText.BarCodeKind`



**Example:**

```pascal
TargetText.BarCodeKind                  := SourceText.BarCodeKind;
```

---


### `BarCodeMinWidth`


**Common values:**

- `SourceText.BarCodeMinWidth`



**Example:**

```pascal
TargetText.BarCodeMinWidth              := SourceText.BarCodeMinWidth;
```

---


### `BarCodeRenderMode`


**Common values:**

- `SourceText.BarCodeRenderMode`



**Example:**

```pascal
TargetText.BarCodeRenderMode            := SourceText.BarCodeRenderMode;
```

---


### `BarCodeShowText`


**Common values:**

- `SourceText.BarCodeShowText`



**Example:**

```pascal
TargetText.BarCodeShowText              := SourceText.BarCodeShowText;
```

---


### `BarCodeXMargin`


**Common values:**

- `SourceText.BarCodeXMargin`



**Example:**

```pascal
TargetText.BarCodeXMargin               := SourceText.BarCodeXMargin;
```

---


### `BarCodeYMargin`


**Common values:**

- `SourceText.BarCodeYMargin`



**Example:**

```pascal
TargetText.BarCodeYMargin               := SourceText.BarCodeYMargin;
```

---


### `BeginModify`


---


### `Bold`


**Common values:**

- `SourceText.Bold`

- `Designator.Bold`

- `DesBold`



**Example:**

```pascal
Designator.Bold := True;
```

---


### `BoundingRectangle`


---


### `Component`


---


### `EndModify`


---


### `FontID`


**Common values:**

- `2`

- `DesFontID`

- `SourceText.FontID`



**Example:**

```pascal
Designator.FontID     := DesFontID;
```

---


### `FontName`


**Common values:**

- `DesFontName`

- `'Microsoft Sans Serif'`

- `fontName`



**Example:**

```pascal
Designator.FontName := 'Microsoft Sans Serif';
```

---


### `GetDesignatorDisplayString`


---


### `GetState_ConvertedString`


---


### `GetState_Mirror`


---


### `GetState_UnderlyingString`


---


### `GraphicallyInvalidate`


---


### `I_ObjectAddress`


---


### `InComponent`


---


### `Index`


---


### `InvRectHeight`


**Common values:**

- `SourceText.InvRectHeight`



**Example:**

```pascal
TargetText.InvRectHeight                := SourceText.InvRectHeight;
```

---


### `InvRectWidth`


**Common values:**

- `SourceText.InvRectWidth`



**Example:**

```pascal
TargetText.InvRectWidth                 := SourceText.InvRectWidth;
```

---


### `Inverted`


**Common values:**

- `DesInverted`

- `SourceText.Inverted`

- `Designator.Inverted`



**Example:**

```pascal
Designator.Inverted := False;
```

---


### `InvertedTTTextBorder`


**Common values:**

- `SourceText.InvertedTTTextBorder`



**Example:**

```pascal
TargetText.InvertedTTTextBorder         := SourceText.InvertedTTTextBorder;
```

---


### `IsDesignator`


---


### `IsHidden`


---


### `Italic`


**Common values:**

- `DesItalic`

- `Designator.Italic`

- `SourceText.Italic`



**Example:**

```pascal
Designator.Italic := False;
```

---


### `Layer`


**Common values:**

- `AssyLayer`

- `SourceText.Layer`

- `MechBot`



**Example:**

```pascal
NewTextObj.Layer                    := AssyLayer;
```

---


### `MirrorFlag`


**Common values:**

- `True`

- `False`



**Example:**

```pascal
if Comp.Layer = eTopLayer then NewTextObj.MirrorFlag := False
```

---


### `Multiline`


---


### `MultilineTextAutoPosition`


---


### `MultilineTextHeight`


**Common values:**

- `0`

- `DesMultilineTH`



**Example:**

```pascal
Designator.MultilineTextHeight := 0;
```

---


### `MultilineTextWidth`


**Common values:**

- `0`

- `DesMultilineTW`



**Example:**

```pascal
Designator.MultilineTextWidth  := 0;
```

---


### `Rotation`


**Common values:**

- `textObj.Rotation`

- `90 - Silkscreen.Rotation`

- `270`



**Example:**

```pascal
Designator.Rotation := 90
```

---


### `Selected`


**Common values:**

- `True`

- `False`



**Example:**

```pascal
Text.Selected := False;
```

---


### `SetState_XSizeYSize`


---


### `Size`


**Common values:**

- `SourceText.Size`

- `MMsToCoord(heightMm)`

- `Size`



**Example:**

```pascal
Designator.Size := CalculateSize(X,S,TextLength)
```

---


### `SnapPointX`


**Common values:**

- `Comp.x`

- `TargetComp.x + DeltaX`

- `CentroidX`



**Example:**

```pascal
NewTextObj.SnapPointX               := Comp.x;
```

---


### `SnapPointY`


**Common values:**

- `Comp.y`

- `CentroidY`

- `TargetComp.y + DeltaY`



**Example:**

```pascal
NewTextObj.SnapPointY               := Comp.y;
```

---


### `TTFInvertedTextJustify`


**Common values:**

- `Designator.TTFInvertedTextJustify`

- `SourceText.TTFInvertedTextJustify`

- `eAutoPos_CenterCenter`



**Example:**

```pascal
MechDesignator.TTFInvertedTextJustify := Designator.TTFInvertedTextJustify;
```

---


### `TTFOffsetFromInvertedRect`


**Common values:**

- `SourceText.TTFOffsetFromInvertedRect`



**Example:**

```pascal
TargetText.TTFOffsetFromInvertedRect    := SourceText.TTFOffsetFromInvertedRect;
```

---


### `TTFTextHeight`


**Common values:**

- `SourceText.TTFTextHeight`



**Example:**

```pascal
TargetText.TTFTextHeight                := SourceText.TTFTextHeight;
```

---


### `TTFTextWidth`


**Common values:**

- `SourceText.TTFTextWidth`



**Example:**

```pascal
TargetText.TTFTextWidth                 := SourceText.TTFTextWidth;
```

---


### `Text`


**Common values:**

- `text`

- `Parameter.DM_Value`

- `'.Legend'`



**Example:**

```pascal
TextObj.Text := ResultString;
```

---


### `TextKind`


**Common values:**

- `SourceText.TextKind`



**Example:**

```pascal
TargetText.TextKind                     := SourceText.TextKind;
```

---


### `UnderlyingString`


**Common values:**

- `'.Designator'`



**Example:**

```pascal
NewTextObj.UnderlyingString         := '.Designator';
```

---


### `UseInvertedRectangle`


**Common values:**

- `SourceText.UseInvertedRectangle`



**Example:**

```pascal
TargetText.UseInvertedRectangle         := SourceText.UseInvertedRectangle;
```

---


### `UseTTFonts`


**Common values:**

- `SourceText.UseTTFonts`

- `Designator.UseTTFonts`

- `True`



**Example:**

```pascal
Designator.UseTTFonts := True;
```

---


### `Width`


**Common values:**

- `MMsToCoord(widthMm)`

- `Designator.Size / cSilkTextWidthRatio`

- `Designator.Size / cTextWidthRatio`



**Example:**

```pascal
Designator.Width := Designator.Size / cTextWidthRatio;
```

---


### `WordWrap`


**Common values:**

- `False`



**Example:**

```pascal
NewTextObj.WordWrap                 := False;
```

---


### `XLocation`


**Common values:**

- `Comp.x`

- `PCBComponent.BoundingRectangleNoNameComment.Left`



**Example:**

```pascal
NewTextObj.XLocation                := Comp.x;
```

---


### `Xlocation`


**Common values:**

- `MMsToCoord(textXmm)`

- `Designator.Xlocation + DesignatorXmove`

- `MMsToCoord(Xmm)`



**Example:**

```pascal
eAutoPos_CenterLeft:Designator.Xlocation := Designator.Xlocation - DesignatorXmove;
```

---


### `YLocation`


**Common values:**

- `Comp.y`

- `PCBComponent.BoundingRectangleNoNameComment.Bottom - TextObj.Size - 2 * TextObj.Width`



**Example:**

```pascal
NewTextObj.YLocation                := Comp.y;
```

---


### `Ylocation`


**Common values:**

- `Designator.Ylocation - DesignatorXmove`

- `Designator.Ylocation + DesignatorXmove`

- `textObj.Ylocation + MilsToCoord(10)`



**Example:**

```pascal
eAutoPos_TopLeft:Designator.Ylocation := Designator.Ylocation - DesignatorXmove;
```

---


### `size`


**Common values:**

- `MilsToCoord(SlkSizeMils)`

- `SilkscreenFixedSize`

- `TextProperites.ValueFromIndex[_Index]`



**Example:**

```pascal
Silkscreen.size := SilkscreenFixedSize
```

---



====================================================================================================


# IPCB_Text3


**Category:** PCB


**API Surface:** 2 methods, 49 properties


---


## Methods (2)


### `IsSaveable()`


---


### `SetState_Selected()`


---


## Properties (49)


### `AdvanceSnapping`


---


### `AllowGlobalEdit`


---


### `BeginModify`


---


### `BoundingRectangle`


---


### `Component`


---


### `Descriptor`


---


### `Detail`


---


### `EnableDraw`


---


### `EndModify`


---


### `FontID`


---


### `GetState_Selected`


---


### `GraphicallyInvalidate`


---


### `Handle`


---


### `I_ObjectAddress`


---


### `Identifier`


---


### `IsComment`


---


### `IsDesignator`


---


### `IsHidden`


---


### `Layer`


---


### `MirrorFlag`


---


### `MiscFlag1`


---


### `MiscFlag2`


---


### `MiscFlag3`


---


### `Moveable`


---


### `Multiline`


---


### `MultilineTextAutoPosition`


---


### `MultilineTextHeight`


---


### `MultilineTextResizeEnabled`


---


### `MultilineTextWidth`


---


### `ObjectIDString`


---


### `ObjectId`


---


### `PadCacheRobotFlag`


---


### `Rotation`


---


### `Selected`


---


### `Size`


---


### `SnapPointX`


---


### `SnapPointY`


---


### `TTFInvertedTextJustify`


---


### `TTFTextHeight`


---


### `TTFTextWidth`


---


### `Text`


---


### `TextKind`


---


### `UnderlyingString`


---


### `UseTTFonts`


---


### `Used`


---


### `UserRouted`


---


### `ViewableObjectID`


---


### `Width`


---


### `WordWrap`


---



====================================================================================================


# IPCB_Track


**Category:** PCB


**API Surface:** 1 methods, 32 properties


---


## Methods (1)


### `Replicate()`


**Examples:**


*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Cleanup_LPW_Footprint.pas*

```pascal
{ Replicate source track. }
//   trackDst := trackSrc.Replicate();

//   { Move trackDst in x,y to remove annoying boardOrigin terms. }
```


*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Cleanup_LPW_Footprint.pas*

```pascal
{ Replicate the queued track and operate on that track. }
         trackNew := trackDst.Replicate();

         { Add new object to PcbLib footprint. }
```


---


## Properties (32)


### `BeginModify`


---


### `Descriptor`


---


### `Detail`


---


### `EndAngle`


**Common values:**

- `360`

- `Prim2.EndAngle`



**Example:**

```pascal
if Prim2.EndAngle   <= Prim1.EndAngle   then Prim1.EndAngle   := Prim2.EndAngle;
```

---


### `EndModify`


---


### `GetState_Length`


---


### `GraphicallyInvalidate`


---


### `I_ObjectAddress`


---


### `Identifier`


---


### `InNet`


---


### `Index`


---


### `Layer`


**Common values:**

- `Arc1.Layer`

- `eTopLayer`

- `trackSrc.Layer`



**Example:**

```pascal
Track.Layer    := Arc1.Layer;
```

---


### `LineWidth`


**Common values:**

- `Int(Prim.LineWidth * Ratio)`



**Example:**

```pascal
Prim.LineWidth := Int(Prim.LineWidth * Ratio);
```

---


### `Net`


**Common values:**

- `Arc1.Net`



**Example:**

```pascal
Track.Net      := Arc1.Net;
```

---


### `ObjectID`


---


### `ObjectIDString`


---


### `ObjectId`


---


### `Radius`


**Common values:**

- `Int(Prim.Radius * Ratio)`



**Example:**

```pascal
Prim.Radius    := Int(Prim.Radius * Ratio);
```

---


### `Selected`


**Common values:**

- `True`



**Example:**

```pascal
Track.Selected := True;
```

---


### `StartAngle`


**Common values:**

- `0`

- `Prim2.StartAngle`



**Example:**

```pascal
if Prim2.StartAngle <= Prim1.StartAngle then Prim1.StartAngle := Prim2.StartAngle;
```

---


### `UnionIndex`


**Common values:**

- `UnionIndex`



**Example:**

```pascal
Track.UnionIndex := UnionIndex;
```

---


### `Width`


**Common values:**

- `MMsToCoord(widthMm)`

- `MMsToCoord(newWidthMm3)`

- `Int(Prim.Width * Ratio)`



**Example:**

```pascal
Track.Width    := Arc1.LineWidth;
```

---


### `X1`


**Common values:**

- `X1`

- `MMsToCoord(CoordToMMs(trackSrc.X1 - boardXorigin))`

- `X`



**Example:**

```pascal
Track.X1       := ReturnArray[i*4+1];
```

---


### `X2`


**Common values:**

- `X2`

- `ReturnArray[i*4+3]`

- `MMsToCoord(CoordToMMs(trackSrc.X2 - boardXorigin))`



**Example:**

```pascal
Track.X2       := ReturnArray[i*4+3];
```

---


### `Y1`


**Common values:**

- `MMsToCoord(Y1mm)`

- `Y`

- `Y1`



**Example:**

```pascal
Track.Y1       := ReturnArray[i*4+2];
```

---


### `Y2`


**Common values:**

- `Y2`

- `MMsToCoord(Y2mm)`

- `Y`



**Example:**

```pascal
Track.Y2       := ReturnArray[i*4+4];
```

---


### `x`


**Common values:**

- `X + Int(Ratio * (Prim.x - X))`



**Example:**

```pascal
Prim.x := X + Int(Ratio * (Prim.x - X));
```

---


### `x1`


**Common values:**

- `Xp`

- `X21`

- `PointX`



**Example:**

```pascal
ATrack.x1 := ATrack.x1 + 1; // just a tiny nudge so undo will be able to recover track
```

---


### `x2`


**Common values:**

- `Xp`

- `X22`

- `PointX`



**Example:**

```pascal
Tr2.x2 := Arc.XCenter;
```

---


### `y`


**Common values:**

- `Y + Int(Ratio * (Prim.y - Y))`



**Example:**

```pascal
Prim.y := Y + Int(Ratio * (Prim.y - Y));
```

---


### `y1`


**Common values:**

- `Y11`

- `Y21`

- `Y`



**Example:**

```pascal
SecondTrack.y1 := SecondTrack.y1 + RemovedLength * sin(Angle[2]);
```

---


### `y2`


**Common values:**

- `Y22`

- `Track2Modify.y2 + Int(kModify * (DestinTrack.x2 - Track2Modify.x2))`

- `Y`



**Example:**

```pascal
Tr2.y2 := Arc.YCenter + Arc.Radius * 1.3;
```

---



====================================================================================================


# IPCB_Via


**Category:** PCB


**API Surface:** 6 methods, 33 properties


---


## Methods (6)


### `IntersectLayer()`


**Observed signatures:**

```pascal
IPCB_Via.IntersectLayer(Primitive.Layer)
```

```pascal
IPCB_Via.IntersectLayer(LayerObj.LayerID)
```

```pascal
IPCB_Via.IntersectLayer(PrimTrack.Layer)
```

**Examples:**


*From: Scripts - PCB\Distribute\Distribute.pas*

```pascal
// If PrimVia intersects the same layer as PrimTrack, use pad size on layer, otherwise use hole size
    if PrimVia.IntersectLayer(PrimTrack.Layer) then size := Max(PrimVia.StackSizeOnLayer(PrimTrack.Layer), PrimVia.HoleSize) else size := PrimVia.HoleSize;

    // Get the parameters of the track (only actually using 'k1', 'c1')
```


*From: Scripts - PCB\LengthTuningHelper\LengthTuningHelper.pas*

```pascal
While LayerObj <> nil do
   begin
      if Via.IntersectLayer(LayerObj.V7_LayerID) then
      begin
         if ILayer.IsSignalLayer(LayerObj.V7_LayerID) then
```


---


### `IsConnectedToPlane()`


**Observed signatures:**

```pascal
IPCB_Via.IsConnectedToPlane(Split.Layer)
```

**Examples:**


*From: Scripts - Outputs\Hyperlynx Exporter\Hyperlynx_Exporter.pas*

```pascal
// we will check weather it is connected to plane, so that we
                // know weather we have to make connection or clearence
                if Via.IsConnectedToPlane(Split.Layer) then
                begin
                   // This via is connected to this plane
```


---


### `PlaneConnectionStyleForLayer()`


**Observed signatures:**

```pascal
IPCB_Via.PlaneConnectionStyleForLayer(Split.Layer)
```

**Examples:**


*From: Scripts - Outputs\Hyperlynx Exporter\Hyperlynx_Exporter.pas*

```pascal
// Thermals
                   if Via.PlaneConnectionStyleForLayer(Split.Layer) = ePlaneReliefConnect then
                   begin
                      // We need to make 4 (or 2) holes here because these are thermals
```


*From: Scripts - Outputs\Hyperlynx Exporter\Hyperlynx_Exporter.pas*

```pascal
// Direct
                   if Via.PlaneConnectionStyleForLayer(Split.Layer) = ePlaneDirectConnect then
                   begin
                      // We need to make one hole here, and it is hole size
```


---


### `SizeOnLayer()`


**Observed signatures:**

```pascal
IPCB_Via.SizeOnLayer(Layer)
```

**Examples:**


*From: Scripts - General\FormatCopy\FormatCopy.pas*

```pascal
begin
                    DestinPrim.SetState_StackShapeOnLayer(Layer, Via.StackShapeOnLayer(Layer) );
                    DestinPrim.SizeOnLayer(Layer) := Via.SizeOnLayer(Layer);
                    DestinPrim.Setstate_StackSizeOnLayer(Layer, Via.StackSizeOnLayer(Layer) );
                end;
```


---


### `StackShapeOnLayer()`


---


### `StackSizeOnLayer()`


**Observed signatures:**

```pascal
IPCB_Via.StackSizeOnLayer(PrimTrack.Layer)
```

**Examples:**


*From: Scripts - PCB\Distribute\Distribute.pas*

```pascal
// If PrimVia intersects the same layer as PrimTrack, use pad size on layer, otherwise use hole size
    if PrimVia.IntersectLayer(PrimTrack.Layer) then size := Max(PrimVia.StackSizeOnLayer(PrimTrack.Layer), PrimVia.HoleSize) else size := PrimVia.HoleSize;

    // Get the parameters of the track (only actually using 'k1', 'c1')
```


---


## Properties (33)


### `BeginModify`


---


### `BoundingRectangle`


---


### `DefinitionLayerIterator`


---


### `Descriptor`


---


### `EndModify`


---


### `GetState_Cache`


---


### `GraphicallyInvalidate`


---


### `HighLayer`


**Common values:**

- `LayerObj.LayerID`

- `eBottomLayer`



**Example:**

```pascal
Via.HighLayer := LayerObj.LayerID
```

---


### `HoleSize`


**Common values:**

- `Rule.PreferedHoleWidth`

- `Rule.MaxHoleWidth`

- `MilsToCoord(20)`



**Example:**

```pascal
Via.HoleSize  := MilsToCoord(20);
```

---


### `I_ObjectAddress`


---


### `InNet`


---


### `IsConnectedToPlane`


---


### `IsTenting`


**Common values:**

- `True`



**Example:**

```pascal
NewVia.IsTenting := True;
```

---


### `IsTenting_Bottom`


---


### `IsTenting_Top`


---


### `LowLayer`


**Common values:**

- `LayerObj.LayerID`

- `eTopLayer`



**Example:**

```pascal
Via.LowLayer  := LayerObj.LayerID;
```

---


### `Mode`


**Common values:**

- `ePadMode_Simple`



**Example:**

```pascal
NewVia.Mode := ePadMode_Simple;
```

---


### `Net`


**Common values:**

- `Net`



**Example:**

```pascal
Via.Net := Net;
```

---


### `ObjectId`


---


### `PowerPlaneClearance`


---


### `PowerPlaneReliefExpansion`


---


### `ReliefAirGap`


---


### `ReliefConductorWidth`


---


### `ReliefEntries`


---


### `Selected`


**Common values:**

- `false`

- `True`

- `False`



**Example:**

```pascal
If ViaPad <> Nil Then ViaPad.Selected := false
```

---


### `Size`


**Common values:**

- `Rule.PreferedWidth`

- `MilsToCoord(50)`

- `MilsToCoord(StrToFloat(EditSize.Text))`



**Example:**

```pascal
Via.Size      := MilsToCoord(50);
```

---


### `StartLayer`


---


### `StopLayer`


---


### `TemplateLink`


---


### `X`


**Common values:**

- `PosX`



**Example:**

```pascal
NewVia.X    := PosX;
```

---


### `Y`


**Common values:**

- `PosY`



**Example:**

```pascal
NewVia.Y    := PosY;
```

---


### `x`


**Common values:**

- `X`



**Example:**

```pascal
Via.x := X;
```

---


### `y`


**Common values:**

- `Y`



**Example:**

```pascal
Via.y := Y;
```

---



====================================================================================================


# IPCB_Violation


**Category:** PCB


**API Surface:** 0 methods, 6 properties


---


## Properties (6)


### `BeginModify`


---


### `DRCError`


**Common values:**

- `False`



**Example:**

```pascal
Violation.DRCError := False;
```

---


### `Enabled`


---


### `EndModify`


---


### `Primitive1`


---


### `Used`


---



====================================================================================================


# IProject


**Category:** General


**API Surface:** 8 methods, 0 properties


---


## Methods (8)


### `DM_AddGeneratedDocument()`


**Observed signatures:**

```pascal
IProject.DM_AddGeneratedDocument(filePath)
```

```pascal
IProject.DM_AddGeneratedDocument(TargetFileName)
```

**Examples:**


*From: Scripts - Examples\SPI_Footprint_scripts\XIA_Generate_Sorted_Multiwire_Netlist.pas*

```pascal
{ What is this first step actually supposed to do??? }
   VFS_SetFileEditorName(TargetFileName, 'XIA_SortedMultiwireNetlist');
   Project.DM_AddGeneratedDocument(TargetFileName);
```


*From: Scripts - Examples\XIA_Release_Manager\XIA_Generate_Sorted_Multiwire_Netlist.pas*

```pascal
{ What is this first step actually supposed to do??? }
   VFS_SetFileEditorName(TargetFileName, 'XIA_SortedMultiwireNetlist');
   Project.DM_AddGeneratedDocument(TargetFileName);
```


---


### `DM_AddSourceDocument()`


**Observed signatures:**

```pascal
IProject.DM_AddSourceDocument(constApprovedDblinkFilePath)
```

```pascal
IProject.DM_AddSourceDocument(constRequiredDbLibFilePath)
```

```pascal
IProject.DM_AddSourceDocument(addRemoveMePath)
```

**Examples:**


*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Cleanup_LPW_Footprint.pas*

```pascal
if ( (action = 'add') and (not found) ) then
   begin
      project.DM_AddSourceDocument(addRemoveMePath);
      WriteToDebugFile(' Adding document "' + addRemoveMePath + '" to project.');
   end;
```


*From: Scripts - Examples\XIA_Release_Manager\XIA_Update_From_Database.pas*

```pascal
{ Attempt to add our XIA_Database_Kludged_no_sym_no_desc_no_footprints.DBLib file, with the proper path. }
      Project.DM_AddSourceDocument(constRequiredDbLibFilePath);
      WriteToDebugFile('Added required DBLib file "' + constRequiredDbLibFilePath + '" to project.');
      WriteToSummaryFile('INFO:     ' + 'Added required DBLib file "' + constRequiredDbLibFilePath + '" to project.');
```


---


### `DM_GeneratedDocuments()`


**Observed signatures:**

```pascal
IProject.DM_GeneratedDocuments(i)
```

```pascal
IProject.DM_GeneratedDocuments(k)
```

**Examples:**


*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Commit_Release_Tag.pas*

```pascal
{ Retrieve reference to kth document in project. }
      document := Project.DM_GeneratedDocuments(k);
      WriteToDebugFile(' Examining project generated file ' + document.DM_FullPath);
```


*From: Scripts - Examples\XIA_Release_Manager\XIA_Release_Manager.pas*

```pascal
{ Extract the full filename of this generated file. }
      genFile := Project.DM_GeneratedDocuments(i).DM_FullPath;
      
      WriteToDebugFile('*Examining generated file "' + genFile + '".');
```


---


### `DM_LogicalDocuments()`


**Observed signatures:**

```pascal
IProject.DM_LogicalDocuments(k)
```

```pascal
IProject.DM_LogicalDocuments(DocNum)
```

```pascal
IProject.DM_LogicalDocuments(I)
```

**Examples:**


*From: Scripts - SCH\CreateTableOfContents\CreateTableOfContentsForm.pas*

```pascal
For LoopIterator:= 1 to LogicalDocumentCount do
    begin
         CurrentSheet := CurrentProject.DM_LogicalDocuments(LoopIterator-1) ;
         if CurrentSheet.DM_DocumentKind = 'SCH' then
            begin
```


*From: Scripts - SCH\GetPinData\GetPinData.pas*

```pascal
for i := 0 to project.DM_LogicalDocumentCount - 1 do
    begin
        document := project.DM_LogicalDocuments(i);

        // for each DM_Nets in document...
```


---


### `DM_Parameters()`


**Observed signatures:**

```pascal
IProject.DM_Parameters(i)
```

**Examples:**


*From: Scripts - Examples\XIA_Release_Manager\XIA_Release_Manager.pas*

```pascal
{ Get current parameter. }
      CurrParm := Project.DM_Parameters(i);

      WriteToDebugFile('Examining project parameter index ' + IntToStr(i) + ' named "' + CurrParm.DM_Name + '", value is "' + CurrParm.DM_Value + '".');
```


---


### `DM_PhysicalDocuments()`


**Observed signatures:**

```pascal
IProject.DM_PhysicalDocuments(DocNum)
```

**Examples:**


*From: Scripts - General\DesignReuse\DesignReuse.pas*

```pascal
for DocNum := 0 to PcbProject.DM_PhysicalDocumentCount - 1 do
   begin
      Document := PCBProject.DM_PhysicalDocuments(DocNum);

      // Remember top level document
```


---


### `DM_ProjectVariants()`


**Observed signatures:**

```pascal
IProject.DM_ProjectVariants(VariantNum)
```

```pascal
IProject.DM_ProjectVariants(i)
```

**Examples:**


*From: Scripts - PCB\VariantFilter\VariantFilter.pas*

```pascal
for VariantNum := 0 to PCBProject.DM_ProjectVariantCount - 1 do
   begin;
      Variant := PCBProject.DM_ProjectVariants(VariantNum);
      VarArray[VariantNum] := Variant.DM_Description;
   end;
```


*From: Scripts - PCB\VariantFilter\VariantFilter.pas*

```pascal
Line := '';
      VariantNum := variantsel -1;
      Variant := PCBProject.DM_ProjectVariants(VariantNum);
      CompVariation := Variant.DM_FindComponentVariationByUniqueId(Component.DM_UniqueId);
```


---


### `DM_RemoveSourceDocument()`


**Observed signatures:**

```pascal
IProject.DM_RemoveSourceDocument(document.DM_FullPath)
```

```pascal
IProject.DM_RemoveSourceDocument(addRemoveMePath)
```

**Examples:**


*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Cleanup_LPW_Footprint.pas*

```pascal
if (action = 'remove') then
         begin
            project.DM_RemoveSourceDocument(addRemoveMePath);
            WriteToDebugFile(' Removing document "' + addRemoveMePath + '" from project.');
         end;
```


*From: Scripts - Examples\XIA_Release_Manager\XIA_Update_From_Database.pas*

```pascal
WriteToDebugFile('Removing DBLib file "' + document.DM_FullPath + '" from project.');
            WriteToSummaryFile('INFO:     ' + 'Removing DBLib file "' + document.DM_FullPath + '" from project.');
            Project.DM_RemoveSourceDocument(document.DM_FullPath);
            
            { Add project file to the list of changed files. }
```


---



====================================================================================================


# ISch_BasicContainer


**Category:** Schematic


**API Surface:** 2 methods, 3 properties


---


## Methods (2)


### `RemoveSchObject()`


**Observed signatures:**

```pascal
ISch_BasicContainer.RemoveSchObject(obj)
```

**Examples:**


*From: Scripts - SCH\TemplateTool\ExtractTemplate.pas*

```pascal
obj := obj_list.Items(i);
        new_obj := obj.Replicate;
        FromContainer.RemoveSchObject(obj);
        ToContainer.RegisterSchObjectInContainer(new_obj);
//        new_obj.GraphicallyInvalidate;
```


*From: Scripts - SCH\TemplateTool\SaveTemplate.pas*

```pascal
obj := obj_list.Items[i];
        ToContainer.AddSchObject(obj);
        FromContainer.RemoveSchObject(obj);
    end;
    obj_list.Free;
```


---


### `SchIterator_Destroy()`


**Observed signatures:**

```pascal
ISch_BasicContainer.SchIterator_Destroy(iter)
```

**Examples:**


*From: Scripts - SCH\TemplateTool\ExtractTemplate.pas*

```pascal
child := iter.NextSchObject;
    end;
    Container.SchIterator_Destroy(iter);
end;
{..............................................................................}
```


*From: Scripts - SCH\TemplateTool\SaveTemplate.pas*

```pascal
child := iter.NextSchObject;
    end;
    Container.SchIterator_Destroy(iter);
end;
{..............................................................................}
```


---


## Properties (3)


### `ObjectId`


---


### `Replicate`


---


### `SchIterator_Create`


---



====================================================================================================


# ISch_Component


**Category:** Schematic


**API Surface:** 5 methods, 23 properties


---


## Methods (5)


### `FullPartDesignator()`


**Observed signatures:**

```pascal
ISch_Component.FullPartDesignator(0)
```

**Examples:**


*From: Scripts - SCH\GetPinData\GetPinData.pas*

```pascal
component := objectList.First;
    componentName := component.Comment.CalculatedValueString;
    componentDesignator := component.FullPartDesignator(0);

    str := ',' + componentName + ',' + projectName;
```


---


### `Mirror()`


**Observed signatures:**

```pascal
ISch_Component.Mirror(CompOrigin)
```

**Examples:**


*From: Scripts - SCH\RotateSymbol\RotateSymbol.pas*

```pascal
// mirror component
            Comp.Mirror(CompOrigin);

            // mirror parameters back to original position
```


---


### `RotateBy90()`


**Observed signatures:**

```pascal
ISch_Component.RotateBy90(CompOrigin, eRotate270)
```

```pascal
ISch_Component.RotateBy90(CompOrigin, eRotate90)
```

**Examples:**


*From: Scripts - SCH\RotateSymbol\RotateSymbol.pas*

```pascal
// rotate part in place by 90°
            if Clockwise then Comp.RotateBy90(CompOrigin, eRotate270) else Comp.RotateBy90(CompOrigin, eRotate90);

            // rotate all the parameters 90° the other way using part as origin
```


*From: Scripts - SCH\RotateSymbol\RotateSymbol.pas*

```pascal
// rotate part in place by 90°
            if Clockwise then Comp.RotateBy90(CompOrigin, eRotate270) else Comp.RotateBy90(CompOrigin, eRotate90);

            // rotate all the parameters 90° the other way using part as origin
```


---


### `SchIterator_Destroy()`


**Observed signatures:**

```pascal
ISch_Component.SchIterator_Destroy(ParamIter)
```

```pascal
ISch_Component.SchIterator_Destroy(PinIter)
```

```pascal
ISch_Component.SchIterator_Destroy(ParamIterator)
```

**Examples:**


*From: Scripts - SCH\AddWireStubsSch\AddWireStubsSch-Form.pas*

```pascal
Finally
		SchComponent.SchIterator_Destroy(PinIterator);
		End;
		End;
```


*From: Scripts - SCH\HideShowParametersSch\HideShowParameters.pas*

```pascal
end;
                finally
                    Component.SchIterator_Destroy(ParamIterator);
                end;
```


---


### `SetState_OrientationWithoutRotating()`


**Observed signatures:**

```pascal
ISch_Component.SetState_OrientationWithoutRotating(eRotate90)
```

```pascal
ISch_Component.SetState_OrientationWithoutRotating(eRotate180)
```

```pascal
ISch_Component.SetState_OrientationWithoutRotating(eRotate270)
```

**Examples:**


*From: Scripts - SCH\RotateSymbol\RotateSymbol.pas*

```pascal
case InitOrientation of
            eRotate0    : begin
                if Clockwise then Comp.SetState_OrientationWithoutRotating(eRotate270) else Comp.SetState_OrientationWithoutRotating(eRotate90);
            end;
            eRotate90   : begin
```


*From: Scripts - SCH\RotateSymbol\RotateSymbol.pas*

```pascal
case InitOrientation of
            eRotate0    : begin
                if Clockwise then Comp.SetState_OrientationWithoutRotating(eRotate270) else Comp.SetState_OrientationWithoutRotating(eRotate90);
            end;
            eRotate90   : begin
```


---


## Properties (23)


### `Comment`


---


### `CurrentPartID`


---


### `Description`


---


### `Designator`


---


### `GetState_Orientation`


---


### `GraphicallyInvalidate`


---


### `I_ObjectAddress`


---


### `IsMultiPartComponent`


---


### `LibReference`


---


### `Location`


---


### `Name`


---


### `PartCount`


---


### `Pattern`


---


### `SchIterator_Create`


---


### `Selected`


---


### `Selection`


**Common values:**

- `True`



**Example:**

```pascal
Component.Selection := True;    // write new designator to the component
```

---


### `SourceFootprintLibrary`


---


### `SourceLibReference`


---


### `SourceLibraryName`


---


### `SymbolReference`


---


### `UniqueId`


---


### `UpdatePart_PostProcess`


---


### `UpdatePart_PreProcess`


---



====================================================================================================


# ISch_Document


**Category:** Schematic


**API Surface:** 6 methods, 17 properties


---


## Methods (6)


### `AddSchObject()`


**Observed signatures:**

```pascal
ISch_Document.AddSchObject(NoERC)
```

```pascal
ISch_Document.AddSchObject(Parameter)
```

```pascal
ISch_Document.AddSchObject(SchNetlabel)
```

**Examples:**


*From: Scripts - SCH\AddWireStubsSch\AddWireStubsSch-Form.pas*

```pascal
If SchNetlabel = Nil Then Exit;

	SchDoc.AddSchObject(SchNetlabel);

	SchNetlabel.Text        := Text;
```


*From: Scripts - SCH\CreateTableOfContents\CreateTableOfContentsForm.pas*

```pascal
Parameter.Text     := ParameterText ;
     Parameter.IsHidden := True ;
     SheetTOC.AddSchObject(Parameter) ;
end ;
```


---


### `ChooseLocationInteractively()`


**Observed signatures:**

```pascal
ISch_Document.ChooseLocationInteractively(ALoc,'Choose Second Pin')
```

```pascal
ISch_Document.ChooseLocationInteractively(ALoc, Tekst)
```

```pascal
ISch_Document.ChooseLocationInteractively(ALoc,'Choose Second Component')
```

**Examples:**


*From: Scripts - General\IncrementDesignators\IncrementDesignators.pas*

```pascal
else                         Tekst := 'Choose Component';

       boolLoc := SchDoc.ChooseLocationInteractively(ALoc, Tekst);

       If Not boolLoc Then Exit;
```


*From: Scripts - General\IncrementDesignators\IncrementDesignators.pas*

```pascal
// Getting second component
           boolLoc := SchDoc.ChooseLocationInteractively(ALoc,'Choose Second Component');
           If Not boolLoc Then Exit;
```


---


### `ChooseRectangleInteractively()`


---


### `RegisterSchObjectInContainer()`


**Observed signatures:**

```pascal
ISch_Document.RegisterSchObjectInContainer(SchWire)
```

```pascal
ISch_Document.RegisterSchObjectInContainer(Wire)
```

```pascal
ISch_Document.RegisterSchObjectInContainer(NetLabel)
```

**Examples:**


*From: Scripts - SCH\AddWireStubsSch\AddWireStubsSch-Form.pas*

```pascal
SchWire.SetState_Vertex(I, Point(MilsToCoord(X), MilsToCoord(Y)));
	End;
	SchDoc.RegisterSchObjectInContainer(SchWire);
End;
{..............................................................................}
```


*From: Scripts - FPGA\VendorTools\VendorTools.pas*

```pascal
Wire.SetState_Vertex(2, Point(X2, Y2));

                             SchDoc.RegisterSchObjectInContainer(Wire);

                             SchServer.RobotManager.SendMessage(SchDoc.I_ObjectAddress,c_BroadCast,
```


---


### `RemoveSchObject()`


**Observed signatures:**

```pascal
ISch_Document.RemoveSchObject(new_template)
```

```pascal
ISch_Document.RemoveSchObject(TempNoERC)
```

```pascal
ISch_Document.RemoveSchObject(TempLabel)
```

**Examples:**


*From: Scripts - SCH\CreateTableOfContents\CreateTableOfContentsForm.pas*

```pascal
ObjectToDelete := ObjectSelect ;
                 ObjectSelect := Iterator.NextSchObject;
                 SheetTOC.RemoveSchObject(ObjectToDelete);
                 SheetTOC.GraphicallyInvalidate;
            end
```


*From: Scripts - SCH\CreateTableOfContents\CreateTableOfContentsForm.pas*

```pascal
ObjectToDelete := ObjectSelect ;
                  ObjectSelect := Iterator.NextSchObject ;
                  SheetTOC.RemoveSchObject(ObjectToDelete) ;
            end
         else ObjectSelect := Iterator.NextSchObject ;
```


---


### `SchIterator_Destroy()`


**Observed signatures:**

```pascal
ISch_Document.SchIterator_Destroy(Iterator)
```

```pascal
ISch_Document.SchIterator_Destroy(NetItr)
```

```pascal
ISch_Document.SchIterator_Destroy(SpatialIterator)
```

**Examples:**


*From: Scripts - SCH\AddWireStubsSch\AddWireStubsSch-Form.pas*

```pascal
End;
	Finally
		SchDoc.SchIterator_Destroy(SpatialIterator);
	End;
End;
```


*From: Scripts - SCH\AddWireStubsSch\AddWireStubsSch-Form.pas*

```pascal
End;
		Finally
		SchDoc.SchIterator_Destroy(SchIterator);
		if (componentCount = 0) then
		begin
```


---


## Properties (17)


### `CustomX`


**Common values:**

- `sheet.CustomX`



**Example:**

```pascal
new_sheet.CustomX := sheet.CustomX;
```

---


### `CustomY`


**Common values:**

- `sheet.CustomY`



**Example:**

```pascal
new_sheet.CustomY := sheet.CustomY;
```

---


### `DocumentName`


---


### `GetState_SheetSizeY`


---


### `GraphicallyInvalidate`


---


### `I_ObjectAddress`


---


### `IsLibrary`


---


### `ReferenceZonesOn`


**Common values:**

- `False`



**Example:**

```pascal
new_sheet.ReferenceZonesOn := False;
```

---


### `SchIterator_Create`


---


### `SheetSizeX`


**Common values:**

- `sheet.SheetSizeX`



**Example:**

```pascal
new_sheet.SheetSizeX := sheet.SheetSizeX;
```

---


### `SheetSizeY`


**Common values:**

- `sheet.SheetSizeY`



**Example:**

```pascal
new_sheet.SheetSizeY := sheet.SheetSizeY;
```

---


### `SheetXSize`


**Common values:**

- `sheet.SheetXSize`



**Example:**

```pascal
new_sheet.SheetXSize := sheet.SheetXSize;
```

---


### `SheetYSize`


**Common values:**

- `sheet.SheetYSize`



**Example:**

```pascal
new_sheet.SheetYSize := sheet.SheetYSize;
```

---


### `TitleBlockOn`


**Common values:**

- `False`



**Example:**

```pascal
new_sheet.TitleBlockOn     := False;
```

---


### `UpdateDocumentProperties`


---


### `UseCustomSheet`


**Common values:**

- `true`



**Example:**

```pascal
new_sheet.UseCustomSheet := true;
```

---


### `VisibleGridSize`


---



====================================================================================================


# ISch_GraphicalObject


**Category:** Schematic


**API Surface:** 0 methods, 4 properties


---


## Properties (4)


### `Justification`


**Common values:**

- `eJustify_BottomLeft`

- `eJustify_TopLeft`

- `eJustify_BottomRight`



**Example:**

```pascal
eJustify_BottomLeft     : txt.Justification := eJustify_BottomRight;
```

---


### `Selection`


---


### `justification`


---


### `selection`


---



====================================================================================================


# ISch_HitTest


**Category:** Schematic


**API Surface:** 1 methods, 1 properties


---


## Methods (1)


### `HitObject()`


**Observed signatures:**

```pascal
ISch_HitTest.HitObject(I)
```

**Examples:**


*From: Scripts - General\FormatCopy\FormatCopy.pas*

```pascal
iBestWeight := 0;
                        bRepeat := false;
                        SchTempPrim := HitTest.HitObject(I);

                        Case SchTempPrim.ObjectId of
```


*From: Scripts - General\FormatCopy\FormatCopy.pas*

```pascal
for I := 0 to (HitTest.HitTestCount - 1) do
                begin
                    SchTempPrim := HitTest.HitObject(I);

                    Case SchTempPrim.ObjectId of
```


---


## Properties (1)


### `HitTestCount`


---



====================================================================================================


# ISch_Implementation


**Category:** Schematic


**API Surface:** 1 methods, 10 properties


---


## Methods (1)


### `GetState_SchDatafileLink()`


**Observed signatures:**

```pascal
ISch_Implementation.GetState_SchDatafileLink(k)
```

**Examples:**


*From: Scripts - Parts library\OpenLib\libUtils.pas*

```pascal
for k:= 0 to SchModel.DatafileLinkCount-1 do
                begin
                     SchModelDataFileLink := SchModel.GetState_SchDatafileLink(k);

                     //SchModelDataFileLink.EntityName;
```


*From: Scripts - Parts library\OpenLib\SchLibOpenFootprintInteractive.pas*

```pascal
for k:= 0 to SchModel.DatafileLinkCount-1 do
                begin
                     SchModelDataFileLink := SchModel.GetState_SchDatafileLink(k);

                     SchModelDataFileLink.EntityName;
```


---


## Properties (10)


### `ClearAllDatafileLinks`


---


### `DatabaseModel`


---


### `DatafileLink`


---


### `DatafileLinkCount`


---


### `Description`


**Common values:**

- `''`



**Example:**

```pascal
Model.Description := '';
```

---


### `I_ObjectAddress`


---


### `IsCurrent`


**Common values:**

- `current`

- `False`



**Example:**

```pascal
Model.IsCurrent   := False;
```

---


### `MapAsString`


**Common values:**

- `''`



**Example:**

```pascal
Model.MapAsString := '';
```

---


### `ModelName`


**Common values:**

- `dbParmValue`



**Example:**

```pascal
Model.ModelName   := dbParmValue;
```

---


### `ModelType`


**Common values:**

- `constKindPcbLib`



**Example:**

```pascal
Model.ModelType   := constKindPcbLib;
```

---



====================================================================================================


# ISch_Iterator


**Category:** Schematic


**API Surface:** 4 methods, 8 properties


---


## Methods (4)


### `AddFilter_Area()`


**Observed signatures:**

```pascal
ISch_Iterator.AddFilter_Area(X-1, Y-Len-1, X+1, Y-Len+1)
```

```pascal
ISch_Iterator.AddFilter_Area(ALoc.X, ALoc.Y, ALoc.X+1, ALoc.Y+1)
```

```pascal
ISch_Iterator.AddFilter_Area(Location.X - 1, Location.Y - 1, Location.X + 1, Location.Y + 1)
```

**Examples:**


*From: Scripts - SCH\AddWireStubsSch\AddWireStubsSch-Form.pas*

```pascal
Case Orientation Of
			eRotate0   : Begin
				SpatialIterator.AddFilter_Area(X+Len-1, Y-1, X+Len+1, Y+1);
			End;
			eRotate90  : Begin
```


*From: Scripts - SCH\AddWireStubsSch\AddWireStubsSch-Form.pas*

```pascal
End;
			eRotate90  : Begin
				SpatialIterator.AddFilter_Area(X-1, Y+Len-1, X+1, Y+Len+1);
			End;
			eRotate180 : Begin
```


---


### `AddFilter_ObjectSet()`


**Observed signatures:**

```pascal
ISch_Iterator.AddFilter_ObjectSet(MkSet(ePowerObject)
```

```pascal
ISch_Iterator.AddFilter_ObjectSet(MkSet(eComponentObject)
```

```pascal
ISch_Iterator.AddFilter_ObjectSet(MkSet(eSignalHarness)
```

**Examples:**


*From: Scripts - SCH\AddWireStubsSch\AddWireStubsSch-Form.pas*

```pascal
// Create an iterator to look for components only
	SchIterator := SchDoc.SchIterator_Create;
	SchIterator.AddFilter_ObjectSet(MkSet(eSchComponent));

	GridSize := SchDoc.VisibleGridSize / cInternalPrecision;
```


*From: Scripts - SCH\AddWireStubsSch\AddWireStubsSch-Form.pas*

```pascal
// Look for Pins associated with this component.
				PinIterator := SchComponent.SchIterator_Create;
				PinIterator.AddFilter_ObjectSet(MkSet(ePin));
				PinIterator.AddFilter_CurrentPartPrimitives;
				Try
```


---


### `Addfilter_ObjectSet()`


---


### `SetState_IterationDepth()`


**Observed signatures:**

```pascal
ISch_Iterator.SetState_IterationDepth(eIterateAllLevels)
```

```pascal
ISch_Iterator.SetState_IterationDepth(eIterateFirstLevel)
```

**Examples:**


*From: Scripts - SCH\CreateTableOfContents\CreateTableOfContentsForm.pas*

```pascal
Begin
     Iterator := SheetTOC.SchIterator_Create ;
     Iterator.SetState_IterationDepth(eIterateFirstLevel) ;
     Iterator.AddFilter_ObjectSet(MkSet(eParameter)) ;
     ReturnValue := False ;
```


*From: Scripts - SCH\CreateTableOfContents\CreateTableOfContentsForm.pas*

```pascal
// Set up iterator to look for schematic sheet parameters
    Iterator := SheetTOC.SchIterator_Create;
    Iterator.SetState_IterationDepth(eIterateFirstLevel);
    Iterator.AddFilter_ObjectSet(MkSet(eParameter));
    Try
```


---


## Properties (8)


### `AddFilter_CurrentDisplayModePrimitives`


---


### `AddFilter_CurrentPartPrimitives`


---


### `FirstPCBObject`


---


### `FirstSCHObject`


---


### `FirstSchObject`


---


### `NextPCBObject`


---


### `NextSchObject`


---


### `SetState_FilterAll`


---



====================================================================================================


# ISch_ModelDatafileLink


**Category:** Schematic


**API Surface:** 0 methods, 3 properties


---


## Properties (3)


### `EntityName`


---


### `FileKind`


---


### `Location`


---



====================================================================================================


# ISch_Netlabel


**Category:** Schematic


**API Surface:** 2 methods, 4 properties


---


## Methods (2)


### `MoveToXY()`


**Observed signatures:**

```pascal
ISch_Netlabel.MoveToXY(MilsToCoord(X)
```

**Examples:**


*From: Scripts - SCH\AddWireStubsSch\AddWireStubsSch-Form.pas*

```pascal
SchNetlabel.MoveToXY(MilsToCoord(X), MilsToCoord(Y));
	SchNetlabel.RotateBy90(Point(MilsToCoord(X), MilsToCoord(Y)), Rotate);
```


---


### `RotateBy90()`


**Observed signatures:**

```pascal
ISch_Netlabel.RotateBy90(Point(MilsToCoord(X)
```

**Examples:**


*From: Scripts - SCH\AddWireStubsSch\AddWireStubsSch-Form.pas*

```pascal
SchNetlabel.MoveToXY(MilsToCoord(X), MilsToCoord(Y));
	SchNetlabel.RotateBy90(Point(MilsToCoord(X), MilsToCoord(Y)), Rotate);

	SchNetlabel.SetState_xSizeySize;
```


---


## Properties (4)


### `GraphicallyInvalidate`


---


### `I_ObjectAddress`


---


### `SetState_xSizeySize`


---


### `Text`


**Common values:**

- `Text`



**Example:**

```pascal
SchNetlabel.Text        := Text;
```

---



====================================================================================================


# ISch_NoERC


**Category:** Schematic


**API Surface:** 0 methods, 1 properties


---


## Properties (1)


### `I_ObjectAddress`


---



====================================================================================================


# ISch_Object


**Category:** Schematic


**API Surface:** 7 methods, 65 properties


---


## Methods (7)


### `SetState_ComponentDescription()`


**Observed signatures:**

```pascal
ISch_Object.SetState_ComponentDescription(SchSourcePrim.GetState_ComponentDescription)
```

**Examples:**


*From: Scripts - General\FormatCopy\FormatCopy.pas*

```pascal
SchDestinPrim.Designator.SetState_ShowName  (SchSourcePrim.Designator.ShowName);
            SchDestinPrim.Comment.SetState_ShowName     (SchSourcePrim.Comment.ShowName);
            SchDestinPrim.SetState_ComponentDescription (SchSourcePrim.GetState_ComponentDescription);
            SchDestinPrim.SetState_OverideColors        (SchSourcePrim.OverideColors);
            SchDestinPrim.PinColor                    := SchSourcePrim.PinColor;
```


---


### `SetState_ComponentKind()`


**Observed signatures:**

```pascal
ISch_Object.SetState_ComponentKind(SchSourcePrim.ComponentKind)
```

**Examples:**


*From: Scripts - General\FormatCopy\FormatCopy.pas*

```pascal
SchDestinPrim.SetState_DisplayMode          (SchSourcePrim.DisplayMode);
            SchDestinPrim.SetState_IsMirrored           (SchSourcePrim.IsMirrored);
            SchDestinPrim.SetState_ComponentKind        (SchSourcePrim.ComponentKind);
            SchDestinPrim.SetState_ShowHiddenFields     (SchSourcePrim.ShowHiddenFields);
            SchDestinPrim.SetState_ShowHiddenPins       (SchSourcePrim.ShowHiddenPins);
```


---


### `SetState_DisplayMode()`


**Observed signatures:**

```pascal
ISch_Object.SetState_DisplayMode(SchSourcePrim.DisplayMode)
```

**Examples:**


*From: Scripts - General\FormatCopy\FormatCopy.pas*

```pascal
eSchComponent :  // ISch_GraphicalObject/ISch_ParametrizedGroup/ISch_Component
        begin
            SchDestinPrim.SetState_DisplayMode          (SchSourcePrim.DisplayMode);
            SchDestinPrim.SetState_IsMirrored           (SchSourcePrim.IsMirrored);
            SchDestinPrim.SetState_ComponentKind        (SchSourcePrim.ComponentKind);
```


---


### `SetState_IsMirrored()`


**Observed signatures:**

```pascal
ISch_Object.SetState_IsMirrored(SchSourcePrim.IsMirrored)
```

**Examples:**


*From: Scripts - General\FormatCopy\FormatCopy.pas*

```pascal
begin
            SchDestinPrim.SetState_DisplayMode          (SchSourcePrim.DisplayMode);
            SchDestinPrim.SetState_IsMirrored           (SchSourcePrim.IsMirrored);
            SchDestinPrim.SetState_ComponentKind        (SchSourcePrim.ComponentKind);
            SchDestinPrim.SetState_ShowHiddenFields     (SchSourcePrim.ShowHiddenFields);
```


---


### `SetState_OverideColors()`


**Observed signatures:**

```pascal
ISch_Object.SetState_OverideColors(SchSourcePrim.OverideColors)
```

**Examples:**


*From: Scripts - General\FormatCopy\FormatCopy.pas*

```pascal
SchDestinPrim.Comment.SetState_ShowName     (SchSourcePrim.Comment.ShowName);
            SchDestinPrim.SetState_ComponentDescription (SchSourcePrim.GetState_ComponentDescription);
            SchDestinPrim.SetState_OverideColors        (SchSourcePrim.OverideColors);
            SchDestinPrim.PinColor                    := SchSourcePrim.PinColor;
            SchDestinPrim.SetState_xSizeySize;
```


---


### `SetState_ShowHiddenFields()`


**Observed signatures:**

```pascal
ISch_Object.SetState_ShowHiddenFields(SchSourcePrim.ShowHiddenFields)
```

**Examples:**


*From: Scripts - General\FormatCopy\FormatCopy.pas*

```pascal
SchDestinPrim.SetState_IsMirrored           (SchSourcePrim.IsMirrored);
            SchDestinPrim.SetState_ComponentKind        (SchSourcePrim.ComponentKind);
            SchDestinPrim.SetState_ShowHiddenFields     (SchSourcePrim.ShowHiddenFields);
            SchDestinPrim.SetState_ShowHiddenPins       (SchSourcePrim.ShowHiddenPins);
            SchDestinPrim.Designator.SetState_ShowName  (SchSourcePrim.Designator.ShowName);
```


---


### `SetState_ShowHiddenPins()`


**Observed signatures:**

```pascal
ISch_Object.SetState_ShowHiddenPins(SchSourcePrim.ShowHiddenPins)
```

**Examples:**


*From: Scripts - General\FormatCopy\FormatCopy.pas*

```pascal
SchDestinPrim.SetState_ComponentKind        (SchSourcePrim.ComponentKind);
            SchDestinPrim.SetState_ShowHiddenFields     (SchSourcePrim.ShowHiddenFields);
            SchDestinPrim.SetState_ShowHiddenPins       (SchSourcePrim.ShowHiddenPins);
            SchDestinPrim.Designator.SetState_ShowName  (SchSourcePrim.Designator.ShowName);
            SchDestinPrim.Comment.SetState_ShowName     (SchSourcePrim.Comment.ShowName);
```


---


## Properties (65)


### `Alignment`


**Common values:**

- `SchSourcePrim.Alignment`



**Example:**

```pascal
SchDestinPrim.Alignment   := SchSourcePrim.Alignment;
```

---


### `AreaColor`


**Common values:**

- `SchSourcePrim.AreaColor`



**Example:**

```pascal
SchDestinPrim.AreaColor := SchSourcePrim.AreaColor;
```

---


### `ArrowKind`


**Common values:**

- `SchSourcePrim.ArrowKind`



**Example:**

```pascal
SchDestinPrim.ArrowKind      := SchSourcePrim.ArrowKind;
```

---


### `Author`


**Common values:**

- `SchSourcePrim.Author`



**Example:**

```pascal
SchDestinPrim.Author        := SchSourcePrim.Author;
```

---


### `Autoposition`


**Common values:**

- `SchSourcePrim.Autoposition`



**Example:**

```pascal
SchDestinPrim.Autoposition   := SchSourcePrim.Autoposition;
```

---


### `BorderWidth`


**Common values:**

- `SchSourcePrim.BorderWidth`



**Example:**

```pascal
SchDestinPrim.BorderWidth := SchSourcePrim.BorderWidth;
```

---


### `ClipToRect`


**Common values:**

- `SchSourcePrim.ClipToRect`



**Example:**

```pascal
SchDestinPrim.ClipToRect  := SchSourcePrim.ClipToRect;
```

---


### `Collapsed`


**Common values:**

- `SchSourcePrim.Collapsed`



**Example:**

```pascal
SchDestinPrim.Collapsed      := SchSourcePrim.Collapsed;
```

---


### `Color`


**Common values:**

- `SchSourcePrim.Color`

- `SchSourcePrim.TextColor`



**Example:**

```pascal
SchDestinPrim.Color     := SchSourcePrim.Color;
```

---


### `Comment`


---


### `ComponentKind`


---


### `CornerXRadius`


**Common values:**

- `SchSourcePrim.CornerXRadius`



**Example:**

```pascal
SchDestinPrim.CornerXRadius := SchSourcePrim.CornerXRadius;
```

---


### `CornerYRadius`


**Common values:**

- `SchSourcePrim.CornerYRadius`



**Example:**

```pascal
SchDestinPrim.CornerYRadius := SchSourcePrim.CornerYRadius;
```

---


### `CrossSheetStyle`


**Common values:**

- `SchSourcePrim.CrossSheetStyle`



**Example:**

```pascal
SchDestinPrim.CrossSheetStyle := SchSourcePrim.CrossSheetStyle;
```

---


### `Designator`


---


### `DisplayMode`


---


### `EndAngle`


**Common values:**

- `SchSourcePrim.EndAngle`



**Example:**

```pascal
SchDestinPrim.EndAngle      := SchSourcePrim.EndAngle;
```

---


### `EndLineShape`


**Common values:**

- `SchSourcePrim.EndLineShape`



**Example:**

```pascal
SchDestinPrim.EndLineShape   := SchSourcePrim.EndLineShape;
```

---


### `FontID`


**Common values:**

- `SchSourcePrim.TextFontID`

- `SchSourcePrim.FontID`



**Example:**

```pascal
SchDestinPrim.FontID        := SchSourcePrim.FontID;
```

---


### `FontId`


**Common values:**

- `SchSourcePrim.FontId`



**Example:**

```pascal
SchDestinPrim.FontId      := SchSourcePrim.FontId;
```

---


### `GetState_ComponentDescription`


---


### `GraphicallyInvalidate`


---


### `HarnessColor`


**Common values:**

- `SchSourcePrim.HarnessColor`



**Example:**

```pascal
SchDestinPrim.HarnessColor   := SchSourcePrim.HarnessColor;
```

---


### `HarnessConnectorType`


---


### `Height`


**Common values:**

- `SchSourcePrim.Height`



**Example:**

```pascal
SchDestinPrim.Height      := SchSourcePrim.Height;
```

---


### `IOType`


**Common values:**

- `SchSourcePrim.IOType`



**Example:**

```pascal
SchDestinPrim.IOType      := SchSourcePrim.IOType;
```

---


### `I_ObjectAddress`


---


### `IsActive`


**Common values:**

- `SchSourcePrim.IsActive`



**Example:**

```pascal
SchDestinPrim.IsActive     := SchSourcePrim.IsActive;
```

---


### `IsHidden`


**Common values:**

- `SchSourcePrim.IsHidden`



**Example:**

```pascal
SchDestinPrim.IsHidden       := SchSourcePrim.IsHidden;
```

---


### `IsMirrored`


**Common values:**

- `SchSourcePrim.IsMirrored`



**Example:**

```pascal
SchDestinPrim.IsMirrored    := SchSourcePrim.IsMirrored;
```

---


### `IsSolid`


**Common values:**

- `SchSourcePrim.IsSolid`



**Example:**

```pascal
SchDestinPrim.IsSolid       := SchSourcePrim.IsSolid;
```

---


### `Justification`


**Common values:**

- `SchSourcePrim.Justification`



**Example:**

```pascal
SchDestinPrim.Justification := SchSourcePrim.Justification;
```

---


### `KeepAspect`


**Common values:**

- `SchSourcePrim.KeepAspect`



**Example:**

```pascal
SchDestinPrim.KeepAspect    := SchSourcePrim.KeepAspect;
```

---


### `LineShapeSize`


**Common values:**

- `SchSourcePrim.LineShapeSize`



**Example:**

```pascal
SchDestinPrim.LineShapeSize  := SchSourcePrim.LineShapeSize;
```

---


### `LineStyle`


**Common values:**

- `SchSourcePrim.LineStyle`



**Example:**

```pascal
SchDestinPrim.LineStyle      := SchSourcePrim.LineStyle;
```

---


### `LineWidth`


**Common values:**

- `SchSourcePrim.LineWidth`



**Example:**

```pascal
SchDestinPrim.LineWidth     := SchSourcePrim.LineWidth;
```

---


### `Locked`


**Common values:**

- `SchSourcePrim.Locked`



**Example:**

```pascal
SchDestinPrim.Locked    := SchSourcePrim.Locked;
```

---


### `MasterEntryLocation`


**Common values:**

- `SchSourcePrim.MasterEntryLocation`



**Example:**

```pascal
SchDestinPrim.MasterEntryLocation            := SchSourcePrim.MasterEntryLocation;
```

---


### `ObjectID`


---


### `ObjectId`


---


### `Orientation`


**Common values:**

- `SchSourcePrim.Orientation`



**Example:**

```pascal
SchDestinPrim.Orientation   := SchSourcePrim.Orientation;
```

---


### `OverideColors`


---


### `PinColor`


**Common values:**

- `SchSourcePrim.PinColor`



**Example:**

```pascal
SchDestinPrim.PinColor                    := SchSourcePrim.PinColor;
```

---


### `SetState_xSizeySize`


---


### `ShowBorder`


**Common values:**

- `SchSourcePrim.ShowBorder`



**Example:**

```pascal
SchDestinPrim.ShowBorder  := SchSourcePrim.ShowBorder;
```

---


### `ShowDesignator`


**Common values:**

- `SchSourcePrim.ShowDesignator`



**Example:**

```pascal
SchDestinPrim.ShowDesignator := SchSourcePrim.ShowDesignator;
```

---


### `ShowHiddenFields`


**Common values:**

- `SchSourcePrim.ShowHiddenFields`



**Example:**

```pascal
SchDestinPrim.ShowHiddenFields := SchSourcePrim.ShowHiddenFields;
```

---


### `ShowHiddenPins`


---


### `ShowName`


**Common values:**

- `SchSourcePrim.ShowName`



**Example:**

```pascal
SchDestinPrim.ShowName      := SchSourcePrim.ShowName;
```

---


### `ShowNetName`


**Common values:**

- `SchSourcePrim.ShowNetName`



**Example:**

```pascal
SchDestinPrim.ShowNetName   := SchSourcePrim.ShowNetName;
```

---


### `Size`


**Common values:**

- `SchSourcePrim.Size`



**Example:**

```pascal
SchDestinPrim.Size      := SchSourcePrim.Size;
```

---


### `StartAngle`


**Common values:**

- `SchSourcePrim.StartAngle`



**Example:**

```pascal
SchDestinPrim.StartAngle    := SchSourcePrim.StartAngle;
```

---


### `StartLineShape`


**Common values:**

- `SchSourcePrim.StartLineShape`



**Example:**

```pascal
SchDestinPrim.StartLineShape := SchSourcePrim.StartLineShape;
```

---


### `Style`


**Common values:**

- `SchSourcePrim.Style`



**Example:**

```pascal
SchDestinPrim.Style         := SchSourcePrim.Style;
```

---


### `SuppressAll`


**Common values:**

- `SchSourcePrim.SuppressAll`



**Example:**

```pascal
SchDestinPrim.SuppressAll  := SchSourcePrim.SuppressAll;
```

---


### `Symbol`


**Common values:**

- `SchSourcePrim.Symbol`



**Example:**

```pascal
SchDestinPrim.Symbol       := SchSourcePrim.Symbol;
```

---


### `TextColor`


**Common values:**

- `SchSourcePrim.Color`

- `SchSourcePrim.TextColor`



**Example:**

```pascal
SchDestinPrim.TextColor   := SchSourcePrim.TextColor;
```

---


### `TextFontID`


**Common values:**

- `SchSourcePrim.TextFontID`

- `SchSourcePrim.FontID`



**Example:**

```pascal
SchDestinPrim.TextFontID     := SchSourcePrim.TextFontID;
```

---


### `TextHorzAnchor`


**Common values:**

- `SchSourcePrim.TextHorzAnchor`



**Example:**

```pascal
SchDestinPrim.TextHorzAnchor := SchSourcePrim.TextHorzAnchor;
```

---


### `TextStyle`


**Common values:**

- `SchSourcePrim.TextStyle`



**Example:**

```pascal
SchDestinPrim.TextStyle      := SchSourcePrim.TextStyle;
```

---


### `TextVertAnchor`


**Common values:**

- `SchSourcePrim.TextVertAnchor`



**Example:**

```pascal
SchDestinPrim.TextVertAnchor := SchSourcePrim.TextVertAnchor;
```

---


### `Transparent`


**Common values:**

- `SchSourcePrim.Transparent`



**Example:**

```pascal
SchDestinPrim.Transparent   := SchSourcePrim.Transparent;
```

---


### `UnderLineColor`


**Common values:**

- `SchSourcePrim.UnderLineColor`



**Example:**

```pascal
SchDestinPrim.UnderLineColor := SchSourcePrim.UnderLineColor;
```

---


### `Width`


**Common values:**

- `SchSourcePrim.Width`



**Example:**

```pascal
SchDestinPrim.Width       := SchSourcePrim.Width;
```

---


### `WordWrap`


**Common values:**

- `SchSourcePrim.WordWrap`



**Example:**

```pascal
SchDestinPrim.WordWrap    := SchSourcePrim.WordWrap;
```

---



====================================================================================================


# ISch_Parameter


**Category:** Schematic


**API Surface:** 2 methods, 9 properties


---


## Methods (2)


### `Mirror()`


**Observed signatures:**

```pascal
ISch_Parameter.Mirror(CompOrigin)
```

**Examples:**


*From: Scripts - SCH\RotateSymbol\RotateSymbol.pas*

```pascal
begin
                Param := ParameterList[ParamIdx];
                Param.Mirror(CompOrigin);
            end;
```


---


### `RotateBy90()`


**Observed signatures:**

```pascal
ISch_Parameter.RotateBy90(CompOrigin, eRotate270)
```

```pascal
ISch_Parameter.RotateBy90(CompOrigin, eRotate90)
```

**Examples:**


*From: Scripts - SCH\RotateSymbol\RotateSymbol.pas*

```pascal
begin
                Param := ParameterList[ParamIdx];
                if Clockwise then Param.RotateBy90(CompOrigin, eRotate90) else Param.RotateBy90(CompOrigin, eRotate270);
            end;
```


*From: Scripts - SCH\RotateSymbol\RotateSymbol.pas*

```pascal
begin
                Param := ParameterList[ParamIdx];
                if Clockwise then Param.RotateBy90(CompOrigin, eRotate90) else Param.RotateBy90(CompOrigin, eRotate270);
            end;
```


---


## Properties (9)


### `Autoposition`


**Common values:**

- `False`



**Example:**

```pascal
Param.Autoposition := False;
```

---


### `GetState_IsHidden`


---


### `I_ObjectAddress`


---


### `IsHidden`


**Common values:**

- `not Show`

- `True`

- `False`



**Example:**

```pascal
Parameter.IsHidden := True ;
```

---


### `Location`


**Common values:**

- `Point((component.Location.X + DxpsToCoord(0.2)), component.Location.Y)`



**Example:**

```pascal
Parameter.Location := Point((component.Location.X + DxpsToCoord(0.2)), component.Location.Y);
```

---


### `Name`


**Common values:**

- `ParameterName`

- `param`

- `dbParmName`



**Example:**

```pascal
Parameter.Name     := ParameterName ;
```

---


### `ShowName`


**Common values:**

- `False`



**Example:**

```pascal
Parameter.ShowName := False ;
```

---


### `Text`


**Common values:**

- `ParameterText`

- `dbParmValue`

- `newText`



**Example:**

```pascal
Parameter.Text     := ParameterText ;
```

---


### `text`


---



====================================================================================================


# ISch_Pin


**Category:** Schematic


**API Surface:** 0 methods, 7 properties


---


## Properties (7)


### `Designator`


**Common values:**

- `DesignatorOld`

- `DesignatorNew`



**Example:**

```pascal
Pin.Designator := DesignatorNew;    // write new designator to the pin
```

---


### `GetState_Location`


---


### `I_ObjectAddress`


---


### `Location`


---


### `Name`


**Common values:**

- `NameOld`

- `Pin.Name`

- `NameNew`



**Example:**

```pascal
Pin.Name := NameNew;
```

---


### `Orientation`


---


### `PinLength`


---



====================================================================================================


# ISch_Port


**Category:** Schematic


**API Surface:** 0 methods, 2 properties


---


## Properties (2)


### `I_ObjectAddress`


---


### `Selection`


**Common values:**

- `True`



**Example:**

```pascal
Port.Selection := True;    // write new designator to the component
```

---



====================================================================================================


# ISch_Sheet


**Category:** Schematic


**API Surface:** 1 methods, 4 properties


---


## Methods (1)


### `SchIterator_Destroy()`


**Observed signatures:**

```pascal
ISch_Sheet.SchIterator_Destroy(LibIterator)
```

```pascal
ISch_Sheet.SchIterator_Destroy(CompIter)
```

```pascal
ISch_Sheet.SchIterator_Destroy(Iterator)
```

**Examples:**


*From: Scripts - SCH\GetPinData\GetPinData.pas*

```pascal
finally
        ResultList.Destroy;
        MySCH.SchIterator_Destroy(iterator);
    end;
End;
```


*From: Scripts - SCH\HideShowParametersSch\HideShowParameters.pas*

```pascal
finally
            SchDocument.SchIterator_Destroy(Iterator);
            SchDocument.GraphicallyInvalidate;
        end;
```


---


## Properties (4)


### `CurrentSchComponent`


---


### `GraphicallyInvalidate`


---


### `SchIterator_Create`


---


### `SchLibIterator_Create`


---



====================================================================================================


# ISch_Wire


**Category:** Schematic


**API Surface:** 1 methods, 3 properties


---


## Methods (1)


### `SetState_Vertex()`


**Observed signatures:**

```pascal
ISch_Wire.SetState_Vertex(I, Point(MilsToCoord(X)
```

```pascal
ISch_Wire.SetState_Vertex(1, Point(MilsToCOord(X)
```

**Examples:**


*From: Scripts - SCH\AddWireStubsSch\AddWireStubsSch-Form.pas*

```pascal
Schwire.Location := Point(MilsToCoord(X), MilsToCoord(Y));
	Schwire.InsertVertex := 1;
	SchWire.SetState_Vertex(1, Point(MilsToCOord(X), MilsToCoord(Y)));

	For I := 2 to NumberOfVertices Do
```


*From: Scripts - SCH\AddWireStubsSch\AddWireStubsSch-Form.pas*

```pascal
WireVertices         := VerticesTrim(WireVertices);

		SchWire.SetState_Vertex(I, Point(MilsToCoord(X), MilsToCoord(Y)));
	End;
	SchDoc.RegisterSchObjectInContainer(SchWire);
```


---


## Properties (3)


### `I_ObjectAddress`


---


### `Selection`


**Common values:**

- `True`



**Example:**

```pascal
Wire.Selection := True;    // write new designator to the component
```

---


### `SetState_LineWidth`


**Common values:**

- `LineWidth`



**Example:**

```pascal
SchWire.SetState_LineWidth := LineWidth;
```

---



====================================================================================================


# IWorkspace


**Category:** General


**API Surface:** 4 methods, 0 properties


---


## Methods (4)


### `DM_GetDocumentFromPath()`


**Observed signatures:**

```pascal
IWorkspace.DM_GetDocumentFromPath(pcbDocNewFilePath)
```

```pascal
IWorkspace.DM_GetDocumentFromPath(LogicalDoc.DM_FullPath)
```

```pascal
IWorkspace.DM_GetDocumentFromPath(tmpstr)
```

**Examples:**


*From: Scripts - Parts library\OpenLib\libUtils.pas*

```pascal
tmpstr := LDoc.DM_FullPath;
                    OpenedLDoc := WS.DM_GetDocumentFromPath(tmpstr);
                    
                    CurrentPCBLib := PcbServer.GetCurrentPCBLibrary;
```


*From: Scripts - Parts library\OpenLib\libUtils.pas*

```pascal
tmpstr := LDoc.DM_FullPath;
                    OpenedLDoc := WS.DM_GetDocumentFromPath(tmpstr);
                                        
                    SchLibDoc :=  SchServer.GetCurrentSchDocument;
```


---


### `DM_OpenProject()`


**Observed signatures:**

```pascal
IWorkspace.DM_OpenProject(LibPrjPath, true)
```

**Examples:**


*From: Scripts - Parts library\OpenLib\libUtils.pas*

```pascal
LibPrjPath := LibPrj.DM_ProjectFullPath;
    
    OpenedLibraryProj := WS.DM_OpenProject(LibPrjPath, true);  // TIntegratedLibraryProjectAdapter

    // open the corresponding PCB-library in the project
```


*From: Scripts - Parts library\OpenLib\libUtils.pas*

```pascal
LibPrjPath := LibPrj.DM_ProjectFullPath;
    
    OpenedLibraryProj := WS.DM_OpenProject(LibPrjPath, true);  // TIntegratedLibraryProjectAdapter

    // open the corresponding PCB-library in the project
```


---


### `DM_ProjectCount()`


**Examples:**


*From: Scripts - Examples\SPI_Footprint_scripts\XIA_Utils.pas*

```pascal
{ Get a count of the number of currently opened projects.  The script project
    from which this script runs must be one of these. }
   projectCount := Workspace.DM_ProjectCount();

   { Loop over all the open projects.  We're looking for the XIA_Altium_scripts
```


*From: Scripts - Examples\XIA_Release_Manager\XIA_Utils.pas*

```pascal
{ Get a count of the number of currently opened projects.  The script project
    from which this script runs must be one of these. }
   projectCount := Workspace.DM_ProjectCount();

   { Loop over all the open projects.  We're looking for the XIA_Altium_scripts
```


---


### `DM_Projects()`


**Observed signatures:**

```pascal
IWorkspace.DM_Projects(i)
```

```pascal
IWorkspace.DM_Projects(k)
```

**Examples:**


*From: Scripts - Parts library\OpenLib\libUtils.pas*

```pascal
for k := 0 to WS.DM_ProjectCount-1 do
    begin
         LibPrj := WS.DM_Projects(k);
         LibPrjName := LibPrj.DM_ProjectFileName;
         LibPrjPath := LibPrj.DM_ProjectFullPath;
```


*From: Scripts - Examples\SPI_Footprint_scripts\XIA_Utils.pas*

```pascal
{ Get reference to project # i. }
      Project := Workspace.DM_Projects(i);

      { See if we found our script project. }
```


---



====================================================================================================


# Net


**Category:** General


**API Surface:** 0 methods, 1 properties


---


## Properties (1)


### `Name`


---



====================================================================================================


# PCBServer


**Category:** General


**API Surface:** 7 methods, 12 properties


---


## Methods (7)


### `DestroyPCBContour()`


**Observed signatures:**

```pascal
PCBServer.DestroyPCBContour(contour)
```

**Examples:**


*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Cleanup_LPW_Footprint.pas*

```pascal
{ Destroy contour to try to minimize memory leaks. }
         PCBServer.DestroyPCBContour(contour);

      end; { endfor j }
```


---


### `DestroyPCBObject()`


**Observed signatures:**

```pascal
PCBServer.DestroyPCBObject(Prim1)
```

```pascal
PCBServer.DestroyPCBObject(textDst)
```

```pascal
PCBServer.DestroyPCBObject(regionFoo)
```

**Examples:**


*From: Scripts - PCB\Arc8\Arc8.pas*

```pascal
Finally
        If ViaPad <> Nil Then PCBServer.DestroyPCBObject(Arc2); // avoid memmory leakage
        // update ....
        PCBServer.PostProcess;
```


*From: Scripts - PCB\FixConnections\FixConnections.pas*

```pascal
Board.SpatialIterator_Destroy(SIter);

      PCBServer.DestroyPCBObject(Prim1);
      Inc(i);
   end;
```


---


### `GetCurrentPCBBoard()`


**Examples:**


*From: Scripts - Parts library\OpenLib\libUtils.pas*

```pascal
if (LogicalPCBLibDoc = Nil) then 
        begin // resort to unsafer method of current document
            CurrentPCB := PCBServer.GetCurrentPCBBoard();
        end
        else
```


---


### `GetPCBBoardByPath()`


**Observed signatures:**

```pascal
PCBServer.GetPCBBoardByPath(pcbDocPath)
```

```pascal
PCBServer.GetPCBBoardByPath(LogicalPCBLibDoc.DM_FullPath)
```

```pascal
PCBServer.GetPCBBoardByPath(''%s'')
```

**Examples:**


*From: Scripts - PCB\ReturnViaCheck\ReturnViaCheck.pas*

```pascal
OpenDocString := ''; // don't need to try to open document because messages are cleared if document is closed
    ShowDocString := Format(' Client.ShowDocumentDontFocus(Client.GetDocumentByPath(''%s'')); ', [documentFullPath]) + sLineBreak; // counterintuitively, Client.ShowDocumentDontFocus() performs better than Client.ShowDocument()
    BoardRefString := Format(' PCB:=PCBServer.GetPCBBoardByPath(''%s''); ', [documentFullPath]) + sLineBreak;
    ZoomOnRectString := Format(' PCB.GraphicalView_ZoomOnRect(%d, %d, %d, %d); ', [X1, Y1, X2, Y2]) + sLineBreak;
    callBackProcess := 'ScriptingSystem:RunScriptText';
```


*From: Scripts - Parts library\OpenLib\libUtils.pas*

```pascal
else
        begin
            CurrentPCB := PCBServer.GetPCBBoardByPath(LogicalPCBLibDoc.DM_FullPath);
        end;
```


---


### `PCBObjectFactory()`


**Observed signatures:**

```pascal
PCBServer.PCBObjectFactory(eArcObject,eNodimension,eCreate_Default)
```

```pascal
PCBServer.PCBObjectFactory(eFillObject, eNoDimension, eCreate_Default)
```

```pascal
PCBServer.PCBObjectFactory(eComponentObject, eNoDimension, eCreate_Default)
```

**Examples:**


*From: Scripts - PCB\AddDatumPointToArcs\AddDatumPointToArcs.pas*

```pascal
begin
         Arc := Board.SelectecObject[i];
         Tr1 := PCBServer.PCBObjectFactory(eTrackObject, eNoDimension, eCreate_Default);
         Tr1.Width := Arc.LineWidth;
         Tr1.Layer := Arc.Layer;
```


*From: Scripts - PCB\Arc8\Arc8.pas*

```pascal
Begin
          // make a fake arc from the pad/via center
          Arc2 := PCBServer.PCBObjectFactory(eArcObject,eNoDimension,eCreate_Default);
          Arc2.XCenter := ViaPad.x;
          Arc2.YCenter := ViaPad.y;
```


---


### `PCBRuleFactory()`


**Observed signatures:**

```pascal
PCBServer.PCBRuleFactory(eRule_ComponentClearance)
```

```pascal
PCBServer.PCBRuleFactory(eRule_PolygonConnectStyle)
```

```pascal
PCBServer.PCBRuleFactory(eRule_MaxMinWidth)
```

**Examples:**


*From: Scripts - PCB\NofittedNoPaste\NofittedNoPaste.pas*

```pascal
filter := copy(filter,1,Length(filter) - 4) + ')';

  RulePaste := PCBServer.PCBRuleFactory(eRule_PasteMaskExpansion);
  RulePaste.Expansion := MMsToCoord(-2539);
  RulePaste.DRCEnabled := false;
```


*From: Scripts - PCB\ReturnViaCheck\ReturnViaCheck.pas*

```pascal
function    Rules_AddCustomViaRule(const RuleKind : TRuleKind; const RuleName : WideString; DrillPairObj : IPCB_DrillLayerPair; const Comment : WideString) : IPCB_Rule;
begin
    Result := PCBServer.PCBRuleFactory(RuleKind);
    Result.Name := RuleName + '_' + DrillPairObj.Description;
    // scope TBD
```


---


### `SendMessageToRobots()`


**Observed signatures:**

```pascal
PCBServer.SendMessageToRobots(PCBBoard.I_ObjectAddress, c_Broadcast, PCBM_BoardRegisteration, PCBComp.I_ObjectAddress)
```

```pascal
PCBServer.SendMessageToRobots(newPcbLib.Board.I_ObjectAddress,c_Broadcast,PCBM_BoardRegisteration,newLibComp.I_ObjectAddress)
```

```pascal
PCBServer.SendMessageToRobots(PCBBoard.I_ObjectAddress, c_Broadcast, PCBM_BoardRegisteration, PCBComp2.I_ObjectAddress)
```

**Examples:**


*From: Scripts - PCB\AdjustDesignators\AdjustDesignators.pas*

```pascal
// notify that the pcb object is going to be modified
            PCBServer.SendMessageToRobots(Designator.I_ObjectAddress, c_Broadcast, PCBM_BeginModify, c_NoEventData);
```


*From: Scripts - PCB\AdjustDesignators\AdjustDesignators.pas*

```pascal
// notify that the pcb object is modified
            PCBServer.SendMessageToRobots(Designator.I_ObjectAddress, c_Broadcast, PCBM_EndModify , c_NoEventData);

           // Destroy the track interator
```


---


## Properties (12)


### `CreatePCBLibComp`


---


### `GetCurrentPCBBoard`


---


### `GetCurrentPCBLibrary`


---


### `LayerUtils`


---


### `PCBContourFactory`


---


### `PCBContourMaker`


---


### `PCBContourUtilities`


---


### `PCBGeometricPolygonFactory`


---


### `PostProcess`


---


### `PreProcess`


---


### `ProcessControl`


---


### `SystemOptions`


---



====================================================================================================


# Project


**Category:** General


**API Surface:** 1 methods, 0 properties


---


## Methods (1)


### `DM_LogicalDocuments()`


---



====================================================================================================


# SCHServer


**Category:** General


**API Surface:** 1 methods, 1 properties


---


## Methods (1)


### `GetSchDocumentByPath()`


**Observed signatures:**

```pascal
SCHServer.GetSchDocumentByPath(Part.DM_OwnerDocumentFullPath)
```

```pascal
SCHServer.GetSchDocumentByPath(Document.DM_FullPath)
```

**Examples:**


*From: Scripts - SCH\LockMultiPartComponents\LockMultiPartComponents.pas*

```pascal
if Document.DM_DocumentKind = 'SCH' then
      begin
         SCHDoc := SCHServer.GetSchDocumentByPath(Document.DM_FullPath);
         if SCHDoc <> nil then
         begin
```


*From: Scripts - SCH\LockMultiPartComponents\LockMultiPartComponents.pas*

```pascal
if Document.DM_DocumentKind = 'SCH' then
      begin
         SCHDoc := SCHServer.GetSchDocumentByPath(Document.DM_FullPath);
         if SCHDoc <> nil then
         begin
```


---


## Properties (1)


### `GetCurrentSchDocument`


---



====================================================================================================


# Sheet


**Category:** General


**API Surface:** 1 methods, 1 properties


---


## Methods (1)


### `SchIterator_Destroy()`


---


## Properties (1)


### `SchIterator_Create`


---



====================================================================================================


# Track


**Category:** General


**API Surface:** 0 methods, 8 properties


---


## Properties (8)


### `BeginModify`


---


### `EndModify`


---


### `Moveable`


---


### `Net`


---


### `x1`


---


### `x2`


---


### `y1`


---


### `y2`


---



====================================================================================================


# Via


**Category:** General


**API Surface:** 0 methods, 10 properties


---


## Properties (10)


### `BeginModify`


---


### `BoundingRectangle`


---


### `DRCError`


---


### `Descriptor`


---


### `EndModify`


---


### `GraphicallyInvalidate`


---


### `I_ObjectAddress`


---


### `Net`


---


### `StartLayer`


---


### `StopLayer`


---



====================================================================================================

