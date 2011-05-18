unit FieldProcessing;

interface

uses Field;

function IsTrueSolution (UnitsArray: TUnitsArray; VisibilityArray: TVisibilityArray; FieldSize: byte): boolean;
procedure WriteVisibilityArraysToFile (var VisibilityArray: Field.TVisibilityArray; FileName: string);
procedure ReadVisibilityArraysFromFile (var VisibilityArray: Field.TVisibilityArray; FileName: string);
procedure FindSolution (VisibilityArray: Field.TVisibilityArray; var UnitsArray: Field.TUnitsArray; FieldSize: byte);

implementation

type
  TCheckSet = set of 1..6;
  TVisibilityRecord = Field.TVisibilityArray;
  TVisibilityFile = file of TVisibilityRecord;

procedure SetReset (var SomeSet: TCheckSet; MaxValue: byte);
begin
  SomeSet:= [1..MaxValue];
end;

function IsTrueSolution (UnitsArray: TUnitsArray; VisibilityArray: TVisibilityArray; FieldSize: byte): boolean;
var
  itrRow, itrCol, itr: byte;
  CheckSet: TCheckSet;
  MaxFloor: byte;
  VisibilityCount: byte;
begin
//repeat checking in rows and columns 
  Result:= true;
  SetReset (CheckSet, FieldSize); //we must identify set variable becouse it is empty by default :(
  //rows
  for itrRow:= 0 to FieldSize - 1 do
  begin
    for itrCol:= 0 to FieldSize - 1 do
    begin
      if not (UnitsArray[itrRow][itrCol] in CheckSet) then
      begin
        IsTrueSolution:= false;
        exit
      end
      else
        CheckSet:= CheckSet - [UnitsArray[itrRow][itrCol]]
    end;
    SetReset (CheckSet, FieldSize);
  end;
  //columns
  for itrCol:= 0 to FieldSize - 1 do
  begin
    for itrRow:= 0 to FieldSize - 1 do
    begin
      if not (UnitsArray[itrRow][itrCol] in CheckSet) then
      begin
        IsTrueSolution:= false;
        exit
      end
      else
        CheckSet:= CheckSet - [UnitsArray[itrRow][itrCol]]
    end;
    SetReset (CheckSet, FieldSize);
  end;
//check visibility
  //Row from left
  for itrRow:= 0 to FieldSize - 1 do
  begin
    if VisibilityArray[visLeft][itrRow] <> 0 then
    begin
      MaxFloor:= 0;
      VisibilityCount:= 0;
      for itrCol:= 0 to FieldSize - 1 do
        if UnitsArray[itrRow][itrCol] < MaxFloor then
        begin
          MaxFloor:= UnitsArray[itrRow][itrCol];
          Inc (VisibilityCount);
          if (MaxFloor = FieldSize) and (VisibilityCount <> VisibilityArray[visLeft][itrRow]) then
          begin
            IsTrueSolution:= false;
            exit
          end;
        end;
    end;
  end;
  //Row from right
  for itrRow:= 0 to FieldSize - 1 do
  begin
    if VisibilityArray[visRight][itrRow] <> 0 then
    begin
      MaxFloor:= 0;
      VisibilityCount:= 0;
      for itrCol:= FieldSize - 1 downto 0 do
        if UnitsArray[itrRow][itrCol] < MaxFloor then
        begin
          MaxFloor:= UnitsArray[itrRow][itrCol];
          Inc (VisibilityCount);
          if (MaxFloor = FieldSize) and (VisibilityCount <> VisibilityArray[visRight][itrCol]) then
          begin
            IsTrueSolution:= false;
            exit
          end;
        end;
    end;
  end;
  //Column from top
  for itrCol:= 0 to FieldSize - 1 do
  begin
    if VisibilityArray[visTop][itrCol] <> 0 then
    begin
      MaxFloor:= 0;
      VisibilityCount:= 0;
      for itrRow:= 0 to FieldSize - 1 do
        if UnitsArray[itrRow][itrCol] < MaxFloor then
        begin
          MaxFloor:= UnitsArray[itrRow][itrCol];
          Inc (VisibilityCount);
          if (MaxFloor = FieldSize) and (VisibilityCount <> VisibilityArray[visTop][itrRow]) then
          begin
            IsTrueSolution:= false;
            exit
          end;
        end;
    end;
  end;
  //Column from bottom
  for itrCol:= 0 to FieldSize - 1 do
  begin
    if VisibilityArray[visBot][itrCol] <> 0 then
    begin
      MaxFloor:= 0;
      VisibilityCount:= 0;
      for itrRow:= FieldSize - 1 downto 0 do
        if UnitsArray[itrRow][itrCol] < MaxFloor then
        begin
          MaxFloor:= UnitsArray[itrRow][itrCol];
          Inc (VisibilityCount);
          if (MaxFloor = FieldSize) and (VisibilityCount <> VisibilityArray[visBot][itrCol]) then
          begin
            IsTrueSolution:= false;
            exit
          end;
        end;
    end;
  end;
