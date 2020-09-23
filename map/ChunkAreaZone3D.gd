extends Area

class_name ChunkAreaZone3D

signal chunk_area_zone_entered
signal chunk_area_zone_exited


func _ready():
  # connect_area_signals()
  pass


func connect_area_signals():
  connect('area_entered', self, '_on_Area_entered')
  connect('area_exited', self, '_on_Area_exited')


func _on_Area_entered(area : Area):
  if area is ChunkAreaDetector3D:
    emit_signal('chunk_area_zone_entered')


func _on_Area_exited(area: Area):
  if area is ChunkAreaDetector3D:
    emit_signal('chunk_area_zone_exited')
