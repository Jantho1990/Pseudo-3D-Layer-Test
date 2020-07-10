extends Node2D


var direction = Vector2(0, 0)
var moving = false

var Controller

onready var Parent = get_parent()
onready var Animator = $Animator


func _physics_process(delta):
  calculate_direction()
  if moving:
    Animator.play('fly')
  else:
    Animator.play('idle')


func init_connections(controller):
  Controller = controller
  Controller.connect('move_entity', self, 'fly')


func calculate_direction():
  direction = Parent.direction


func idle():
  moving = false


func fly(_a, _b):
  moving = true
