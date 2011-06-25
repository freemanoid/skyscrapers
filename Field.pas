unit Field;
//Курсовой проект. Тема "Головоломка "небоскрёбы"". Выполнил Елховенко Саша гр. 93492
//
//Описание юнита:
//Основной юнит, содержащий главную форму, методы отрисовки поля и обработчики событий.

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Spin, Menus, ComCtrls;

const
  _UnitWidth = 81;
  _UnitHeight = 81;
  _FloorIncrement = 5;
  _DistanceBeetwenUnits = 9;
  _DefaultFieldSize = 4;
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
    OpenFieldDialog: TOpenDialog;
    MainMenuItemFile: TMenuItem;
    OpenConditionMenuItem: TMenuItem;
    ClearButton: TButton;
    NewFieldButton: TButton;
    SaveConditionMenuItem: TMenuItem;
    SaveFieldMenuItem: TMenuItem;
    OpenFieldMenuItem: TMenuItem;
    ExitMenuItem: TMenuItem;
    SaveFieldDialog: TSaveDialog;
    DiffucaltyTrackBar: TTrackBar;
    DiffucaltyLabel: TLabel;
    OpenConditionDialog: TOpenDialog;
    SaveConditionDialog: TSaveDialog;
    N1: TMenuItem;
    HelpMenuItem: TMenuItem;
    AboutMenuItem: TMenuItem;
    GenerationProgressBar: TProgressBar;
    GenerationTimer: TTimer;
    GenerationLabel: TLabel;
    GenerationPanel: TPanel;
    ExitButton: TButton;
    procedure FormCreate(Sender: TObject);  //инициализация переменных
    procedure DrawUnit (UnitNumber, Row, Col: shortint); //отрисовка небоскрёба
    procedure DrawEmptyField; //отрисовка пустого поля
    procedure DrawFieldFromUnitsArray; //отрисовка поля из массива UnitsArray
    procedure FieldSizeSpinEditChange(Sender: TObject);
    procedure HideUnit (Row, Col: shortint); //убрать небоскрёб с поля
    procedure DrawVisibilityBorder; //отрисовка рамки с видимостями
    procedure ClearTheField; //очистить поле с небоскрёбами
    procedure UnitMouseDown (Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
    procedure CheckButtonClick(Sender: TObject); 
    procedure AutoSolutionButtonClick(Sender: TObject);
    procedure SetUnit (var UnitsArray: TUnitsArray; Value, Row, Col: shortint); //добавить небоскрёб в массив со значениями (не отрисовка)
    procedure OpenConditionMenuItemClick(Sender: TObject);
    procedure ClearButtonClick(Sender: TObject);
    procedure HideVisibilityUnit (UnitSide, UnitIndex: shortint); //убрать один из элементов из рамки с видимостями
    procedure ClearVisibilityBorder; //очистить рамку видимостей
    procedure ClearUnitsArray (var UnitsArray: TUnitsArray); //очистить массив со значениями небоскрёбов
    procedure ClearVisibilityArray; //очистить массив со значениями рамки видимостей
    procedure NewFieldButtonClick(Sender: TObject);
    procedure SaveConditionMenuItemClick(Sender: TObject);
    procedure ExitMenuItemClick(Sender: TObject);
    procedure DiffucaltyTrackBarChange(Sender: TObject);
    procedure SaveFieldMenuItemClick(Sender: TObject);
    procedure OpenFieldMenuItemClick(Sender: TObject);
    procedure GenerationTimerTimer(Sender: TObject);
    procedure ExitButtonClick(Sender: TObject);
  private
    procedure StopTimer (ShowFullProgressBar: boolean); //остановить таймер (используется при генерации условия)
    procedure StartTimer; //запустить таймер (используется при генерации условия)
  public
    ImageArray: TImageArray;  //массив изображений
    UnitsArray: TUnitsArray;  //массив значений в поле
    FieldSize: shortint;      //размер поля
    VisibilityLabelArray: TVisibilityLabelArray; //массив TLabel, который содержит видимости 
    VisibilityArray: TVisibilityArray; //массив значений видимостей
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
  Application.HintPause:= 0; //to have a dynamic hint in DiffucaltyTrackBar
  AutoSolutionButton.Enabled:= false;
  GenerationLabel.Visible:= false;
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
    OnMouseDown:= UnitMouseDown;
    Tag:= Row * 10 + Col;//we use tag field to connect ImageArray and UnitsArray
    Parent:= FieldForm;
    Left:= _TopLeftFieldBorder.X + _BorderWidth +
          (_UnitWidth + _DistanceBeetwenUnits) * Col;
    Top:= _TopLeftFieldBorder.Y + _BorderWidth +
         (_UnitHeight + _DistanceBeetwenUnits) * Row - _FloorIncrement * UnitNumber;
    if (UnitNumber > _MaxFieldSize) or (UnitNumber < 0) then
      ShowMessage (Format ('Ошибка: высота небоскрёба не может быть равной %d (должна быть от 0 до 6)', [UnitNumber]));
    Picture.LoadFromFile (ExtractFilePath (Application.ExeName) + _PicturesDir + IntToStr (UnitNumber) + '.bmp'); //UnitNumber must be in 0-6
    Transparent:= true;
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
  ClearUnitsArray (UnitsArray);
  for itrRow:= 0 to FieldSize - 1 do
    for itrCol:= 0 to FieldSize - 1 do
      HideUnit (itrRow, itrCol);  
end;

procedure TFieldForm.DrawEmptyField;
var
  itrRow, itrCol: smallint;
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

procedure TFieldForm.ClearUnitsArray (var UnitsArray: TUnitsArray);
var
  itrRow, itrCol: shortint;
begin
  for itrRow:= 0 to FieldSize - 1 do
      for itrCol:= 0 to FieldSize - 1 do
        UnitsArray[itrRow][itrCol]:= 0;  
end;

procedure TFieldForm.UnitMouseDown (Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  
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
    case Button of
    mbLeft:
        if UnitsArray[Row, Col] = FieldSize then
          UnitNumber:= 0
        else
        begin
          UnitNumber:= UnitsArray[Row, Col];
          Inc (UnitNumber);
        end;
    mbRight:
        if UnitsArray[Row, Col] = 0 then
          UnitNumber:= FieldSize
        else
        begin
          UnitNumber:= UnitsArray[Row, Col];
          Dec (UnitNumber);
        end;
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

procedure TFieldForm.AutoSolutionButtonClick(Sender: TObject);
begin
  ClearUnitsArray (UnitsArray);
  FieldProcessing.FindSolution (VisibilityArray, UnitsArray, FieldSize);
  DrawFieldFromUnitsArray;
  AutoSolutionButton.Enabled:= false;
end;

procedure TFieldForm.OpenConditionMenuItemClick(Sender: TObject);
var
  TempVisibilityArray: TVisibilityArray;
begin
  if OpenConditionDialog.Execute then
  begin
    ClearVisibilityBorder;
    ClearTheField;
    FieldProcessing.ReadVisibilityArraysFromFile(VisibilityArray, FieldSize, OpenConditionDialog.FileName);
    TempVisibilityArray:= VisibilityArray; //hack because of clear part of FieldSizeSpinEdit OnChange event
    FieldSizeSpinEdit.Value:= FieldSize;
    ClearVisibilityBorder;
    VisibilityArray:= TempVisibilityArray; //hack because of clear part of FieldSizeSpinEdit OnChange event
    DrawVisibilityBorder;
    DrawEmptyField;
    FieldProcessing.ResetPlacedVariantsArray (FieldSize);
    FieldProcessing.ResetUnitsStatsArray (FieldSize);
    AutoSolutionButton.Enabled:= true;
  end;
end;

procedure TFieldForm.ClearButtonClick(Sender: TObject);
begin
  DrawEmptyField;
  FieldProcessing.ResetPlacedVariantsArray (FieldSize);
  FieldProcessing.ResetUnitsStatsArray (FieldSize);
  AutoSolutionButton.Enabled:= true;
end;

procedure TFieldForm.NewFieldButtonClick(Sender: TObject);
begin
  ClearTheField;
  DrawEmptyField;
  StartTimer;
  FieldGeneration.GenerateVisibilityArray (VisibilityArray, DiffucaltyTrackBar.Min, DiffucaltyTrackBar.Max, DiffucaltyTrackBar.Position, FieldSize);
  StopTimer (true);
  DrawVisibilityBorder;
  AutoSolutionButton.Enabled:= true;
end;

procedure TFieldForm.SaveConditionMenuItemClick(Sender: TObject);
begin
  if SaveConditionDialog.Execute then
    FieldProcessing.WriteVisibilityArraysToFile (VisibilityArray, FieldSize, SaveConditionDialog.FileName);
end;

procedure TFieldForm.ExitMenuItemClick(Sender: TObject);
begin
  FieldForm.Close;
end;

procedure TFieldForm.DiffucaltyTrackBarChange(Sender: TObject);
begin
  Application.CancelHint;
  DiffucaltyTrackBar.Hint:= IntToStr (DiffucaltyTrackBar.Position);
end;

procedure TFieldForm.SaveFieldMenuItemClick(Sender: TObject);
begin
  if SaveFieldDialog.Execute then
    FieldProcessing.WriteUnitsArrayToFile (UnitsArray, FieldSize, SaveFieldDialog.FileName);  
end;

procedure TFieldForm.OpenFieldMenuItemClick(Sender: TObject);
var
  TempUnitsArray: TUnitsArray;
begin
  if OpenFieldDialog.Execute then
  begin
    ClearTheField;
    ClearVisibilityBorder;
    FieldProcessing.ReadUnitsArrayFromFile (UnitsArray, FieldSize, OpenFieldDialog.FileName);
    TempUnitsArray:= UnitsArray;    //hack because of clear part of FieldSizeSpinEdit OnChange event
    FieldSizeSpinEdit.Value:= FieldSize;
    UnitsArray:= TempUnitsArray; //hack because of clear part of FieldSizeSpinEdit OnChange event
    DrawFieldFromUnitsArray;
    DrawVisibilityBorder;
    FieldProcessing.ResetPlacedVariantsArray (FieldSize);
    FieldProcessing.ResetUnitsStatsArray (FieldSize);
    AutoSolutionButton.Enabled:= false;
  end; 
end;

procedure TFieldForm.FieldSizeSpinEditChange(Sender: TObject);
begin
  AutoSolutionButton.Enabled:= false;
  ClearTheField;
  if FieldSizeSpinEdit.Value < FieldSize then
  begin
    ClearVisibilityBorder;
    FieldSize:= FieldSizeSpinEdit.Value;
  end
  else
  begin
    FieldSize:= FieldSizeSpinEdit.Value;
    ClearVisibilityBorder;
  end;
  DrawVisibilityBorder;
  DrawEmptyField;
end;

procedure TFieldForm.StartTimer;
begin
  GenerationProgressBar.Position:= 0;
  GenerationLabel.Visible:= true;
  FieldForm.Enabled:= false;
  case FieldSize of
  4: GenerationTimer.Interval:= 100;
  5: GenerationTimer.Interval:= 500;
  6: GenerationTimer.Interval:= 1000;
  end;
  GenerationTimer.Enabled:= true;
end;

procedure TFieldForm.StopTimer (ShowFullProgressBar: boolean);
  procedure ClearGenerationLabel (var GenerationLabel: TLabel); //removes Tag dots from the end of GenerationLabel
  var
    NewLength: byte;
    NewCaption: string;
  begin           
    NewLength:= Length (GenerationLabel.Caption) - GenerationLabel.Tag;
    NewCaption:= GenerationLabel.Caption;
    SetLength (NewCaption, NewLength);
    GenerationLabel.Caption:= NewCaption;
    GenerationLabel.Tag:= 0;
  end;
  
begin
  if ShowFullProgressBar then
  begin
    GenerationProgressBar.Position:= 100;
    GenerationTimer.Interval:= 500;
  end
  else
  begin
    GenerationTimer.Enabled:= false;
    FieldForm.Enabled:= true; 
    GenerationLabel.Visible:= false; 
    ClearGenerationLabel (GenerationLabel);
  end;
end;

procedure TFieldForm.GenerationTimerTimer(Sender: TObject);
  procedure ClearGenerationLabel (var GenerationLabel: TLabel); //removes Tag dots from the end of GenerationLabel
  var
    NewLength: byte;
    NewCaption: string;
  begin           
    NewLength:= Length (GenerationLabel.Caption) - GenerationLabel.Tag;
    NewCaption:= GenerationLabel.Caption;
    SetLength (NewCaption, NewLength);
    GenerationLabel.Caption:= NewCaption;
    GenerationLabel.Tag:= 0;
  end;
  
  procedure GenerationLabelNextStep (var GenerationLabel: TLabel);
  begin
    if GenerationLabel.Tag = 3 then
      ClearGenerationLabel (GenerationLabel)
    else
    begin
      GenerationLabel.Tag:= GenerationLabel.Tag + 1;
      GenerationLabel.Caption:= GenerationLabel.Caption + '.';
    end;
  end;
  
begin
  if GenerationProgressBar.Position < 99 then
  begin
    GenerationProgressBar.Position:= GenerationProgressBar.Position + 1;
    GenerationLabelNextStep (GenerationLabel);
  end
  else
    if GenerationProgressBar.Position = 100 then
      StopTimer (false);
  GenerationProgressBar.Repaint;
end;

initialization
procedure TFieldForm.ExitButtonClick(Sender: TObject);
begin
  FieldForm.Close;
end;

end.


