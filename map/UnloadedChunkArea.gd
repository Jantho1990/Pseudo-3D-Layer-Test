extends Spatial

class_name UnloadedChunkArea


var chunk_id : int
var is_chunk_loaded_func : FuncRef
var load_chunk_func : FuncRef
var unload_chunk_func : FuncRef


func _ready():
  connect_collision_area_zones()


func _on_Chunk_area_zone_entered():
  if load_chunk_func and \
    is_chunk_loaded_func and \
    !is_chunk_loaded_func.call_func(chunk_id):
    load_chunk_func.call_func(chunk_id)


func _on_Chunk_area_zone_exited():
  if unload_chunk_func:
    unload_chunk_func.call_func(chunk_id)


func connect_collision_area_zones():
  for child in get_children():
    if child is ChunkAreaZone3D:
      child.connect('chunk_area_zone_entered', self, '_on_Chunk_area_zone_entered')
      child.connect('chunk_area_zone_exited', self, '_on_Chunk_area_zone_exited')
