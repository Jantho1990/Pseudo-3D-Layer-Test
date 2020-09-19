extends Spatial


# Declare member variables here. Examples:
var testvar = 0


# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#  pass

func _physics_process(_delta):
  testvar += 1
  if testvar == 360: testvar = 0
  translation.x = sin(deg2rad(testvar)) * 0.35