unit FieldProcessing;

interface

uses Field, SysUtils, Dialogs;

const
  ConditionExtension = 'skc';
  FieldExtension = 'skf';
  _CheckMaxAndMinVisibility = 1;
  _CheckIfOnlyOneEmptyUnitOnLine = 1;
  _CheckIfOnlyOneVariantToLocateUnit = 6;
  _UpdateUnitsArrayAccordingToPlacedVariants = 10;
  _IfOnlyOnePossiblePlace = 15;
  _BruteforceRows = 20;

type
  TPlacedVariantsArray = array[0..(Field._MaxFieldSize - 1)] of array[0..(Field._MaxFieldSize - 1)] of array[1..Field._MaxFieldSize] of boolean; //Containts such types of units
  //that can be placed in the concrete unit
  TCheckSet = set of 1..Field._MaxFieldSize;
  

function IsTrueSolution (UnitsArray: TUnitsArray; VisibilityArray: TVisibilityArray; FieldSize: shortint): boolean;
procedure WriteVisibilityArraysToFile (VisibilityArray: Field.TVisibilityArray; FieldSize: shortint; FileName: string);
procedure ReadVisibilityArraysFromFile (var VisibilityArray: Field.TVisibilityArray; var FieldSize: shortint; FileName: string);
function FindSolution (VisibilityArray: Field.TVisibilityArray; var UnitsArray: Field.TUnitsArray; FieldSize: shortint): boolean;
procedure ResetPlacedVariantsArray (FieldSize: shortint);
procedure ResetUnitsStatsArray (FieldSize: shortint);
procedure UpdatePlacedVariantsAccordingToNewUnit (var PlacedVariants: TPlacedVariantsArray; UnitValue, Row, Col, FieldSize: shortint);
procedure SetReset (var SomeSet: TCheckSet; MaxValue: shortint);
procedure SetClear (var SomeSet: TCheckSet);
function CalculateDiffucultyScores (VisibilityArray: Field.TVisibilityArray; FieldSize: shortint): smallint;

implementation

type
  TVisibilityRecord = record
    FieldSize: shortint;
    VisibilityArray: Field.TVisibilityArray;
  end;
  TVisibilityFile = file of TVisibilityRecord;
  TUnitStatsArray = array[1..Field._MaxFieldSize] of shortint;//Containts the "statistic" information about different types of
  //units that have been already placed to their places. Array index - unit type, value - number of
  //units of this type
  
var
  UnitStats: TUnitStatsArray;
  PlacedVariants: TPlacedVariantsArray;
  UnitsFoundCounter: shortint; //counter for units that have been found (it needs for diffucalty calculation)

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
  begin
    Inc (UnitStats[UnitValue]);
    Inc (UnitsFoundCounter); //counter for units that have been found (it needs for diffucalty calculation)
  end;
end;

procedure SetReset (var SomeSet: TCheckSet; MaxValue: shortint);
begin
  SomeSet:= [1..MaxValue];
end;

procedure SetClear (var SomeSet: TCheckSet);
begin
  SomeSet:= [];
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
        Exit
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
        Exit
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
        if UnitsArray[itrRow][itrCol] > MaxFloor then
        begin
          MaxFloor:= UnitsArray[itrRow][itrCol];
          Inc (VisibilityCount);
          if (MaxFloor = FieldSize) and (VisibilityCount <> VisibilityArray[visLeft][itrRow]) then
          begin
            IsTrueSolution:= false;
            Exit
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
        if UnitsArray[itrRow][itrCol] > MaxFloor then
        begin
          MaxFloor:= UnitsArray[itrRow][itrCol];
          Inc (VisibilityCount);
          if (MaxFloor = FieldSize) and (VisibilityCount <> VisibilityArray[visRight][itrRow]) then
          begin
            IsTrueSolution:= false;
            Exit
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
        if UnitsArray[itrRow][itrCol] > MaxFloor then
        begin
          MaxFloor:= UnitsArray[itrRow][itrCol];
          Inc (VisibilityCount);
          if (MaxFloor = FieldSize) and (VisibilityCount <> VisibilityArray[visTop][itrCol]) then
          begin
            IsTrueSolution:= false;
            Exit
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
        if UnitsArray[itrRow][itrCol] > MaxFloor then
        begin
          MaxFloor:= UnitsArray[itrRow][itrCol];
          Inc (VisibilityCount);
          if (MaxFloor = FieldSize) and (VisibilityCount <> VisibilityArray[visBot][itrCol]) then
          begin
            IsTrueSolution:= false;
            Exit
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
      ShowMessage ('Формат файла не верный');
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

