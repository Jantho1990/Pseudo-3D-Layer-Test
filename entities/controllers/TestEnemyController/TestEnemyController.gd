extends Controller


class_name TestEnemyController


signal idle
signal move_left
signal move_right


export(NodePath) var Locomotor

var motion = Vector2(0, 0)

var target = null

onready var Parent = get_parent()
onready var Patrol = $Patrol
onready var State = $State


# Called when the node enters the scene tree for the first time.
func _ready():
  if !Locomotor:
    print('No Locomotor for ', self.get_class(), ' in ', Parent.get_class())
  else:
    Locomotor = get_node(Locomotor)
    Locomotor.init_connections(self)
  
  Patrol.set_new_patrol()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
  match State.current:
    'idle': process_state_idle()
    'patrol': process_state_patrol()
    'pursue': process_state_pursue()
  
  # GlobalSignal.dispatch('debug_label', { 'text': String(State.current) })
  # GlobalSignal.dispatch('debug_label', { 'text': String(Patrol.patrol_points[0]) })
  # GlobalSignal.dispatch('debug_label2', { 'text': Parent.position })


func _on_Decoy_destroyed():
  target = null
  State.pop()


func decoy_detected(decoy):
  target = decoy
  State.push('pursue')


func process_state_idle():
  emit_signal('idle')


func process_state_patrol():
  # Get info I need to make decisions
  var shouldResumePatrol = !Patrol.check_patrol and Patrol.check_patrol_timer.is_stopped()
  var hasNoPatrolPoints = Patrol.patrol_points.size() == 0
  var atPatrolPoint = Patrol.at_patrol_point()

  # Determine if I can act

  # Do my action in this state
  if hasNoPatrolPoints:
    Patrol.set_new_patrol()
  
  Patrol.face_patrol_point(Parent)

  if shouldResumePatrol:
    Patrol.enable_patrol_check()
  
  if atPatrolPoint:
    Patrol.advance_to_next_patrol_point()
    Patrol.disable_patrol_check()
    # if math.randOneIn(5):
    #   State.pop()
  
  # Dispatch my signal
  move()
    
  # GlobalSignal.dispatch('debug_label2', { 'text': Parent.direction })
  
  # Decide if I need to do something else


func process_state_pursue():
  face_target()
  move()


func face_target():
  if !target or !is_instance_valid(target):
    return
  
  var rad = PI / 2
  var angle = Parent.get_angle_to(target.position)
  
  # Direction x
  if abs(angle) >= rad: # If true it means target to the left.
    Parent.direction.x = -1
  else: # Means target is to the right.
    Parent.direction.x = 1


func move():
  match int(Parent.direction.x):
    -1: emit_signal('move_left')
    1: emit_signal('move_right')
    _:
      print('No direction: ', Parent.direction)
