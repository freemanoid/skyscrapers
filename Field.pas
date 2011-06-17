unit Field;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Spin, Menus;

const
  _UnitWidth = 81;
  _UnitHeight = 81;
  _FloorIncrement = 5;
  _DistanceBeetwenUnits = 9;
  _DefaultFieldSize = 3;
  _BorderWidth = 50;
  _TopLeftFieldBorder: TPoint = (X: 150; Y: 50);
  _BorderFontName: String = 'Comic Sans MS';
  _BorderFontSize = 18;
  _BorderFontStyle = fsBold;
  _VisibilityUnitBackgroundColor = clInactiveCaptionText;
  _ImageCursor = crHandPoint;
  _MaxFieldSize = 6;
  visLeft = 1;
  visRight = 2;
  visTop = 3;
  visBot = 4;
  _PicturesDir = 'images\';
  
type
  TImageArray = array[0..(Field._MaxFieldSize - 1), 0..(Field._MaxFieldSize - 1)] of TImage;
  TUnitsArray = array[0..(Field._MaxFieldSize - 1), 0..(Field._MaxFieldSize - 1)] of shortint;
  TVisibilityLabelArray = array[1..4] of array[0..(Field._MaxFieldSize - 1)] of TLabel;
  TVisibilityArray = array[1..4] of array[0..(Field._MaxFieldSize - 1)] of shortint;
  TFieldForm = class(TForm)
    FieldSizeSpinEdit: TSpinEdit;
    FieldSizeLabel: TLabel;
    CheckButton: TButton;
    AutoSolutionButton: TButton;
    MainMenu: TMainMenu;
    OpenDialog: TOpenDialog;
    File1: TMenuItem;
    Open: TMenuItem;
    ClearButton: TButton;
    Button1: TButton;
    NewFieldButton: TButton;
    procedure FormCreate(Sender: TObject);
    procedure DrawUnit (UnitNumber, Row, Col: shortint);
    procedure DrawEmptyField;
    procedure DrawFieldFromUnitsArray;
    procedure FieldSizeSpinEditChange(Sender: TObject);
    procedure HideUnit (Row, Col: shortint);
    procedure DrawVisibilityBorder;
    procedure ClearTheField;
    procedure UnitClick(Sender: TObject);
    procedure CheckButtonClick(Sender: TObject);
    procedure AutoSolutionButtonClick(Sender: TObject);
    procedure SetUnit (var UnitsArray: TUnitsArray; Value, Row, Col: shortint);
    procedure OpenClick(Sender: TObject);
    procedure ClearButtonClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure HideVisibilityUnit (UnitSide, UnitIndex: shortint);
    procedure ClearVisibilityBorder;
    procedure ClearUnitsArray;
    procedure ClearVisibilityArray;
    procedure NewFieldButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    ImageArray: TImageArray;
    UnitsArray: TUnitsArray;
    FieldSize: shortint;
    VisibilityLabelArray: TVisibilityLabelArray;
    VisibilityArray: TVisibilityArray;
    AllreadySolved: boolean;
  end;
var
  FieldForm: TFieldForm;

implementation

uses
  FieldProcessing, FieldGeneration;

{$R *.dfm}

procedure TFieldForm.SetUnit (var UnitsArray: TUnitsArray; Value, Row, Col: shortint);
begin                     
  UnitsArray[Row][Col]:= Value;
end;

procedure TFieldForm.FormCreate(Sender: TObject);
begin
  //variables initializate
  //all field objects initialization
  FieldSize:= _MaxFieldSize;
  DrawEmptyField;
  ClearTheField;
  DrawVisibilityBorder;
  ClearVisibilityBorder;
  FieldSize:= _DefaultFieldSize;
  DrawEmptyField;
  DrawVisibilityBorder;
  FieldProcessing.ResetPlacedVariantsArray (FieldSize);
end;

procedure TFieldForm.DrawUnit (UnitNumber, Row, Col: shortint);
begin
  UnitsArray[Row, Col]:= UnitNumber;
  if ImageArray[Row, Col] = nil then
    ImageArray[Row, Col]:= TImage.Create (FieldForm);
  with ImageArray[Row, Col] do
  begin
    Cursor:= _ImageCursor;
    OnClick:= UnitClick;
    Tag:= Row * 10 + Col;//we use tag field to connect ImageArray and UnitsArray
    Parent:= FieldForm;
    Left:= _TopLeftFieldBorder.X + _BorderWidth +
          (_UnitWidth + _DistanceBeetwenUnits) * Col;
    Top:= _TopLeftFieldBorder.Y + _BorderWidth +
         (_UnitHeight + _DistanceBeetwenUnits) * Row - _FloorIncrement * UnitNumber;
    if (UnitNumber > _MaxFieldSize) or (UnitNumber < 0) then
      ShowMessage (Format ('Ошибка: высота небоскрёба не может быть равной %d (должна быть от 0 до 6)', [UnitNumber]));
    Picture.LoadFromFile (ExtractFilePath (Application.ExeName) + _PicturesDir + IntToStr (UnitNumber) + '.bmp'); //UnitNumber must be in 0-6
    Show;
  end;
