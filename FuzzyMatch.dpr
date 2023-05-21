program FuzzyMatch;

uses
  Forms,
  UnitMatch in 'UnitMatch.pas' {FormFuzzy},
  Vcl.Themes,
  Vcl.Styles;

{$R *.RES}

begin
  Application.Initialize;
  TStyleManager.TrySetStyle('Glow');
  Application.CreateForm(TFormFuzzy, FormFuzzy);
  Application.Run;
end.
