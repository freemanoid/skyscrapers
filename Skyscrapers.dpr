program Skyscrapers;

{%ToDo 'Skyscrapers.todo'}

uses
  Forms,
  Field in 'Field.pas' {FieldForm},
  FieldProcessing in 'FieldProcessing.pas',
  FieldGeneration in 'FieldGeneration.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Небоскрёбы';
  Application.CreateForm(TFieldForm, FieldForm);
  Application.Run;
end.
