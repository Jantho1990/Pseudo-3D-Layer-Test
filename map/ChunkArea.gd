extends Spatial

class_name ChunkArea


var chunk_id

onready var zone = Area.new()
onready var parent = get_parent()
onready var packed_state_saver = PackedStateSaver.new()

# Called when the node enters the scene tree for the first time.
func _ready():
  owner = get_parent()
  if not has_packed_state_saver():
    add_child(packed_state_saver)
    packed_state_saver = get_node(packed_state_saver.name)
    packed_state_saver.parent_properties = ['chunk_id']
    packed_state_saver.owner = self
  
  acquire_ownership_of_children(self)
  connect_collision_area_zones()


func _on_Chunk_area_zone_entered():
  print(name, ' loading zone entered')


func _on_Chunk_area_zone_exited():
  print(name, ' loading zone exited')


func connect_collision_area_zones():
  for child in get_children():
    if child is ChunkAreaZone3D:
      child.connect('chunk_area_zone_entered', self, '_on_Chunk_area_zone_entered')
      child.connect('chunk_area_zone_exited', self, '_on_Chunk_area_zone_exited')


func has_packed_state_saver():
  for child in get_children():
    if child is PackedStateSaver:
      return true
  return false


# Gives control of every child node which isn't part of another scene to this ChunkArea.
func acquire_ownership_of_children(node):
  for child in node.get_children():
    if child.owner != self and child.owner == parent.get_owner():
      child.owner = self
    elif child.owner == parent.get_owner():
      child.owner = child.get_parent()
    
    if child.get_children().size() > 0:
      acquire_ownership_of_children(child)


func get_serialized_chunk():
  return get_property_list()


func unload_chunk_area():
  queue_free()
