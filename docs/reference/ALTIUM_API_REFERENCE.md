# Altium DelphiScript API Reference

*Extracted from community scripts in scripts-libraries*

---

## Schematic API (SCH)

### SCHServer

**Methods:**
- `GetSchDocumentByPath()`

**Properties:**
- `GetCurrentSchDocument`
- `GetSchDocumentByPat`

## PCB API

### PCBServer

**Methods:**
- `DestroyPCBContour()`
- `DestroyPCBObject()`
- `GetCurrentPCBBoard()`
- `GetPCBBoardByPath()`
- `PCBObjectFactory()`
- `PCBRuleFactory()`
- `SendMessageToRobots()`

**Properties:**
- `CreatePCBLibComp`
- `DestroyPCBContou`
- `DestroyPCBObjec`
- `GetCurrentPCBBoar`
- `GetCurrentPCBBoard`
- `GetCurrentPCBLibrary`
- `GetPCBBoardByPat`
- `LayerUtils`
- `PCBContourFactory`
- `PCBContourMaker`
- `PCBContourUtilities`
- `PCBGeometricPolygonFactory`
- `PCBObjectFactor`
- `PCBRuleFactor`
- `PostProcess`
- `PreProcess`
- `ProcessControl`
- `SendMessageToRobot`
- `SendMessageToRobots`
- `SystemOptions`

## Design Manager API (DM_)

**Properties:**
- `DM_AddGeneratedDocument`
- `DM_AddSourceDocument`
- `DM_AlternatePart`
- `DM_ChildDocumentCount`
- `DM_ChildDocuments`
- `DM_ChildSheet`
- `DM_ChildSheetCount`
- `DM_Compile`
- `DM_ComponentCount`
- `DM_Components`
- `DM_CurrentProjectVariant`
- `DM_Description`
- `DM_DocumentFlattened`
- `DM_DocumentKind`
- `DM_Electrical`
- `DM_ElectricalString`
- `DM_FileName`
- `DM_FindComponentVariationByDesignator`
- `DM_FindComponentVariationByUniqueId`
- `DM_FlattenedNetName`
- `DM_FocusedDocument`
- `DM_FocusedProject`
- `DM_Footprint`
- `DM_FullCrossProbeString`
- `DM_FullLogicalDesignator`
- `DM_FullPath`
- `DM_GenerateUniqueID`
- `DM_GeneratedDocumentCount`
- `DM_GeneratedDocuments`
- `DM_GetDocumentFromPath`
- `DM_GetOutputPath`
- `DM_GetParameterByName`
- `DM_ID`
- `DM_IndentLevel`
- `DM_IsLocal`
- `DM_LibraryReference`
- `DM_LocationString`
- `DM_LocationX`
- `DM_LocationY`
- `DM_LogicalDesignator`
- `DM_LogicalDocumentCount`
- `DM_LogicalDocuments`
- `DM_LogicalPartDesignator`
- `DM_LongDescriptorString`
- `DM_MessagesManager`
- `DM_Name`
- `DM_NetCount`
- `DM_NetLabelCount`
- `DM_NetLabels`
- `DM_NetName`
- `DM_Nets`
- `DM_OpenProject`
- `DM_OwnerDocumentFullPath`
- `DM_OwnerDocumentName`
- `DM_OwnerNetLogical`
- `DM_ParameterCount`
- `DM_ParameterName`
- `DM_Parameters`
- `DM_ParentDocumentCount`
- `DM_Part`
- `DM_PartID`
- `DM_PhysicalDesignator`
- `DM_PhysicalDocumentCount`
- `DM_PhysicalDocuments`
- `DM_PhysicalPartDesignator`
- `DM_PinCount`
- `DM_PinName`
- `DM_PinNumber`
- `DM_Pins`
- `DM_PortCount`
- `DM_PortName`
- `DM_Ports`
- `DM_PowerObjectCount`
- `DM_ProjectCount`
- `DM_ProjectFileName`
- `DM_ProjectFilename`
- `DM_ProjectFullPath`
- `DM_ProjectVariantCount`
- `DM_ProjectVariants`
- `DM_Projects`
- `DM_RemoveSourceDocument`
- `DM_SchHandle`
- `DM_SheetEntries`
- `DM_SheetEntryCount`
- `DM_SheetSymbolCount`
- `DM_SheetSymbols`
- `DM_ShowMessageView`
- `DM_SubPartCount`
- `DM_SubParts`
- `DM_TopLevelLogicalDocument`
- `DM_UniqueId`
- `DM_UniqueIdName`
- `DM_UniqueIdPath`
- `DM_Value`
- `DM_VariationCount`
- `DM_VariationKind`
- `DM_Variations`
- `DM_VariedValue`

