extends KinematicBody2D

const UP = Vector2(0, -1)
var motion = Vector2(0, 0)


# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.


func _physics_process(_delta):
  # print('MOTION ', motion)
  motion = move_and_slide(motion, UP)