//Check visibility for max(fieldsize) and min(1) visibility, becouse in this way we can 
//identify some skyscrapers
function CheckMaxAndMinVisibility (VisibilityArray: Field.TVisibilityArray; var UnitsArray: Field.TUnitsArray; const FieldSize: shortint): boolean;
  procedure FillColumnAscending (var SomeArray: Field.TUnitsArray; ColNumber, FieldSize: shortint);
  var
    itr: shortint;
  begin
    for itr:= 0 to FieldSize - 1 do
    begin
      AddUnitStat (itr + 1, SomeArray[itr][ColNumber]);
      UpdatePlacedVariantsAccordingToNewUnit (PlacedVariants, itr + 1, itr, ColNumber, FieldSize);
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
      UpdatePlacedVariantsAccordingToNewUnit (PlacedVariants, FieldSize - itr, itr, ColNumber, FieldSize);
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
      UpdatePlacedVariantsAccordingToNewUnit (PlacedVariants, itr + 1, RowNumber, itr, FieldSize);
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
      UpdatePlacedVariantsAccordingToNewUnit (PlacedVariants, FieldSize - itr, RowNumber, itr, FieldSize);
      Field.FieldForm.SetUnit (SomeArray, FieldSize - itr, RowNumber, itr);
    end;
  end;

var
  itr: shortint;
begin
  Result:= false;
  for itr:= 0 to FieldSize - 1 do
  begin
  //left side
    if VisibilityArray[Field.visLeft][itr] = FieldSize then
    begin
      FillRowAscending (UnitsArray, itr, FieldSize);
      Result:= true;
    end
    else
      if VisibilityArray[Field.visLeft][itr] = 1 then
      begin   
        AddUnitStat (FieldSize, UnitsArray [itr][0]);
        UpdatePlacedVariantsAccordingToNewUnit (PlacedVariants, FieldSize, itr, 0, FieldSize);
        Field.FieldForm.SetUnit (UnitsArray, FieldSize, itr, 0);
        Result:= true;
      end;
  //right side
    if VisibilityArray[Field.visRight][itr] = FieldSize then
    begin
      FillRowDescending (UnitsArray, itr, FieldSize);
      Result:= true;
    end
    else
      if VisibilityArray[Field.visRight][itr] = 1 then 
      begin
        AddUnitStat (FieldSize, UnitsArray [itr][FieldSize - 1]);
        UpdatePlacedVariantsAccordingToNewUnit (PlacedVariants, FieldSize, itr, FieldSize - 1, FieldSize);
        Field.FieldForm.SetUnit (UnitsArray, FieldSize, itr, FieldSize - 1);
        Result:= true;
      end;
  //top side
    if VisibilityArray[Field.visTop][itr] = FieldSize then
    begin
      FillColumnAscending (UnitsArray, itr, FieldSize);
      Result:= true;
    end
    else
      if VisibilityArray[Field.visTop][itr] = 1 then 
      begin
        AddUnitStat (FieldSize, UnitsArray [0][itr]);
        UpdatePlacedVariantsAccordingToNewUnit (PlacedVariants, FieldSize, 0, itr, FieldSize);
        Field.FieldForm.SetUnit (UnitsArray, FieldSize, 0, itr);
        Result:= true;
      end;
  //bottom side
    if  VisibilityArray[Field.visBot][itr] = FieldSize then
    begin
      FillColumnDescending (UnitsArray, itr, FieldSize);
      Result:= true;
    end
    else
      if VisibilityArray[Field.visBot][itr] = 1 then
      begin
        AddUnitStat (FieldSize, UnitsArray [FieldSize - 1][itr]);
        UpdatePlacedVariantsAccordingToNewUnit (PlacedVariants, FieldSize, FieldSize - 1, itr, FieldSize);
        Field.FieldForm.SetUnit (UnitsArray, FieldSize, FieldSize - 1, itr);
        Result:= true;
      end;
  end;
