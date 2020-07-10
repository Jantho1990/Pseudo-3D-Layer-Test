extends KinematicBody2D


signal attack
signal attack_stop
signal idle
signal melee_attack_start
signal melee_attack_stop
signal move_left
signal move_right
signal change_speed


const UP = Vector2(0, -1)
var direction = Vector2(1, 0)
var motion = Vector2(0, 0)

var damage = 1

var dead = false

var target = null

onready var Animator = $Sprites/Animator
onready var Attack = $AttackAnimation
onready var Health = $Health
onready var Locomotor = $GroundLocomotor
onready var MeleeSensor = $MeleeSensor
onready var Patrol = $Patrol
onready var State = $State
onready var Sprites = $Sprites
onready var TargetSensor = $TargetSensor
onready var Weapon = $DaggerAttack


# Called when the node enters the scene tree for the first time.
func _ready():
  Health.connect('dead', self, '_on_Dead')
  MeleeSensor.connect('melee_range_entered', self, '_on_Melee_range_entered')
  MeleeSensor.connect('melee_range_exited', self, '_on_Melee_range_exited')
  TargetSensor.connect('target_acquired', self, '_on_Target_acquired')
  TargetSensor.connect('target_lost', self, '_on_Target_lost')
  Locomotor.init_connections(self)
  Sprites.init_connections(self)
  Patrol.set_new_patrol()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
  Weapon.position = Vector2(abs(Weapon.position.x), abs(Weapon.position.y)) * direction
  motion = move_and_slide(motion, UP)
  direction = Locomotor.direction

  process_state()


func _on_Dead():
  dead = true
  queue_free()


func _on_Decoy_destroyed():
  target_lost()


func _on_Melee_range_entered():
  if State.current != 'attack':
    State.push('attack')


func _on_Melee_range_exited():
  if State.current == 'attack':
    State.pop()
    emit_signal('attack_stop')


func _on_Target_acquired(melee_target):
  target_acquired(melee_target)


func _on_Target_lost():
  target_lost()


func process_state():
  match State.current:
    'idle': process_state_idle()
    'patrol': process_state_patrol()
    'pursue': process_state_pursue()
    'attack': process_state_attack()


func process_state_attack():
  # GlobalSignal.dispatch('debug_label2', { 'text': 'ATTACK' })
  # Animator.play('attack')
  emit_signal('attack')


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
  
  Patrol.face_patrol_point(self)

  if shouldResumePatrol:
    Patrol.enable_patrol_check()
  
  if atPatrolPoint:
    Patrol.advance_to_next_patrol_point()
    Patrol.disable_patrol_check()
    # if math.randOneIn(5):
    #   State.pop()
  
  # Dispatch my signal
  move()


func process_state_pursue():
  face_target()
  move()


###
# OTHER METHODS
###


func decoy_detected(decoy):
  target_acquired(decoy)


func face_target():
  if !target or !is_instance_valid(target):
    return
  
  var rad = PI / 2
  var angle = get_angle_to(target.position)
  
  # Direction x
  if abs(angle) >= rad: # If true it means target to the left.
    direction.x = -1
  else: # Means target is to the right.
    direction.x = 1


func hit_adjacent_entities():
  var collisions = get_slide_count()
  for i in collisions:
    var collision = get_slide_collision(i)
    if collision.collider.has_node('Health'):
      collision.collider.get_node('Health').hurt(damage)


func move():
  match int(direction.x):
    -1: emit_signal('move_left')
    1: emit_signal('move_right')
    _: emit_signal('idle')


func target_acquired(new_target):
  target = new_target
  if State.current != 'pursue':
    State.push('pursue')
    emit_signal('change_speed', 'run')


func target_lost():
  target = null
  if State.current == 'pursue':
    State.pop()
    emit_signal('change_speed', 'walk')
