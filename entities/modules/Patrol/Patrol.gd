extends Node

const PATROL_RADIUS = {
  "maximum": 100,
  "minimum": 100
}

const MIN_PATROL_DISTANCE = 20

var patrol_points = []
export var num_patrol_points = 2

export var detection_radius = 10

# Don't check patrol points while active.
var check_patrol = false
var check_patrol_timer = Timer.new()

# Will be set with _ready
var Parent
var position
var direction


# Called when the node enters the scene tree for the first time.
func _ready():
  Parent = get_parent()
  if Parent is Controller:
    Parent = Parent.get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#  pass

# Cycle to the next patrol point in sequence.
func advance_to_next_patrol_point():
  if patrol_points.size() > 1:
    var previous_point = patrol_points[0]
    patrol_points.pop_front()
    patrol_points.push_back(previous_point)

# Get direction of current patrol point.
func angle_to_patrol_point():
  return Parent.position.get_angle_to(patrol_points[0])
  
# Face direction of current patrol point.
func face_patrol_point(pos : Node2D):
  var rad = PI / 2
  var angle = pos.get_angle_to(patrol_points[0])
  
  # Direction x
  if abs(angle) >= rad: # If true it means target to the left.
    Parent.direction.x = -1
  else: # Means target is to the right.
    Parent.direction.x = 1
    
# Check if at the patrol point.
func at_patrol_point(check_y = false):
  if not check_patrol:
    return false
  
  var point = patrol_points[0]
  var beyond_patrol_point = (abs(Parent.position.x - point.x) < detection_radius)
  if beyond_patrol_point:
    if check_y:
      var beyond_y_patrol_point = (abs(Parent.position.y - point.y) < detection_radius)
      if beyond_y_patrol_point:
        return true
      else:
        return false
    else:
      return true
  return false
  
func disable_patrol_check():
  check_patrol_timer = Timer.new()
  add_child(check_patrol_timer)
  check_patrol_timer.one_shot = true
  check_patrol_timer.start(0.25)
  check_patrol = false

func enable_patrol_check():
  check_patrol = true
  remove_child(check_patrol_timer)

# Get a random patrol radius.
func random_patrol_radius():
  return math.rand(PATROL_RADIUS.minimum, PATROL_RADIUS.maximum)

# Create a new set of patrol points.
func make_patrol_points():
  var new_patrol_points = []
  for _i in range(num_patrol_points):
    var valid
    while not valid:
      valid = true
      var radius = random_patrol_radius()
      var point = Vector2(
        Parent.position.x + math.randOneFrom([radius, -radius]),
        Parent.position.y
      )
      for new_patrol_point in new_patrol_points:
        if point == new_patrol_point:
          # Can't have two identical patrol points, break
          valid = false
          break
        if point.distance_to(new_patrol_point) < MIN_PATROL_DISTANCE:
          valid = false
          break
      if valid:
        new_patrol_points.push_back(point)
    
  return new_patrol_points

func set_new_patrol():
  if has_waypoints(Parent):
    patrol_points = get_waypoints(Parent)
  else:
    patrol_points = make_patrol_points()
  print(patrol_points, " ", Parent.position)

# Detect if a node has Waypoint nodes for children
func has_waypoints(node):
  for child in node.get_children():
    if child is Waypoint:
      return true
  return false

# Get waypoints from a node.
func get_waypoints(node):
  var ret = []
  for child in node.get_children():
    if child is Waypoint:
      ret.push_back(child.global_position)
  return ret