end;

function CheckIfOnlyOneEmptyUnitOnLine (var UnitsArray: Field.TUnitsArray; FieldSize: shortint): boolean;
var
  itrRow, itrCol, itrEmptyUnits, EmptyUnitPosition, EmptyUnitCounter: shortint;
begin
  Result:= false;
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
      UpdatePlacedVariantsAccordingToNewUnit (PlacedVariants, EmptyUnitCounter, itrRow, EmptyUnitPosition, FieldSize);
      Field.FieldForm.SetUnit (UnitsArray, EmptyUnitCounter, itrRow, EmptyUnitPosition);
      Result:= true;
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
      UpdatePlacedVariantsAccordingToNewUnit (PlacedVariants, EmptyUnitCounter, EmptyUnitPosition, itrCol, FieldSize);
      Field.FieldForm.SetUnit (UnitsArray, EmptyUnitCounter, EmptyUnitPosition, itrCol);
      Result:= true;
    end;
  end;
end;

function CheckIfOnlyOneVariantToLocateUnit (var UnitsArray: Field.TUnitsArray; UnitStats: TUnitStatsArray; FieldSize: shortint): boolean;
var
  itrHostedUnit, itrRow, itrCol, FreeColIndexCounter, FreeRowIndexCounter: shortint;
begin
  Result:= false;
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
      UpdatePlacedVariantsAccordingToNewUnit (PlacedVariants, itrHostedUnit, FreeRowIndexCounter, FreeColIndexCounter, FieldSize);
      Field.FieldForm.SetUnit (UnitsArray, itrHostedUnit, FreeRowIndexCounter, FreeColIndexCounter);
      Result:= true;
    end;
end;

procedure AddPlacedVariant (var PlacedVariants: TPlacedVariantsArray; Variant, Row, Col: shortint);
begin
  PlacedVariants[Row][Col][Variant]:= true;
end;

procedure RemovePlacedVariant (var PlacedVariants: TPlacedVariantsArray; Variant, Row, Col: shortint);
begin
  PlacedVariants[Row][Col][Variant]:= false;
end;

procedure RemoveAllPlacedVariantsExcept (var PlacedVariants: TPlacedVariantsArray; Variant, Row, Col, FieldSize: shortint);
var
  itrVariant: shortint;
begin
  for itrVariant:= 1 to FieldSize do
    PlacedVariants[Row][Col][itrVariant]:= false;
  PlacedVariants[Row][Col][Variant]:= true;
end;

procedure UpdatePlacedVariantsAccordingToNewUnit (var PlacedVariants: TPlacedVariantsArray; UnitValue, Row, Col, FieldSize: shortint);
var
  itrRow, itrCol: shortint;
begin
  for itrRow:= 0 to Row - 1 do
    RemovePlacedVariant (PlacedVariants, UnitValue, itrRow, Col);
  for itrRow:= Row + 1 to FieldSize - 1 do
    RemovePlacedVariant (PlacedVariants, UnitValue, itrRow, Col);
  for itrCol:= 0 to Col - 1 do
    RemovePlacedVariant (PlacedVariants, UnitValue, Row, itrCol);
  for itrCol:= Col + 1 to FieldSize - 1 do
    RemovePlacedVariant (PlacedVariants, UnitValue, Row, itrCol);
  RemoveAllPlacedVariantsExcept (PlacedVariants, UnitValue, Row, Col, FieldSize);
end;

