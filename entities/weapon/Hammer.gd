extends KinematicBody2D

signal hammer_rotation

const UP = Vector2(0, -1)
const MELEE_RETURN_TIME = 0.05
const THROW_RETURN_TIME = 0.2
const GRAVITY = 20

enum throw_state {
  HOLDING,
  THROWING,
  SUSPENDING,
  RETURNING,
  MELEE
}

# Weapon damage
var throw_damage = 1.0
var melee_damage = 2.0
var charged_melee_damage = 3.0

# Throw state
var current_throw_state = throw_state.HOLDING setget set_throw_state
var next_throw_state = -1

var hold_offset = Vector2(-36, -36)
var dir = Vector2(1, 1)

# Hammer throw
var returning = false
var rotating = false
var throwing = false
var throw_held = false
var throw_charging = false
var throw_charge_increment = 25
var min_throw_range = 160
var max_throw_range = 400
var throw_range = min_throw_range
var min_throw_max_speed = 800
var max_throw_max_speed = 1600
var throw_max_speed = min_throw_max_speed
var throw_max_speed_increment = 100
var throw_travel_distance = 0
var return_time = THROW_RETURN_TIME
var thrown_dir = dir
var throw_origin_position = Vector2(0, 0)
var throw_target_position = Vector2(0, 0)
var throw_target_position_direction = Vector2(0, 0)
var cursor_position = Vector2(0, 0)

# Hammer melee
var meleeing = false
var melee_charging = false
var melee_min_force = 50
var melee_max_force = 500
var melee_force_delta = 10
var melee_force = melee_min_force
var melee_held = false
var melee_range = 150
var melee_max_speed = 3200
var melee_charge_delay = 0.15
var charge_delay_active = false

var motion = Vector2(0, 0)

var rotation_force_deg = 60
var __delta

var parent_dead = false

onready var parent = get_parent()
onready var throwTween = $ThrowTween
onready var MeleeChargeDelay = $MeleeChargeDelay
onready var Sounds = $Sounds

# Called when the node enters the scene tree for the first time.
func _ready():
  GlobalSignal.listen('teleport', self, '_on_Teleport')
  GlobalSignal.listen('build_unit', self, '_on_Build_unit')
  parent.connect('dead', self, '_on_Parent_dead')
  MeleeChargeDelay.connect('timeout', self, '_on_Melee_charge_delay_timeout')


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
  if parent_dead:
    motion.y += GRAVITY
    motion = move_and_slide(motion, Vector2.UP)
    return
  
  __delta = delta
  dir = parent.direction
  if dir.y <= 0:
    dir.y = 1
  cursor_position = get_local_mouse_position()
  
  if rotating:
    rotation_degrees += rotation_force_deg * dir.x
    if not current_throw_state == throw_state.HOLDING:
      Sounds.get_node('HammerSpin').play()

  calculate_throw_state()
  match current_throw_state:
    throw_state.THROWING:
      handle_throw_state_throwing()
    throw_state.SUSPENDING:
      handle_throw_state_suspending()
    throw_state.RETURNING:
      handle_throw_state_returning()
    throw_state.MELEE:
      handle_throw_state_melee()
    throw_state.HOLDING, _:
     handle_throw_state_holding()

# Response if parent dies.
func _on_Parent_dead():
  parent_dead = true

# Calculates if the current throw state should be changed.
func calculate_throw_state():
  if Input.is_action_just_pressed('weapon_throw') and \
    current_throw_state == throw_state.HOLDING:
      current_throw_state = throw_state.THROWING
  elif Input.is_action_pressed('weapon_melee') and \
    current_throw_state == throw_state.HOLDING:
      current_throw_state = throw_state.MELEE
  elif (collision_detected() or throw_travel_distance >= throw_range) and \
    current_throw_state == throw_state.THROWING:
      if collision_detected():
        current_throw_state = throw_state.RETURNING
        hit_enemies(throw_damage)
      else:
        current_throw_state = throw_state.SUSPENDING
  elif next_throw_state != -1:
    current_throw_state = next_throw_state
    next_throw_state = -1

func get_spellcaster():
  return get_parent()

func _on_Build_unit(_data):
  next_throw_state = throw_state.SUSPENDING

