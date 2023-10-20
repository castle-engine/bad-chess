{ Main view, where most of the application logic takes place.

  Feel free to use this code as a starting point for your own projects.
  This template code is in public domain, unlike most other CGE code which
  is covered by BSD or LGPL (see https://castle-engine.io/license). }
unit GameViewMain;

interface

uses Classes,
  CastleVectors, CastleComponentSerialize,
  CastleUIControls, CastleControls, CastleKeysMouse, CastleScene,
  CastleTransform, CastleViewport;

type
  TChessPieceBehavior = class(TCastleBehavior)
  public
    Black: Boolean;
  end;

  { Main view, where most of the application logic takes place. }
  TViewMain = class(TCastleView)
  published
    { Components designed using CGE editor.
      These fields will be automatically initialized at Start. }
    LabelFps: TCastleLabel;
    SceneBlackKing1: TCastleScene;
    BlackPieces, WhitePieces: TCastleTransform;
    MainViewport: TCastleViewport;
  private
    ChessPieceHover, ChessPieceSelected: TChessPieceBehavior;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Start; override;
    procedure Update(const SecondsPassed: Single; var HandleInput: Boolean); override;
    function Press(const Event: TInputPressRelease): Boolean; override;
  end;

var
  ViewMain: TViewMain;

implementation

uses SysUtils,
  CastleLog, CastleColors;

{ TViewMain ----------------------------------------------------------------- }

constructor TViewMain.Create(AOwner: TComponent);
begin
  inherited;
  DesignUrl := 'castle-data:/gameviewmain.castle-user-interface';
end;

procedure TViewMain.Start;

  procedure ConfigureChessPiece(const Child: TCastleTransform; const Black: Boolean);
  var
    ChessPiece: TChessPieceBehavior;
  begin
    ChessPiece := TChessPieceBehavior.Create(FreeAtStop);
    ChessPiece.Black := true;
    Child.AddBehavior(ChessPiece);
    if Child.FindBehavior(TCastleRigidBody) = nil then
      Child.AddBehavior(TCastleRigidBody.Create(FreeAtStop));
    if Child.FindBehavior(TCastleCollider) = nil then
      Child.AddBehavior(TCastleBoxCollider.Create(FreeAtStop));
  end;

var
  Child: TCastleTransform;
begin
  inherited;
  for Child in BlackPieces do
    ConfigureChessPiece(Child, true);
  for Child in WhitePieces do
    ConfigureChessPiece(Child, false);
  WritelnLog('Configured %d black and %d white chess pieces', [
    BlackPieces.Count,
    WhitePieces.Count
  ]);
end;

procedure TViewMain.Update(const SecondsPassed: Single; var HandleInput: Boolean);
var
  NewHover: TChessPieceBehavior;
  NewHoverScene, ChessPieceHoverScene: TCastleScene;
begin
  inherited;
  { This virtual method is executed every frame (many times per second). }
  Assert(LabelFps <> nil, 'If you remove LabelFps from the design, remember to remove also the assignment "LabelFps.Caption := ..." from code');
  LabelFps.Caption := 'FPS: ' + Container.Fps.ToString;

  if MainViewport.TransformUnderMouse <> nil then
  begin
    NewHover := MainViewport.TransformUnderMouse.FindBehavior(TChessPieceBehavior)
      as TChessPieceBehavior;
  end else
    NewHover := nil;

  if ChessPieceHover <> NewHover then
  begin
    // disable hover effect on previous piece
    if ChessPieceHover <> ChessPieceSelected then
    begin
      ChessPieceHoverScene := ChessPieceHover.Parent as TCastleScene;
      ChessPieceHoverScene.RenderOptions.WireframeEffect := weNormal;
    end;
    // enable hover effect on new piece
    if NewHover <> ChessPieceSelected then
    begin
      NewHoverScene := NewHover.Parent as TCastleScene;
      NewHoverScene.RenderOptions.WireframeEffect := weSilhouette;
      NewHoverScene.RenderOptions.WireframeColor := HexToColorRGB('5455FF');
      NewHoverScene.RenderOptions.LineWidth := 5;
      NewHoverScene.RenderOptions.SilhouetteBias := 20;
      NewHoverScene.RenderOptions.SilhouetteScale := 20;
    end;
    ChessPieceHover := NewHover;
  end;
end;

function TViewMain.Press(const Event: TInputPressRelease): Boolean;
var
  MyBody: TCastleRigidBody;
begin
  Result := inherited;
  if Result then Exit; // allow the ancestor to handle keys

  if Event.IsKey(keyX) then
  begin
    MyBody := SceneBlackKing1.FindBehavior(TCastleRigidBody) as TCastleRigidBody;
    MyBody.ApplyImpulse(Vector3(0, 10, 0), SceneBlackKing1.WorldTranslation);
    Exit(true); // key was handled
  end;

  if Event.IsMouseButton(buttonLeft) then
  begin
    // TODO FFEB00
  end;
end;

end.
