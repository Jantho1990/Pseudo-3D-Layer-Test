extends Spatial

class_name WorldArea


var chunk_areas = []


# Called when the node enters the scene tree for the first time.
func _ready():
  # Put all the chunk areas into an array.
  for child in get_children():
    if child is ChunkArea:
      chunk_areas.push_back(child)
    else:
      # Must only have ChunkArea nodes as children.
      push_error('Child of WorldArea "' + name + '" is not a ChunkArea (' + child.name + ')')


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#  pass
