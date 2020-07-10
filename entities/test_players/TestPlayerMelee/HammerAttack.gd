extends Area2D


signal current_melee_state


enum ATTACK_STATES {
  NONE,
  MELEE,
  THROW
}
var attack_state = ATTACK_STATES.NONE
var next_attack_state = null

enum MELEE_STATES {
  NONE,
  CHARGED,
  CHARGING,
  RELEASE_CHARGED,
  RELEASE_NORMAL,
  RELEASE_RETURN,
  WIND
}
var melee_state = MELEE_STATES.NONE
var next_melee_state = null


###
# MELEE
###

export(int) var melee_damage_throw = 1
export(int) var melee_damage_normal = 2
export(int) var melee_damage_charged = 3

var melee_damage_applied : bool = false
var melee_queued = false
var melee_charge_queued = false

var melee_charge_power_max = 10
var melee_charge_power_min = 0
var melee_charge_power_increment = 1
var melee_charge_power = melee_charge_power_min

var melee_charge_delay_timer = Timer.new()
var melee_charge_delay = 0.15
var melee_charge_delay_active : bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
  connect('body_entered', self, '_on_Body_entered')
  add_child(melee_charge_delay_timer)
  melee_charge_delay_timer.connect('timeout', self, '_on_Melee_charge_delay_timer_timeout')


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#  pass


func _physics_process(_delta):
  calculate_attack_state()
  match attack_state:
    ATTACK_STATES.MELEE: handle_attack_state_melee()
    ATTACK_STATES.THROW: handle_attack_state_throw()


###
# INIT
###

func init_connections(connector):
  connector.connect('melee_just_pressed', self, '_on_Melee_just_pressed')
  connector.connect('melee_pressed', self, '_on_Melee_pressed')
  connector.connect('melee_released', self, '_on_Melee_released')


###
# SIGNAL RESPONSES
###

func _on_Body_entered(body):
  if 'Health' in body and not melee_damage_applied:
    match attack_state:
      ATTACK_STATES.THROW: body.Health.hurt(melee_damage_throw)
      ATTACK_STATES.MELEE:
        match melee_state:
          MELEE_STATES.RELEASE_NORMAL: body.Health.hurt(melee_damage_normal)
          MELEE_STATES.RELEASE_CHARGED: body.Health.hurt(melee_damage_charged)
    melee_damage_applied = true


func _on_Melee_charge_delay_timer_timeout():
  melee_charge_delay_active = false
    

func _on_Melee_swing_end():
  if melee_queued:
    next_melee_state = MELEE_STATES.RELEASE_NORMAL
  elif melee_charge_queued:
    next_melee_state = MELEE_STATES.CHARGING
  else:
    next_melee_state = MELEE_STATES.RELEASE_RETURN
  
  
func _on_Melee_return_end():
  next_melee_state = MELEE_STATES.NONE


func _on_Melee_just_pressed():
  next_attack_state = ATTACK_STATES.MELEE

  if melee_state == MELEE_STATES.RELEASE_CHARGED or melee_state == MELEE_STATES.RELEASE_NORMAL:
    melee_queued = true
  
  if melee_state == MELEE_STATES.NONE or melee_state == MELEE_STATES.RELEASE_RETURN:
    next_melee_state = MELEE_STATES.WIND


func _on_Melee_pressed():
  if melee_state == MELEE_STATES.CHARGED or next_melee_state == MELEE_STATES.CHARGED:
    return
  
  if melee_queued and not melee_charge_delay_active:
    melee_charge_queued = true

  if melee_state != MELEE_STATES.CHARGING and not melee_charge_delay_active:
    next_melee_state = MELEE_STATES.CHARGING


func _on_Melee_released():
  if melee_state == MELEE_STATES.WIND:
    next_melee_state = MELEE_STATES.RELEASE_NORMAL
  elif melee_state == MELEE_STATES.CHARGING or melee_state == MELEE_STATES.CHARGED:
    next_melee_state = MELEE_STATES.RELEASE_CHARGED
  elif melee_state == MELEE_STATES.RELEASE_NORMAL or melee_state == MELEE_STATES.RELEASE_CHARGED:
    melee_queued = false
    melee_charge_queued = false


###
# ATTACK STATES
###

func calculate_attack_state():
  if next_attack_state:
    if next_attack_state != attack_state:
      attack_state = next_attack_state
    
    next_attack_state = null


func handle_attack_state_melee():
  calculate_melee_state()
  match melee_state:
    MELEE_STATES.WIND: handle_melee_state_wind()
    MELEE_STATES.RELEASE_NORMAL: handle_melee_state_release_normal()
    MELEE_STATES.RELEASE_CHARGED: handle_melee_state_release_charged()
    MELEE_STATES.CHARGING: handle_melee_state_charging()
    MELEE_STATES.CHARGED: handle_melee_state_charged()
    MELEE_STATES.RELEASE_RETURN: handle_melee_state_release_return()
    MELEE_STATES.NONE: handle_melee_state_none()


func handle_attack_state_throw():
  pass


###
# MELEE STATES
###

func calculate_melee_state():
  if next_melee_state != null:
    if next_melee_state != melee_state:
      melee_state = next_melee_state
    
    next_melee_state = null
  
  var dbg_text = ''
  match melee_state:
    MELEE_STATES.NONE: dbg_text = 'none'
    MELEE_STATES.WIND: dbg_text = 'wind'
    MELEE_STATES.RELEASE_NORMAL: dbg_text = 'release_normal'
    MELEE_STATES.RELEASE_CHARGED: dbg_text = 'release_charged'
    MELEE_STATES.CHARGING: dbg_text = 'charging'
    MELEE_STATES.CHARGED: dbg_text = 'charged'
    MELEE_STATES.RELEASE_RETURN: dbg_text = 'release_return'
  GlobalSignal.dispatch('debug_label2', { 'text': dbg_text })


func handle_melee_state_charged():
  emit_signal('current_melee_state', MELEE_STATES.CHARGED)


func handle_melee_state_charging():
  emit_signal('current_melee_state', MELEE_STATES.CHARGING)
  if melee_charge_power < melee_charge_power_max:
    melee_charge_power += melee_charge_power_increment
  else:
    next_melee_state = MELEE_STATES.CHARGED


func handle_melee_state_none():
  emit_signal('current_melee_state', MELEE_STATES.NONE)
  reset_melee_values()


func handle_melee_state_release_charged():
  emit_signal('current_melee_state', MELEE_STATES.RELEASE_CHARGED)


func handle_melee_state_release_normal():
  emit_signal('current_melee_state', MELEE_STATES.RELEASE_NORMAL)
  melee_charge_delay = false
  melee_charge_delay_timer.stop()


func handle_melee_state_release_return():
  emit_signal('current_melee_state', MELEE_STATES.RELEASE_RETURN)


func handle_melee_state_wind():
  emit_signal('current_melee_state', MELEE_STATES.WIND)
  melee_charge_delay_active = true
  melee_charge_delay_timer.start(melee_charge_delay)


###
# OTHER METHODS
###

func cancel_active_attack_state():
  next_attack_state = ATTACK_STATES.NONE


func reset_melee_values():
  melee_damage_applied = false
  
  melee_queued = false
  melee_charge_queued = false
  melee_charge_power = melee_charge_power_min
  
  melee_charge_delay_active = false
