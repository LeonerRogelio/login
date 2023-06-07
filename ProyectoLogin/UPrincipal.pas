unit UPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects;

type
  TfrmPrincipal = class(TForm)
    ToolBar1: TToolBar;
    PanelContenedorPrincipal: TPanel;
    PanelContenedorDeBtns: TPanel;
    BtnAgregarProducto: TButton;
    Image2: TImage;
    BtnOpciones: TButton;
    TLTitulo: TLabel;
    BtnVenderProducto: TButton;
    Image1: TImage;
    BtnMostrarInventario: TButton;
    Image3: TImage;
    BtnRegistros: TButton;
    Image4: TImage;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.fmx}

end.
