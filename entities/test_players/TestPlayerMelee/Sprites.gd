extends Node2D


signal change_melee_swing
signal melee_swing_end
signal melee_return_end


enum MELEE_STATES {
  NONE,
  CHARGED,
  CHARGING,
  RELEASE_CHARGED,
  RELEASE_NORMAL,
  RELEASE_RETURN,
  WIND
}


enum MELEE_SWINGS {
  URDL,
  DLUR
}
var melee_swing = MELEE_SWINGS.URDL


var current_animation = ''
var dead = false
var direction = Vector2(0, 0)
var melee_state = MELEE_STATES.NONE
var moving = false
var running = false
var jump_starting = false
var jump_landing = false

var Controller

onready var Parent = get_parent()
onready var Animator = $Animator


func _ready():
  connect('change_melee_swing', self, '_on_Change_melee_swing')


func _physics_process(delta):
  if dead:
    return
  
  calculate_direction()
  var dbg_text = ''
  match melee_state:
    MELEE_STATES.NONE: dbg_text = 'SPRITE none'
    MELEE_STATES.WIND:dbg_text = 'SPRITE wind'
    MELEE_STATES.RELEASE_NORMAL: dbg_text = 'SPRITE release_normal'
    MELEE_STATES.RELEASE_CHARGED: dbg_text = 'SPRITE release_charged'
    MELEE_STATES.CHARGING: dbg_text = 'SPRITE charging'
    MELEE_STATES.CHARGED: dbg_text = 'SPRITE charged'
    MELEE_STATES.RELEASE_RETURN: dbg_text = 'SPRITE release_return'
  GlobalSignal.dispatch('debug_label', { 'text': dbg_text })
  if melee_state != MELEE_STATES.NONE:
    handle_melee_animation()
  elif moving and running:
    Animator.play('run')
  elif moving:
    Animator.play('walk')
  else:
    Animator.play('idle')


func _on_Change_melee_swing(next_swing):
  if MELEE_SWINGS.has(next_swing): melee_swing = next_swing


func init_connections(controller):
  Controller = controller
  Controller.connect('ui_left', self, 'move_left')
  Controller.connect('ui_right', self, 'move_right')
  Controller.connect('ui_up', self, 'move_up')
  Controller.connect('ui_idle', self, 'idle')
  Controller.connect('start_run', self, 'start_run')
  Controller.connect('stop_run', self, 'stop_run')
  Controller.connect('dead', self, 'parent_dead')


func calculate_direction():
  var mouse_position = Parent.get_local_mouse_position()
  if sign(Vector2(0, 0).direction_to(mouse_position).x) < 0:
    direction = Vector2(-1, 0)
  else:
    direction = Vector2(1, 0)


func change_melee_state(type):
  if melee_state != type:
    melee_state = type


func handle_melee_animation():
  match melee_state:
    MELEE_STATES.WIND: play_animation_once('melee_wind')
    MELEE_STATES.RELEASE_NORMAL: handle_normal_melee_swing()
    MELEE_STATES.CHARGING: play_animation_once('melee_charging')
    MELEE_STATES.CHARGED: play_animation_once('melee_charged')
    MELEE_STATES.RELEASE_CHARGED: handle_normal_melee_swing()
    MELEE_STATES.RELEASE_RETURN: handle_melee_return()


func handle_melee_return():
  match melee_swing:
    MELEE_SWINGS.URDL: play_animation_once('melee_return_dldr')
    MELEE_SWINGS.DLUR: play_animation_once('melee_return_urdr')


func handle_normal_melee_swing():
  match melee_swing:
    MELEE_SWINGS.URDL: play_animation_once('melee_swing_urdl')
    MELEE_SWINGS.DLUR: play_animation_once('melee_swing_dlur')


func idle():
  moving = false


func move_left():
  if not moving:
    moving = true
  # Animator.play('walk')


func move_right():
  if not moving:
    moving = true
  # Animator.play('walk')


func move_up():
  pass


func parent_dead():
  dead = true
  Animator.play('dead')


func play_animation_once(anim):
  if current_animation != anim:
    Animator.play(anim)
    # current_animation = anim


func start_run():
  if not running:
    running = true

    
func stop_run():
  running = false
