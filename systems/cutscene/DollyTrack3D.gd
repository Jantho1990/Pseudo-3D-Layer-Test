extends Path

class_name DollyTrack3D # This is used to provide a path for DollyCameras to follow. You can create a path similarly to how a normal Path node works.

export(bool) var dolly_active = false # This controls whether the dolly should be moving.
export(bool) var dolly_repeat = false # If set to true, then the dolly movement will restart from zero after reaching the end.
export(float) var dolly_speed = 1.0 # How fast the dolly moves along the track.

onready var path_follow_node = PathFollow.new()

func _ready():
  if not dolly_repeat: path_follow_node.loop = false
  add_child(path_follow_node)

  # For ease of understanding, we make DollyCameras direct children of the track.
  # This will properly place them as children of the PathFollow node.
  for child in get_children():
    if child is DollyCamera3D:
      remove_child(child)
      path_follow_node.add_child(child)


func _physics_process(delta):
  if dolly_active:
    var move_speed = dolly_speed * delta
    advance_dolly_along_track(move_speed)


func advance_dolly_along_track(speed):
  path_follow_node.offset += speed
  if path_follow_node.offset == curve.get_baked_length() and not dolly_repeat:
    dolly_active = false
