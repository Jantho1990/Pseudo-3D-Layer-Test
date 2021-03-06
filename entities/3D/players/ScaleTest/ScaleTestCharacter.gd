extends KinematicBody

# With help from KidsCanCode: https://www.youtube.com/watch?v=ickZ_Genr7A


# Declare member variables here. Examples:
export(bool) var free_move = true
export(bool) var free_direction = true
var velocity = Vector3()
var speed = 2
var gravity = Vector3.DOWN * 2
var moving = false
var direction = Vector2(0, 0)
var layer_shift = 1
var is_shifting_layer = false
var layer_shift_delayed = false
var layer_shift_delay_time = 1
var layer_shift_delay_transition_time = 0.3

# onready var Animator = $AnimationPlayer
onready var CharacterExpressions = [
  $Sprite3D64Neutral,
  $Sprite3D64Happy,
  $Sprite3D64Sad,
  $Sprite3D64Angry
]
onready var cei = 0
onready var LayerShiftDelay = $LayerShiftDelay
onready var LayerShiftTween = $LayerShiftTween
onready var Sprite = CharacterExpressions[cei]


# Called when the node enters the scene tree for the first time.
func _ready():
  change_expression('default')
  LayerShiftDelay.connect('timeout', self, '_on_Layer_shift_delay_stop')
  LayerShiftTween.connect('tween_all_completed', self, '_on_Layer_shift_tween_all_completed')


func _physics_process(delta):
  # Disabling to fix jitters until I can look into this: https://godotengine.org/qa/42375/unexpected-collision-normals-touching-adjacent-collision
  # if not is_on_floor():
  #   velocity += gravity * delta
  get_input()
  # animate()
  # if not moving: Animator.stop()
  velocity = move_and_slide(velocity, Vector3.UP)
  face_direction()

func _on_Layer_shift_delay_stop():
  layer_shift_delayed = false

func _on_Layer_shift_tween_all_completed():
  is_shifting_layer = false


func _unhandled_input(event):
  if Input.is_action_just_pressed('sprite_change_right'):
    change_expression('right')
  if Input.is_action_just_pressed('sprite_change_left'):
    change_expression('left')

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#  pass


func change_expression(face):
  match face:
    'left':
      cei -= 1
      if cei < 0:
        cei = CharacterExpressions.size() - 1
    'right':
      cei += 1
      if cei >= CharacterExpressions.size():
        cei = 0
    'default':
      cei = 0
    _: return
  
  for ce in range(0, (CharacterExpressions.size())):
    if ce != cei:
      CharacterExpressions[ce].visible = false
    else:
      CharacterExpressions[ce].visible = true
  Sprite = CharacterExpressions[cei]
  face_direction()


func face_direction():
  if free_direction:
    match direction:
      Vector2(0, 1): Sprite.frame = 0
      Vector2(0, -1): Sprite.frame = 1
      Vector2(1, 0): Sprite.frame = 2
      Vector2(-1, 0): Sprite.frame = 3
      Vector2(1, 1): Sprite.frame = 4
      Vector2(-1, 1): Sprite.frame = 5
      Vector2(1, -1): Sprite.frame = 6
      Vector2(-1, -1): Sprite.frame = 7
  else:
    match direction:
      Vector2(0, 1), Vector2(1, 1), Vector2(-1, 1): Sprite.frame = 0
      Vector2(0, -1), Vector2(1, -1), Vector2(-1, -1): Sprite.frame = 1
      Vector2(1, 0): Sprite.frame = 2
      Vector2(-1, 0): Sprite.frame = 3


func get_input():
  if free_move:
    free_move()
  else:
    limited_move()

func animate():
  pass
  # match direction:
  #   Vector2(-1, 0): Animator.play('walk_w')
  #   Vector2(1, 0): Animator.play('walk_e')
  #   Vector2(0, -1): Animator.play('walk_n')
  #   Vector2(0, 1): Animator.play('walk_s')

func free_move():
  var vy = velocity.y
  velocity = Vector3()
  moving = false
  if Input.is_action_pressed('ui_left'):
    moving = true
    velocity += -transform.basis.x * speed
    direction = Vector2(-1, direction.y)
  elif Input.is_action_pressed('ui_right'):
    moving = true
    velocity += transform.basis.x * speed
    direction = Vector2(1, direction.y)
  else:
    direction = Vector2(0, direction.y)

  if Input.is_action_pressed('ui_up'):
    moving = true
    velocity += -transform.basis.z * speed
    direction = Vector2(direction.x, -1)
  elif Input.is_action_pressed('ui_down'):
    moving = true
    velocity += transform.basis.z * speed
    direction = Vector2(direction.x, 1)
  else:
    direction = Vector2(direction.x, 0)
    
  velocity.y = vy

func limited_move():
  var vy = velocity.y
  velocity = Vector3()
  moving = false
  
  # Cancel movement if we're shifting layers.
  if is_shifting_layer: return

  if Input.is_action_pressed('ui_left'):
    moving = true
    velocity += -transform.basis.x * speed
    direction = Vector2(-1, 0)
  elif Input.is_action_pressed('ui_right'):
    moving = true
    velocity += transform.basis.x * speed
    direction = Vector2(1, 0)

  if not layer_shift_delayed:
    if Input.is_action_pressed('ui_up'):
      start_layer_shift_tween(-layer_shift)
    elif Input.is_action_pressed('ui_down'):
      start_layer_shift_tween(layer_shift)
    
  velocity.y = vy

func start_layer_shift_tween(amount):
  is_shifting_layer = true
  var target_translation = translation
  target_translation.z += amount
  LayerShiftTween.interpolate_property(self, 'translation', translation, target_translation, layer_shift_delay_transition_time)
  LayerShiftTween.start()
  start_layer_shift_delay()

func start_layer_shift_delay():
  layer_shift_delayed = true
  LayerShiftDelay.start(layer_shift_delay_time)
