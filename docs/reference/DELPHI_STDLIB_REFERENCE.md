# Delphi Standard Library Reference

*Built-in Delphi/Pascal functions and types used in Altium scripts*

*Extracted from actual usage in 128 working examples*


================================================================================


## Built-in Functions


Functions used in the scripts (sorted by frequency):


### `IntToStr()`


**Usage count:** 1035 times


**Examples:**


```pascal
PlaceASchWire(2, 'X1='+ IntToStr(LocX+Len) +
```

*From: Scripts - SCH\AddWireStubsSch\AddWireStubsSch-Form.pas*


```pascal
CreateNewSchObject.Text := IntToStr(SchPageNumberText) ;
```

*From: Scripts - SCH\CreateTableOfContents\CreateTableOfContentsForm.pas*


---


### `Format()`


**Usage count:** 730 times


**Examples:**


```pascal
if (NumOutput = 1) and (NumInput > 0) and (NumBidirectional = 0) and (NumUnspecified = 0)       then Result := Format('1 output port with %d input ports is valid.', [NumInput])
```

*From: Scripts - SCH\FindUnmatchedPorts\FindUnmatchedPorts.pas*


```pascal
GUI_LoopProgress(Format('Processing designators', [i, MyPercent_GetTotal]));
```

*From: Scripts - PCB\AssemblyTextPrep\AssemblyTextPrep.pas*


---


### `FloatToStr()`


**Usage count:** 491 times


**Examples:**


```pascal
TempString                  := IniFile.ReadString('Hidden Settings', 'stroke font height ratio', FloatToStr(cSTROKE_RATIO));
```

*From: Scripts - PCB\AssemblyTextPrep\AssemblyTextPrep.pas*


```pascal
NEWLINECODE + 'Text.Rotation: ' + FloatToStr(Text.Rotation) +
```

*From: Scripts - PCB\AutoPlaceSilkscreen\AutoPlaceSilkscreen.pas*


---


### `StrToFloat()`


**Usage count:** 324 times


**Examples:**


```pascal
MaximumHeight := MMsToCoord(StrToFloat(EditMaxHeight.Text));
```

*From: Scripts - PCB\AdjustDesignators2\AdjustDesignators2.pas*


```pascal
if IsStringANum(EditControl.Text) then EditControl.Text := CoordToMMs(MilsToCoord(StrToFloat(TempString)));
```

*From: Scripts - PCB\AssemblyTextPrep\AssemblyTextPrep.pas*


---


### `ShowMessage()`


**Usage count:** 283 times


**Examples:**


```pascal
ShowMessage('Unable to create iterator for checking pins');
```

*From: Scripts - SCH\AddWireStubsSch\AddWireStubsSch-Form.pas*


```pascal
ShowMessage ('Error: More than ' + VarToStr(cMaxLogicalDocuments) + ' logical schematic pages in project.  Cannot fit TOC on one sheet') ;
```

*From: Scripts - SCH\CreateTableOfContents\CreateTableOfContentsForm.pas*


---


### `Insert()`


**Usage count:** 277 times


**Examples:**


```pascal
SettingsDebugList.Insert(0, AFileName);
```

*From: Scripts - PCB\AssemblyTextPrep\AssemblyTextPrep.pas*


```pascal
if (Prim2 = nil) then SortedTracks.Insert(i + 1, '0') // no connected track so insert placeholder
```

*From: Scripts - PCB\Distribute\Distribute.pas*


---


### `Length()`


**Usage count:** 263 times


**Examples:**


```pascal
For char_cnt := 1 To Length(StrList[csv_row]) Do
```

*From: Scripts - SCH\ImportPinPackageLengths\ImportPinPackLenForm.pas*


```pascal
if Length(Designator) = 0 then break;
```

*From: Scripts - SCH\LockMultiPartComponents\LockMultiPartComponents.pas*


---


### `StringReplace()`


**Usage count:** 160 times


**Examples:**


```pascal
NewStr := StringReplace(Text, NEWLINECODE, ',', rfReplaceAll);
```

*From: Scripts - PCB\AutoPlaceSilkscreen\AutoPlaceSilkscreen.pas*


```pascal
Line := StringReplace(Line, #9, #32, mkset(rfReplaceAll));
```

