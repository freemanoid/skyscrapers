unit Field;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Spin;

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
  visLeft = 1;
  visRight = 2;
  visTop = 3;
  visBot = 4;
  
type
  TImageArray = array[0..5, 0..5] of TImage;
  TUnitsArray = array[0..5, 0..5] of byte;
  TVisibilityLabelArray = array[1..4] of array[0..5] of TLabel;
  TVisibilityArray = array[1..4] of array[0..5] of byte;
  TFieldForm = class(TForm)
    FieldSizeSpinEdit: TSpinEdit;
    FieldSizeLabel: TLabel;
    CheckButton: TButton;
    TestButton: TButton;
    AutoSolutionButton: TButton;
    procedure FormCreate(Sender: TObject);
    procedure DrawUnit (UnitNumber, Row, Col: byte);
    procedure DrawEmptyField (DeleteOldImages: boolean);
    procedure DrawFieldFromUnitsArray;
    procedure FieldSizeSpinEditChange(Sender: TObject);
    procedure DeleteUnit (Row, Col: byte);
    procedure DrawVisibilityBorder (DeleteOldUnits: boolean);
    procedure DrawVisibilityBorderUnit (UnitSide: byte; UnitIndex: byte);
    procedure DeleteVisibilityUnit (UnitSide, UnitIndex: byte);
    procedure UnitClick(Sender: TObject);
    function GetRowFromTag (Tag: integer): integer;
    function GetColFromTag (Tag: integer): integer;
    procedure CheckButtonClick(Sender: TObject);
    procedure TestButtonClick(Sender: TObject);
    procedure AutoSolutionButtonClick(Sender: TObject);
    procedure SetUnit (var UnitsArray: TUnitsArray; Value, row, col: byte);
  private
    { Private declarations }
  public
    ImageArray: TImageArray;
    UnitsArray: TUnitsArray;
    FieldSize: byte;
    VisibilityLabelArray: TVisibilityLabelArray;
    VisibilityArray: TVisibilityArray;
  end;
var
  FieldForm: TFieldForm;

implementation

uses
  FieldProcessing;

{$R *.dfm}

procedure TFieldForm.SetUnit (var UnitsArray: TUnitsArray; Value, Row, Col: byte);
begin
  FieldProcessing.UpdatePlacedVariantsAccordingToNewUnit (Value, Row, Col, FieldSize);                      
  UnitsArray[Row][Col]:= Value;
end;

procedure TFieldForm.FormCreate(Sender: TObject);
begin
  //variables initializate
  FieldSize:= _DefaultFieldSize;
  DrawEmptyField (false);
  DrawVisibilityBorder (false);
  FieldProcessing.ResetPlacedVariantsArray (FieldSize);
end;

procedure TFieldForm.DrawUnit (UnitNumber, Row, Col: byte);
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
    Picture.LoadFromFile('images\' + IntToStr (UnitNumber) + '.bmp'); //UnitNumber must be in 0-6
  end;
end;

procedure TFieldForm.DeleteUnit (Row, Col: byte);
begin
  FreeAndNil (ImageArray[Row, Col]);
end;

procedure TFieldForm.DrawFieldFromUnitsArray;
var
  itrRow, itrCol: smallint;
begin
  for itrRow:= 0 to FieldSize - 1 do
    for itrCol:= 0 to FieldSize - 1 do
      DrawUnit (UnitsArray[itrRow][itrCol], itrRow, itrCol);  
end;

procedure TFieldForm.DrawEmptyField (DeleteOldImages: boolean);
var
  itrRow, itrCol, itr: smallint;
begin
  if DeleteOldImages then
    for itr:= 0 to FieldSize do
    begin
      DeleteUnit (itr, FieldSize);  
      DeleteUnit (FieldSize, itr);
    end;
  for itrRow:= 0 to FieldSize - 1 do
    for itrCol:= 0 to FieldSize - 1 do
      DrawUnit (0, itrRow, itrCol);  
end;

procedure TFieldForm.DrawVisibilityBorderUnit (UnitSide: byte; UnitIndex: byte);
begin
  DeleteVisibilityUnit (UnitSide, UnitIndex);
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
  end;  
end;

procedure TFieldForm.DeleteVisibilityUnit (UnitSide, UnitIndex: byte);
begin
  FreeAndNil (VisibilityLabelArray[UnitSide][UnitIndex]);  
end;

procedure TFieldForm.DrawVisibilityBorder (DeleteOldUnits: boolean);
var
  itr: byte;
begin
  if DeleteOldUnits then
    for itr:= 0 to FieldSize do
    begin
      DeleteVisibilityUnit (visLeft, itr);
      DeleteVisibilityUnit (visRight, itr);
      DeleteVisibilityUnit (visTop, itr);
      DeleteVisibilityUnit (visBot, itr);
    end;
  for itr:= 0 to FieldSize - 1 do
  begin
    DrawVisibilityBorderUnit (visLeft, itr);
    DrawVisibilityBorderUnit (visRight, itr);
    DrawVisibilityBorderUnit (visTop, itr);
    DrawVisibilityBorderUnit (visBot, itr);
  end; 
end;

procedure TFieldForm.FieldSizeSpinEditChange(Sender: TObject);
begin
  if FieldSizeSpinEdit.Value < FieldSize then
  begin
    FieldSize:= FieldSizeSpinEdit.Value;
    DrawVisibilityBorder (true);
    DrawEmptyField (true);
  end
  else
  begin
    FieldSize:= FieldSizeSpinEdit.Value; 
    DrawVisibilityBorder (false);
    DrawEmptyField (false);
  end;
end;

function TFieldForm.GetRowFromTag (Tag: integer): integer;
begin
  GetRowFromTag:= Tag div 10;
end;

function TFieldForm.GetColFromTag (Tag: integer): integer;
begin
  GetColFromTag:= Tag mod 10;
end;



procedure TFieldForm.UnitClick (Sender: TObject);
var
  Row, Col: byte;
  SenderImage: TImage;
  UnitNumber: byte;
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
  if FieldProcessing.IsTrueSolution(UnitsArray, VisibilityArray, FieldSize) then
    ShowMessage ('Решение верно!')
  else
    ShowMessage ('Решение неправильное!');
end;

procedure TFieldForm.TestButtonClick(Sender: TObject);
begin
  FieldProcessing.ReadVisibilityArraysFromFile(VisibilityArray, 'vis.txt');
  DrawVisibilityBorder(true);
end;

procedure TFieldForm.AutoSolutionButtonClick(Sender: TObject);
begin
  FieldProcessing.FindSolution(VisibilityArray, UnitsArray, FieldSize);
  DrawFieldFromUnitsArray;
end;

initialization

end.


