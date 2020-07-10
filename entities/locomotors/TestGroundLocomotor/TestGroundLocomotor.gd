extends Locomotor


class_name TestGroundLocomotor


signal change_speed


const UP = Vector2(0, -1)
const GRAVITY = 20 #Physics2DServer.AREA_PARAM_GRAVITY
const MAX_GRAVITY = 1960
export(float) var ACCELERATION = 50.0
export(float) var MAX_WALK_SPEED = 200.0
export(float) var MAX_RUN_SPEED = 300.00

var Controller

var direction = Vector2(1, 0)

onready var Parent = get_parent()
onready var State = $State

# Called when the node enters the scene tree for the first time.
func _ready():
  pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
  Parent.motion.y += GRAVITY

  # Prevent falling too fast
  if Parent.motion.y > MAX_GRAVITY:
    Parent.motion.y = MAX_GRAVITY
  
  # Friction
  # friction = true
  Parent.motion.x = lerp(Parent.motion.x, 0, 0.1)


func _on_Change_speed(speed_state):
  if State.has(speed_state):
    State.swap(speed_state)


func init_connections(controller):
  Controller = controller
  Controller.connect('idle', self, 'idle')
  Controller.connect('move_left', self, 'move_left')
  Controller.connect('move_right', self, 'move_right')
  Controller.connect('change_speed', self, '_on_Change_speed')


func idle():
  Parent.motion.x = 0


func move_left():
  var acceleration = ACCELERATION
  var max_speed = get_max_speed()
  Parent.motion.x = max(Parent.motion.x - acceleration, -max_speed)
  direction = Vector2(-1, 0)


func move_right():
  var acceleration = ACCELERATION
  var max_speed = get_max_speed()
  Parent.motion.x = min(Parent.motion.x + acceleration, max_speed)
  direction = Vector2(1, 0)


func get_max_speed():
  match State.current:
    'walk': return MAX_WALK_SPEED
    'run': return MAX_RUN_SPEED