*From: Scripts - PCB\LengthTuningHelper\LengthTuningHelper.pas*


---


### `Copy()`


**Usage count:** 127 times


**Examples:**


```pascal
NewValue := Copy(WireVertices, Pos('=', WireVertices) + 1, pos('|',
```

*From: Scripts - SCH\AddWireStubsSch\AddWireStubsSch-Form.pas*


```pascal
If (Copy(StrList[csv_row], char_cnt, 1) = ',') Then
```

*From: Scripts - SCH\ImportPinPackageLengths\ImportPinPackLenForm.pas*


---


### `StrToInt()`


**Usage count:** 119 times


**Examples:**


```pascal
TableYOrigin       := CoordToMils (SheetTOC.GetState_SheetSizeY) / 10 - StrToInt(EditVerOffset.Text) ;
```

*From: Scripts - SCH\CreateTableOfContents\CreateTableOfContentsForm.pas*


```pascal
if StrToInt(Parameter.Text) > MaxNumber then
```

*From: Scripts - SCH\LockMultiPartComponents\LockMultiPartComponents.pas*


---


### `Delete()`


**Usage count:** 89 times


**Examples:**


```pascal
Delete(WireVertices, 1, pos('|', WireVertices));
```

*From: Scripts - SCH\AddWireStubsSch\AddWireStubsSch-Form.pas*


```pascal
UnmatchedPortNetList.Delete(NetIdx);
```

*From: Scripts - SCH\FindUnmatchedPorts\FindUnmatchedPorts.pas*


---


### `Assigned()`


**Usage count:** 84 times


**Examples:**


```pascal
If Not Assigned(Board) Then
```

*From: Scripts - PCB\Arc8\Arc8.pas*


```pascal
if not Assigned(IsAtLeastAD19) then if (GetBuildNumberPart(Client.GetProductVersion, 0) >= cVersionMajorAD19) then IsAtLeastAD19 := True else IsAtLeastAD19 := False;
```

*From: Scripts - PCB\AssemblyTextPrep\AssemblyTextPrep.pas*


---


### `Abs()`


**Usage count:** 75 times


**Examples:**


```pascal
Length := Power(( Power(Abs((Track.X2-Track.X1)),2) + Power(Abs((Track.Y2-Track.Y1)),2) ), 1/2 );
```

*From: Scripts - PCB\CopyAngleToComponent\CopyAngleToComponent.pas*


```pascal
if ((IsVert1 = IsVert2) and (Abs(k1 - k2) < 0.01)) then
```

*From: Scripts - PCB\Distribute\Distribute.pas*


---


### `Round()`


**Usage count:** 70 times


**Examples:**


```pascal
box_width := Round(Sqrt(box_width*box_width + box_height*box_height)) * 1000; // use corner dist
```

*From: Scripts - PCB\AssemblyTextPrep\AssemblyTextPrep.pas*


```pascal
rotation := Round(((Silkscreen.Rotation mod 360 + 360) mod 360) / 90) * 90; // coerce any possible value of rotation to a multiple of 90
```

*From: Scripts - PCB\AutoPlaceSilkscreen\AutoPlaceSilkscreen.pas*


---


### `FileExists()`


**Usage count:** 69 times


**Examples:**


```pascal
If Not(FileExists(Edit.Text)) or (Edit.Text = '') Then
```

*From: Scripts - SCH\ImportPinPackageLengths\ImportPinPackLenForm.pas*


```pascal
if (not FileExists(Result)) or bForbidLocalSettings then Result := IncludeTrailingPathDelimiter(SpecialFolder_AltiumApplicationData) + cConfigFileName;
```

*From: Scripts - PCB\AssemblyTextPrep\AssemblyTextPrep.pas*


---


### `SetLength()`


**Usage count:** 50 times


**Examples:**


```pascal
SetLength(Pair, Pos - 1);
```

*From: Scripts - PCB\AdjustDesignators2\AdjustDesignators2.pas*


```pascal
SetLength(TempLine, 7);
```

*From: Scripts - PCB\AutoRouter_Interface\AutoRouter_Interface.pas*


---


### `ExtractFilePath()`


**Usage count:** 34 times


**Examples:**


```pascal
Result := ExtractFilePath(GetRunningScriptProjectName) + cConfigFileName;
```

