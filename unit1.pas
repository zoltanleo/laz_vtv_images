unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  laz.VirtualTrees, ImgList, ExtCtrls;

type
  PMyRec = ^TMyRec;
  TMyRec = record
    StrVal: String;
    ImgIndex: SizeInt;
    BoolVal: Boolean;
    StrHint: String;
  end;

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    imgList_24w: TImageList;
    imgList_32w: TImageList;
    imgList_16w: TImageList;
    imgList_32: TImageList;
    imgList_16: TImageList;
    imgList_24: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    RadioGroup1: TRadioGroup;
    RadioGroup2: TRadioGroup;
    vst: TLazVirtualStringTree;
    procedure Button1Click(Sender: TObject);
    procedure CheckBox2Change(Sender: TObject);
    procedure CheckBox3Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure vstAddToSelection(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstFreeNode(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure vstGetNodeDataSize(Sender: TBaseVirtualTree;
      var NodeDataSize: Integer);
    procedure vstGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
  private
    FCurrentImgList: TImageList;
    FInitNodeHeight: SizeInt;
    FShowCounter: SizeInt;
    procedure TreeGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean;
      var ImageIndex: Integer);
    procedure TreeGetImageIndexEx(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer; var ImageList: TCustomImageList
  );
    procedure TreeMeasureItem(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; var NodeHeight: Integer);
    procedure TreeGetHint(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; var LineBreakStyle: TVTTooltipLineBreakStyle;
  var HintText: String);
  public
    property CurrentImgList: TImageList read FCurrentImgList;
    property ShowCounter: SizeInt read FShowCounter;
    property InitNodeHeight: SizeInt read FInitNodeHeight;
  end;

var
  Form1: TForm1;

implementation

uses Math;

{$R *.lfm}

{ TForm1 }

procedure TForm1.vstFreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  if Assigned(Sender.GetNodeData(Node)) then
    Finalize(PMyRec(Sender.GetNodeData(Node))^);
end;

procedure TForm1.vstGetNodeDataSize(Sender: TBaseVirtualTree;
  var NodeDataSize: Integer);
begin
  NodeDataSize:= SizeOf(TMyRec);
end;

procedure TForm1.vstGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
var
  Data: PMyRec = nil;
begin
  Data := vst.GetNodeData(Node);
  if not Assigned(Data) then Exit;

  case Column of
    0: CellText := Data^.StrVal;
    else;
  end;
end;

procedure TForm1.TreeGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  Data: PMyRec = nil;
begin
  //if  (ShowCounter = 0) then ShowMessage('we are inside TreeGetImageIndex procedure');
  Inc(FShowCounter);

  Data:= vst.GetNodeData(Node);
  if not Assigned(Data) then Exit;

  ImageIndex:= PtrInt(Data^.BoolVal);
  //Ghosted:= not Data^.BoolVal;
end;

procedure TForm1.TreeGetImageIndexEx(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer; var ImageList: TCustomImageList
  );
var
  Data: PMyRec = nil;
begin
  //if  (ShowCounter = 0) then ShowMessage('we are inside TreeGetImageIndexEx procedure');
  Inc(FShowCounter);

  Data:= vst.GetNodeData(Node);
  if not Assigned(Data) then Exit;

  if Data^.BoolVal
    then ImageList:= FCurrentImgList
    else
      case RadioGroup1.ItemIndex of
        0: ImageList:= imgList_16w;
        1: ImageList:= imgList_24w;
      else
        ImageList:= imgList_32w;
      end;

  ImageIndex:= PtrInt(Data^.BoolVal);
end;

procedure TForm1.TreeMeasureItem(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; var NodeHeight: Integer);
var
  Data: PMyRec;
  ImgHeight: Integer;
  TextHeight: Integer;
begin
  Data := vst.GetNodeData(Node);
  if not Assigned(Data) then Exit;

  // Getting the height of the image from the current ImageList
  if Assigned(vst.Images)
  then
    ImgHeight := vst.Images.Height
  else
    ImgHeight := InitNodeHeight; // Default value

  // Getting the height of the text
  TextHeight := TargetCanvas.TextHeight('Wg');

  // Choosing the maximum value + margins
  NodeHeight := Max(ImgHeight, TextHeight) + 4;//uses math
end;

procedure TForm1.TreeGetHint(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; var LineBreakStyle: TVTTooltipLineBreakStyle;
  var HintText: String);
var
  Data: PMyRec = nil;
begin
  Data := vst.GetNodeData(Node);
  if (Assigned(Data) and (Data^.StrHint <> ''))
    then HintText:= Data^.StrHint
    else HintText:= 'Value StrHint field is empty';

  LineBreakStyle := hlbDefault;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FShowCounter:= 0;

  with RadioGroup1 do
  begin
    ItemIndex:= 0;
    Columns:= Items.Count;
    AutoSize:= True;
    ChildSizing.TopBottomSpacing:= 10;
    ChildSizing.LeftRightSpacing:= 10;
  end;

  with RadioGroup2 do
  begin
    ItemIndex:= 0;
    Columns:= Items.Count;
    AutoSize:= True;
    ChildSizing.TopBottomSpacing:= 10;
    ChildSizing.LeftRightSpacing:= 10;
    OnClick:= @RadioGroup1Click;
  end;

  FCurrentImgList:= imgList_16;

  with vst do
  begin
    ShowHint := True;
    Application.HintPause := 500;    // Delay before showing (ms)
    Application.HintHidePause := 2500; // Display time (ms)
    Application.HintShortPause := 50;  // Delay between prompts


    with Header do
    begin
      Columns.Clear;
      Columns.Add;
      Columns[0].Text := '';

      AutoSizeIndex := 0;
      Height := Canvas.TextHeight('W') * 3 div 2;
      Options := Options + [hoAutoResize,
                            hoOwnerDraw,
                            hoShowHint,
                            hoShowImages
                            //, hoVisible
                            ];
      Height := Canvas.TextHeight('W') * 3 div 2;
    end;

    with TreeOptions do
    begin
      AutoOptions := AutoOptions
                    + [toAutoScroll
                      , toAutoSpanColumns]
                    - [];

      MiscOptions := MiscOptions
                    + [toCheckSupport]
                    - [toAcceptOLEDrop
                      , toEditOnClick];

      PaintOptions := PaintOptions
                    + [toShowButtons
                      , toUseExplorerTheme
                      ]
                    - [toShowDropmark];

      SelectionOptions := SelectionOptions
                     + [toExtendedFocus
                      , toFullRowSelect
                      , toCenterScrollIntoView
                      , toRestoreSelection
                      , toAlwaysSelectNode]
                    - [toMultiSelect];
    end;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  Node: PVirtualNode = nil;
  Data: PMyRec = nil;
begin
  Node:= vst.GetFirstSelected;
  if not Assigned(Node) then Exit;

  vst.BeginUpdate;
  try
    Data:= vst.GetNodeData(Node);
    Data^.BoolVal:= CheckBox1.Checked;
  finally
    vst.EndUpdate;
  end;

end;

procedure TForm1.CheckBox2Change(Sender: TObject);
begin
  if CheckBox2.Checked then
  begin
    vst.TreeOptions.MiscOptions:= vst.TreeOptions.MiscOptions + [toVariableNodeHeight];
    vst.OnMeasureItem:= @TreeMeasureItem;
  end else
  begin
    vst.TreeOptions.MiscOptions:= vst.TreeOptions.MiscOptions - [toVariableNodeHeight];
    vst.OnMeasureItem:= nil;
  end;

  RadioGroup1Click(Sender);
end;

procedure TForm1.CheckBox3Change(Sender: TObject);
var
  Node: PVirtualNode = nil;
begin
  case CheckBox3.Checked of
    True:
      begin
        vst.HintMode := hmHintAndDefault;
        vst.OnGetHint:= @TreeGetHint;
      end;
  else
    begin
      vst.HintMode := hmTooltip;
      vst.OnGetHint:= nil;
    end;
  end;

  Node:= vst.GetFirst;

  while Assigned(Node) do
  begin
    vst.ReinitNode(Node,True);
    Node:= Node^.NextSibling;
  end;
end;

procedure TForm1.FormShow(Sender: TObject);
var
  Node: PVirtualNode = nil;
  Data: PMyRec = nil;
  i: Integer;
begin
  FInitNodeHeight:= vst.DefaultNodeHeight;
  RadioGroup1Click(Sender);
  CheckBox3Change(Sender);

  vst.Clear;
  for i := 0 to Pred(8) do
  begin
    Node:= vst.AddChild(nil);
    Data:= vst.GetNodeData(Node);
    Data^.StrVal:= 'some string ' + IntToStr(Succ(i));
    Data^.ImgIndex:= 0;
    Data^.BoolVal:= ((Succ(i) mod 2) = 0);
    Data^.StrHint:= Format('This line contains a hint for the %s string',[Data^.StrVal]) ;
  end;
end;

procedure TForm1.RadioGroup1Click(Sender: TObject);
var
  Node: PVirtualNode = nil;
begin
  FShowCounter:= 0;

  case RadioGroup1.ItemIndex of
    0: FCurrentImgList:= imgList_16;
    1: FCurrentImgList:= imgList_24;
  else
    FCurrentImgList:= imgList_32;
  end;

  vst.Images:= CurrentImgList;

  case RadioGroup2.ItemIndex of
    0:
      begin
        vst.OnGetImageIndex:= @TreeGetImageIndex;
        vst.OnGetImageIndexEx:= nil;
      end;
    1:
      begin
        vst.OnGetImageIndex:= nil;
        vst.OnGetImageIndexEx:= @TreeGetImageIndexEx;
      end
  else ;
  end;

  vst.BeginUpdate;
  try
    // Reinitialize all nodes for height recalculation
    Node := vst.GetFirst;
    while Assigned(Node) do
    begin
      vst.ReinitNode(Node, True);
      Node:= Node^.NextSibling;
    end;
  finally
    vst.EndUpdate;
  end;
end;

procedure TForm1.vstAddToSelection(Sender: TBaseVirtualTree; Node: PVirtualNode
  );
var
  Data: PMyRec = nil;
begin
  Data:= vst.GetNodeData(Node);

  Label1.Caption:= Format('StrVal: %s',[Data^.StrVal]);
  Label2.Caption:= Format('ImgIndex: %d',[Data^.ImgIndex]);
  Label3.Caption:= Format('StrHint: %s',[Data^.StrHint]);
  CheckBox1.Checked:= Data^.BoolVal;
end;

end.

