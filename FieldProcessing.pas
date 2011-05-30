unit FieldProcessing;

interface

uses Field, SysUtils, Dialogs;

function IsTrueSolution (UnitsArray: TUnitsArray; VisibilityArray: TVisibilityArray; FieldSize: shortint): boolean;
procedure WriteVisibilityArraysToFile (VisibilityArray: Field.TVisibilityArray; FieldSize: shortint; FileName: string);
procedure ReadVisibilityArraysFromFile (var VisibilityArray: Field.TVisibilityArray; var FieldSize: shortint; FileName: string);
procedure FindSolution (VisibilityArray: Field.TVisibilityArray; var UnitsArray: Field.TUnitsArray; FieldSize: shortint);
procedure ResetPlacedVariantsArray (FieldSize: shortint);
procedure ResetUnitsStatsArray (FieldSize: shortint);
procedure UpdatePlacedVariantsAccordingToNewUnit (UnitValue, Row, Col, FieldSize: shortint);

implementation

type
  TCheckSet = set of 1..6;
  TVisibilityRecord = record
    FieldSize: shortint;
    VisibilityArray: Field.TVisibilityArray;
  end;
  TVisibilityFile = file of TVisibilityRecord;
  TPlacedVariantsArray = array[0..5] of array[0..5] of array[1..6] of boolean;//Containts such types of units
  //that can be placed in the concrete unit
  TUnitStatsArray = array[1..6] of shortint;//Containts the "statistic" information about different types of
  //units that have been already placed to their places. Array index - unit type, value - number of
  //units of this type
  
var
  UnitStats: TUnitStatsArray;
  PlacedVariants: TPlacedVariantsArray;

procedure SetPlacedVariantsAccordingToVisibility (VisibilityArray: Field.TVisibilityArray; FieldSize: shortint); 
var
  itrVis, itrUnit, itrVariants: integer;
begin
  for itrVis:= 0 to FieldSize - 1 do
  begin
    //from left
    for itrUnit:= 0 to (VisibilityArray[Field.visLeft][itrVis] - 2) do
      for itrVariants:= FieldSize - VisibilityArray[Field.visLeft][itrVis] + itrUnit + 2 to FieldSize do 
        PlacedVariants[itrVis][itrUnit][itrVariants]:= false;
    //from right
    for itrUnit:= 0 to (VisibilityArray[Field.visRight][itrVis] - 2) do
      for itrVariants:= (FieldSize - VisibilityArray[Field.visRight][itrVis] + itrUnit + 2) to 4 do 
        PlacedVariants[itrVis][FieldSize - 1 - itrUnit][itrVariants]:= false;
    //from top
    for itrUnit:= 0 to (VisibilityArray[Field.visTop][itrVis] - 2) do
      for itrVariants:= FieldSize - VisibilityArray[Field.visTop][itrVis] + itrUnit + 2 to FieldSize do 
        PlacedVariants[itrUnit][itrVis][itrVariants]:= false;
    //from bottom
    for itrUnit:= 0 to (VisibilityArray[Field.visBot][itrVis] - 2) do
      for itrVariants:= FieldSize - VisibilityArray[Field.visBot][itrVis] + itrUnit + 2 to FieldSize do 
        PlacedVariants[FieldSize - 1 - itrUnit][itrVis][itrVariants]:= false;
  end;
end;
  
procedure ResetPlacedVariantsArray (FieldSize: shortint);
var
  itr1, itr2, itr3: shortint;
begin
  for itr1:= 0 to FieldSize - 1 do
    for itr2:= 0 to FieldSize - 1 do
      for itr3:= 1 to FieldSize do
        PlacedVariants[itr1][itr2][itr3]:= true;
end;

procedure ResetUnitsStatsArray (FieldSize: shortint);
var
  itr: shortint;
begin
  for itr:= 1 to FieldSize do
    UnitStats[itr]:= 0;
end;

procedure AddUnitStat (UnitValue, PreviousValue: shortint);
begin
  if PreviousValue = 0 then
    Inc (UnitStats[UnitValue]);
end;

procedure SetReset (var SomeSet: TCheckSet; MaxValue: shortint);
begin
  SomeSet:= [1..MaxValue];
end;

