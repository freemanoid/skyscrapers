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
  TopLeftFieldBorder: TPoint = (X: 150; Y: 50);
  BorderWidth = 50;
  
type
  TImageArray = array[0..5, 0..5] of TImage;
  TFieldForm = class(TForm)
    FieldSizeSpinEdit: TSpinEdit;
    FieldSizeLabel: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure DrawUnit (UnitNumber, Row, Col: byte);
    procedure DrawEmptyField;
    procedure FieldSizeSpinEditChange(Sender: TObject);
  private
    { Private declarations }
  public
    ImageArray: TImageArray;
  end;
var
  FieldForm: TFieldForm;

implementation

{$R *.dfm}

procedure TFieldForm.DrawUnit (UnitNumber, Row, Col: byte);
var
  itr: byte;
begin
  ImageArray[Row, Col]:= TImage.Create (FieldForm);
  with ImageArray[Row, Col] do
  begin
    Parent:= FieldForm;
    Top:= TopLeftFieldBorder.Y + BorderWidth + (UnitHeight + DistanceBeetwenUnits) * Col - FloorIncrement * UnitNumber;
    Left:= TopLeftFieldBorder.X + BorderWidth + (UnitWidth + DistanceBeetwenUnits) * Row;
    Picture.LoadFromFile('images\' + IntToStr (UnitNumber) + '.bmp'); //UnitNumber must be in 0-6
  end;
end;

procedure TFieldForm.DrawEmptyField;
var
  itrRow, itrCol: smallint;
begin
  for itrRow:= 0 to FieldSizeSpinEdit.Value - 1 do
    for itrCol:= 0 to FieldSizeSpinEdit.Value - 1 do
    begin
      DrawUnit (0, itrRow, itrCol);  
    end;
end;

procedure TFieldForm.FormCreate(Sender: TObject);
var
  itrRow, itrCol: smallint;
begin
  DrawEmptyField;
end;

procedure TFieldForm.FieldSizeSpinEditChange(Sender: TObject);
begin

  DrawEmptyField;
end;

end.
