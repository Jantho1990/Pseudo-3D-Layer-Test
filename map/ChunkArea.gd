extends Spatial

class_name ChunkArea


var chunk_id

onready var zone = Area.new()
onready var parent = get_parent()
onready var packed_state_saver = PackedStateSaver.new()

# Called when the node enters the scene tree for the first time.
func _ready():
  # yield(parent, 'ready')
  # print(self, 'was owned by', owner)
  owner = get_parent()
  # print(self, 'now owned by', owner)
  acquire_ownership_of_children(self)
  add_child(packed_state_saver)
  packed_state_saver = get_node(packed_state_saver.name)
  packed_state_saver.parent_properties = ['chunk_id']
  packed_state_saver.owner = self
  print('MY KIDS ', get_children())


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#  pass


# Gives control of every child node which isn't part of another scene to this ChunkArea.
func acquire_ownership_of_children(node):
  for child in node.get_children():
    # print(child.name, ' owned by ', child.owner.name)
    if child.owner != self and child.owner == parent.get_owner():
      child.owner = self
    elif child.owner == parent.get_owner():
      child.owner = child.get_parent()
    # else:
    #   print(child.name, ' is derped by ', child.owner.name)
      # return
    
    if child.get_children().size() > 0:
      acquire_ownership_of_children(child)


func get_serialized_chunk():
  return get_property_list()


func unload_chunk_area():
  queue_free()
