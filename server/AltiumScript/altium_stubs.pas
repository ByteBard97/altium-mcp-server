unit altium_stubs;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils;

type
  // Coordinate types
  TCoord = Integer;
  TAngle = Double;
  TLayer = Integer;
  TShape = Integer;
  TSet = Integer;

  // Rect type
  TCoordRect = record
    Left, Top, Right, Bottom: TCoord;
  end;

  // Forward declarations for all IPCB interfaces
  IPCB_Board = interface;
  IPCB_Net = interface;
  IPCB_BoardIterator = interface;
  IPCB_ObjectClass = interface;
  IPCB_Component = interface;
  IPCB_Pad = interface;
  IPCB_LayerObject = interface;
  IPCB_MechanicalLayer = interface;
  IPCB_GroupIterator = interface;
  IPCB_Rule = interface;
  IPCB_LayerObjectIterator = interface;
  IPCB_Primitive = interface;
  IPCB_Dielectric = interface;
  IPCB_SystemOptions = interface;

  // Text type
  IPCB_TextClass = class
    Text: WideString;
  end;

  // Dielectric interface
  IPCB_Dielectric = interface
    function GetDielectricType: Integer;
    function GetDielectricMaterial: WideString;
    function GetDielectricHeight: TCoord;
    function GetDielectricConstant: Double;
    property DielectricType: Integer read GetDielectricType;
    property DielectricMaterial: WideString read GetDielectricMaterial;
    property DielectricHeight: TCoord read GetDielectricHeight;
    property DielectricConstant: Double read GetDielectricConstant;
  end;

  // Net interface
  IPCB_Net = interface
    function GetName: WideString;
    property Name: WideString read GetName;
  end;

  // Pad interface
  IPCB_Pad = interface
    function GetName: WideString;
    function GetNet: IPCB_Net;
    function GetX: TCoord;
    function GetY: TCoord;
    function GetRotation: TAngle;
    function GetLayer: TLayer;
    function GetInComponent: Boolean;
    function GetXSizeOnLayer(Layer: TLayer): TCoord;
    function GetYSizeOnLayer(Layer: TLayer): TCoord;
    function GetShapeOnLayer(Layer: TLayer): Integer;
    property Name: WideString read GetName;
    property Net: IPCB_Net read GetNet;
    property x: TCoord read GetX;
    property y: TCoord read GetY;
    property Rotation: TAngle read GetRotation;
    property Layer: TLayer read GetLayer;
    property InComponent: Boolean read GetInComponent;
  end;

  // Component interface
  IPCB_Component = interface
    function GetName: IPCB_TextClass;
    function GetIdentifier: WideString;
    function GetSourceDescription: WideString;
    function GetPattern: WideString;
    function GetLayer: TLayer;
    function GetX: TCoord;
    function GetY: TCoord;
    function GetRotation: TAngle;
    function GetSelected: Boolean;
    function BoundingRectangleNoNameComment: TCoordRect;
    function GroupIterator_Create: IPCB_GroupIterator;
    procedure GroupIterator_Destroy(Iterator: IPCB_GroupIterator);
    procedure MoveByXY(DX, DY: TCoord);
    property Name: IPCB_TextClass read GetName;
    property Identifier: WideString read GetIdentifier;
    property SourceDescription: WideString read GetSourceDescription;
    property Pattern: WideString read GetPattern;
    property Layer: TLayer read GetLayer;
    property x: TCoord read GetX;
    property y: TCoord read GetY;
    property Rotation: TAngle read GetRotation;
    property Selected: Boolean read GetSelected;
  end;

  // Layer Object interface
  IPCB_LayerObject = interface
    function GetName: WideString;
    function GetLayerID: TLayer;
    function GetV6_LayerID: Integer;
    function GetCopperThickness: TCoord;
    function GetDielectric: IPCB_Dielectric;
    function GetIsDisplayed(Board: IPCB_Board): Boolean;
    procedure SetIsDisplayed(Board: IPCB_Board; Value: Boolean);
    property Name: WideString read GetName;
    property LayerID: TLayer read GetLayerID;
    property V6_LayerID: Integer read GetV6_LayerID;
    property CopperThickness: TCoord read GetCopperThickness;
    property Dielectric: IPCB_Dielectric read GetDielectric;
    property IsDisplayed[Board: IPCB_Board]: Boolean read GetIsDisplayed write SetIsDisplayed;
  end;

  // Mechanical Layer interface
  IPCB_MechanicalLayer = interface(IPCB_LayerObject)
    function GetMechanicalLayerEnabled: Boolean;
    function GetLinkToSheet: Boolean;
    property MechanicalLayerEnabled: Boolean read GetMechanicalLayerEnabled;
    property LinkToSheet: Boolean read GetLinkToSheet;
  end;

  // Layer Stack interface
  IPCB_LayerStack = interface
    function GetFirstLayer: IPCB_LayerObject;
    function NextLayer(Layer: IPCB_LayerObject): IPCB_LayerObject;
    function GetLayerObject_V7(Layer: TLayer): IPCB_MechanicalLayer;
    function GetLayersInStackCount: Integer;
    function GetSignalLayerCount: Integer;
    property FirstLayer: IPCB_LayerObject read GetFirstLayer;
    property LayerObject_V7[Layer: TLayer]: IPCB_MechanicalLayer read GetLayerObject_V7;
    property LayersInStackCount: Integer read GetLayersInStackCount;
    property SignalLayerCount: Integer read GetSignalLayerCount;
  end;

  IPCB_LayerStack_V7 = IPCB_LayerStack;
  IPCB_LayerObject_V7 = IPCB_LayerObject;

  // Iterator interfaces
  IPCB_BoardIterator = interface
    procedure AddFilter_ObjectSet(ObjectSet: Integer);
    procedure AddFilter_LayerSet(LayerSet: Integer);
    procedure AddFilter_IPCB_LayerSet(LayerSet: Integer);
    procedure AddFilter_Method(Method: Integer);
    procedure SetState_FilterAll;
    function FirstPCBObject: IPCB_Primitive;
    function NextPCBObject: IPCB_Primitive;
  end;

  IPCB_GroupIterator = interface
    procedure SetState_FilterAll;
    procedure AddFilter_ObjectSet(ObjectSet: Integer);
    function FirstPCBObject: IPCB_Primitive;
    function NextPCBObject: IPCB_Primitive;
  end;

  IPCB_LayerObjectIterator = interface
    function Next: Boolean;
    function GetLayerObject: IPCB_LayerObject;
    property LayerObject: IPCB_LayerObject read GetLayerObject;
  end;

  // Primitive base interface
  IPCB_Primitive = interface
    function GetObjectId: Integer;
    property ObjectId: Integer read GetObjectId;
  end;

  // Object Class interface
  IPCB_ObjectClass = interface
    function GetMemberKind: Integer;
    function GetKind: Integer;
    procedure SetKind(Value: Integer);
    function GetName: WideString;
    procedure SetName(Value: WideString);
    procedure SetSuperClass(Value: Boolean);
    function AddMemberByName(MemberName: WideString): Boolean;
    procedure AddMember(Member: IPCB_Primitive);
    property MemberKind: Integer read GetMemberKind;
    property Kind: Integer read GetKind write SetKind;
    property Name: WideString read GetName write SetName;
    property SuperClass: Boolean write SetSuperClass;
  end;

  // Rule interface
  IPCB_Rule = interface
    function GetDescriptor: WideString;
    function GetState_ShortDescriptorString: WideString;
    function GetScope1Expression: WideString;
    function GetScope2Expression: WideString;
    property Descriptor: WideString read GetDescriptor;
  end;

  // Mechanical Pairs interface
  IPCB_MechanicalPairs = interface
    function LayerUsed(Layer: TLayer): Boolean;
  end;

  // View Manager interface
  IPCB_ViewManager = interface
    procedure FullUpdate;
    procedure UpdateLayerTabs;
  end;

  // Board interface
  IPCB_Board = interface
    function GetXOrigin: TCoord;
    function GetYOrigin: TCoord;
    function GetFileName: WideString;
    function GetLayerStack: IPCB_LayerStack;
    function GetLayerStack_V7: IPCB_LayerStack_V7;
    function GetLayerColor(Layer: TLayer): Integer;
    function GetLayerIsDisplayed(Layer: TLayer): Boolean;
    procedure SetLayerIsDisplayed(Layer: TLayer; Value: Boolean);
    function GetSelectecObjectCount: Integer;
    function GetSelectecObject(Index: Integer): IPCB_Primitive;
    function GetMechanicalPairs: IPCB_MechanicalPairs;
    function GetViewManager: IPCB_ViewManager;
    function GetElectricalLayerIterator: IPCB_LayerObjectIterator;
    function BoardIterator_Create: IPCB_BoardIterator;
    procedure BoardIterator_Destroy(Iterator: IPCB_BoardIterator);
    function GetPcbComponentByRefDes(Designator: WideString): IPCB_Component;
    procedure AddPCBObject(Obj: IPCB_Primitive);
    property XOrigin: TCoord read GetXOrigin;
    property YOrigin: TCoord read GetYOrigin;
    property FileName: WideString read GetFileName;
    property LayerStack: IPCB_LayerStack read GetLayerStack;
    property LayerStack_V7: IPCB_LayerStack_V7 read GetLayerStack_V7;
    property LayerColor[Layer: TLayer]: Integer read GetLayerColor;
    property LayerIsDisplayed[Layer: TLayer]: Boolean read GetLayerIsDisplayed write SetLayerIsDisplayed;
    property SelectecObjectCount: Integer read GetSelectecObjectCount;
    property SelectecObject[Index: Integer]: IPCB_Primitive read GetSelectecObject;
    property MechanicalPairs: IPCB_MechanicalPairs read GetMechanicalPairs;
    property ElectricalLayerIterator: IPCB_LayerObjectIterator read GetElectricalLayerIterator;
  end;

  // PCB Server interface
  IPCB_Server = interface
    function GetCurrentPCBBoard: IPCB_Board;
    procedure PreProcess;
    procedure PostProcess;
    function PCBClassFactoryByClassMember(MemberKind: Integer): IPCB_ObjectClass;
    function PCBObjectFactory(ObjectType: Integer; Dimension: Integer; CreateMode: Integer): IPCB_Primitive;
    procedure SendMessageToRobots(Address: Integer; Msg1: Integer; Msg2: Integer; Data: Integer);
    function GetSystemOptions: IPCB_SystemOptions;
  end;

  IPCB_SystemOptions = interface
    function GetLayerColors(Layer: Integer): Integer;
    property LayerColors[Layer: Integer]: Integer read GetLayerColors;
  end;

  // Unused interfaces (minimal definitions)
  IPCB_Text = interface
  end;

  IPCB_SchComponent = interface
  end;

  IPCB_SchPin = interface
  end;

  IPCB_LibComponent = interface
  end;

  IPCB_Track = interface
  end;

  IPCB_Via = interface
  end;

  IPCB_Polygon = interface
  end;

  IPCB_Contour = interface
  end;

  // Client interface
  IPCB_Client = interface
    procedure SendMessage(Msg: WideString; Params: WideString; Unknown1: Integer; Unknown2: Integer);
    function GetCurrentView: Integer;
    property CurrentView: Integer read GetCurrentView;
  end;

