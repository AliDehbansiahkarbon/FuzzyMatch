program FuzzyMatch;

uses
  Forms,
  UnitMatch in 'UnitMatch.pas' {FormFuzzy};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFormFuzzy, FormFuzzy);
  Application.Run;
end.
