extends Resource

export(Dictionary) var chunk_areas = {}


func get_formatted_chunk_area(chunk_node):
  var packed_scene = PackedScene.new()
  var chunk_id = chunk_node.chunk_id
  var result = packed_scene.pack(chunk_node)
  if result == OK:
    return {
      'chunk_area': packed_scene,
      'chunk_id': chunk_id,
      'is_loaded': false
    }
  return null


# Saves a chunk area.
func save_chunk_area(new_chunk_area : Node):
  trigger_packed_state_savers_pack(new_chunk_area)
  chunk_areas[new_chunk_area.chunk_id] = get_formatted_chunk_area(new_chunk_area)


func save_chunk_areas(new_chunk_areas : Array):
  for new_chunk_area in new_chunk_areas:
    save_chunk_area(new_chunk_area)


func get_chunk_area(target_area_id):
  return get_chunk_areas([target_area_id])[0]


# Get a chunk area, unpacking it in the process.
func get_chunk_areas(target_area_ids : Array):
  var ret = []
  
  for target_area_id in target_area_ids:
    if chunk_areas.has(target_area_id):
      var chunk_area = chunk_areas[target_area_id]
      var chunk_area_node = chunk_area.chunk_area.instance()
      trigger_packed_state_savers_unpack(chunk_area_node)
      ret.push_back({
        'chunk_area': chunk_area_node,
        'chunk_id': chunk_area.chunk_id,
        'is_loaded': false
      })
  
  return ret


func trigger_packed_state_savers_pack(node):
  if node is PackedStateSaver:
    node.pack_parent_properties()
  
  for child in node.get_children():
    trigger_packed_state_savers_pack(child)

  
func trigger_packed_state_savers_unpack(node):
  if node is PackedStateSaver:
    node.unpack_parent_properties()
  
  for child in node.get_children():
    trigger_packed_state_savers_unpack(child)
