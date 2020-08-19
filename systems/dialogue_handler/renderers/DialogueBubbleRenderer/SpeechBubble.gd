extends Spatial


onready var Bubble = $Bubble
onready var TextViewport = $TextViewport


# Called when the node enters the scene tree for the first time.
func _ready():
  pass
  # Bubble.mesh.material.albedo_texture = TextViewport.get_texture()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#  pass
