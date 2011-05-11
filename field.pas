unit field;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Spin;

const
  UnitWidth = 81;
  UnitHeight = 81;
  FloorIncrement = 5;
  DistanceBeetwenUnits = 9;
  DefaultFieldSize = 3;
  TopLeftFieldBorder: TPoint = (X: 150; Y: 50);
  BorderWidth = 50;
  BorderFontName: String = 'Comic Sans MS';
  BorderFontSize = 18;
  BorderFontStyle = fsBold;
  
type
  TImageArray = array[0..5, 0..5] of TImage;
  TVisibilityArray = array[0..5] of TLabel;
  TFieldForm = class(TForm)
    FieldSizeSpinEdit: TSpinEdit;
    FieldSizeLabel: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure DrawUnit (UnitNumber, Row, Col: byte);
    procedure DrawEmptyField (DeleteOldImages: boolean);
    procedure FieldSizeSpinEditChange(Sender: TObject);
    procedure DeleteUnit (Row, Col: byte);
    procedure DrawBorder;
  private
    { Private declarations }
  public
    ImageArray: TImageArray;
    FieldSize: byte;
    TopVisibilityArray, LeftVisibilityArray, RightVisibilityArray, BottomVisibilityArray: TVisibilityArray;
  end;
var
  FieldForm: TFieldForm;

implementation

{$R *.dfm}

procedure TFieldForm.DrawUnit (UnitNumber, Row, Col: byte);
begin
  ImageArray[Row, Col].Free;
  ImageArray[Row, Col]:= TImage.Create (FieldForm);
  with ImageArray[Row, Col] do
  begin
    Parent:= FieldForm;
    Left:= TopLeftFieldBorder.X + BorderWidth + (UnitWidth + DistanceBeetwenUnits) * Row;
    Top:= TopLeftFieldBorder.Y + BorderWidth + (UnitHeight + DistanceBeetwenUnits) * Col - FloorIncrement * UnitNumber;
    Picture.LoadFromFile('images\' + IntToStr (UnitNumber) + '.bmp'); //UnitNumber must be in 0-6
  end;
end;

procedure TFieldForm.DrawBorder;
var
  itr: byte;
begin
  for itr:= 0 to FieldSize - 1 do  
  begin
    TextOut (TopLeftFieldBorder.X + BorderWidth div 2, 
            TopLeftFieldBorder.Y + BorderWidth + UnitHeight div 2 + (UnitHeight + DistanceBeetwenUnits) * itr, 
            IntToStr (LeftVisibilityArray[itr])); //left border
    TextOut (TopLeftFieldBorder.X + (BorderWidth * 3 div 2) + (UnitWidth + DistanceBeetwenUnits) * FieldSize,
            TopLeftFieldBorder.Y + BorderWidth + UnitHeight div 2 + (UnitHeight + DistanceBeetwenUnits) * itr,
            IntToStr (RightVisibilityArray[itr])); //right border
    TextOut (TopLeftFieldBorder.X + BorderWidth + UnitWidth div 2 + (UnitHeight + DistanceBeetwenUnits) * itr,
            TopLeftFieldBorder.Y + BorderWidth div 2,
            IntToStr (TopVisibilityArray[itr])); //top border
    TextOut (TopLeftFieldBorder.X + BorderWidth + UnitWidth div 2 + (UnitHeight + DistanceBeetwenUnits) * itr,
            TopLeftFieldBorder.Y + (BorderWidth * 3 div 2) + (UnitWidth + DistanceBeetwenUnits) * FieldSize, 
            IntToStr (BottomVisibilityArray[itr])); //bottom border
  end;  
end;

procedure TFieldForm.DeleteUnit (Row, Col: byte);
begin
    FreeAndNil (ImageArray[Row, Col]);
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

procedure TFieldForm.FormCreate(Sender: TObject);
var
  itrRow, itrCol: smallint;
begin
  //variables initializate
  FieldSize:= DefaultFieldSize;
  Canvas.Font.Size:= BorderFontSize;
  Canvas.Font.Name:= BorderFontName;
  Canvas.Font.Style:= [BorderFontStyle];
  DrawBorder;
  DrawEmptyField (false);
  
end;

procedure TFieldForm.FieldSizeSpinEditChange(Sender: TObject);
begin
  if FieldSizeSpinEdit.Value < FieldSize then
  begin
    FieldSize:= FieldSizeSpinEdit.Value;
    DrawEmptyField (true);
  end
  else
  begin
    FieldSize:= FieldSizeSpinEdit.Value; 
    DrawEmptyField (false);
  end;
  DrawBorder;
end; 

initialization

end.