## Constants & Enums

- `MkSet( rfReplaceAll, rfIgnoreCase )`
- `MkSet('59')`
- `MkSet((*ePadObject, eViaObject,*)`
- `MkSet(ALayer)`
- `MkSet(CLayer)`
- `MkSet(CmpOutlineLayerID)`
- `MkSet(Comp.Layer)`
- `MkSet(CurrentLayer)`
- `MkSet(FirstPrim.Layer)`
- `MkSet(Layer1)`
- `MkSet(LayerObj.LayerID)`
- `MkSet(ObjID)`
- `MkSet(Ord('-')`
- `MkSet(Ord('.')`
- `MkSet(Prim.Layer)`
- `MkSet(Prim1.Layer)`
- `MkSet(Prim1.Layer, String2Layer('Multi Layer')`
- `MkSet(Prim1.Layer, eMultiLayer)`
- `MkSet(SPLayer)`
- `MkSet(SchSourcePrim.ObjectId)`
- `MkSet(SlkLayer)`
- `MkSet(SourcePrim.ObjectId)`
- `MkSet(Text.Layer)`
- `MkSet(TopBot, eMultiLayer)`
- `MkSet(cAltKey)`
- `MkSet(cCntlKey)`
- `MkSet(cCtrlKey)`
- `MkSet(cShiftKey)`
- `MkSet(eArcObject)`
- `MkSet(eArcObject, eTrackObject)`
- `MkSet(eArcObject, eTrackObject, eFillObject, eRegionObject)`
- `MkSet(eArcObject, eTrackObject, eFillObject, eRegionObject, eViaObject)`
- `MkSet(eArcObject, eViaObject, eTrackObject, eFillObject, ePadObject, eNetObject, ePolyObject, eRegionObject)`
- `MkSet(eArcObject, eViaObject, eTrackObject, eFillObject, ePadObject, ePolyObject, eRegionObject)`
- `MkSet(eAutoPos_Manual, eAutoPos_CenterCenter)`
- `MkSet(eAutoPos_TopLeft, eAutoPos_BottomLeft, eAutoPos_TopRight, eAutoPos_BottomRight)`
- `MkSet(eBottomLayer)`
- `MkSet(eBus)`
- `MkSet(eBus, eWire, eSignalHarness)`
- `MkSet(eBusEntry)`
- `MkSet(eClassObject)`
- `MkSet(eCompileMask)`
- `MkSet(eComponentBodyObject)`
- `MkSet(eComponentObject)`
- `MkSet(eComponentObject, eTextObject)`
- `MkSet(eConnectionObject)`
- `MkSet(eDesignator, eParameter)`
- `MkSet(eDesignator, eParameter, eLabel)`
- `MkSet(eDesignator, eParameter, eLabel, eNetlabel, ePort, eCrossSheetConnector, eHarnessEntry, eSheetEntry)`
- `MkSet(eDesignator, eParameter, eSheetName, eSheetFileName, eHarnessConnectorType)`

## Example Scripts

### SCH Examples

**Scripts - SCH\GetPinData\GetPinData.pas:**
```pascal
Function SCH_GetSelectedComponents(FilterSet: TObjectSet = nil): TObjectList;
Var
    iterator    :   ISch_Iterator;
    MySCH       :   ISch_Sheet;
    s           :   ISch_GraphicalObject;
    ResultList  :   TObjectList;
Begin
    // ensure we're in a schematic doc
    MySCH := SCHServer.GetCurrentSchDocument;
    If MySCH = Nil then Exit;

    // Initialize iterator
    try
        iterator := MySCH.SchIterator_Create;
        ResultList := TObjectList.Create;
        iterator.SetState_FilterAll;
        iterator.SetState_IterationDepth(eIterateAllLevels);

        if (FilterSet = Nil) then iterator.AddFilter_CurrentPartPrimitives
        else iterator.AddFilter_ObjectSet(FilterSet);
```

