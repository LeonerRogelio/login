unit Registro;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.DialogService,FMX.Platform, // Para los Dialogos.
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.FMXUI.Wait, Data.DB,
  FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet, RegularExpressions, FMX.Objects, FMX.Layouts;

type
  TRegistroU = class(TForm)
    TLTituloRegistro: TLabel;
    BtnAtras: TButton;
    ToolBar1: TToolBar;
    Panel1: TPanel;
    Image1: TImage;
    TLTituloUsuario: TLabel;
    ENombres: TEdit;
    Panel2: TPanel;
    EApellidoP: TEdit;
    EApellidoM: TEdit;
    ECorreo: TEdit;
    EPassword: TEdit;
    ENoCelular: TEdit;
    BtnRegistrarme: TButton;
    MostrarPassword: TCheckBox;
    check8: TCheckBox;
    checkCE: TCheckBox;
    checkMay: TCheckBox;
    checkMin: TCheckBox;
    EConfiPassword: TEdit;
    VertScrollBox1: TVertScrollBox;
    PanelChecks: TPanel;
    PanelContraseñas: TPanel;
    Panel3: TPanel;
    procedure BtnRegistrarmeClick(Sender: TObject);
    procedure MostrarPasswordChange(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BtnAtrasClick(Sender: TObject);
    procedure EPasswordKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure FormResize(Sender: TObject);

  private
    { Private declarations }
    procedure ValidarPassword(const Password: string);
    procedure LimpiarCampos();
  public
    { Public declarations }
  end;

var
  RegistroU: TRegistroU;
  varDialogo: Boolean;

implementation

uses UMain;

{$R *.fmx}

// Inisializar las variables que se necesitan al crear el frm.
procedure TRegistroU.BtnAtrasClick(Sender: TObject);
begin
  varDialogo := false;
  close;
end;

procedure TRegistroU.BtnRegistrarmeClick(Sender: TObject);
begin
  if ((ENombres.Text <> '') and (EApellidoP.Text <> '') and
    (EApellidoM.Text <> '') and (ECorreo.Text <> '') and (EPassword.Text <> '')
    and (EConfiPassword.Text <> '') and (ENoCelular.Text <> '')) then
  begin
    if EPassword.Text = EConfiPassword.Text then
    begin
      if ((check8.IsChecked = true) and (checkMin.IsChecked = true) and
        (checkMay.IsChecked = true) and (checkCE.IsChecked = true)) then
      begin
        try
          frmMain.tblUsuario.Append;
          frmMain.tblUsuario.FieldByName('nombre').Value := ENombres.Text;
          frmMain.tblUsuario.FieldByName('apellidoP').Value := EApellidoP.Text;
          frmMain.tblUsuario.FieldByName('apellidoM').Value := EApellidoM.Text;
          frmMain.tblUsuario.FieldByName('correoE').Value := ECorreo.Text;
          frmMain.tblUsuario.FieldByName('contrasena').Value := EPassword.Text;
          frmMain.tblUsuario.FieldByName('telefono').Value := ENoCelular.Text;
          frmMain.tblUsuario.Post;
          ShowMessage
            ('¡Felicidades! El registro se ha realizado con éxito. ¡Bienvenido/a a nuestro sistema! Ahora puedes disfrutar los servicios disponibles.');
          LimpiarCampos; // (Metodos) Limpiar campos.
          close; // Salir.
        except
          on E: EDatabaseError do
          begin
            ShowMessage
              ('Lo siento, pero el Correo que has ingresado ya está en uso. Por favor, elige un correo diferente para continuar.');
            ECorreo.Text := '';
            frmMain.tblUsuario.Cancel;
          end
        end;
      end
      else
      begin
        ShowMessage
          ('La contraseña ingresada es incorrecta. Por favor, verifica y vuelve a intentarlo.')
      end;
    end
    else
    begin
      // Las contraseñas no coinciden
      ShowMessage
        ('Las contraseñas no coinciden. Por favor, inténtalo de nuevo');
    end;
  end
  else
  begin
    ShowMessage
      ('No has introducido los datos necesarios. Por favor, proporciona la información solicitada')
  end;
end;

procedure TRegistroU.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if (ENombres.Text = '') and (EApellidoP.Text = '') and (EApellidoM.Text = '')
    and (ECorreo.Text = '') and (EPassword.Text = '') and
    (EConfiPassword.Text = '') and (ENoCelular.Text = '') then
  begin
    varDialogo := true;
  end
  else
  begin
    TDialogService.MessageDialog
      ('¿Estás seguro/a de que deseas salir sin guardar? Toda la información no guardada se perderá.',
      TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
      TMsgDlgBtn.mbNo, 0,
      procedure(const AResult: TModalResult)
      begin
        case AResult of
          mrYES:
            begin
              LimpiarCampos; // (Metodo) Limpiar campos
              varDialogo := true; // Salir.
{$IF DEFINED(ANDROID)}
              close;
{$ENDIF}
            end;
          mrNo:
            begin
              varDialogo := false; // Permanece en la ventana.
            end;
        end; // Fin del case.
      end); // Fin del Dialogo.
  end; // Fin del if.
  CanClose := varDialogo;
end;

// vkHardwareBack del movil. Mostrara el dialogo antes de salir.
procedure TRegistroU.FormKeyUp(Sender: TObject; var Key: Word;
var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkHardwareBack then
  begin
    varDialogo := false;
  end;
end;

// Ocultar imagenes.
procedure TRegistroU.FormResize(Sender: TObject);
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
          //TLTituloUsuario.Visible := true;
        end;

      // Landscape Orientation: Ocultar imagenes.
      TScreenOrientation.Landscape:
        begin
          Image1.Visible := false;
          //TLTituloUsuario.Visible := false;
        end;

      // InvertedPortrait Orientation: Mostrar imagenes.
      TScreenOrientation.InvertedPortrait:
        begin
          Image1.Visible := true;
          //TLTituloUsuario.Visible := true;
        end;
      // InvertedLandscape Orientation: Ocultar imagenes.
      TScreenOrientation.InvertedLandscape:
        begin
          Image1.Visible := false;
          //TLTituloUsuario := false;
        end;
    end;
  end;
end;

// Para mostrar la contraseña escrita por el usuario.
procedure TRegistroU.MostrarPasswordChange(Sender: TObject);
begin
  EPassword.Password := not MostrarPassword.IsChecked;
  EConfiPassword.Password := not MostrarPassword.IsChecked;
end;

// Metodo para limpiar campos del frame.
procedure TRegistroU.LimpiarCampos();
begin
  ENombres.Text := '';
  EApellidoP.Text := '';
  EApellidoM.Text := '';
  ECorreo.Text := '';
  EPassword.Text := '';
  EConfiPassword.Text := '';
  ENoCelular.Text := '';

  check8.IsChecked := false;
  checkMin.IsChecked := false;
  checkMay.IsChecked := false;
  checkCE.IsChecked := false;
  MostrarPassword.IsChecked := false;
end;

{ Validar la contraseña: Valida el password constantemente que se presiona una tecla en el edit. }
procedure TRegistroU.EPasswordKeyUp(Sender: TObject; var Key: Word;
var KeyChar: Char; Shift: TShiftState);
var
  varPassword: string;
begin
  // Las contraseñas coinciden
  varPassword := EPassword.Text; // Obtener contraseña ingresada.
  ValidarPassword(varPassword);
end;

// Para verificar que la contraseña cumpla con los requerimientos.
procedure TRegistroU.ValidarPassword(const Password: string);
var
  varLetraMinuscula: TRegEx;
  varLetraMayuscula: TRegEx;
  varCaracterEspecial: TRegEx;
begin
  // Expresión regular para validar una letra minúscula
  varLetraMinuscula := TRegEx.Create('^(?=.*[a-z]).*$');
  // Expresión regular para validar una letra mayúscula
  varLetraMayuscula := TRegEx.Create('^(?=.*[A-Z]).*$');
  // Expresión regular para validar un caracter especial.
  varCaracterEspecial := TRegEx.Create('^(?=.*\W).*$');

  if varLetraMinuscula.IsMatch(Password) then
    checkMin.IsChecked := true
  else
    checkMin.IsChecked := false;
  if varLetraMayuscula.IsMatch(Password) then
    checkMay.IsChecked := true
  else
    checkMay.IsChecked := false;
  if varCaracterEspecial.IsMatch(Password) then
    checkCE.IsChecked := true
  else
    checkCE.IsChecked := false;
  if Password.Length >= 8 then
    check8.IsChecked := true
  else
    check8.IsChecked := false;
end;

end.
