extends KinematicBody2D

signal melee_just_pressed
signal melee_pressed
signal melee_released
signal ui_down
signal ui_left
signal ui_right
signal ui_up
signal ui_idle
signal stop_jump
signal start_run
signal stop_run
signal dead


const UP = Vector2(0, -1)
var motion = Vector2(0, 0)
var direction = Vector2(0, 0)

# Freeze controls
const FREEZE_TIME = 0.2 # seconds, should match locomotor's SUSPENSION_TIME
var dead = false
var frozen = false
var hurt = false

onready var Animator = $Sprites/Animator
onready var FreezeTimer = $FreezeTimer
onready var Health = $Health
onready var Locomotor = $PlayerLocomotor
onready var Sprites = $Sprites
onready var Sounds = $Sounds
onready var Weapon = $HammerAttack


# Called when the node enters the scene tree for the first time.
func _ready():
  GlobalSignal.listen('teleport', self, '_on_Teleport')
  FreezeTimer.connect('timeout', self, '_on_Freeze_timer_timeout')

  Health.connect('hurt', self, '_on_Hurt')
  Health.connect('dead', self, '_on_Dead')
  GlobalSignal.dispatch('set_health', {
    'health': Health.current,
    'min_health': 0,
    'max_health': Health.maximum
  })

  Locomotor.init_connections(self)
  Locomotor.connect('play_sound', self, '_on_Play_sound')
  
  Sprites.init_connections(self)
  Sprites.connect('melee_swing_end', Weapon, '_on_Melee_swing_end')
  Sprites.connect('melee_return_end', Weapon, '_on_Melee_return_end')
  
  Weapon.init_connections(self)
  Weapon.connect('current_melee_state', Sprites, 'change_melee_state')



func _physics_process(_delta):
  if not frozen:
    process_basic_movement()
    process_run()
    process_melee()
    
  motion = move_and_slide(motion, UP)
  direction = Locomotor.direction


func _on_Hurt():
  if not dead:
    Health.get_node('HurtEffect').play('hurt')
    GlobalSignal.dispatch('health_change', { 'health': Health.current })
    print('OW!')


func _on_Dead():
  print('DEAD')
  if not dead:
    die()


func _on_Hurt_end():
  hurt = false


func _on_Freeze_timer_timeout():
  frozen = false


func _on_Play_sound(sound_name):
  if Sounds.has_node(sound_name):
    Sounds.get_node(sound_name).play()


func _on_Teleport():
  frozen = true
  FreezeTimer.start(FREEZE_TIME)


func die():
  dead = true
  frozen = true
  emit_signal('dead')


func process_basic_movement():
  if Input.is_action_pressed('ui_left'):
    emit_signal('ui_left')
  elif Input.is_action_pressed('ui_right'):
    emit_signal('ui_right')
  elif Input.is_action_just_released('ui_left') or \
    Input.is_action_just_released('ui_right'):
    emit_signal('ui_idle')
  
  if Input.is_action_pressed('ui_up'):
    emit_signal('ui_up')
  elif Input.is_action_pressed('ui_down'):
    emit_signal('ui_down')
  
  # Scaling jump
  if Input.is_action_just_released('ui_up'):
    emit_signal('stop_jump')


func process_melee():
  if Input.is_action_just_pressed('weapon_melee'):
    emit_signal('melee_just_pressed')
  elif Input.is_action_pressed('weapon_melee'):
    emit_signal('melee_pressed')
  elif Input.is_action_just_released('weapon_melee'):
    emit_signal('melee_released')


func process_run():
  if Input.is_action_just_pressed('run'):
    emit_signal('start_run')
  elif Input.is_action_just_released('run'):
    emit_signal('stop_run')


func play_footstep():
  if not Locomotor.is_in_air: Sounds.get_node('Footstep').play()