*From: Scripts - PCB\AssemblyTextPrep\AssemblyTextPrep.pas*


```pascal
fileName := ExtractFilePath(PCBServer.GetCurrentPCBBoard.FileName) + 'temp\';
```

*From: Scripts - PCB\FixConnections\FixConnections.pas*


---


### `Pos()`


**Usage count:** 32 times


**Examples:**


```pascal
If Pos('|', WireVertices) > 0 Then
```

*From: Scripts - SCH\AddWireStubsSch\AddWireStubsSch-Form.pas*


```pascal
EndofToken := Pos(SepChar, Tekst);
```

*From: Scripts - PCB\AutoRouter_Interface\AutoRouter_Interface.pas*


---


### `Sqrt()`


**Usage count:** 32 times


**Examples:**


```pascal
box_width := Round(Sqrt(box_width*box_width + box_height*box_height)) * 1000; // use corner dist
```

*From: Scripts - PCB\AssemblyTextPrep\AssemblyTextPrep.pas*


```pascal
Result := MilsToCoord(Abs(( ((X2 - X1)*(Y1 - Y)) - ((X1 - X)*(Y2 - Y1)) ) / Sqrt(Sqr(X2 - X1) + Sqr(Y2 - Y1))));
```

*From: Scripts - PCB\Fillet\Fillet.pas*


---


### `ChangeFileExt()`


**Usage count:** 32 times


**Examples:**


```pascal
SettingsDebugFile := ChangeFileExt(ConfigFile_GetPath,'.ini') + '_debug.ini';
```

*From: Scripts - PCB\AssemblyTextPrep\AssemblyTextPrep.pas*


```pascal
Line := ChangeFileExt(FileName,'');
```

*From: Scripts - PCB\AutoRouter_Interface\AutoRouter_Interface.pas*


---


### `ExtractFileName()`


**Usage count:** 30 times


**Examples:**


```pascal
LabelFileName.Caption := ExtractFileName(FileName);
```

*From: Scripts - PCB\LengthTuningHelper\LengthTuningHelper.pas*


```pascal
MessageText.Add(ExtractFileName(Board.FileName));
```

*From: Scripts - PCB\PolygonBenchmark\PolygonBenchmark.pas*


---


### `Now()`


**Usage count:** 24 times


**Examples:**


```pascal
StartTime := Now();
```

*From: Scripts - PCB\AutoPlaceSilkscreen\AutoPlaceSilkscreen.pas*


```pascal
startTime := Now();
```

*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Checkin_SchLib_PcbLib_Libraries.pas*


---


### `Trim()`


**Usage count:** 20 times


**Examples:**


```pascal
Result := Trim(Tekst);
```

*From: Scripts - PCB\LengthTuningHelper\LengthTuningHelper.pas*


```pascal
TempStrg := Trim(CurrPart.DM_PhysicalDesignator);
```

*From: Scripts - Outputs\InteractiveHTMLBOM4Altium2\InteractiveHTMLBOM4Altium2.pas*


---


### `Sqr()`


**Usage count:** 19 times


**Examples:**


```pascal
Result := MilsToCoord(Abs(( ((X2 - X1)*(Y1 - Y)) - ((X1 - X)*(Y2 - Y1)) ) / Sqrt(Sqr(X2 - X1) + Sqr(Y2 - Y1))));
```

*From: Scripts - PCB\Fillet\Fillet.pas*


```pascal
oldPadToPadDistance := Sqrt(Sqr(xDiffMMs) + Sqr(yDiffMMs));
```

*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Cleanup_LPW_Footprint.pas*


---


### `DirectoryExists()`


**Usage count:** 17 times


**Examples:**


```pascal
If (DirectoryExists(SourceFolder)) Then
```

*From: Scripts - PCB\AutoSTEPplacer\AutoSTEPplacer.pas*


```pascal
if not DirectoryExists(Path) then
```

*From: Scripts - Outputs\InteractiveHTMLBOM4Altium2\InteractiveHTMLBOM4Altium2.pas*


---


### `ExtractFileExt()`


**Usage count:** 16 times


**Examples:**


```pascal
If (AnsiUpperCase(ExtractFileExt(PCBProject.DM_ProjectFileName)) <> '.PRJPCB') then
```

