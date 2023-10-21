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
    DesignForceGizmo: TCastleTransformDesign;
  private
    ChessPieceHover, ChessPieceSelected: TChessPieceBehavior;
    TransformForceAngle, TransformForceStrength: TCastleTransform;
    ForceAngle: Single;
    ForceStrength: Single;
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

uses SysUtils, Math,
  CastleLog, CastleColors, CastleUtils;

const
  MinStrength = 1;
  MaxStrength = 1000;

  MinStrengthScale = 1;
  MaxStrengthScale = 3;

  StrengthChangeSpeed = 30;
  AngleAChangeSpeed = 10;

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

  TransformForceAngle := DesignForceGizmo.DesignedComponent('TransformForceAngle')
    as TCastleTransform;
  TransformForceStrength := DesignForceGizmo.DesignedComponent('TransformForceStrength')
    as TCastleTransform;
  ForceAngle := 0; // 0 is default value of Single field anyway
  TransformForceAngle.Rotation := Vector4(1, 0, 0, ForceAngle);
  ForceStrength := 10; // set some sensible initial value
  TransformForceStrength.Scale := Vector3(1,
    MapRange(ForceStrength, MinStrength, MaxStrength, MinStrengthScale, MaxStrengthScale),
    1);
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
    Scene.RenderOptions.LineWidth := 10;
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

  if Container.Pressed[keyArrowLeft] then
    ForceAngle := ForceAngle - SecondsPassed * AngleAChangeSpeed;
  if Container.Pressed[keyArrowRight] then
    ForceAngle := ForceAngle + SecondsPassed * AngleAChangeSpeed;
  if Container.Pressed[keyArrowUp] then
    ForceStrength := Min(MaxStrength, ForceStrength + SecondsPassed * StrengthChangeSpeed);
  if Container.Pressed[keyArrowDown] then
    ForceStrength := Max(MinStrength, ForceStrength - SecondsPassed * StrengthChangeSpeed);

  TransformForceAngle.Rotation := Vector4(1, 0, 0, ForceAngle);
  TransformForceStrength.Scale := Vector3(1,
    MapRange(ForceStrength, MinStrength, MaxStrength, MinStrengthScale, MaxStrengthScale),
    1);
end;

function TViewMain.Press(const Event: TInputPressRelease): Boolean;
var
  MyBody: TCastleRigidBody;
  OldSelected: TChessPieceBehavior;
  ChessPieceSelectedScene: TCastleScene;
  ForceDirection: TVector3;
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
      DesignForceGizmo.Exists := true;
      DesignForceGizmo.Translation := ChessPieceSelected.Parent.WorldTranslation;
    end;
    Exit(true); // mouse click was handled
  end;

  if Event.IsKey(keyEnter) and (ChessPieceSelected <> nil) then
  begin
    ChessPieceSelectedScene := ChessPieceSelected.Parent as TCastleScene;
    MyBody := ChessPieceSelectedScene.FindBehavior(TCastleRigidBody) as TCastleRigidBody;
    ForceDirection := RotatePointAroundAxis(
      Vector4(0, 1, 0, ForceAngle), Vector3(-1, 0, 0));
    MyBody.ApplyImpulse(
      ForceDirection * ForceStrength,
      ChessPieceSelectedScene.WorldTranslation);
    // unselect after flicking; not strictly necessary, but looks better
    ChessPieceSelected := nil;
    DesignForceGizmo.Exists := false;
    Exit(true); // input was handled
  end;
end;

end.