end;

procedure TFieldForm.HideUnit (Row, Col: shortint);
begin
    ImageArray[Row][Col].Hide;
    UnitsArray[Row][Col]:= 0;
end;

procedure TFieldForm.DrawFieldFromUnitsArray;
var
  itrRow, itrCol: smallint;
begin
  for itrRow:= 0 to FieldSize - 1 do
    for itrCol:= 0 to FieldSize - 1 do
      DrawUnit (UnitsArray[itrRow][itrCol], itrRow, itrCol);  
end;

procedure TFieldForm.ClearTheField;
var
  itrRow, itrCol: smallint;
begin
  ClearUnitsArray;
  for itrRow:= 0 to FieldSize - 1 do
    for itrCol:= 0 to FieldSize - 1 do
      HideUnit (itrRow, itrCol);  
end;

procedure TFieldForm.DrawEmptyField;
var
  itrRow, itrCol, itr: smallint;
begin
  for itrRow:= 0 to FieldSize - 1 do
      for itrCol:= 0 to FieldSize - 1 do
        DrawUnit (0, itrRow, itrCol);  
end;

procedure TFieldForm.HideVisibilityUnit (UnitSide, UnitIndex: shortint);
begin
  VisibilityArray[UnitSide][UnitIndex]:= 0;
  VisibilityLabelArray[UnitSide][UnitIndex].Hide;
end;

procedure TFieldForm.DrawVisibilityBorder;  
  procedure DrawVisibilityBorderUnit (UnitSide: shortint; UnitIndex: shortint);
  begin
    if VisibilityLabelArray[UnitSide][UnitIndex] = nil then
      VisibilityLabelArray[UnitSide][UnitIndex]:= TLabel.Create(FieldForm);
    with VisibilityLabelArray[UnitSide][UnitIndex] do
    begin
      Color:= _VisibilityUnitBackgroundColor;
      Parent:= FieldForm;
      Font.Size:= _BorderFontSize;
      Font.Name:= _BorderFontName;
      Font.Style:= [_BorderFontStyle];
      //it is always possible to see at least one skyscraper (the highest one) and therefore we
      //can use zero-visibility as undefined visibility
      if VisibilityArray[UnitSide][UnitIndex] = 0 then
        Caption:= ''
      else
        Caption:= IntToStr (VisibilityArray[UnitSide][UnitIndex]);
      case UnitSide of
      visLeft:
      begin
        Left:= _TopLeftFieldBorder.X + _BorderWidth div 2;
        Top:= _TopLeftFieldBorder.Y + _BorderWidth +
              (_UnitHeight + _DistanceBeetwenUnits) * UnitIndex;  
      end;
      visRight:
      begin
        Left:= _TopLeftFieldBorder.X + _BorderWidth + 
              (_UnitWidth + _DistanceBeetwenUnits) * FieldSize - _DistanceBeetwenUnits;
        Top:= _TopLeftFieldBorder.Y + _BorderWidth +
              (_UnitHeight + _DistanceBeetwenUnits) * UnitIndex;  
      end;
      visTop:
      begin
        Left:= _TopLeftFieldBorder.X + _BorderWidth + _UnitWidth div 3 +
              (_UnitWidth + _DistanceBeetwenUnits) * UnitIndex - _DistanceBeetwenUnits;
        Top:= _TopLeftFieldBorder.Y - _BorderWidth div 2;  
      end;
      visBot:
      begin
        Left:= _TopLeftFieldBorder.X + _BorderWidth + _UnitWidth div 3 +
              (_UnitWidth + _DistanceBeetwenUnits) * UnitIndex - _DistanceBeetwenUnits;
        Top:= _TopLeftFieldBorder.Y + _BorderWidth + 
              (_UnitWidth + _DistanceBeetwenUnits) * FieldSize;  
      end;
      end;
      Show;
    end;  
  end;
  
var
  itr: shortint;
begin
  for itr:= 0 to FieldSize - 1 do
  begin
    DrawVisibilityBorderUnit (visLeft, itr);
    DrawVisibilityBorderUnit (visRight, itr);
    DrawVisibilityBorderUnit (visTop, itr);
    DrawVisibilityBorderUnit (visBot, itr);
  end; 
end;

procedure TFieldForm.ClearVisibilityBorder;
var
  itr: shortint;
