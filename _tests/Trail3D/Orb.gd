extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#  pass

func _physics_process(delta):
  # var axis = math.randOneFrom([Vector3(1, 0, 0), Vector3(0, 1, 0), Vector3(0, 0, 1)])
  var axis = Vector3(0, 0, 1)
  rotate_around(
    Vector3(0, 0, 0),
    axis,
    0.01
  )


# Taken from https://godotengine.org/qa/45609/how-you-rotate-spatial-node-around-axis-given-point-in-space
func rotate_around(point, axis, angle):
    var rot = angle + rotation.y
    var tStart = point
    global_translate (-tStart)
    transform = transform.rotated(axis, -rot)
    global_translate (tStart)