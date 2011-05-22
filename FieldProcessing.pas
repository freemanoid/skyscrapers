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
  TPlacedVariant = array[1..6] of array[1..6] of array[1..6] of byte;//Containts such types of units
  //that can be placed in the concrete unit
  TUnitStats = array[1..6] of byte;//Containts the "statistic" information about different types of
  //units that have been already placed to their places. Array index - unit type, value - number of
  //units of this type
  
var
  UnitStats: TUnitStats;

procedure AddUnitStat (UnitValue, PreviousValue: byte);
begin
  if PreviousValue = 0 then
    Inc (UnitStats[UnitValue]);
end;

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
  begin
    AddUnitStat (itr + 1, SomeColumn[itr]);
    SomeColumn[itr]:= itr + 1;
  end;
end;

procedure FillColumnDescending (var SomeColumn: array of byte; MaxValue: byte);
var
  itr: byte;
begin
  for itr:= MaxValue - 1 downto 0 do
  begin
    AddUnitStat (MaxValue - itr, SomeColumn[itr]);
    SomeColumn[itr]:= MaxValue - itr;
  end;
end;

procedure FillRowAscending (var SomeArray: Field.TUnitsArray; RowNumber, MaxValue: byte);
var
  itr: byte;
begin
  for itr:= 0 to MaxValue - 1 do
  begin
    AddUnitStat (itr + 1, SomeArray[RowNumber][itr]);
    SomeArray[RowNumber][itr]:= itr + 1;
  end;
end;

procedure FillRowDescending (var SomeArray: Field.TUnitsArray; RowNumber, MaxValue: byte);
var
  itr: byte;
begin
  for itr:= MaxValue - 1 downto 0 do
  begin
    AddUnitStat (MaxValue - itr, SomeArray[RowNumber][itr]);
    SomeArray[RowNumber][itr]:= MaxValue - itr;
  end;
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
      begin   
        AddUnitStat (4, UnitsArray [itr][0]);
        UnitsArray [itr][0]:= 4;
      end;
  //right side
    if VisibilityArray[Field.visRight][itr] = FieldSize then
      FillRowDescending (UnitsArray, itr, FieldSize)
    else
      if VisibilityArray[Field.visRight][itr] = 1 then 
      begin
        AddUnitStat (4, UnitsArray [itr][FieldSize - 1]);
        UnitsArray [itr][FieldSize - 1]:= 4;
      end;
  //top side
    if VisibilityArray[Field.visTop][itr] = FieldSize then
      FillColumnAscending (UnitsArray[itr], FieldSize)
    else
      if VisibilityArray[Field.visTop][itr] = 1 then 
      begin
        AddUnitStat (4, UnitsArray [0][itr]);
        UnitsArray [0][itr]:= 4;
      end;
  //bottom side
    if  VisibilityArray[Field.visBot][itr] = FieldSize then
      FillColumnDescending (UnitsArray[itr], FieldSize)
    else
      if VisibilityArray[Field.visBot][itr] = 1 then
      begin
        AddUnitStat (4, UnitsArray [FieldSize - 1][itr]);
        UnitsArray [FieldSize - 1][itr]:= 4;
      end;
  end;
end;

procedure CheckIfOnlyOneEmptyUnitOnLine (var UnitsArray: Field.TUnitsArray; FieldSize: byte );
var
  itrRow, itrCol, itrEmptyUnits, EmptyUnitPosition, EmptyUnitCounter: byte;
begin
  //all rows
  for itrRow:= 0 to FieldSize - 1 do
  begin
    EmptyUnitCounter:= ((1 + FieldSize) * FieldSize) div 2; //summ of a line
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
    begin
      AddUnitStat (EmptyUnitCounter, UnitsArray[itrRow][EmptyUnitPosition]);
      UnitsArray[itrRow][EmptyUnitPosition]:= EmptyUnitCounter;
    end;
  end;
  //all columns
  for itrCol:= 0 to FieldSize - 1 do
  begin
    EmptyUnitCounter:= ((1 + FieldSize) * FieldSize) div 2; //summ of a line
    itrEmptyUnits:= 0;
    for itrRow:= 0 to FieldSize - 1 do
    begin
      Dec (EmptyUnitCounter, UnitsArray[itrRow][itrCol]);
      if UnitsArray[itrRow][itrCol] = 0 then
      begin
        Inc (itrEmptyUnits);
        EmptyUnitPosition:= itrRow;
      end;
    end;
    if itrEmptyUnits = 1 then
    begin
      AddUnitStat (EmptyUnitCounter, UnitsArray[EmptyUnitPosition][itrCol]);
      UnitsArray[EmptyUnitPosition][itrCol]:= EmptyUnitCounter;
    end;
  end;
end;

procedure CheckIfOnlyOneVariantToLocateUnit (var UnitsArray: Field.TUnitsArray; UnitStats: TUnitStats; FieldSize: byte);
var
  itrHostedUnit, itrRow, itrCol, FreeColIndexCounter, FreeRowIndexCounter: byte;
begin
  for itrHostedUnit:= 1 to FieldSize do
    if UnitStats[itrHostedUnit] = FieldSize - 1 then
    begin
      FreeColIndexCounter:= ((0 + FieldSize - 1) * FieldSize) div 2; //summ of a line indexes
      FreeRowIndexCounter:= FreeColIndexCounter; //because we always use square matrix (maxRow = maxCol)
      for itrRow:= 0 to FieldSize - 1 do
        for itrCol:= 0 to FieldSize - 1 do
          if UnitsArray[itrRow][itrCol] = itrHostedUnit then
          begin
            Dec (FreeRowIndexCounter, itrRow);
            Dec (FreeColIndexCounter, itrCol);
            Break;
          end;
      AddUnitStat (itrHostedUnit, UnitsArray[FreeRowIndexCounter][FreeColIndexCounter]);
      UnitsArray[FreeRowIndexCounter][FreeColIndexCounter]:= itrHostedUnit;
    end;
end;

procedure FindSolution (VisibilityArray: Field.TVisibilityArray; var UnitsArray: Field.TUnitsArray; FieldSize: byte);

begin
  CheckMaxAndMinVisibility (VisibilityArray, UnitsArray, FieldSize);
  CheckIfOnlyOneEmptyUnitOnLine (UnitsArray, FieldSize);
  CheckIfOnlyOneVariantToLocateUnit (UnitsArray, UnitStats, FieldSize);
end;

end.
 