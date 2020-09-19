extends Resource

export(Dictionary) var chunk_areas = {}


func get_formatted_chunk_area(chunk_node):
  var packed_scene = PackedScene.new()
  var result = packed_scene.pack(chunk_node)
  if result == OK:
    return {
      'chunk_area': packed_scene,
      'chunk_id': chunk_node.chunk_id,
      'is_loaded': false
    }
  return null


# Saves a chunk area.
func save_chunk_area(new_chunk_area : Node):
  if chunk_areas.has(new_chunk_area.chunk_id):
    chunk_areas[new_chunk_area.chunk_id] = get_formatted_chunk_area(new_chunk_area)
  else:
    chunk_areas[new_chunk_area.chunk_id] = (get_formatted_chunk_area(new_chunk_area))


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
      ret.push_back({
        'chunk_area': chunk_area.chunk_area,
        'chunk_id': chunk_area.chunk_id,
        'is_loaded': false
      })
  
  return ret