*From: Scripts - SCH\LockMultiPartComponents\LockMultiPartComponents.pas*


```pascal
if (ExtractFileExt(LabelFileName.Caption) = '.csv') then
```

*From: Scripts - PCB\LengthTuningHelper\LengthTuningHelper.pas*


---


### `DegToRad()`


**Usage count:** 12 times


**Examples:**


```pascal
X := Distance * cos(DegToRad(DestinRot + Angle));
```

*From: Scripts - PCB\ComponentPlacement\ComponentPlacement.pas*


---


### `Trunc()`


**Usage count:** 10 times


**Examples:**


```pascal
PadX := IntToStr(Trunc(CoordToMMs(Pad.X) * 100));
```

*From: Scripts - PCB\AutoPlaceSilkscreen\AutoPlaceSilkscreen.pas*


```pascal
AdjustAmtEdit.Text:=Trunc(0.5 + 10000 * AdjustAmtEdit.Text / 25.4)/10;
```

*From: Scripts - PCB\MoveAPdesignators\MoveAPForm.pas*


---


### `MessageDlg()`


**Usage count:** 10 times


**Examples:**


```pascal
z := MessageDlg(OutputString,mtinformation,4,0);
```

*From: Scripts - PCB\CurrentCalculator\CurrentCalculator.pas*


```pascal
buttonSelected := MessageDlg('!!!This operation CANNOT be undone, proceed with caution!!!', mtwarning, mbOKCancel, 0);
```

*From: Scripts - Parts library\DeleteAllSelectedItemsInPCBLib\DeleteAllSelectedItemsInPCBLib.pas*


---


### `FormatDateTime()`


**Usage count:** 10 times


**Examples:**


```pascal
WriteToDebugFile('**Script took ' + FormatDateTime('h:n:s', (endTime-startTime)) + ' (hrs:mins:secs) to run on this project on this PC.');
```

*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Checkin_SchLib_PcbLib_Libraries.pas*


```pascal
WriteToDebugFile('**Script took ' + FormatDateTime('h:n:s', (endTime-startTime)) + ' (hrs:mins:secs) to run on this project on this PC.');
```

*From: Scripts - Examples\SPI_Footprint_scripts\SPI_Cleanup_AltLib_Footprint.pas*


---


### `Floor()`


**Usage count:** 9 times


**Examples:**


```pascal
max_height := MIN(Floor((TEXTHEIGHTMAX / height_ratio) / TEXTSTEPSIZE) * TEXTSTEPSIZE, Floor((target_height / height_ratio) / TEXTSTEPSIZE) * TEXTSTEPSIZE);
```

*From: Scripts - PCB\AssemblyTextPrep\AssemblyTextPrep.pas*


```pascal
Angle := Angle - 360.0 * Floor(Angle / 360.0);
```

*From: Scripts - PCB\CopyAngleToComponent\CopyAngleToComponent.pas*


---


### `VarToStr()`


**Usage count:** 8 times


**Examples:**


```pascal
if (VarToStr(ParameterSheetNumber.text) = '*') or (VarToStr(ParameterSheetNumber.text) = '0') or (VarToStr(ParameterSheetNumber.text) = '') then
```

*From: Scripts - SCH\CreateTableOfContents\CreateTableOfContentsForm.pas*


```pascal
// ShowMessage('Barrel Relief Vias with Hole Sizes > ' + VarToStr(Threshold) + 'mils :  Qty = ' +  IntToStr(ViaNumber));
```

*From: Scripts - PCB\ViaSoldermaskBarrelRelief\ViaSoldermaskBarrelRelief.pas*


---


### `Cos()`


**Usage count:** 8 times


**Examples:**


```pascal
CentroidX := Round((Cos(radRotation) * (temp_cx - Comp.x) - Sin(radRotation) * (temp_cy - Comp.y) + Comp.x) / 10) * 10;
```

*From: Scripts - PCB\AssemblyTextPrep\AssemblyTextPrep.pas*


```pascal
StartVecX   := CoordToMils2((Radius * Cos(NewStartAngle)));
```

*From: Scripts - PCB\Fillet\Fillet.pas*


---


### `Sin()`


**Usage count:** 8 times