function UpdateUnitsArrayAccordingToPlacedVariants (var UnitsArray: Field.TUnitsArray;
                                                     var PlacedVariants: TPlacedVariantsArray; FieldSize: shortint): shortint; //returns number of units that was set
                                                     
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
  
var
  itrRow, itrCol, VariantResult: shortint;
begin
  Result:= 0;
  for itrRow:= 0 to FieldSize - 1 do
    for itrCol:= 0 to FieldSize - 1 do
      if (UnitsArray[itrRow][itrCol] = 0) and (IsOneVariantOnLine (PlacedVariants, itrRow, itrCol, FieldSize) > 0) then
      begin
        VariantResult:= IsOneVariantOnLine (PlacedVariants, itrRow, itrCol, FieldSize);
        AddUnitStat (VariantResult, UnitsArray[itrRow][itrCol]);
        UpdatePlacedVariantsAccordingToNewUnit(PlacedVariants, VariantResult, itrRow, itrCol, FieldSize);
        Field.FieldForm.SetUnit(UnitsArray, VariantResult, itrRow, itrCol);
        Inc (Result);
      end;
end;

function IfOnlyOnePossiblePlace (var UnitsArray: Field.TUnitsArray; FieldSize: shortint): boolean;
//if there is only one place to set some unit on line (there are no possitive records in PlacedVariants
//array for this unit)
var 
  itrRow, itrCol, itrUnit, itr, NewIndex: shortint; 
begin
  Result:= false;
  //by rows
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
        UpdatePlacedVariantsAccordingToNewUnit (PlacedVariants, itrUnit, itrRow, NewIndex, FieldSize);
        AddUnitStat (itrUnit, UnitsArray[itrRow][NewIndex]);  
        Field.FieldForm.SetUnit (UnitsArray, itrUnit, itrRow, NewIndex);
        Result:= true;
      end;
    end;
  //by columns
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
        UpdatePlacedVariantsAccordingToNewUnit (PlacedVariants, itrUnit, NewIndex, itrCol, FieldSize);
        AddUnitStat (itrUnit, UnitsArray[NewIndex][itrCol]);  
        Field.FieldForm.SetUnit(UnitsArray, itrUnit, NewIndex, itrCol);
        Result:= true;
      end;
    end;
end;

function IsStillTrueCol (PlacedVariants: TPlacedVariantsArray; Row, Col, FieldSize: shortint): boolean;
var
   itrVar, itrRow, MaxFloor, VisibilityCount: shortint;
begin
  Result:= true;
  if Field.FieldForm.VisibilityArray[Field.visTop][Col] <> 0 then
  begin
    MaxFloor:= 0;
    VisibilityCount:= 0;
    for itrRow:= 0 to Row do
    begin
      itrVar:= 1;
      while not PlacedVariants[itrRow][Col][itrVar] do
        Inc (itrVar);
      if itrVar > MaxFloor then
      begin
        MaxFloor:= itrVar;
        Inc (VisibilityCount);
      end;
    end;
    if (VisibilityCount > Field.FieldForm.VisibilityArray[Field.visTop][Col]) or
      ((VisibilityCount < Field.FieldForm.VisibilityArray[Field.visTop][Col]) and (MaxFloor = FieldSize)) or
      ((VisibilityCount = Field.FieldForm.VisibilityArray[Field.visTop][Col]) and (MaxFloor < FieldSize)) then
    begin
      Result:= false;
      Exit;
    end;
  end;
  
  if Row = FieldSize - 1 then
    if Field.FieldForm.VisibilityArray[Field.visBot][Col] <> 0 then
    begin
      MaxFloor:= 0;
      VisibilityCount:= 0;
      itrRow:= FieldSize - 1;
      while MaxFloor < FieldSize do
      begin
        itrVar:= 1;
        while not PlacedVariants[itrRow][Col][itrVar] do
          Inc (itrVar);
        if itrVar > MaxFloor then
        begin
          MaxFloor:= itrVar;
          Inc (VisibilityCount);
        end;
        Dec (itrRow);
      end;
        if VisibilityCount <> Field.FieldForm.VisibilityArray[Field.visBot][Col] then
        begin
          Result:= false;
          Exit;
        end;
    end;
