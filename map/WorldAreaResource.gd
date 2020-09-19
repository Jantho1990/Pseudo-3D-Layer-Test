extends Resource

export(Array) var chunk_areas = []
var chunk_area_ids = []


# Saves a chunk area.
func save_chunk_area(new_chunk_area : Node):
  var ps = PackedScene.new()
  var chunk_exists = false
  for chunk_area in chunk_areas:
    if chunk_area.chunk_id == new_chunk_area.chunk_id:
      chunk_exists = true
      break
  
  if chunk_exists:
      chunk_areas.insert(new_chunk_area.chunk_id, new_chunk_area)
      chunk_areas.remove(new_chunk_area.chunk_id + 1)
  else:
    chunk_areas.push_back({
      'chunk_area': ps.pack(new_chunk_area),
      'chunk_id': new_chunk_area.chunk_id,
      'is_loaded': false
    })


func save_chunk_areas(new_chunk_areas : Array):
  for new_chunk_area in new_chunk_areas:
    save_chunk_area(new_chunk_area)


func get_chunk_area(target_area_id):
  return get_chunk_areas([target_area_id])[0]


# Get a chunk area, unpacking it in the process.
func get_chunk_areas(target_area_ids : Array):
  var ret = []
  for chunk_area in chunk_areas:
    var carara = chunk_area
    print(carara)
    if target_area_ids.has(chunk_area.chunk_id):
      ret.push_back({
      'chunk_area': chunk_area.chunk_area,
      'chunk_id': chunk_area.chunk_id,
      'is_loaded': false
    })
  return ret
