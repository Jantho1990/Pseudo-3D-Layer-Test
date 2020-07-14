extends Camera


# Declare member variables here. Examples:
var speed = 0.1
var rotation_y = 0.1


# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#  pass

func _unhandled_input(event):
  if Input.is_action_pressed('ui_up'):
    translation.y -= speed
  if Input.is_action_pressed('ui_down'):
    translation.y += speed
  if Input.is_action_pressed('ui_left'):
    translation.x -= speed
  if Input.is_action_pressed('ui_right'):
    translation.x += speed
  if Input.is_action_pressed('rotate_left'):
    rotation.y -= rotation_y
  if Input.is_action_pressed('rotate_right'):
    rotation.y += rotation_y