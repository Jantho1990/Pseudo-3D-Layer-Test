extends MeshInstance


onready var viewport_path = mesh.material.albedo_texture.viewport_path


# Called when the node enters the scene tree for the first time.
func _ready():
  var t1 = mesh
  var t2 = t1.material
  var t3 = t2.albedo_texture
  var t4 = t3.viewport_path


func _unhandled_input(event):
  owner.get_node(viewport_path).input(event)
