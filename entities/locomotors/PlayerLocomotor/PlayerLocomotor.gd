extends Node


signal play_sound

const UP = Vector2(0, -1)
const GRAVITY = 20 #Physics2DServer.AREA_PARAM_GRAVITY
const MAX_GRAVITY = 1960
const ACCELERATION = 50
const MAX_SPEED = 200
const RUN_ACCELERATION = 100
const RUN_MAX_SPEED = 400
const MAX_JUMP_HEIGHT = 600
const JUMP_ACCELERATION = MAX_JUMP_HEIGHT / 100.0
const RUN_MAX_JUMP_HEIGHT = 750

var Controller

var direction = Vector2(1, 0)

var current_jump_height = 0.0
var jump_acceleration = (MAX_JUMP_HEIGHT / 20.0) + GRAVITY
var is_in_air = false
var is_jumping = false
var is_running = false

# Suspension from gravity
const SUSPENSION_TIME = 0.2 # seconds, should match controller's FREEZE_TIME
var is_suspended = false

onready var Parent = get_parent()
onready var SuspensionTimer = $SuspensionTimer


# Called when the node enters the scene tree for the first time.
func _ready():
  SuspensionTimer.connect('timeout', self, '_on_Suspension_timer_timeout')
  GlobalSignal.listen('teleport', self, '_on_Teleport')


func _physics_process(_delta):
  if not is_suspended:
    Parent.motion.y += GRAVITY
  else:
    Parent.motion.y = 0
  
  # Prevent falling too fast
  if Parent.motion.y > MAX_GRAVITY:
    Parent.motion.y = MAX_GRAVITY

  # Air check
  is_in_air = !Parent.is_on_floor()
  
  # Reset jump
  if not is_jumping and Parent.is_on_floor() and current_jump_height > 0:
    current_jump_height = 0
    jump_acceleration = (MAX_JUMP_HEIGHT / 20.0) + GRAVITY

  # Friction
  # friction = true
  Parent.motion.x = lerp(Parent.motion.x, 0, 0.1)

  # Face direction
  calculate_direction()


func _on_Suspension_timer_timeout():
  is_suspended = false


func _on_Teleport():
  suspend(SUSPENSION_TIME)


func calculate_direction():
  var mouse_position = Parent.get_local_mouse_position()
  if sign(Vector2(0, 0).direction_to(mouse_position).x) < 0:
    direction = Vector2(-1, 0)
  else:
    direction = Vector2(1, 0)


func init_connections(controller):
  Controller = controller
  Controller.connect('ui_left', self, 'move_left')
  Controller.connect('ui_right', self, 'move_right')
  Controller.connect('ui_up', self, 'move_up')
  Controller.connect('stop_jump', self, 'stop_jump')
  Controller.connect('start_run', self, 'start_run')
  Controller.connect('stop_run', self, 'stop_run')


func move_left():
  var acceleration = ACCELERATION if not is_running else RUN_ACCELERATION
  var max_speed = MAX_SPEED if not is_running else RUN_MAX_SPEED
  Parent.motion.x = max(Parent.motion.x - acceleration, -max_speed)
  # direction = Vector2(-1, 0)


func move_right():
  var acceleration = ACCELERATION if not is_running else RUN_ACCELERATION
  var max_speed = MAX_SPEED if not is_running else RUN_MAX_SPEED
  Parent.motion.x = min(Parent.motion.x + acceleration, max_speed)
  # direction = Vector2(1, 0)


func move_up():
  jump()


func stop_jump():
  is_jumping = false


func start_run():
  is_running = true


func stop_run():
  is_running = false


func jump():
  if not is_jumping:
    if not is_in_air:
      is_jumping = true
      emit_signal('play_sound', 'TempJump')
    else:
      Parent.motion.y += 10
      return
  elif is_jumping and not is_in_air:
    return
    
  var max_jump_height = MAX_JUMP_HEIGHT if not is_running else RUN_MAX_JUMP_HEIGHT
  if -current_jump_height > -max_jump_height: # and Parent.motion.y != MAX_JUMP_HEIGHT:
    jump_acceleration += JUMP_ACCELERATION
    current_jump_height += jump_acceleration
    if current_jump_height > max_jump_height:
      current_jump_height = max_jump_height
    Parent.motion.y = -current_jump_height
  else:
    Parent.motion.y += 10


func suspend(time):
  is_suspended = true
  SuspensionTimer.start(time)