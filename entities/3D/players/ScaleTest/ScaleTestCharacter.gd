extends KinematicBody

# With help from KidsCanCode: https://www.youtube.com/watch?v=ickZ_Genr7A


# Declare member variables here. Examples:
export(bool) var free_move = true
var velocity = Vector3()
var speed = 4
var gravity = Vector3.DOWN * 2
var moving = false
var direction = Vector2(0, 0)
var layer_shift = 1
var is_shifting_layer = false
var layer_shift_delayed = false
var layer_shift_delay_time = 1
var layer_shift_delay_transition_time = 0.3

# onready var Animator = $AnimationPlayer
onready var LayerShiftDelay = $LayerShiftDelay
onready var LayerShiftTween = $LayerShiftTween


# Called when the node enters the scene tree for the first time.
func _ready():
  LayerShiftDelay.connect('timeout', self, '_on_Layer_shift_delay_stop')
  LayerShiftTween.connect('tween_all_completed', self, '_on_Layer_shift_tween_all_completed')


func _physics_process(delta):
  velocity += gravity * delta
  get_input()
  # animate()
  # if not moving: Animator.stop()
  velocity = move_and_slide(velocity, Vector3.UP)

func _on_Layer_shift_delay_stop():
  layer_shift_delayed = false

func _on_Layer_shift_tween_all_completed():
  is_shifting_layer = false


func _unhandled_input(event):
  if Input.is_action_just_pressed('sprite_change_right'):
    if $Sprite3D.frame == $Sprite3D.hframes - 1:
      $Sprite3D.frame = 0
    else:
      $Sprite3D.frame += 1
  if Input.is_action_just_pressed('sprite_change_left'):
    if $Sprite3D.frame == 0:
      $Sprite3D.frame = $Sprite3D.hframes - 1
    else:
      $Sprite3D.frame -= 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#  pass

func get_input():
  if free_move:
    free_move()
  else:
    limited_move()

func animate():
  pass
  # match direction:
  #   Vector2(-1, 0): Animator.play('walk_w')
  #   Vector2(1, 0): Animator.play('walk_e')
  #   Vector2(0, -1): Animator.play('walk_n')
  #   Vector2(0, 1): Animator.play('walk_s')

func free_move():
  var vy = velocity.y
  velocity = Vector3()
  moving = false
  if Input.is_action_pressed('ui_left'):
    moving = true
    velocity += -transform.basis.x * speed
    direction = Vector2(-1, 0)
  elif Input.is_action_pressed('ui_right'):
    moving = true
    velocity += transform.basis.x * speed
    direction = Vector2(1, 0)

  if Input.is_action_pressed('ui_up'):
    moving = true
    velocity += -transform.basis.z * speed
    direction = Vector2(0, -1)
  elif Input.is_action_pressed('ui_down'):
    moving = true
    velocity += transform.basis.z * speed
    direction = Vector2(0, 1)
    
  velocity.y = vy

func limited_move():
  var vy = velocity.y
  velocity = Vector3()
  moving = false
  
  # Cancel movement if we're shifting layers.
  if is_shifting_layer: return

  if Input.is_action_pressed('ui_left'):
    moving = true
    velocity += -transform.basis.x * speed
    direction = Vector2(-1, 0)
  elif Input.is_action_pressed('ui_right'):
    moving = true
    velocity += transform.basis.x * speed
    direction = Vector2(1, 0)

  if not layer_shift_delayed:
    if Input.is_action_pressed('ui_up'):
      start_layer_shift_tween(-layer_shift)
    elif Input.is_action_pressed('ui_down'):
      start_layer_shift_tween(layer_shift)
    
  velocity.y = vy

func start_layer_shift_tween(amount):
  is_shifting_layer = true
  var target_translation = translation
  target_translation.z += amount
  LayerShiftTween.interpolate_property(self, 'translation', translation, target_translation, layer_shift_delay_transition_time)
  LayerShiftTween.start()
  start_layer_shift_delay()

func start_layer_shift_delay():
  layer_shift_delayed = true
  LayerShiftDelay.start(layer_shift_delay_time)