**Scripts - SCH\LockMultiPartComponents\LockMultiPartComponents.pas:**
```pascal
procedure LockMultiPartComponents;
var

    Workspace         : IWorkspace;
    PCBProject        : IProject;
    ProjectName       : String;
    Document          : IDocument;
    DocNum            : Integer;
    Rectangle         : TCoordRect;
    FlatHierarchy     : IDocument;
    SCHDoc            : ISCH_document;
    MaxNumber         : Integer;
    Iterator          : ISCH_Iterator;
    AComponent        : ISCH_Component;
    CompIterator      : ISCH_Iterator;
    Parameter         : ISCH_Parameter;
    Designator        : String;
    AsciiCode         : Integer;

begin
```

**Scripts - SCH\LRJustify\LRJustify.pas:**
```pascal
Function Modify_Begin(TObject);
begin
    SchServer.RobotManager.SendMessage(TObject.I_ObjectAddress, c_BroadCast, SCHM_BeginModify, c_NoEventData);
end;

Function Modify_End(TObject);
begin
    SchServer.RobotManager.SendMessage(TObject.I_ObjectAddress, c_BroadCast, SCHM_EndModify, c_NoEventData);
end;

procedure LRJustify;
  Var
    sk       :  ISCH_Document;
    txt      :  ISch_GraphicalObject;
    iterator :  ISch_Iterator;
    firstloc :  IDispatch;
  Begin
    //Check we're in a schematic
      sk := SCHServer.GetCurrentSchDocument;
      If sk = Nil then Exit;
```

**Scripts - Misc\MultiPCBProject\MultiPCBProject.pas:**
```pascal
{     RecompileProject - This procedure recompiles the project. Used a lot.    }
{                                                                              }
{..............................................................................}
Procedure RecompileProject(Confirm : Bool);
begin
   // Recompile
   if Confirm then
   begin
      ResetParameters;
      AddStringParameter('Action','Compile');
      AddStringParameter('ObjectKind','Project');
      RunProcess('WorkspaceManager:Compile');
   end;
end;


Procedure UnMasksAll(Confirm : bool);
var

   PcbProject       : IProject;
```

**Scripts - General\DesignReuse\DesignReuse.pas:**
```pascal
{   WriteSnippetsFolders - Procedure used to get snippets folders.             }
{                                                                              }
{..............................................................................}
Procedure WriteSnippetsFolders;
begin
   SnippetsFolders := TStringList.Create;

   SnippetsFolders.Add('C:\Users\Public\Documents\Altium\AD 10\Examples\Snippets Examples');

   // I have used default Snippets folder in previous line:
   // If you use some other folders for snippets, please uncomment
   // following lines and add those folders:

// SnippetsFolders.Add('Folder-Path-1-Here');
// SnippetsFolders.Add('Folder-Path-2-Here');


end;


```

### PCB Examples

**Scripts - PCB\AddDatumPointToArcs\AddDatumPointToArcs.pas:**
```pascal
procedure AddDatumPointToArcs;
var
   Board    : IPCB_Board;
   Arc      : IPCB_Arc;
   i        : Integer;
   Tr1, Tr2 : IPCB_Track;
   Tr3, Tr4 : IPCB_Track;
begin
   Board := PCBServer.GetCurrentPCBBoard;
   if Board = nil then exit;

   if Board.SelectecObjectCount = 0 then exit;

   for i := 0 to Board.SelectecObjectCount - 1 do
      if Board.SelectecObject[i].ObjectId = eArcObject then
      begin
         Arc := Board.SelectecObject[i];
         Tr1 := PCBServer.PCBObjectFactory(eTrackObject, eNoDimension, eCreate_Default);
         Tr1.Width := Arc.LineWidth;
         Tr1.Layer := Arc.Layer;
```

**Scripts - PCB\AdjustDesignators\AdjustDesignators.pas:**
```pascal
function CalculateSize (Size:Integer,S:String,TextLength:Integer):Integer;
begin
     case TextLength of
          1 : Result := MMsToCoord(1.3013*CoordToMMs(Size)-0.0597);
          2 : Result := MMsToCoord(0.7201*CoordToMMs(Size)+0.0612);
          3 : Result := MMsToCoord(0.4319*CoordToMMs(Size)+0.1116);
          4 : Result := MMsToCoord(0.3265*CoordToMMs(Size)+0.1327);
          5 : Result := MMsToCoord(0.2622*CoordToMMs(Size)+0.1508);
          6 : Result := MMsToCoord(0.2194*CoordToMMs(Size)+0.1519);
          7 : Result := MMsToCoord(0.1957*CoordToMMs(Size)-0.2201);
          else ShowWarning('The length of the designator'+ S +' is '+IntToStr(TextLength) +' characters. Designator must be between 1 and 7 characters to be auto adjusted in size.');
     end;
end;


{..............................................................................}
Procedure AdjustDesignators;
Var
    Track                   : IPCB_Primitive;
    TrackIteratorHandle     : IPCB_GroupIterator;
```

