unit UMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit, FMX.Platform, FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.FMXUI.Wait, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, FMX.Objects

  /// Helpers for Android implementations by FMX.
    , FMX.Helpers.Android
  // Java Native Interface permite a programas
  // ejecutados en la JVM interactue con otros lenguajes.
    , Androidapi.JNI.GraphicsContentViewText, Androidapi.JNI.Net,
  Androidapi.JNI.JavaTypes, Androidapi.Helpers
  // Obtiene datos de telefonia del dispositivo
    , Androidapi.JNI.Telephony, FMX.Layouts;

type
  TfrmMain = class(TForm)
    BtnIniciar: TButton;
    BtnRegistrar: TButton;
    Label2: TLabel;
    ECorreo: TEdit;
    Label3: TLabel;
    EPassword: TEdit;
    Database: TFDConnection;
    tblUsuario: TFDTable;
    ToolBar1: TToolBar;
    Label4: TLabel;
    Image1: TImage;
    Panel1: TPanel;
    Label1: TLabel;
    Label6: TLabel;
    Panel2: TPanel;
    btnRegistrate: TButton;
    BtnRecuperarPassword: TButton;
    MostrarPassword: TCheckBox;
    Salir: TButton;
    ScrollBox1: TScrollBox;
    procedure BtnRegistrarClick(Sender: TObject);
    procedure BtnIniciarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MostrarPasswordChange(Sender: TObject);
    procedure ECorreoChange(Sender: TObject);
    procedure SalirClick(Sender: TObject);
    procedure BtnRecuperarPasswordClick(Sender: TObject);
    procedure FormResize(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
    // Para enviar mensajes SMS desde un dispositivo móvil.
    procedure SendSMS(target, message: string);
  end;

var
  frmMain: TfrmMain;
  varContador: Integer = 0;

implementation

uses Registro, UPrincipal, System.IOUtils;

{$R *.fmx}

// Esto se ejecuta al iniciar el programa/app siempre para establecer la BD.
procedure TfrmMain.FormCreate(Sender: TObject);
var
  dbFileName: string;
begin
{$IF DEFINED(MSWINDOWS)}
  // Ubicacion de la bd en Windows.
  dbFileName := 'C:\Users\Rogelio Leoner\Desktop\Login\login2.db';
{$ELSE}
  // Ubicacion de la bd en Android.
  dbFileName := TPath.Combine(TPath.GetDocumentsPath, 'login2.db');
{$ENDIF}
  // Asignar la base de datos.
  Database.Params.Database := dbFileName;
  try
    Database.Connected := true; // Conectarse a la BD.
    tblUsuario.Active := true; // Ativar la tabla.
    Database.Open;
    tblUsuario.Open;
  except
    // Se ejecuta si ocurre una falla al intentar conectarse a la BD.
    on E: Exception do
      ShowMessage('Error de conexion');
  end;
end;

// Ocultar imagenes.
procedure TfrmMain.FormResize(Sender: TObject);
var
  s: IFMXScreenService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXScreenService, s)
  then
  begin
    case s.GetScreenOrientation of
      // Portrait Orientation: Mostrar imagenes.
      TScreenOrientation.Portrait:
        begin
          Image1.Visible := true;
          // TLTituloUsuario.Visible := true;
        end;

      // Landscape Orientation: Ocultar imagenes.
      TScreenOrientation.Landscape:
        begin
          Image1.Visible := false;
          // TLTituloUsuario.Visible := false;
        end;

      // InvertedPortrait Orientation: Mostrar imagenes.
      TScreenOrientation.InvertedPortrait:
        begin
          Image1.Visible := true;
        end;

      // InvertedLandscape Orientation: Ocultar imagenes.
      TScreenOrientation.InvertedLandscape:
        begin
          Image1.Visible := false;
        end;
    end;
  end;
end;

// Se ejecuta al hacer clic en el botón "Iniciar sesión".
procedure TfrmMain.BtnIniciarClick(Sender: TObject);
var
  varCorreo: string;
  varPassword: string;