function IsTrueSolution (UnitsArray: TUnitsArray; VisibilityArray: TVisibilityArray; FieldSize: shortint): boolean;
var
  itrRow, itrCol: shortint;
  CheckSet: TCheckSet;
  MaxFloor: shortint;
  VisibilityCount: shortint;
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

procedure ReadVisibilityArraysFromFile (var VisibilityArray: Field.TVisibilityArray; var FieldSize: shortint; FileName: string);
var
  InputFile: TVisibilityFile;
  FileRecord: TVisibilityRecord;
begin
  AssignFile (InputFile, FileName);
  Reset (InputFile);
  try
    Read (InputFile, FileRecord);
  except
    on E : EInOutError do 
    begin
      ShowMessage ('��� ����� �� ������');
      Close (InputFile);
      Exit;
    end;
  end;
  Close (InputFile);
  FieldSize:= FileRecord.FieldSize;
  VisibilityArray:= FileRecord.VisibilityArray;
end;

procedure WriteVisibilityArraysToFile (VisibilityArray: Field.TVisibilityArray; FieldSize: shortint; FileName: string);
var
  OutputFile: TVisibilityFile;
  FileRecord: TVisibilityRecord;
begin
  FileRecord.FieldSize:= FieldSize;
  FileRecord.VisibilityArray:= VisibilityArray;
  AssignFile (OutputFile, FileName);
  Rewrite (OutputFile);
  Write (OutputFile, FileRecord);
  Close (OutputFile);
end;

procedure FillColumnAscending (var SomeArray: Field.TUnitsArray; ColNumber, FieldSize: shortint);
var
  itr: shortint;
begin
  for itr:= 0 to FieldSize - 1 do
  begin
    AddUnitStat (itr + 1, SomeArray[itr][ColNumber]);
    UpdatePlacedVariantsAccordingToNewUnit (itr + 1, itr, ColNumber, FieldSize);
    Field.FieldForm.SetUnit(SomeArray, itr + 1, itr, ColNumber);
  end;
end;

procedure FillColumnDescending (var SomeArray: Field.TUnitsArray; ColNumber, FieldSize: shortint);
var
  itr: shortint;
begin
  for itr:= FieldSize - 1 downto 0 do
  begin
    AddUnitStat (FieldSize - itr, SomeArray[itr][ColNumber]);
    UpdatePlacedVariantsAccordingToNewUnit (FieldSize - itr, itr, ColNumber, FieldSize);
    Field.FieldForm.SetUnit (SomeArray, FieldSize - itr, itr, ColNumber);
  end;
end;

procedure FillRowAscending (var SomeArray: Field.TUnitsArray; RowNumber, FieldSize: shortint);
var
  itr: shortint;
begin
  for itr:= 0 to FieldSize - 1 do
  begin
    AddUnitStat (itr + 1, SomeArray[RowNumber][itr]);
    UpdatePlacedVariantsAccordingToNewUnit (itr + 1, RowNumber, itr, FieldSize);
    Field.FieldForm.SetUnit (SomeArray, itr + 1, RowNumber, itr);
  end;
end;

procedure FillRowDescending (var SomeArray: Field.TUnitsArray; RowNumber, FieldSize: shortint);
var
  itr: shortint;
begin
  for itr:= FieldSize - 1 downto 0 do
  begin
    AddUnitStat (FieldSize - itr, SomeArray[RowNumber][itr]);
    UpdatePlacedVariantsAccordingToNewUnit (FieldSize - itr, RowNumber, itr, FieldSize);
    Field.FieldForm.SetUnit (SomeArray, FieldSize - itr, RowNumber, itr);
  end;
end;


