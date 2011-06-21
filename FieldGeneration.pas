unit FieldGeneration;

interface

uses
  Field, SysUtils, Dialogs;

function GenerateVisibilityArray (var VisibilityArray: Field.TVisibilityArray; FieldSize: shortint): shortint;

implementation

uses
  FieldProcessing;
  
function RandomButNotIn (var SomeSet: FieldProcessing.TCheckSet; MaxValue: shortint): shortint;
begin
  while true do
  begin
    Result:= Random (MaxValue) + 1;
    if not (Result in SomeSet) then
    begin
      SomeSet:= SomeSet + [Result];
      Break;
    end;
  end;
end;
  
function GenerateUnitsArray(FieldSize: shortint): Field.TUnitsArray;
  procedure GenerateRow (var UnitsArray: Field.TUnitsArray; Row, FieldSize: shortint);
  var
    itrCol: shortint;
    CurrentSet: FieldProcessing.TCheckSet;
  begin
    SetClear (CurrentSet);
    for itrCol:= 0 to FieldSize - 1 do
      UnitsArray[Row][itrCol]:= RandomButNotIn (CurrentSet, FieldSize);  
  end;
  
  function StillLatinSquare (UnitsArray: Field.TUnitsArray; MaxRow, FieldSize: shortint): boolean;
  var
    UsedSetsArray: array[0..Field._MaxFieldSize - 1] of FieldProcessing.TCheckSet;
    itrRow, itrCol: shortint;
  begin
    Result:= true;
     if MaxRow < 1 then 
      Exit;
    for itrCol:= 0 to FieldSize - 1 do
      SetClear (UsedSetsArray[itrCol]);
    for itrRow:= 0 to MaxRow do
      for itrCol:= 0 to FieldSize - 1 do
      begin
        if UnitsArray[itrRow][itrCol] in UsedSetsArray[itrCol] then
        begin
          Result:= false;
          Exit;
        end;
        UsedSetsArray[itrCol]:= UsedSetsArray[itrCol] + [UnitsArray[itrRow][itrCol]];
      end;
  end;
  
  procedure SwapRandomRowsAndCols (var UnitsArray: Field.TUnitsArray; FieldSize: shortint);
    procedure Swap (var Value1, Value2: shortint);
    var
      temp: shortint;
    begin
      temp:= Value1;
      Value1:= Value2;
      Value2:= temp;
    end;
    
    procedure SwapRows (var UnitsArray: Field.TUnitsArray; Row1, Row2, FieldSize: shortint);
    var
      itrCol: shortint;
    begin
      for itrCol:= 0 to FieldSize - 1 do
        Swap (UnitsArray[itrCol][Row1], UnitsArray[itrCol][Row2]);
    end;

    procedure SwapCols (var UnitsArray: Field.TUnitsArray; Col1, Col2, FieldSize: shortint);
    var
      itrRow: shortint;
    begin
      for itrRow:= 0 to FieldSize - 1 do
        Swap (UnitsArray[Col1][itrRow], UnitsArray[Col2][itrRow]);
    end;
    
  var
    swap1, swap2: shortint;  
  begin
    randomize;
    //swap rows
    swap1:= Random (FieldSize - 1) + 1;
    swap2:= Random (FieldSize - 1) + 1;
    while swap2 = swap1 do
      swap2:= Random (FieldSize - 1) + 1;
    SwapRows (UnitsArray, swap1, swap2, FieldSize);
    //swap cols
    swap1:= Random (FieldSize - 1) + 1;
    swap2:= Random (FieldSize - 1) + 1;
    while swap2 = swap1 do
      swap2:= Random (FieldSize - 1) + 1;
    SwapCols (UnitsArray, swap1, swap2, FieldSize);
  end;
  
var
  itr, itrRow: shortint;
begin
  itrRow:= 0;
  while itrRow <= FieldSize - 1 do
  begin
    GenerateRow (Result, itrRow, FieldSize);
    if StillLatinSquare (Result, itrRow, FieldSize) then
      Inc (itrRow);  
  end;
  for itr:= 1 to 10 do
    SwapRandomRowsAndCols (Result, FieldSize);
end;

function GetVisibilityArrayFromUnitsArray (UnitsArray: Field.TUnitsArray; FieldSize: shortint): Field.TVisibilityArray;
var
  itrRow, itrCol, MaxFloor: shortint;
begin
//check visibility
  //Row from left
  for itrRow:= 0 to FieldSize - 1 do
  begin
    MaxFloor:= 0;
    Result[Field.visLeft][itrRow]:= 0;
    for itrCol:= 0 to FieldSize - 1 do
      if UnitsArray[itrRow][itrCol] > MaxFloor then
      begin
        MaxFloor:= UnitsArray[itrRow][itrCol];
        Inc (Result[Field.visLeft][itrRow]);
        if MaxFloor = FieldSize then
          Break;
      end;
  end;
  //Row from right
  for itrRow:= 0 to FieldSize - 1 do
  begin
    MaxFloor:= 0;
    Result[Field.visRight][itrRow]:= 0;
    for itrCol:= FieldSize - 1 downto 0 do
      if UnitsArray[itrRow][itrCol] > MaxFloor then
      begin
        MaxFloor:= UnitsArray[itrRow][itrCol];
        Inc (Result[Field.visRight][itrRow]);
        if MaxFloor = FieldSize then
          Break;
      end;
  end;
  //Column from top
  for itrCol:= 0 to FieldSize - 1 do
  begin
    MaxFloor:= 0;
    Result[Field.visTop][itrCol]:= 0;
    for itrRow:= 0 to FieldSize - 1 do
      if UnitsArray[itrRow][itrCol] > MaxFloor then
      begin
        MaxFloor:= UnitsArray[itrRow][itrCol];
        Inc (Result[Field.visTop][itrCol]);
        if MaxFloor = FieldSize then
          Break;
      end;
  end;
  //Column from bottom
  for itrCol:= 0 to FieldSize - 1 do
  begin
    MaxFloor:= 0;
    Result[Field.visBot][itrCol]:= 0;
    for itrRow:= FieldSize - 1 downto 0 do
      if UnitsArray[itrRow][itrCol] > MaxFloor then
      begin
        MaxFloor:= UnitsArray[itrRow][itrCol];
        Inc (Result[Field.visBot][itrCol]);
        if MaxFloor = FieldSize then
          Break;
      end;
  end;
end;

function GenerateVisibilityArray (var VisibilityArray: Field.TVisibilityArray; FieldSize: shortint): shortint;
begin
  VisibilityArray:= GetVisibilityArrayFromUnitsArray (GenerateUnitsArray (FieldSize), FieldSize);
end;

end.