// Type aliases for compatibility
type
  IPCB_ServerInterface = IPCB_Server;
  IClient = IPCB_Client;

// Global objects
var
  PCBServer: IPCB_Server;
  Client: IPCB_Client;

// Constants for object types
const
  eNetObject = 1;
  eComponentObject = 2;
  ePadObject = 3;
  eRuleObject = 4;
  eClassObject = 5;
  eNoLayer = 0;

  // Class kinds
  eNetClass = 1;
  eComponentClass = 2;
  eFromToClass = 3;
  ePadClass = 4;
  eLayerClass = 5;

  // Class member kinds
  eClassMemberKind_Net = 1;

  // Dimensions
  eNoDimension = 0;
  e2DObject = 1;
  e3DObject = 2;

  // Create modes
  eCreate_Default = 0;
  eCreate_New = 1;

  // Dielectric types
  eNoDielectric = 0;
  eCore = 1;
  ePrePreg = 2;
  eSurfaceMaterial = 3;

  // Process methods
  eProcessAll = 1;

  // Messages
  c_Broadcast = 1;
  PCBM_BeginModify = 1;
  PCBM_EndModify = 2;
  c_NoEventData = 0;

// Layer set constants
var
  AllLayers: Integer;

// Layer set helper
type
  TLayerSet = class
  public
    class function AllLayers: Integer;
  end;

  TLayerSetHelper = class
  public
    SignalLayers: TLayerSet;
  end;

