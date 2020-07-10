extends Node2D


var dead = false
var direction = Vector2(0, 0)
var moving = false
var running = false
var jump_starting = false
var jump_landing = false

var Controller

onready var Parent = get_parent()
onready var Animator = $Animator


func _physics_process(delta):
  if dead:
    return
  
  calculate_direction()
  if moving and running:
    Animator.play('run')
  elif moving:
    Animator.play('walk')
  else:
    Animator.play('idle')


func init_connections(controller):
  Controller = controller
  Controller.connect('ui_left', self, 'move_left')
  Controller.connect('ui_right', self, 'move_right')
  Controller.connect('ui_up', self, 'move_up')
  Controller.connect('ui_idle', self, 'idle')
  Controller.connect('start_run', self, 'start_run')
  Controller.connect('stop_run', self, 'stop_run')
  Controller.connect('dead', self, 'parent_dead')


func calculate_direction():
  var mouse_position = Parent.get_local_mouse_position()
  if sign(Vector2(0, 0).direction_to(mouse_position).x) < 0:
    direction = Vector2(-1, 0)
  else:
    direction = Vector2(1, 0)


func idle():
  moving = false


func move_left():
  if not moving:
    moving = true
  # Animator.play('walk')


func move_right():
  if not moving:
    moving = true
  # Animator.play('walk')


func move_up():
  pass


func parent_dead():
  dead = true
  Animator.play('dead')


func start_run():
  if not running:
    running = true

    
func stop_run():
  running = false
