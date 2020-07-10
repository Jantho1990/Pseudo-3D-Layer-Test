extends KinematicBody2D


# Large thanks to GDQuest for example code
# https://github.com/GDQuest/godot-kickstarter-2019/blob/master/youtube-tutorial-demos/01-19-navigation-2d-and-tilemaps/end/Character.gd

signal move_entity


export(String) var DBG_NAV_LINE = 'Line2D'
var direction = Vector2(1, 0)
var motion = Vector2(0, 0)

var target = null
var dead = false

onready var Health = $Health
onready var Locomotor = $AirLocomotor
onready var MeleeSensor = $MeleeSensor
onready var Navigator = $Navigator
onready var Patrol = $Patrol
onready var PursuePathTimer = $PursuePathTimer
onready var Sprites = $Sprites
onready var State = $State
onready var TargetSensor = $TargetSensor


# Called when the node enters the scene tree for the first time.
func _ready():
  Health.connect('dead', self, '_on_Dead')
  Locomotor.connect('target_reached', Navigator, 'pop_path')
  MeleeSensor.connect('melee_range_entered', self, '_on_Melee_range_entered')
  MeleeSensor.connect('melee_range_exited', self, '_on_Melee_range_exited')
  TargetSensor.connect('target_acquired', self, '_on_Target_acquired')
  TargetSensor.connect('target_lost', self, '_on_Target_lost')
  PursuePathTimer.connect('timeout', self, '_on_Pursue_Path_Timer_timeout')
  Sprites.init_connections(self)
  Patrol.set_new_patrol()
  # Engine.time_scale = 0.025


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#  pass


func _physics_process(delta):
  match State.current:
    'patrol':
      process_state_patrol(delta)
    'pursue':
      process_state_pursue(delta)
  
  calculate_direction()
  # GlobalSignal.dispatch('debug_label3', { 'text': position })


func _on_Dead():
  dead = true
  queue_free()


func _on_Melee_range_entered():
  if State.current != 'attack':
    State.push('attack')


func _on_Melee_range_exited():
  if State.current == 'attack':
    State.pop()


func _on_Pursue_Path_Timer_timeout():
  if State.current == 'pursue':
    Navigator.get_new_path(target.position)


func _on_Target_acquired(melee_target):
  target_acquired(melee_target)


func _on_Target_lost():
  target_lost()


func process_state_patrol(delta):
  process_patrol()
  move(delta)


func process_state_pursue(delta):
  if target and not Navigator.path:
    Navigator.get_new_path(target.position)
    PursuePathTimer.start(0.5)
  
  move(delta)


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
  # Don't do anything if there's no path.
  if Navigator.path.empty(): return
  
  emit_signal('move_entity', Navigator.path[0], delta)
  # breakpoint
  var collision_count = get_slide_count()
  for i in collision_count:
    var collision = get_slide_collision(i)
    if collision:
      pass # We'll deal with this another time, perhaps.


func calculate_direction():
  direction = Vector2(sign(motion.x), sign(motion.y))


func target_acquired(new_target):
  target = new_target
  if State.current != 'pursue':
    State.push('pursue')
    Navigator.clear_path()
    emit_signal('change_speed', 'run')


func target_lost():
  target = null
  if State.current == 'pursue':
    State.pop()
    emit_signal('change_speed', 'walk')
