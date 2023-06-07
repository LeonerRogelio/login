program Login;

uses
  System.StartUpCopy,
  FMX.Forms,
  UMain in 'UMain.pas' {frmMain},
  Registro in 'Registro.pas' {RegistroU},
  UPrincipal in 'UPrincipal.pas' {frmPrincipal},
  vkbdhelper in 'vkbdhelper.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TRegistroU, RegistroU);
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.
