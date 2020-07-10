extends Node


class_name Navigator


export(float) var offset = 0.0 # This will be used to adjust path points away from nearby surfaces.

var NavigationNode
var path : PoolVector2Array

onready var Parent = get_parent()


func _init():
  GlobalSignal.listen('navigation_node_ready', self, '_on_Navigation_node_ready')


# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#  pass


func get_new_path(target_pos : Vector2):
  path = NavigationNode.get_simple_path(Parent.global_position, target_pos, false)
  # GlobalSignal.dispatch('debug_label2', { 'text': path })
  # breakpoint
  # path = add_path_point_offsets(path)
  # breakpoint
  if NavigationNode.has_node(Parent.DBG_NAV_LINE):
    NavigationNode.get_node(Parent.DBG_NAV_LINE).points = path


# Add Navigator offset to each path so points aren't too close to surfaces.
func add_path_point_offsets(path_points):
  var new_path_points = PoolVector2Array()
  for i in range(path_points.size()):
    var path_point = path_points[i]
    var new_path_point = get_path_point_offset(path_point)
    if path_point != new_path_point:
      breakpoint
      new_path_points.push_back(new_path_point)
    else:
      new_path_points.push_back(path_point)
  return new_path_points


# Clear existing path.
func clear_path():
  path = PoolVector2Array()


# Calculate the offset vector for a path point based on where it collides with the world.
func get_path_point_offset(path_point):
  # The world around the parent entity
  var space_state = Parent.get_world_2d().direct_space_state
  
  for ang in range(0, 360, 45):
    var target_position = Vector2(path_point)
    var origin_position = target_position - Vector2(offset, 0).rotated(rad2deg(ang))
    if origin_position == Vector2(0, 0):
      return path_point
    var ray_result = space_state.intersect_ray(origin_position, target_position, [Parent])

    if ray_result:
      var remaining = offset - ray_result.position.distance_to(target_position)
      var ret = target_position + Vector2(remaining, 0).rotated(rad2deg(ang - 180))
      breakpoint
      return ret
    
  return path_point

func pop_path():
  path.remove(0)