func _on_Teleport():
  if current_throw_state != throw_state.HOLDING:
    Sounds.get_node('HammerTeleport').play()
    parent.motion = Vector2(0, 0)
    GlobalSignal.dispatch('hammer_returned', { 'hammer': self })
    $ThrowTween.stop_all()
    $ThrowTween.reset_all()
    _on_Tween_returning_stop()

func handle_throw_state_holding():
  if rotation != 0:
    rotation = 0
  update_position()

func handle_throw_state_throwing():
  rotating = true
  
  if not throwing and not meleeing:
    return_time = THROW_RETURN_TIME
    throw_weapon()
  else:
    update_thrown_weapon()
    
  charge_throw()

func handle_throw_state_suspending():
  tween_suspend()

func handle_throw_state_returning():
  tween_return()

func handle_throw_state_melee():
  if !meleeing:
    meleeing = true
    return_time = MELEE_RETURN_TIME
    start_melee_charge_delay()
  
  # If this is the first frame in this state, defer to next frame
  # so we can detect if hammer is being charged.
  if Input.is_action_just_pressed('weapon_melee'):
    update_position()
    return
  
  if Input.is_action_pressed('weapon_melee'):
    melee_held = true
  elif Input.is_action_just_released('weapon_melee'):
    melee_held = false

  var charging = melee_held and \
    !charge_delay_active and \
    !throwing

  if collision_detected() or throw_travel_distance >= melee_range:
    next_throw_state = throw_state.RETURNING
    if collision_detected():
      if charging:
        hit_enemies(charged_melee_damage)
      else:
        hit_enemies(melee_damage)
  
  if (not charging and not melee_held) or Input.is_action_just_released('weapon_melee'):
    print('NORMAL MELEE')
    melee_normal()
  elif charging:
    print('CHARGING: ', charging)
    print('WEAPON PRESSED: ', Input.is_action_pressed('weapon_melee'))
    print('WEAPON JUST PRESSED: ', Input.is_action_just_pressed('weapon_melee'))
    print('CHARGE DELAY: ', charge_delay_active)
    print('THROWING: ', throwing)
    # breakpoint
    melee_charged()
    pass
  
  GlobalSignal.dispatch('debug_label2', { 'text': throw_travel_distance })

func throw_weapon():
  throwing = true
  throw_origin_position = global_position
  thrown_dir = dir# * Vector2(-1, 1) # correct the x direction since dir is inverted
  throw_target_position.rotated(throw_target_position.angle() - throw_target_position.angle())
  $Sprite.rotation = 0
  # throw_target_position = (global_position + (Vector2(throw_range, 0) * thrown_dir)).rotated(global_position.angle_to_point(cursor_position))
  # var tvec = (position + cursor_position).normalized() * throw_range # * thrown_dir
  # throw_target_position = global_position + tvec
  # GlobalSignal.dispatch('debug_label', { 'text': String(tvec) + ' ' + String(cursor_position) + ' ' + String(thrown_dir) })
  calculate_throw_target('throw')
  release_weapon()
  calculate_motion()
  motion = move_and_slide(motion, UP)
  
func update_thrown_weapon():
  calculate_motion()
  motion = move_and_slide(motion, UP)

func charge_throw():
  if Input.is_action_pressed('weapon_throw') and throw_range != max_throw_range:
    throw_charging = true
  elif Input.is_action_just_released('weapon_throw'):
    throw_charging = false
    
  # GlobalSignal.dispatch('debug_label', { 'text': throw_travel_distance })
  if throw_charging:
    if throw_range < max_throw_range:
      throw_range = min((throw_charge_increment + throw_range), max_throw_range)
      throw_max_speed = min((throw_max_speed_increment + throw_max_speed), max_throw_max_speed)
      # GlobalSignal.dispatch('debug_label2', { 'text': throw_range })
    else:
      throw_charging = false

func release_weapon():
  GlobalSignal.dispatch('hammer_thrown', { 'hammer': self })

func calculate_throw_target(throw_type = 'throw'):
  var distance
  match throw_type:
    'throw': distance = throw_range
    'melee':   distance = melee_range
  
  var tvec = (position + cursor_position).normalized() * distance
  throw_target_position = global_position + tvec
  throw_target_position_direction = global_position.direction_to(throw_target_position)