begin
  ClearVisibilityArray;
  for itr:= 0 to FieldSize - 1 do
      begin
        HideVisibilityUnit (visLeft, itr);
        HideVisibilityUnit (visRight, itr);
        HideVisibilityUnit (visTop, itr);
        HideVisibilityUnit (visBot, itr);
      end;
end;

procedure TFieldForm.ClearVisibilityArray;
var
  itrSide, itrVis: shortint;
begin
  for itrSide:= visLeft to VisBot do
    for itrVis:= 0 to FieldSize - 1 do
      VisibilityArray[itrSide][itrVis]:= 0; 
end;

procedure TFieldForm.ClearUnitsArray;
var
  itrRow, itrCol: shortint;
begin
  for itrRow:= 0 to FieldSize - 1 do
      for itrCol:= 0 to FieldSize - 1 do
        UnitsArray[itrRow][itrCol]:= 0;  
end;
    
procedure TFieldForm.FieldSizeSpinEditChange(Sender: TObject);
begin
  if FieldSizeSpinEdit.Value < FieldSize then
  begin
    ClearTheField;
    ClearVisibilityBorder;
    FieldSize:= FieldSizeSpinEdit.Value;
    DrawVisibilityBorder;
    DrawEmptyField;
  end
  else
  begin
    ClearTheField;
    FieldSize:= FieldSizeSpinEdit.Value;
    ClearVisibilityBorder;
    DrawVisibilityBorder;
    DrawEmptyField;
  end;
end;

procedure TFieldForm.UnitClick (Sender: TObject);
  function GetRowFromTag (Tag: integer): integer;
  begin
    GetRowFromTag:= Tag div 10;
  end;

  function GetColFromTag (Tag: integer): integer;
  begin
    GetColFromTag:= Tag mod 10;
  end;

var
  Row, Col: shortint;
  SenderImage: TImage;
  UnitNumber: shortint;
begin
  if Sender is TImage then
  begin
    SenderImage:= Sender as TImage;
    Row:= GetRowFromTag (SenderImage.Tag);
    Col:= GetColFromTag (SenderImage.Tag);
    if UnitsArray[Row, Col] = FieldSize then
      UnitNumber:= 0
    else
    begin
      UnitNumber:= UnitsArray[Row, Col];
      Inc (UnitNumber);
    end;
    DrawUnit (UnitNumber, Row, Col);
  end;
end;

procedure TFieldForm.CheckButtonClick(Sender: TObject);
begin
  if FieldProcessing.IsTrueSolution(UnitsArray, VisibilityArray, FieldSize) or AllreadySolved then
    ShowMessage ('Решение верно!')
  else
    ShowMessage ('Решение неправильное!');
end;

procedure TFieldForm.AutoSolutionButtonClick(Sender: TObject);
begin
  if not AllreadySolved then
  begin
    FieldProcessing.FindSolution(VisibilityArray, UnitsArray, FieldSize);
    DrawFieldFromUnitsArray;
    AllreadySolved:= true;
  end;
end;

procedure TFieldForm.OpenClick(Sender: TObject);
var
  TempVisibilityArray: TVisibilityArray;
begin
  if OpenDialog.Execute then
  begin
    AllreadySolved:= false;
    ClearVisibilityBorder;
    ClearTheField;
    FieldProcessing.ReadVisibilityArraysFromFile(VisibilityArray, FieldSize, OpenDialog.FileName);
    TempVisibilityArray:= VisibilityArray; //hack because of clear part of FieldSizeSpinEdit OnChange event
    FieldSizeSpinEdit.Value:= FieldSize;
    VisibilityArray:= TempVisibilityArray; //hack because of clear part of FieldSizeSpinEdit OnChange event
    DrawVisibilityBorder;
    FieldProcessing.ResetPlacedVariantsArray (FieldSize);
    FieldProcessing.ResetUnitsStatsArray (FieldSize);
  end;
end;

procedure TFieldForm.ClearButtonClick(Sender: TObject);
begin
  AllreadySolved:= false;
  DrawEmptyField;
  FieldProcessing.ResetPlacedVariantsArray (FieldSize);
  FieldProcessing.ResetUnitsStatsArray (FieldSize);
end;

procedure TFieldForm.Button1Click(Sender: TObject);
begin
  if FieldProcessing.IsTrueSolution(UnitsArray, VisibilityArray, FieldSize) then
    ShowMessage ('Решение верно!')
  else
    ShowMessage ('Решение неправильное!');
end;

procedure TFieldForm.NewFieldButtonClick(Sender: TObject);
begin
  ClearTheField;
  UnitsArray:= FieldGeneration.UnitsArrayGeneration (FieldSize);
  VisibilityArray:= FieldGeneration.GetVisibilityArrayFromUnitsArray(UnitsArray, FieldSize);
  DrawFieldFromUnitsArray;
  DrawVisibilityBorder;
end;

initialization

end.


