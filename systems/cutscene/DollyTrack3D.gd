extends Path

class_name DollyTrack3D # This is used to provide a path for DollyCameras to follow. You can create a path similarly to how a normal Path node works.

signal dolly_movement

const DOLLY_FORWARD = 0
const DOLLY_REVERSE = 1

enum dolly_directions {
  DOLLY_FORWARD,
  DOLLY_REVERSE
}

export(bool) var dolly_active = false setget set_dolly_active # This controls whether the dolly should be moving.
export(dolly_directions) var dolly_direction = DOLLY_FORWARD setget set_dolly_direction # Whether the dolly should move backwards or forwards.
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

  # Set the dolly up for use.
  reset_dolly()


func _physics_process(delta):
  if dolly_active:
    var move_speed = dolly_speed * delta
    advance_dolly_along_track(move_speed)


func advance_dolly_along_track(speed):
  var dolly_sign
  match dolly_direction:
    DOLLY_FORWARD: dolly_sign = 1
    DOLLY_REVERSE: dolly_sign = -1
  
  path_follow_node.offset += speed * dolly_sign
  GlobalSignal.dispatch('debug_label1', { 'text': path_follow_node.offset })
  GlobalSignal.dispatch('debug_label2', { 'text': speed * dolly_sign })
  
  if dolly_reached_end_of_track() and not dolly_repeat:
    dolly_active = false

  emit_signal('dolly_movement', {
    'track_position': path_follow_node.offset, # The position of the dolly along the track.
    'dolly_direction': dolly_direction, # Which direction the dolly is moving.
    'relative_position': path_follow_node.unit_offset # Relative position along the track, from 0-1
  })


func dolly_reached_end_of_track():
  match dolly_direction:
    DOLLY_FORWARD: return path_follow_node.offset == curve.get_baked_length()
    DOLLY_REVERSE: return path_follow_node.offset == 0


func get_track_length():
  return curve.get_baked_length()


func reset_dolly():
  print('reset')
  match dolly_direction:
    DOLLY_FORWARD:
      path_follow_node.offset = 0
      print('forward')
    DOLLY_REVERSE: path_follow_node.offset = curve.get_baked_length()


func set_dolly_active(value : bool):
  dolly_active = value
  if dolly_reached_end_of_track():
    reset_dolly()


func set_dolly_direction(value):
  match value:
    DOLLY_FORWARD, DOLLY_REVERSE: dolly_direction = value
  
  if dolly_reached_end_of_track():
    reset_dolly()
