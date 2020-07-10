extends KinematicBody

# With help from KidsCanCode: https://www.youtube.com/watch?v=ickZ_Genr7A


# Declare member variables here. Examples:
var velocity = Vector3()
var speed = 4
var gravity = Vector3.DOWN * 2
var moving = false
var direction = Vector2(0, 0)

onready var Animator = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.


func _physics_process(delta):
  velocity += gravity * delta
  get_input()
  animate()
  if not moving: Animator.stop()
  velocity = move_and_slide(velocity, Vector3.UP)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#  pass

func get_input():
  var vy = velocity.y
  velocity = Vector3()
  moving = false
  if Input.is_action_pressed('ui_left'):
    moving = true
    velocity += -transform.basis.x * speed
    direction = Vector2(-1, 0)
  elif Input.is_action_pressed('ui_right'):
    moving = true
    velocity += transform.basis.x * speed
    direction = Vector2(1, 0)

  if Input.is_action_pressed('ui_up'):
    moving = true
    velocity += -transform.basis.z * speed
    direction = Vector2(0, -1)
  elif Input.is_action_pressed('ui_down'):
    moving = true
    velocity += transform.basis.z * speed
    direction = Vector2(0, 1)
    
  velocity.y = vy

func animate():
  match direction:
    Vector2(-1, 0): Animator.play('walk_w')
    Vector2(1, 0): Animator.play('walk_e')
    Vector2(0, -1): Animator.play('walk_n')
    Vector2(0, 1): Animator.play('walk_s')