//Check visibility for max(fieldsize) and min(1) visibility, becouse in this way we can 
//identify some skyscrapers
procedure CheckMaxAndMinVisibility (VisibilityArray: Field.TVisibilityArray; var UnitsArray: Field.TUnitsArray; const FieldSize: shortint);
var
  itr: shortint;
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
        UpdatePlacedVariantsAccordingToNewUnit (4, itr, 0, FieldSize);
        Field.FieldForm.SetUnit (UnitsArray, 4, itr, 0);
      end;
  //right side
    if VisibilityArray[Field.visRight][itr] = FieldSize then
      FillRowDescending (UnitsArray, itr, FieldSize)
    else
      if VisibilityArray[Field.visRight][itr] = 1 then 
      begin
        AddUnitStat (4, UnitsArray [itr][FieldSize - 1]);
        UpdatePlacedVariantsAccordingToNewUnit (4, itr, FieldSize - 1, FieldSize);
        Field.FieldForm.SetUnit (UnitsArray, 4, itr, FieldSize - 1);
      end;
  //top side
    if VisibilityArray[Field.visTop][itr] = FieldSize then
      FillColumnAscending (UnitsArray, itr, FieldSize)
    else
      if VisibilityArray[Field.visTop][itr] = 1 then 
      begin
        AddUnitStat (4, UnitsArray [0][itr]);
        UpdatePlacedVariantsAccordingToNewUnit (4, 0, itr, FieldSize);
        Field.FieldForm.SetUnit (UnitsArray, 4, 0, itr);
      end;
  //bottom side
    if  VisibilityArray[Field.visBot][itr] = FieldSize then
      FillColumnDescending (UnitsArray, itr, FieldSize)
    else
      if VisibilityArray[Field.visBot][itr] = 1 then
      begin
        AddUnitStat (4, UnitsArray [FieldSize - 1][itr]);
        UpdatePlacedVariantsAccordingToNewUnit (4, FieldSize - 1, itr, FieldSize);
        Field.FieldForm.SetUnit (UnitsArray, 4, FieldSize - 1, itr);
      end;
  end;
end;

procedure CheckIfOnlyOneEmptyUnitOnLine (var UnitsArray: Field.TUnitsArray; FieldSize: shortint );
var
  itrRow, itrCol, itrEmptyUnits, EmptyUnitPosition, EmptyUnitCounter: shortint;
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
      UpdatePlacedVariantsAccordingToNewUnit (EmptyUnitCounter, itrRow, EmptyUnitPosition, FieldSize);
      Field.FieldForm.SetUnit (UnitsArray, EmptyUnitCounter, itrRow, EmptyUnitPosition);
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
      UpdatePlacedVariantsAccordingToNewUnit (EmptyUnitCounter, EmptyUnitPosition, itrCol, FieldSize);
      Field.FieldForm.SetUnit (UnitsArray, EmptyUnitCounter, EmptyUnitPosition, itrCol);
    end;
  end;
end;

procedure CheckIfOnlyOneVariantToLocateUnit (var UnitsArray: Field.TUnitsArray; UnitStats: TUnitStatsArray; FieldSize: shortint);
var
  itrHostedUnit, itrRow, itrCol, FreeColIndexCounter, FreeRowIndexCounter: shortint;
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
      UpdatePlacedVariantsAccordingToNewUnit (itrHostedUnit, FreeRowIndexCounter, FreeColIndexCounter, FieldSize);
      Field.FieldForm.SetUnit (UnitsArray, itrHostedUnit, FreeRowIndexCounter, FreeColIndexCounter);
    end;
end;

procedure AddPlacedVariant (Variant, Row, Col: shortint);
begin
  PlacedVariants[Row][Col][Variant]:= true;
end;

procedure RemovePlacedVariant (Variant, Row, Col: shortint);
begin
  PlacedVariants[Row][Col][Variant]:= false;
end;

procedure RemoveAllPlacedVariantsExcept (Variant, Row, Col, FieldSize: shortint);
var
  itrVariant: shortint;
begin
  for itrVariant:= 1 to FieldSize do
    PlacedVariants[Row][Col][itrVariant]:= false;
  PlacedVariants[Row][Col][Variant]:= true;
end;

procedure UpdatePlacedVariantsAccordingToNewUnit (UnitValue, Row, Col, FieldSize: shortint);
var
  itrRow, itrCol, itrVariant: shortint;
begin
  for itrRow:= 0 to Row - 1 do
    RemovePlacedVariant (UnitValue, itrRow, Col);
  for itrRow:= Row + 1 to FieldSize - 1 do
    RemovePlacedVariant (UnitValue, itrRow, Col);
  for itrCol:= 0 to Col - 1 do
    RemovePlacedVariant (UnitValue, Row, itrCol);
  for itrCol:= Col + 1 to FieldSize - 1 do
    RemovePlacedVariant (UnitValue, Row, itrCol);
  RemoveAllPlacedVariantsExcept (UnitValue, Row, Col, FieldSize);
end;

function IsOneVariantOnLine (PlacedVariants: TPlacedVariantsArray; Row, Col, Length: shortint): shortint;
//if there is only one variant on a line of variants then returns its index else returns 0
var
  IsOnlyOneVariant: boolean;
  itrVar: shortint;
