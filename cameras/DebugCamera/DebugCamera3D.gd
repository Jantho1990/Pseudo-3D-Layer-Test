extends Camera

class_name DebugCamera3D


const SPEED_MODIFIER = 0.01 # Help speed values feel more authentic, otherwise 1 = 1 meter per tick

export(float) var speed = 1.0


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.


func _physics_process(delta):
  if Input.is_action_pressed('ui_left'):
    translation.x -= speed * SPEED_MODIFIER
  elif Input.is_action_pressed('ui_right'):
    translation.x += speed * SPEED_MODIFIER
  
  if Input.is_action_pressed('ui_up'):
    translation.z -= speed * SPEED_MODIFIER
  elif Input.is_action_pressed('ui_down'):
    translation.z += speed * SPEED_MODIFIER

  if Input.is_action_pressed('rotate_left'):
    translation.y -= speed * SPEED_MODIFIER
  elif Input.is_action_pressed('rotate_right'):
    translation.y += speed * SPEED_MODIFIER
