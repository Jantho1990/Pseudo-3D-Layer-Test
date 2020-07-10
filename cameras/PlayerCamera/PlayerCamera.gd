extends Position2D


export var current = false

var dead = false

onready var Parent = $".."
onready var Camera = $"CameraOffset/Camera2D"


# Called when the node enters the scene tree for the first time.
func _ready():
  update_pivot_angle()
  Parent.connect('dead', self, '_on_Parent_dead')


func _physics_process(_delta):
  if not dead: update_pivot_angle()
  Camera.current = current


func _on_Parent_dead():
  dead = true


func update_pivot_angle():
  rotation = Parent.direction.angle()
