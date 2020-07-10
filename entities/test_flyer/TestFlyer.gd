extends KinematicBody2D


# Large thanks to GDQuest for example code
# https://github.com/GDQuest/godot-kickstarter-2019/blob/master/youtube-tutorial-demos/01-19-navigation-2d-and-tilemaps/end/Character.gd


export(String) var DBG_NAV_LINE = 'Line2D'
var speed = 200
var direction = Vector2(1, 0)
var motion = Vector2(0, 0)

onready var Navigator = $Navigator
onready var Patrol = $Patrol


# Called when the node enters the scene tree for the first time.
func _ready():
  Patrol.set_new_patrol()
  # Engine.time_scale = 0.025


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#  pass


func _physics_process(delta):
  process_patrol()
  move(delta)
  GlobalSignal.dispatch('debug_label3', { 'text': position })

func process_patrol():
  # Get info I need to make decisions
  var shouldResumePatrol = !Patrol.check_patrol and Patrol.check_patrol_timer.is_stopped()
  var hasNoPatrolPoints = Patrol.patrol_points.size() == 0
  var atPatrolPoint = Patrol.at_patrol_point(true)

  # GlobalSignal.dispatch('debug_label2', { 'text': Patrol.patrol_points })

  # Determine if I can act

  # Do my action in this state
  if hasNoPatrolPoints:
    Patrol.set_new_patrol()
  
  if not Navigator.path:
    Navigator.get_new_path(Patrol.patrol_points[0])
  
  Patrol.face_patrol_point(self)

  if shouldResumePatrol:
    Patrol.enable_patrol_check()
  
  if atPatrolPoint:
    Patrol.advance_to_next_patrol_point()
    Patrol.disable_patrol_check()
    Navigator.get_new_path(Patrol.patrol_points[0])
    # if math.randOneIn(5):
    #   State.pop()


func move(delta):
  var path = Navigator.path
  # GlobalSignal.dispatch('debug_label', { 'text': path })
  var distance = speed * delta
  var target_position
  var last_position : = position
  for index in range(path.size()):
    var distance_to_next = last_position.distance_to(path[0])
    if distance <= distance_to_next and distance >= 0.0:
      # breakpoint
      target_position = last_position.linear_interpolate(path[0], distance / distance_to_next)
      break
    elif path.size() == 1 and distance >= distance_to_next:
      # breakpoint
      target_position = path[0]
      last_position = path[0]
      set_process(false)
      break
      
    distance -= distance_to_next
    target_position = path[0]
    path.remove(0)
  
  # motion = get_motion_to_pos(target_position)
  motion = target_position - last_position
  motion = move_and_slide(motion / delta, Vector2.UP)
  var collision_count = get_slide_count()
  for i in collision_count:
    var collision = get_slide_collision(i)
    if collision:
      pass # We'll deal with this another time, perhaps.
  
  Navigator.path = path

func get_motion_to_pos(pos):
  var tvec = (position + pos).normalized() * speed
  var target_position = global_position + tvec
  var target_position_direction = global_position.direction_to(target_position)
  var ret = target_position_direction * speed
  return ret
