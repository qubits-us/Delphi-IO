program ModbTest;

uses
  Vcl.Forms,
  frmMain in 'frmMain.pas' {MainFrm},
  uModBus in 'uModBus.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainFrm, MainFrm);
  Application.Run;
end.
