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
    { Turn on / off the highlight effect, depending on whether
      Behavior equals ChessPieceHover, ChessPieceSelected or none of them.
      It accepts (and ignores) Behavior = nil value. }
    procedure ConfigureEffect(const Behavior: TChessPieceBehavior);
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

procedure TViewMain.ConfigureEffect(const Behavior: TChessPieceBehavior);
var
  Scene: TCastleScene;
begin
  if Behavior = nil then
    Exit;
  { Behavior can be attached to any TCastleTransform.
    In our case, we know it is attached to TCastleScene. }
  Scene := Behavior.Parent as TCastleScene;
  if (Behavior = ChessPieceHover) or
     (Behavior = ChessPieceSelected) then
  begin
    Scene.RenderOptions.WireframeEffect := weSilhouette;
    if Behavior = ChessPieceSelected then
      Scene.RenderOptions.WireframeColor := HexToColorRGB('FFEB00')
    else
      Scene.RenderOptions.WireframeColor := HexToColorRGB('5455FF');
    Scene.RenderOptions.LineWidth := 5;
    Scene.RenderOptions.SilhouetteBias := 20;
    Scene.RenderOptions.SilhouetteScale := 20;
  end else
  begin
    Scene.RenderOptions.WireframeEffect := weNormal;
  end;
end;

procedure TViewMain.Update(const SecondsPassed: Single; var HandleInput: Boolean);
var
  OldHover: TChessPieceBehavior;
begin
  inherited;

  Assert(LabelFps <> nil, 'If you remove LabelFps from the design, remember to remove also the assignment "LabelFps.Caption := ..." from code');
  LabelFps.Caption := 'FPS: ' + Container.Fps.ToString;

  OldHover := ChessPieceHover;

  if MainViewport.TransformUnderMouse <> nil then
  begin
    ChessPieceHover := MainViewport.TransformUnderMouse.FindBehavior(TChessPieceBehavior)
      as TChessPieceBehavior;
  end else
    ChessPieceHover := nil;

  if OldHover <> ChessPieceHover then
  begin
    ConfigureEffect(OldHover);
    ConfigureEffect(ChessPieceHover);
  end;
end;

function TViewMain.Press(const Event: TInputPressRelease): Boolean;
var
  MyBody: TCastleRigidBody;
  OldSelected: TChessPieceBehavior;
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
    OldSelected := ChessPieceSelected;
    if (ChessPieceHover <> nil) and
       (ChessPieceHover <> ChessPieceSelected) then
    begin
      ChessPieceSelected := ChessPieceHover;
      ConfigureEffect(OldSelected);
      ConfigureEffect(ChessPieceSelected);
    end;
    Exit(true); // mouse click was handled
  end;
end;

end.
