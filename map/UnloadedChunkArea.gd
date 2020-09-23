extends Spatial

class_name UnloadedChunkArea


func _ready():
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
