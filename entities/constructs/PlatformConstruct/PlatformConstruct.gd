extends Construct

class_name PlatformConstruct

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
  $AnimationPlayer.play('idle')

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
  # position.y += sin(global.run_time / 0.1) * 0.35
  pass