var
  LayerSet: TLayerSetHelper;

// ILayer helper
type
  TILayer = class
  public
    class function MechanicalLayer(Index: Integer): TLayer;
  end;

var
  ILayer: TILayer;

// Workspace and Document interfaces
type
  IDocument = interface
    function DM_DocumentSave: Boolean;
    function DM_FileName: WideString;
  end;

  IProject = interface
    function DM_AddSourceDocument(FileName: WideString): Boolean;
    procedure DM_ProjectSave;
    function DM_ProjectFileName: WideString;
    function DM_ProjectFullPath: WideString;
    function DM_LogicalDocumentCount: Integer;
    function DM_LogicalDocuments(Index: Integer): IDocument;
    function DM_DocumentCount: Integer;
    function DM_Documents(Index: Integer): IDocument;
  end;

  IWorkspace = interface
    function DM_CreateNewProject(ProjectPath: WideString): IProject;
    function DM_CreateNewDocument(DocType: WideString): IDocument;
    function DM_FocusedProject: IProject;
    procedure DM_CloseProject(Project: IProject);
  end;

// Helper functions
function MkSet(Value: Integer): Integer;
function CoordToMils(Coord: TCoord): Double;
function MilsToCoord(Mils: Double): TCoord;
function MMsToCoord(MM: Double): TCoord;
function Layer2String(Layer: TLayer): WideString;
function String2Layer(LayerName: WideString): TLayer;
function ColorToString(Color: Integer): WideString;
function ShapeToString(Shape: Integer): WideString;
function ExtractFileName(FileName: WideString): WideString;
function ExtractFilePath(FileName: WideString): WideString;
function ExtractFileExt(FileName: WideString): WideString;
function UpperCase(S: WideString): WideString;
function FileExists(FileName: WideString): Boolean;
function IntToStr(Value: Integer): WideString;
function StrToIntDef(S: WideString; Default: Integer): Integer;
function StrToFloat(S: WideString): Double;
function Trim(S: WideString): WideString;

