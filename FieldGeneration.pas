unit FieldGeneration;

interface

uses
  Field, SysUtils, Dialogs;

function UnitsArrayGeneration (FieldSize: shortint): Field.TUnitsArray;

implementation

uses 
  FieldProcessing;

function RandomButNotIn (SomeSet: FieldProcessing.TCheckSet; MaxValue: shortint); shortint;
begin
  while true do
  begin
    Result:= Random (MaxValue + 1);
    if not Result in SomeSet then
    begin
      SomeSet:= SomeSet + [Result];
      Break;
    end;
  end;
end;
  
function UnitsArrayGeneration (FieldSize: shortint): Field.TUnitsArray;
var
  UsedSetsArray: array[0..Field._MaxFieldSize - 1] of FieldProcessing.TCheckSet;
  CurrentSet: FieldProcessing.TCheckSet;
  itr: shortint;
begin
  SetClear (CurrentSet);
  for itr:= 0 to FieldSize - 1 do
    SetClear (UsedSetsArray[itr]);

  
end;

end.
