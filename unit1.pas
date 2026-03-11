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
  end;

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    CheckBox1: TCheckBox;
    imgList_24w: TImageList;
    imgList_32w: TImageList;
    imgList_16w: TImageList;
    imgList_32: TImageList;
    imgList_16: TImageList;
    imgList_24: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    RadioGroup1: TRadioGroup;
    RadioGroup2: TRadioGroup;
    vst: TLazVirtualStringTree;
    procedure Button1Click(Sender: TObject);
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
    FShowCounter: SizeInt;
    procedure TreeGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean;
      var ImageIndex: Integer);
    procedure TreeGetImageIndexEx(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer; var ImageList: TCustomImageList
  );
  public
    property CurrentImgList: TImageList read FCurrentImgList;
    property ShowCounter: SizeInt read FShowCounter;
  end;

var
  Form1: TForm1;

implementation

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
  Ghosted:= not Data^.BoolVal;
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
    HintMode := hmTooltip;
    ShowHint := True;
    //OnGetImageIndex:= @TreeGetImageIndex;
    //Images:= imgList_32;
    //OnGetImageIndexEx:= @TreeGetImageIndexEx;

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

    //OnDblClick := @actChoiceExecute;
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

procedure TForm1.FormShow(Sender: TObject);
var
  Node: PVirtualNode = nil;
  Data: PMyRec = nil;
  i: Integer;
begin
  RadioGroup1Click(Sender);

  vst.Clear;
  for i := 0 to Pred(8) do
  begin
    Node:= vst.AddChild(nil);
    Data:= vst.GetNodeData(Node);
    Data^.StrVal:= 'some string ' + IntToStr(Succ(i));
    Data^.ImgIndex:= 0;
    Data^.BoolVal:= ((Succ(i) mod 2) = 0);
  end;
end;

procedure TForm1.RadioGroup1Click(Sender: TObject);
begin
  FShowCounter:= 0;

  case RadioGroup1.ItemIndex of
    0: FCurrentImgList:= imgList_16;
    1: FCurrentImgList:= imgList_24;
  else
    FCurrentImgList:= imgList_32;
  end;

    vst.Invalidate;
  //Exit;

  case RadioGroup2.ItemIndex of
    0:
      begin
        vst.Images:= FCurrentImgList;
        vst.OnGetImageIndex:= @TreeGetImageIndex;
        vst.OnGetImageIndexEx:= nil;
      end;
    1:
      begin
        vst.Images:= imgList_16;
        vst.OnGetImageIndex:= nil;
        vst.OnGetImageIndexEx:= @TreeGetImageIndexEx;
        vst.Invalidate;
      end
  else ;
  end;

  //vst.Invalidate;
  //vst.Repaint;
end;

procedure TForm1.vstAddToSelection(Sender: TBaseVirtualTree; Node: PVirtualNode
  );
var
  Data: PMyRec = nil;
begin
  Data:= vst.GetNodeData(Node);

  Label1.Caption:= Format('StrVal: %s',[Data^.StrVal]);
  Label2.Caption:= Format('ImgIndex: %d',[Data^.ImgIndex]);
  CheckBox1.Checked:= Data^.BoolVal;
end;

end.