**Scripts - PCB\AdjustDesignators2\AdjustDesignators2.pas:**
```pascal
function GetFirstLayerName(Pair : String) : String;                                     forward;
function GetSecondLayerName(Pair : String) : String;                                    forward;
function IsStringANum(Tekst : String) : Boolean;                                        forward;
function CalculateSize (Size : Integer, S : String, UseStrokeFont : boolean) : Integer; forward;
function GetMechLayerObject(LS: IPCB_MasterLayerStack, i : integer, var MLID : TLayer) : IPCB_MechanicalLayer; forward;

procedure TFormAdjustDesignators.ButtonCancelClick(Sender: TObject);
begin
    FormAdjustDesignators.Close;
    slMechPairs.Clear;
    slMechSingles.Clear;
end;

procedure TFormAdjustDesignators.FormAdjustDesignatorsShow(Sender: TObject);
var
    i, j         : Integer;

begin
    ComboBoxLayers.Clear;
    ComboBoxDesignators.Clear;
```

**Scripts - PCB\Arc8\Arc8.pas:**
```pascal

{................................................. ............................}
{Summary: Connects two arcs or an arc with a pad or via                        }
{                                                                              }
{    To connect two arcs with a line up where tangent points                   }
{    Or an arc and a via or pad                                                }
{                                                                              }
{    Select a arc and an arc / pad / via and run the script (Arc8.Arc8)        }
{                                                                              }
{    Arcs will be adjusted to fit the new line                                 }
{                                                                              }
{                                                                              }
{         Version 0.3                                                          }
{..............................................................................}



{ calculate the 4 posible connections}
{ ReturnArray is groupes Of  |: x1,y1,x2,y2 :|  }
Procedure FindTangents(
```

**Scripts - PCB\AssemblyTextPrep\AssemblyTextPrep.pas:**
```pascal
function    GetComponentBounds_Body(Comp : IPCB_Component; out CentroidX : TCoord; out CentroidY : TCoord; out box_width : TCoord; out box_height : TCoord) : Tnteger; forward;
function    GetComponentBounds_Pads(Comp : IPCB_Component; out CentroidX : TCoord; out CentroidY : TCoord; out box_width : TCoord; out box_height : TCoord) : Tnteger; forward;
function    GetComponentBounds_Simple(const Comp : IPCB_Component; out CentroidX : TCoord; out CentroidY : TCoord; out box_width : TCoord; out box_height : TCoord) : Integer; forward;
function    GetDesignator(var Comp : IPCB_Component) : IPCB_Primitive; forward;
function    GetMechLayerObject(MLS: IPCB_MasterLayerStack, i : integer, var MLID : TLayer) : IPCB_MechanicalLayer; forward;
function    GetObjPoly(Obj: IPCB_ObjectClass, Expansion: TCoord = 0) : IPCB_GeometricPolygon; forward;
function    GetSelectedAssyTextCount(dummy : Boolean = False) : Integer; forward;
function    GetSelectedComponentCount(dummy : Boolean = False) : Integer; forward;
function    GetSelectedInvalidCount(dummy : Boolean = False) : Integer; forward;
procedure   GUI_BeginProcess(dummy : Boolean = False); forward;
procedure   GUI_EndProcess(dummy : Boolean = False); forward;
function    GUI_ForLoopStart(StatusMsg : String; LoopCount : Integer) : Integer; forward;
procedure   GUI_LoopEnd(dummy : Boolean = False); forward;
procedure   GUI_LoopProgress(StatusMsg : String = ''); forward;
procedure   InitialCheckGUI(var status : Integer); forward;
procedure   InitialCheckSelectBoth(var status : Integer); forward;
procedure   InitialCheckSelectComponents(var status : Integer); forward;
procedure   InitialCheckSelectDesignators(var status : Integer); forward;
procedure   Inspect_IPCB_Text(var Text : IPCB_Text3; const MyLabel : string = ''); forward;
function    IsSelectableCheck(var bCanSelectComp : Boolean; var bCanSelectText : Boolean); forward;
```