end;

function IsTrueCheckFilledRow (PlacedVariants: TPlacedVariantsArray; Row, FieldSize: shortint): boolean;
var
  itrVar, itrCol, MaxFloor, VisibilityCount: shortint;
begin
  Result:= true;
  if Field.FieldForm.VisibilityArray[Field.visLeft][Row] <> 0 then
  begin
    MaxFloor:= 0;
    VisibilityCount:= 0;
    itrCol:= 0;
    while (MaxFloor < FieldSize) and (itrCol < FieldSize) do //some tread will be here if we will remove second condition (we can go out of range but we check _filled_ row and this is tread...)
    begin
      itrVar:= 1;
      while not PlacedVariants[Row][itrCol][itrVar] do
        Inc (itrVar);
      if itrVar > MaxFloor then
      begin
        MaxFloor:= itrVar;
        Inc (VisibilityCount);
      end;
      Inc (itrCol);
    end;
    if VisibilityCount <> Field.FieldForm.VisibilityArray[Field.visLeft][Row] then
    begin
      Result:= false;
      Exit;
    end;
  end;

  if Field.FieldForm.VisibilityArray[Field.visRight][Row] <> 0 then
  begin
    MaxFloor:= 0;
    VisibilityCount:= 0;
    itrCol:= FieldSize - 1;
    while (MaxFloor < FieldSize) and (itrCol >= 0) do //some tread will be here if we will remove second condition (we can go out of range but we check _filled_ row and this is tread...)
    begin
      itrVar:= 1;
      while not PlacedVariants[Row][itrCol][itrVar] do
        Inc (itrVar);
      if itrVar > MaxFloor then
      begin
        MaxFloor:= itrVar;
        Inc (VisibilityCount);
      end;
      Dec (itrCol);
    end;
      if VisibilityCount <> Field.FieldForm.VisibilityArray[Field.visRight][Row] then
      begin
        Result:= false;
        Exit;
      end;
  end;

  for itrCol:= 0 to FieldSize - 1 do
  begin
    if not Result then
      Break;
    Result:= IsStillTrueCol (PlacedVariants, Row, itrCol, FieldSize);
  end;
  
end;

//backtracking algorithm
//if SolutionCounter = 0 then we don't check if there is only one solution and exit when found a solution (SolutionCounter will be zero) 
//if SolutionCounter = 1 then we returns last solution and SolutionCounter = number of solutions + 1
function BruteforceRows (const UnitsArray: Field.TUnitsArray; PlacedVariants: TPlacedVariantsArray; 
var IsFound: boolean; SolutionCounter, prevValue, Row, Col, FieldSize: shortint): TPlacedVariantsArray;
var
  itr: shortint;
begin
  IsFound:= false;
  if prevValue <> 0 then
    UpdatePlacedVariantsAccordingToNewUnit (PlacedVariants, prevValue, Row, Col - 1, FieldSize);
  if Col = FieldSize then //checking exit conditions
    if IsTrueCheckFilledRow (PlacedVariants, Row, FieldSize) then
    begin
      if Row = FieldSize - 1 then
      begin
        if SolutionCounter = 0 then
          IsFound:= true
        else
          Inc (SolutionCounter); 
        Result:= PlacedVariants;
        Exit;
      end;
      Result:= BruteforceRows (UnitsArray, PlacedVariants, IsFound, SolutionCounter, 0, Row + 1, 0, FieldSize);
      Exit;
    end
    else
      Exit;

  if UnitsArray[Row][Col] = 0 then
  begin
    for itr:= 1 to FieldSize do
      if PlacedVariants[Row][Col][itr] and not IsFound then
        Result:= BruteforceRows (UnitsArray, PlacedVariants, IsFound, SolutionCounter, itr, Row, Col + 1, FieldSize);
  end
  else
    Result:= BruteforceRows (UnitsArray, PlacedVariants, IsFound, SolutionCounter, 0, Row, Col + 1, FieldSize);  
