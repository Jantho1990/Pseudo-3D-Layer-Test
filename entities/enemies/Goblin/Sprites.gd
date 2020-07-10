extends Node2D


var attacking = false
var direction = Vector2(0, 0)
var moving = false
var running = false

var Controller

onready var Parent = get_parent()
onready var Animator = $Animator


func _physics_process(delta):
  calculate_direction()
  if attacking:
    Animator.play('attack')
  elif moving and running:
    Animator.play('run')
  elif moving:
    Animator.play('walk')
  else:
    Animator.play('idle')


func init_connections(controller):
  Controller = controller
  Controller.connect('move_left', self, 'move_left')
  Controller.connect('move_right', self, 'move_right')
  Controller.connect('idle', self, 'idle')
  Controller.connect('change_speed', self, 'change_speed')
  Controller.connect('attack', self, 'attack')
  Controller.connect('attack_stop', self, 'attack_stop')


func attack():
  if not attacking:
    attacking = true


func attack_stop():
  attacking = false


func calculate_direction():
  direction = Parent.direction


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


func change_speed():
  if not running:
    running = true
  else:
    running = false
