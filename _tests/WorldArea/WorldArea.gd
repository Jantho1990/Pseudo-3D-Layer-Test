extends Spatial

class_name WorldArea


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
  # Must only have ChunkArea nodes as children.
  for child in get_children():
    if not child is ChunkArea:
      push_error('Child of WorldArea "' + name + '" is not a ChunkArea (' + child.name + ')')
      return


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#  pass