end;

procedure VisibilityBruteforce (VisibilityArray: Field.TVisibilityArray; PlacedVariants: TPlacedVariantsArray; var UnitsArray: Field.TUnitsArray; FieldSize: shortint);
  function SearchOnColInterval (UnitsArray: Field.TUnitsArray; SearchGoal, Col, RowStart, RowEnd: shortint): shortint;
  begin
    Result:= 0;
    for RowStart:= RowStart to RowEnd do
      if UnitsArray[RowStart][Col] = SearchGoal then
      begin
        Result:= RowStart;
        Exit;
      end;
  end;

  function SearchOnRowInterval (UnitsArray: Field.TUnitsArray; SearchGoal, Row, ColStart, ColEnd: shortint): shortint;
  begin
    Result:= 0;
    for ColStart:= ColStart to ColEnd do
      if UnitsArray[Row][ColStart] = SearchGoal then
      begin
        Result:= ColStart;
        Exit;
      end;
  end;
  
var
  itr: shortint;
begin

end;

//returns true if there is only one solution and false if more
function FindSolution (VisibilityArray: Field.TVisibilityArray; var UnitsArray: Field.TUnitsArray; FieldSize: shortint): boolean;
var
  itr, SolutionCounter: shortint;
  IsFound: boolean;
begin
  Result:= true;
  SolutionCounter:= 1;
  ResetUnitsStatsArray (FieldSize);
  ResetPlacedVariantsArray (FieldSize);
  SetPlacedVariantsAccordingToVisibility (VisibilityArray, FieldSize);
  CheckMaxAndMinVisibility (VisibilityArray, UnitsArray, FieldSize);
  CheckIfOnlyOneEmptyUnitOnLine (UnitsArray, FieldSize);
  CheckIfOnlyOneVariantToLocateUnit (UnitsArray, UnitStats, FieldSize);
  for itr:= 1 to 10 do
  begin
    UpdateUnitsArrayAccordingToPlacedVariants (UnitsArray, PlacedVariants, FieldSize);
    IfOnlyOnePossiblePlace (UnitsArray, FieldSize);
  end;
  PlacedVariants:= BruteforceRows (UnitsArray, PlacedVariants, IsFound, SolutionCounter, 0, 0, 0, FieldSize);
  if SolutionCounter > 2 then
    Result:= false;
  UpdateUnitsArrayAccordingToPlacedVariants (UnitsArray, PlacedVariants, FieldSize);
end;

function CalculateDiffucultyScores (VisibilityArray: Field.TVisibilityArray; FieldSize: shortint): smallint;
  function UnitsArraysIsEqual (UnitsArray1, UnitsArray2: Field.TUnitsArray; FieldSize: shortint): boolean;
  var
    itrRow, itrCol: shortint;
  begin
    Result:= false;
    for itrRow:= 0 to FieldSize - 1 do
      for itrCol:= 0 to FieldSize - 1 do
        if UnitsArray1[itrRow][itrCol] <> UnitsArray2[itrRow][itrCol] then
          Exit;
    Result:= true;
  end;

  function CountChanges (UnitsArray1, UnitsArray2: Field.TUnitsArray; FieldSize: shortint): shortint;
  var
    itrRow, itrCol: shortint;
  begin
    Result:= 0;
    for itrRow:= 0 to FieldSize - 1 do
      for itrCol:= 0 to FieldSize - 1 do
        if UnitsArray1[itrRow][itrCol] <> UnitsArray2[itrRow][itrCol] then
          Inc (Result);
  end;
  
var
  CurrentAnswerUnitsArray: Field.TUnitsArray;
  PrevUnitsFoundCounter, SolutionCounter: shortint;
  IsFound: boolean; //variable for backtracking BruteforceRows function
