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
  pass

func _physics_process(delta):
  # Disabling to fix jitters until I can look into this: https://godotengine.org/qa/42375/unexpected-collision-normals-touching-adjacent-collision
  # if not is_on_floor():
  #   velocity += gravity * delta
  get_input()
  # animate()
  # if not moving: Animator.stop()
  velocity = move_and_slide(velocity, Vector3.UP)


func get_input():
  free_move()

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
