extends Spatial

class_name ChunkArea


var chunk_id

onready var zone = Area.new()
onready var parent = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
  # yield(parent, 'ready')
  # print(self, 'was owned by', owner)
  owner = get_parent()
  # print(self, 'now owned by', owner)
  acquire_ownership_of_children(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#  pass


# Gives control of every child node which isn't part of another scene to this ChunkArea.
func acquire_ownership_of_children(node):
  for child in node.get_children():
    # print(child.name, ' owned by ', child.owner.name)
    if child.owner != self and child.owner == parent.get_owner():
      child.owner = self
    else:
      return
    
    if child.get_children().size() > 0:
      acquire_ownership_of_children(child)


func get_serialized_chunk():
  return get_property_list()


func unload_chunk_area():
  queue_free()