begin
  Result:= 0;
  UnitsFoundCounter:= 0;
  SolutionCounter:= 1;
  PrevUnitsFoundCounter:= UnitsFoundCounter;
  ResetPlacedVariantsArray (FieldSize);
  Field.FieldForm.ClearUnitsArray (CurrentAnswerUnitsArray);
  ResetUnitsStatsArray (FieldSize);
  SetPlacedVariantsAccordingToVisibility (VisibilityArray, FieldSize);
  
  if CheckMaxAndMinVisibility (VisibilityArray, CurrentAnswerUnitsArray, FieldSize) then
  begin
    Inc (Result, _CheckMaxAndMinVisibility * (UnitsFoundCounter - PrevUnitsFoundCounter));
    PrevUnitsFoundCounter:= UnitsFoundCounter;
    UpdateUnitsArrayAccordingToPlacedVariants (CurrentAnswerUnitsArray, PlacedVariants, FieldSize);
    Inc (Result, _UpdateUnitsArrayAccordingToPlacedVariants * (UnitsFoundCounter - PrevUnitsFoundCounter));
    PrevUnitsFoundCounter:= UnitsFoundCounter;
  end;
  repeat
    if CheckIfOnlyOneEmptyUnitOnLine (CurrentAnswerUnitsArray, FieldSize) then
    begin
      Inc (Result, _CheckIfOnlyOneEmptyUnitOnLine * (UnitsFoundCounter - PrevUnitsFoundCounter));
      PrevUnitsFoundCounter:= UnitsFoundCounter;
      UpdateUnitsArrayAccordingToPlacedVariants (CurrentAnswerUnitsArray, PlacedVariants, FieldSize);
      Inc (Result, _UpdateUnitsArrayAccordingToPlacedVariants * (UnitsFoundCounter - PrevUnitsFoundCounter));
      PrevUnitsFoundCounter:= UnitsFoundCounter;
      Continue;
    end;
  
    if CheckIfOnlyOneVariantToLocateUnit (CurrentAnswerUnitsArray, UnitStats, FieldSize) then
    begin
      Inc (Result, _CheckIfOnlyOneVariantToLocateUnit * (UnitsFoundCounter - PrevUnitsFoundCounter));
      PrevUnitsFoundCounter:= UnitsFoundCounter;
      UpdateUnitsArrayAccordingToPlacedVariants (CurrentAnswerUnitsArray, PlacedVariants, FieldSize);
      Inc (Result, _UpdateUnitsArrayAccordingToPlacedVariants * (UnitsFoundCounter - PrevUnitsFoundCounter));
      PrevUnitsFoundCounter:= UnitsFoundCounter;
      Continue;
    end;
    
    if IfOnlyOnePossiblePlace (CurrentAnswerUnitsArray, FieldSize) then
    begin
      Inc (Result, _IfOnlyOnePossiblePlace * (UnitsFoundCounter - PrevUnitsFoundCounter));
      PrevUnitsFoundCounter:= UnitsFoundCounter;
      UpdateUnitsArrayAccordingToPlacedVariants (CurrentAnswerUnitsArray, PlacedVariants, FieldSize);
      Inc (Result, _UpdateUnitsArrayAccordingToPlacedVariants * (UnitsFoundCounter - PrevUnitsFoundCounter));
      PrevUnitsFoundCounter:= UnitsFoundCounter;
      Continue;
    end;
  until PrevUnitsFoundCounter = UnitsFoundCounter;
  {можно попробывать юзать для проверки количества решений не перебор всего unitsarray, а юзать unitstats array}
  {added: изменено на подсчёт изменений в функции AddUnitStat и дальнейшим сравнением (вполне годная реализация)}
  
  PlacedVariants:= BruteforceRows (CurrentAnswerUnitsArray, PlacedVariants, IsFound, SolutionCounter, 0, 0, 0, FieldSize);
  if SolutionCounter > 2 then
  begin
    Result:= 0; //we have more then one possible solution
    Exit;
  end;
  UpdateUnitsArrayAccordingToPlacedVariants (CurrentAnswerUnitsArray, PlacedVariants, FieldSize);
  Inc (Result, _BruteforceRows * (UnitsFoundCounter - PrevUnitsFoundCounter));
end;

end.
 