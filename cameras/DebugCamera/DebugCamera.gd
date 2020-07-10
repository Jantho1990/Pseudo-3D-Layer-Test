extends Camera2D


var speed = 20


# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.


func _physics_process(delta):
  if Input.is_action_pressed('ui_left'):
    position.x -= speed
  elif Input.is_action_pressed('ui_right'):
    position.x += speed
  
  if Input.is_action_pressed('ui_up'):
    position.y -= speed
  elif Input.is_action_pressed('ui_down'):
    position.y += speed