**Examples:**


```pascal
CentroidX := Round((Cos(radRotation) * (temp_cx - Comp.x) - Sin(radRotation) * (temp_cy - Comp.y) + Comp.x) / 10) * 10;
```

*From: Scripts - PCB\AssemblyTextPrep\AssemblyTextPrep.pas*


```pascal
StartVecY   := CoordToMils2((Radius * Sin(NewStartAngle)));
```

*From: Scripts - PCB\Fillet\Fillet.pas*


---


### `ArcTan()`


**Usage count:** 7 times


**Examples:**


```pascal
Angle := RadToDeg(ArcTan((Source.y - SourceY) / (Source.x - SourceX))) - SourceRot;
```

*From: Scripts - PCB\ComponentPlacement\ComponentPlacement.pas*


```pascal
Angle := ArcTan((Track.Y2-Track.Y1)/(Track.X2-Track.X1))/(Pi)*180;
```

*From: Scripts - PCB\CopyAngleToComponent\CopyAngleToComponent.pas*


---


### `IncludeTrailingPathDelimiter()`


**Usage count:** 6 times


**Examples:**


```pascal
if (not FileExists(Result)) or bForbidLocalSettings then Result := IncludeTrailingPathDelimiter(SpecialFolder_AltiumApplicationData) + cConfigFileName;
```

*From: Scripts - PCB\AssemblyTextPrep\AssemblyTextPrep.pas*


```pascal
if (not FileExists(Result)) or bForbidLocalSettings then Result := IncludeTrailingPathDelimiter(SpecialFolder_AltiumApplicationData) + cConfigFileName;
```

*From: Scripts - PCB\QuickSilk\QuickSilk.pas*


---


### `LowerCase()`


**Usage count:** 5 times


**Examples:**


```pascal
if LowerCase(ignorelist[i]) = LowerCase(pattern) then Exit
```

*From: Scripts - SCH\AddWireStubsSch\AddWireStubsSch-Form.pas*


```pascal
if ((LowerCase(MechDesignator.GetState_UnderlyingString) = '.designator' ) or (MechDesignator.GetState_ConvertedString = Designator.GetState_ConvertedString)) then
```

*From: Scripts - PCB\AdjustDesignators2\AdjustDesignators2.pas*


---


### `UpperCase()`


**Usage count:** 5 times


**Examples:**


```pascal
if (UpperCase(Parameter.Text) = '=CURRENTFOOTPRINT') then
```

*From: Scripts - SCH\HideShowParametersSch\HideShowParameters.pas*


```pascal
If ((AnsiCompareStr(UpperCase(Doc.DM_DocumentKind), 'PCB') = 0)) then
```

*From: Scripts - Parts library\OpenLib\OpenLib.pas*


---


### `RadToDeg()`


**Usage count:** 5 times


**Examples:**


```pascal
Angle := RadToDeg(ArcTan((Source.y - SourceY) / (Source.x - SourceX))) - SourceRot;
```

*From: Scripts - PCB\ComponentPlacement\ComponentPlacement.pas*


---


### `Ceil()`


**Usage count:** 3 times


**Examples:**


```pascal
viaminc := Ceil(viaminc / 10) * 10;     // apply some rounding to make sure to clear by the requested amount
```

*From: Scripts - PCB\Distribute\Distribute.pas*


---


### `StrToIntDef()`


**Usage count:** 3 times


**Examples:**


```pascal
Thickness := StrToIntDef(ThicknessStr, 0);
```

*From: Scripts - PCB\ReturnViaCheck\ReturnViaCheck.pas*


---


## Built-in Types


### TStringList


**Usage count:** 50 declarations


**Common methods:**


- `Create()` - used 36 times



---


### TInterfaceList


**Usage count:** 13 declarations


**Common methods:**


- `Create()` - used 16 times



---


### TDateTime


**Usage count:** 10 declarations


---


### TObjectList


**Usage count:** 6 declarations


---


### TList


**Usage count:** 4 declarations


---


### TPoint


**Usage count:** 3 declarations


**Common methods:**


- `FrmModelListMouseWheelDown()` - used 1 times

- `FrmModelListMouseWheelUp()` - used 1 times



---


### TColor


**Usage count:** 2 declarations


---

