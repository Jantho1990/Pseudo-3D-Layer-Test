extends Camera

class_name DollyCamera3D

export(NodePath) var focal_point # If set, this is what the camera will look at as it is moved along the dolly.

var path_follow_node setget set_path_follow_node # This will be set by the dolly track to be the PathFollow node this camera gets assigned to.


func _ready():
  if focal_point:
    focal_point = get_node(focal_point)


# Rotate the camera to look at a point by rotating the parent PathFollow.
func focus_on_focal_point():
  path_follow_node.look_at(focal_point.global_transform.origin, Vector3.UP)
  GlobalSignal.dispatch('debug_label1', { 'text': path_follow_node.rotation_degrees })
  GlobalSignal.dispatch('debug_label2', { 'text': focal_point.global_transform.origin })


func set_path_follow_node(value : PathFollow):
  path_follow_node = value
  translation = Vector3(0, 0, 0) # Unsets any translation which was done in the editor, since we want it to match the PathFollow.
  
  # Make the PathFollow's rotation equal camera rotation, while resetting camera's rotation to zero.
  # This preserves rotation for regular dolly movement while allowing for focal point methods to work properly.
  var camera_rotation = rotation
  rotation = Vector3(0, 0, 0)
  path_follow_node.rotation = camera_rotation