begin
  IsOnlyOneVariant:= false;
  for itrVar:= 1 to Length do
    if PlacedVariants[Row][Col][itrVar] then
      if not IsOnlyOneVariant then
      begin
        IsOnlyOneVariant:= true;
        Result:= itrVar;
      end
      else
      begin
        Result:= 0;
        Exit;
      end;  
end;

procedure UpdateUnitsArrayAccordingToPlacedVariants (var UnitsArray: Field.TUnitsArray; 
                                                     PlacedVariants: TPlacedVariantsArray; FieldSize: shortint);
var
  itrRow, itrCol, VariantResult: shortint;
begin
  for itrRow:= 0 to FieldSize - 1 do
    for itrCol:= 0 to FieldSize - 1 do
      if (UnitsArray[itrRow][itrCol] = 0) and (IsOneVariantOnLine (PlacedVariants, itrRow, itrCol, FieldSize) > 0) then
      begin
        VariantResult:= IsOneVariantOnLine (PlacedVariants, itrRow, itrCol, FieldSize);
        AddUnitStat (VariantResult, UnitsArray[itrRow][itrCol]);
        UpdatePlacedVariantsAccordingToNewUnit(VariantResult, itrRow, itrCol, FieldSize);
        Field.FieldForm.SetUnit(UnitsArray, VariantResult, itrRow, itrCol);
      end;
end;

procedure IfOnlyOnePossiblePlace (var UnitsArray: Field.TUnitsArray; FieldSize: shortint);
//if there is only one place to set some unit on line (there are no possitive records in PlacedVariants
//array for this unit)
var
  CheckSet: TCheckSet; 
  itrRow, itrCol, itrVar, itrUnit, itr, NewIndex: shortint; 
begin
  for itrRow:= 0 to FieldSize - 1 do
    for itrUnit:= 1 to FieldSize do
    begin
      itr:= 0;
      for itrCol:= 0 to FieldSize - 1 do
        if PlacedVariants[itrRow][itrCol][itrUnit] then
        begin
          Inc (itr);
          NewIndex:= itrCol;
        end;
      if (itr = 1) and (UnitsArray[itrRow][NewIndex] = 0) then
      begin
        UpdatePlacedVariantsAccordingToNewUnit (itrUnit, itrRow, NewIndex, FieldSize);
        AddUnitStat (itrUnit, UnitsArray[itrRow][NewIndex]);  
        Field.FieldForm.SetUnit(UnitsArray, itrUnit, itrRow, NewIndex);
      end;
    end;
  for itrCol:= 0 to FieldSize - 1 do
    for itrUnit:= 1 to FieldSize do
    begin
      itr:= 0;
      for itrRow:= 0 to FieldSize - 1 do
        if PlacedVariants[itrRow][itrCol][itrUnit] then
        begin
          Inc (itr);
          NewIndex:= itrRow;
        end;
      if (itr = 1) and (UnitsArray[NewIndex][itrCol] = 0) then
      begin
        UpdatePlacedVariantsAccordingToNewUnit (itrUnit, NewIndex, itrCol, FieldSize);
        AddUnitStat (itrUnit, UnitsArray[NewIndex][itrCol]);  
        Field.FieldForm.SetUnit(UnitsArray, itrUnit, NewIndex, itrCol);
      end;
    end;
end;
                                                              
procedure FindSolution (VisibilityArray: Field.TVisibilityArray; var UnitsArray: Field.TUnitsArray; FieldSize: shortint);
var
  itr: shortint;
begin
  ResetPlacedVariantsArray (FieldSize);
  SetPlacedVariantsAccordingToVisibility (VisibilityArray, FieldSize);
  CheckMaxAndMinVisibility (VisibilityArray, UnitsArray, FieldSize);
  CheckIfOnlyOneEmptyUnitOnLine (UnitsArray, FieldSize);
  CheckIfOnlyOneVariantToLocateUnit (UnitsArray, UnitStats, FieldSize);
  for itr:= 1 to 4 do
  begin
    UpdateUnitsArrayAccordingToPlacedVariants (UnitsArray, PlacedVariants, FieldSize);
    IfOnlyOnePossiblePlace (UnitsArray, FieldSize);
  end;
end;

end.
 