// Global API functions
function GetPCBServer: IPCB_Server;
function GetWorkspace: IWorkspace;

implementation

function MkSet(Value: Integer): Integer;
begin
  Result := Value;
end;

function CoordToMils(Coord: TCoord): Double;
begin
  Result := Coord / 10000.0;
end;

function MilsToCoord(Mils: Double): TCoord;
begin
  Result := Round(Mils * 10000);
end;

function MMsToCoord(MM: Double): TCoord;
begin
  Result := Round(MM * 393700.787);
end;

function Layer2String(Layer: TLayer): WideString;
begin
  Result := '';
end;

function String2Layer(LayerName: WideString): TLayer;
begin
  Result := 0;
end;

function ColorToString(Color: Integer): WideString;
begin
  Result := '';
end;

function ShapeToString(Shape: Integer): WideString;
begin
  Result := '';
end;

function ExtractFileName(FileName: WideString): WideString;
begin
  Result := SysUtils.ExtractFileName(FileName);
end;

function ExtractFilePath(FileName: WideString): WideString;
begin
  Result := SysUtils.ExtractFilePath(FileName);
end;

function ExtractFileExt(FileName: WideString): WideString;
begin
  Result := SysUtils.ExtractFileExt(FileName);
end;

function UpperCase(S: WideString): WideString;
begin
  Result := SysUtils.UpperCase(S);
end;

function FileExists(FileName: WideString): Boolean;
begin
  Result := SysUtils.FileExists(FileName);
end;

function IntToStr(Value: Integer): WideString;
begin
  Result := SysUtils.IntToStr(Value);
end;

function StrToIntDef(S: WideString; Default: Integer): Integer;
begin
  Result := SysUtils.StrToIntDef(S, Default);
end;

function StrToFloat(S: WideString): Double;
begin
  Result := SysUtils.StrToFloat(S);
end;

function Trim(S: WideString): WideString;
begin
  Result := SysUtils.Trim(S);
end;

function GetPCBServer: IPCB_Server;
begin
  Result := PCBServer;
end;

function GetWorkspace: IWorkspace;
begin
  Result := nil;
end;

class function TLayerSet.AllLayers: Integer;
begin
  Result := -1;  // All bits set, equivalent to $FFFFFFFF in two's complement
end;

class function TILayer.MechanicalLayer(Index: Integer): TLayer;
begin
  Result := Index;
end;

end.