end;

procedure ReadVisibilityArraysFromFile (var VisibilityArray: Field.TVisibilityArray; FileName: string);
var
  InputFile: TVisibilityFile;
begin
  AssignFile (InputFile, FileName);
  Reset (InputFile);
  Read (InputFile, VisibilityArray);
  Close (InputFile);
end;

procedure WriteVisibilityArraysToFile (var VisibilityArray: Field.TVisibilityArray; FileName: string);
var
  OutputFile: TVisibilityFile;
begin
  AssignFile (OutputFile, FileName);
  Rewrite (OutputFile);
  Write (OutputFile, VisibilityArray);
  Close (OutputFile);
end;

procedure FillColumnAscending (var SomeColumn: array of byte; MaxValue: byte);
var
  itr: byte;
begin
  for itr:= 0 to MaxValue - 1 do
    SomeColumn[itr]:= itr + 1;
end;

procedure FillColumnDescending (var SomeColumn: array of byte; MaxValue: byte);
var
  itr: byte;
begin
  for itr:= MaxValue - 1 downto 0 do
    SomeColumn[itr]:= itr + 1;
end;

procedure FillRowAscending (var SomeArray: Field.TUnitsArray; RowNumber, MaxValue: byte);
var
  itr: byte;
begin
  for itr:= 0 to MaxValue - 1 do
    SomeArray[RowNumber][itr]:= itr + 1;
end;

procedure FillRowDescending (var SomeArray: Field.TUnitsArray; RowNumber, MaxValue: byte);
var
  itr: byte;
begin
  for itr:= MaxValue - 1 downto 0 do
    SomeArray[RowNumber][itr]:= itr + 1;
end;


//Check visibility for max(fieldsize) and min(1) visibility, becouse in this way we can 
//identify some skyscrapers
procedure CheckMaxAndMinVisibility (VisibilityArray: Field.TVisibilityArray; var UnitsArray: Field.TUnitsArray; const FieldSize: byte);
var
  itrRow, itrCol, itr, itrSide: byte;
begin
  for itr:= 0 to FieldSize - 1 do
  begin
  //left side
    if VisibilityArray[Field.visLeft][itr] = FieldSize then
      FillRowAscending (UnitsArray, itr, FieldSize)
    else
      if VisibilityArray[Field.visLeft][itr] = 1 then   
        UnitsArray [itr][0]:= 4;
  //right side
    if VisibilityArray[Field.visRight][itr] = FieldSize then
      FillRowDescending (UnitsArray, itr, FieldSize)
    else
      if VisibilityArray[Field.visRight][itr] = 1 then 
        UnitsArray [itr][FieldSize - 1]:= 4;
  //top side
    if VisibilityArray[Field.visTop][itr] = FieldSize then
      FillColumnAscending (UnitsArray[itr], FieldSize)
    else
      if VisibilityArray[Field.visTop][itr] = 1 then 
        UnitsArray [0][itr]:= 4;
  //bottom side
    if  VisibilityArray[Field.visBot][itr] = FieldSize then
      FillColumnDescending (UnitsArray[itr], FieldSize)
    else
      if VisibilityArray[Field.visBot][itr] = 1 then
        UnitsArray [FieldSize - 1][itr]:= 4;
  end;
end;

procedure CheckIfThereIsOnlyOneEmptyOnLine (var UnitsArray: Field.TUnitsArray; FieldSize: byte );
var
  itrRow, itrCol, itrEmptyUnits, EmptyUnitPosition, EmptyUnitCounter: byte;
begin
  for itrRow:= 0 to FieldSize - 1 do
  begin
    EmptyUnitCounter:= ((1 + FieldSize) div 2) * FieldSize; //summ of a line
    itrEmptyUnits:= 0;
    for itrCol:= 0 to FieldSize - 1 do
    begin
      Dec (EmptyUnitCounter, UnitsArray[itrRow][itrCol]);
      if UnitsArray[itrRow][itrCol] = 0 then
      begin
        Inc (itrEmptyUnits);
        EmptyUnitPosition:= itrCol;
      end;
    end;
    if itrEmptyUnits = 1 then
      UnitsArray[itrRow][EmptyUnitPosition]:= EmptyUnitCounter;
    
  end;
end;

procedure FindSolution (VisibilityArray: Field.TVisibilityArray; var UnitsArray: Field.TUnitsArray; FieldSize: byte);

begin
  CheckMaxAndMinVisibility (VisibilityArray, UnitsArray, FieldSize);
  CheckIfThereIsOnlyOneEmptyOnLine (UnitsArray, FieldSize);
end;

end.
 