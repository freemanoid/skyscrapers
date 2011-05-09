unit field;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Spin;

const
  EmptyUnitWidth = 50;
  EmptyUnitHeight = 50;
  UnitIncrement = 6;
  DistanceBeetwenUnits = 40;
  TopLeftFieldBorder: TPoint = (X: 150; Y: 50);
  BorderWidth = 50;
  
type
  ImageArray = array of array of TImage;
  TForm1 = class(TForm)
    FieldSizeSpinEdit: TSpinEdit;
    FieldSizeLabel: TLabel;
    procedure FieldSizeSpinEditChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure DrawUnit (UnitNumber, Row, Col: byte);
var

begin
  with TImage.Create(Form1);
  
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  itrRow, itrCol: smallint;
begin
  for itrRow:= 0 to FieldSizeSpinEdit.Value - 1 do
    for itrCol:= 0 to FieldSizeSpinEdit.Value - 1 do
    begin
      
    end;
end;

end.