func calculate_motion(throw_type = 'throw'):
  var distance_range
  match throw_type:
    'throw': distance_range = throw_range
    'melee':   distance_range = melee_range
  var max_speed = melee_max_speed if meleeing else throw_max_speed
  motion = throw_target_position_direction * max_speed
  throw_travel_distance = min(throw_travel_distance + (max_speed * __delta), distance_range)

func collision_detected():
  return get_slide_count() > 0

func hit_enemies(damage):
  for i in get_slide_count():
    # breakpoint
    var collision = get_slide_collision(i)
    # breakpoint
    if 'Health' in collision.collider:
      collision.collider.Health.hurt(damage)

func return_weapon():
  calculate_motion()
  motion = move_and_slide(motion, UP)

func calculate_return_motion():
  motion = (Vector2(throw_max_speed, 0) * thrown_dir).rotated(global_position.angle_to(parent.position))
  throw_travel_distance = min(throw_travel_distance + (throw_max_speed * __delta), throw_range)

func tween_suspend():
  if not $ThrowTween.is_active():
    $ThrowTween.interpolate_callback(self, 0.2, '_on_Tween_suspending_stop')
    $ThrowTween.start()

func tween_return():
  if not returning:
    returning = true
    # GlobalSignal.dispatch('debug_label2', { 'text': 'fish' })
    # breakpoint
    var offset_position = Vector2(0, 0) + (global_position - parent.global_position)
    GlobalSignal.dispatch('hammer_returned', { 'hammer': self })
    # breakpoint
    # var start = position
    # var start = global_position
    var start = offset_position
    var destination = hold_offset * dir
    # var destination = parent.position
    # var destination = parent.global_position
    $ThrowTween.interpolate_property(self, 'position', start, destination, return_time)
    # $ThrowTween.interpolate_property(self, 'global_position', start, destination, return_time)
    $ThrowTween.interpolate_callback(self, return_time, '_on_Tween_returning_stop')
    $ThrowTween.start()

func _on_Tween_throwing_stop():
  next_throw_state = throw_state.SUSPENDING

func _on_Tween_suspending_stop():
  next_throw_state = throw_state.RETURNING

func _on_Tween_returning_stop():
  Sounds.get_node('HammerCatch').play()
  Sounds.get_node('HammerSpin').stop()
  next_throw_state = throw_state.HOLDING
  throwing = false
  meleeing = false
  returning = false
  rotating = false
  motion = Vector2(0, 0)
  melee_force = melee_min_force
  throw_travel_distance = 0
  throw_range = min_throw_range
  throw_max_speed = min_throw_max_speed
  update_position()
  stop_melee_charge_delay()
  print('STOPPED')

func update_position():
  position = hold_offset * dir
  position.y += sin(global.run_time / 0.15) * 4
  $Sprite.rotation = position.angle_to_point(cursor_position) - deg2rad(90)

func set_throw_state(value):
  if throw_state.has(value):
    current_throw_state = throw_state[value]

func melee_normal():  
  if not throwing:
    throwing = true
    # melee_held = true
    # meleeing = true
    calculate_throw_target('melee')
    release_weapon()
    calculate_motion('melee')
    # start_melee_charge_delay()
  elif throwing:
    # update_thrown_weapon()
    calculate_motion('melee')
    motion = move_and_slide(motion, UP)

func melee_charged():
  if melee_held:
    position = (hold_offset + Vector2(-12, 0)) * dir
    position.y += sin(global.run_time / 0.025) * 4
    position.x += cos(global.run_time / 0.025) * 2
    $Sprite.rotation = position.angle_to_point(cursor_position) - deg2rad(90)
    if melee_force < melee_max_force:
      melee_force += melee_force_delta
    else:
      melee_force = melee_max_force

func start_melee_charge_delay():
  MeleeChargeDelay.start(melee_charge_delay)
  charge_delay_active = true

func stop_melee_charge_delay():
  MeleeChargeDelay.stop()
  charge_delay_active = false

func _on_Melee_charge_delay_timeout():
  charge_delay_active = false
