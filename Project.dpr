program Project;

uses
  Forms,
  field in 'field.pas' {FieldForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFieldForm, FieldForm);
  Application.Run;
end.
