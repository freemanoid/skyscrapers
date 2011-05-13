unit FieldProcessing;

interface

uses Field;

type
  TCheckSet = set of 1..6;

function IsTrueSolution (UnitsArray: TUnitsArray; VisibilityArray: TVisibilityArray; FieldSize: byte): boolean;

implementation

procedure SetReset (var SomeSet: TCheckSet);
begin
  SomeSet:= [1..6];
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
    SetReset (CheckSet);
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
    SetReset (CheckSet);
  end;
//check visibility
  //Row from left
  for itrRow:= 0 to FieldSize - 1 do
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
  //Row from right
  for itrRow:= 0 to FieldSize - 1 do
  begin
    MaxFloor:= 0;
    VisibilityCount:= 0;
    for itrCol:= FieldSize - 1 downto 0 do
      if UnitsArray[itrRow][itrCol] < MaxFloor then
      begin
        MaxFloor:= UnitsArray[itrRow][itrCol];
        Inc (VisibilityCount);
        if (MaxFloor = FieldSize) and (VisibilityCount <> VisibilityArray[visRight][itrRow]) then
        begin
          IsTrueSolution:= false;
          exit
        end;
      end;
  end;
  //Column from top
  for itrCol:= 0 to FieldSize - 1 do
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
  //Column from bottom
  for itrCol:= 0 to FieldSize - 1 do
  begin
    MaxFloor:= 0;
    VisibilityCount:= 0;
    for itrRow:= FieldSize - 1 downto 0 do
      if UnitsArray[itrRow][itrCol] < MaxFloor then
      begin
        MaxFloor:= UnitsArray[itrRow][itrCol];
        Inc (VisibilityCount);
        if (MaxFloor = FieldSize) and (VisibilityCount <> VisibilityArray[visBot][itrRow]) then
        begin
          IsTrueSolution:= false;
          exit
        end;
      end;
  end;
end;
end.
 