begin
  varCorreo := ECorreo.Text; // Valor del nombre de usuario ingresado.
  varPassword := EPassword.Text; // Valor del nombre de usuario ingresado.

  // Buscar Registro con el correo y contraseña ingresados.
  if tblUsuario.Locate('correoE;contrasena', VarArrayOf([varCorreo, varPassword]
    ), []) then
  begin
{$IF DEFINED(MSWINDOWS)}
    frmPrincipal.ShowModal;
{$ELSE}
    frmPrincipal.Show;
{$ENDIF}
    ECorreo.Text := '';
    EPassword.Text := '';
  end
  else
  begin
    ShowMessage
      ('El correo electronico o el password es inválido, verifica la información y prueba nuevamente.');
    // Número de intentos de inicio de sesión.
    varContador := varContador + 1;
    // Verificación de intentos de inicio de sesión.
    if ((varContador = 3)) then
    begin
      BtnIniciar.Enabled := false; // Deshabilitar el botón.
      ShowMessage('Intente de nuevo despues de 20 segundos.');
      // (Thread) para esperar 5 segundos y habilitar el botón nuevamente.
      TThread.CreateAnonymousThread(
        procedure
        begin
          Sleep(20000); // Esperar 20 segundos.
        end).Start;
      varContador := 0; // Reiniciar contador.
    end;
    EPassword.Text := '';
  end;
end;

// Para enviar un SMS al numero de telefono que esta en la BD con la contraseña.
procedure TfrmMain.BtnRecuperarPasswordClick(Sender: TObject);
var
  varCelular: String; // Contendra el número registrado.
  varMensaje: String; // Contendra la nueva contraseña.
begin

  // Verificar si exixte el correo electronico ingresado.
  if tblUsuario.Locate('correoE', ECorreo.Text, []) then
  begin
    // Obtener los datos originales de la BD.
    varCelular := tblUsuario.FieldByName('telefono').aSString;
    varMensaje := tblUsuario.FieldByName('contrasena').aSString;

    // Llamar a SendSMS que recibe 2 paramentros
    // target: Destinatario de SMS; message: contenido del SMS;
    // Modificar. poner los datos de la base de datos, numero de telefono y la contraseña
    SendSMS(varCelular, 'Tu contraseña es: ' + varMensaje);
  end;
end;

procedure TfrmMain.SendSMS(target, message: string);
var
  smsManager: JSmsManager; // Declarar administrador de mensajes
  smsTo: JString; // Variable destinatario del SMS
begin
  try
    // inicializar administrador de mensajes
    smsManager := TJSmsManager.JavaClass.getDefault;
    // convertir target a tipo Jstring tipo de dato usado por JNI
    smsTo := StringToJString(target);
    // pasar parametros a administrador para enviar mensaje
    smsManager.sendTextMessage(smsTo, nil, StringToJString(message), nil, nil);
    ShowMessage('Mensaje enviado');
  except
    on E: Exception do
      ShowMessage(E.ToString);
  end;
end;

procedure TfrmMain.BtnRegistrarClick(Sender: TObject);
begin
  ECorreo.Text := '';
  EPassword.Text := '';
  MostrarPassword := false;
end;

// Para mostrar la contraseña escrita por el usuario.
procedure TfrmMain.MostrarPasswordChange(Sender: TObject);
begin
  EPassword.Password := not MostrarPassword.IsChecked;
end;

// Si todos los campos están llenos, habilitar el botón, de lo contrario, deshabilítar.
procedure TfrmMain.ECorreoChange(Sender: TObject);
begin
  if (ECorreo.Text <> '') and (EPassword.Text <> '') then
    BtnIniciar.Enabled := true
  else
    BtnIniciar.Enabled := false;
end;

// Termina el programa-aplicacion.
procedure TfrmMain.SalirClick(Sender: TObject);
begin
  Database.close;
  tblUsuario.close;
  close;
end;

end.
