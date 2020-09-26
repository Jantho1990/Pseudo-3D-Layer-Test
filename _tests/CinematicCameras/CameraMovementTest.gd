extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var camera_rotation
var pf_rotation


# Called when the node enters the scene tree for the first time.
func _ready():
  camera_rotation = $CameraPath/PathFollow/Camera.rotation
  pf_rotation = $CameraPath/PathFollow.rotation


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#  pass

func _physics_process(delta):
  var prev_offset = $CameraPath/PathFollow.offset
  $CameraPath/PathFollow.offset += delta * 1
  if prev_offset > $CameraPath/PathFollow.offset:
    $CameraPath/PathFollow.rotation = pf_rotation
  GlobalSignal.dispatch('debug_label', { 'text': $CameraPath/PathFollow.offset })
  GlobalSignal.dispatch('debug_label2', { 'text': $CameraPath/PathFollow.rotation })