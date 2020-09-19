extends Control


# Declare member variables here. Examples:
onready var world_area = get_parent().get_node('TestWorldArea')


# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.


func load_scene(chunk_id):
  if world_area.is_chunk_area_loaded(chunk_id):
    world_area.unload_chunk_area(chunk_id)
  else:
    world_area.load_chunk_area(chunk_id)
