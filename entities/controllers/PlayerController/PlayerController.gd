extends Node

class_name PlayerController

signal ui_down
signal ui_left
signal ui_right
signal ui_up
signal stop_jump
signal start_run
signal stop_run

export(NodePath) var Locomotor

# Freeze controls
const FREEZE_TIME = 0.2 # seconds, should match locomotor's SUSPENSION_TIME
var frozen = false

onready var Parent = get_parent()
onready var FreezeTimer = $FreezeTimer

# Called when the node enters the scene tree for the first time.
func _ready():
  FreezeTimer.connect('timeout', self, '_on_Freeze_timer_timeout')
  GlobalSignal.listen('teleport', self, '_on_Teleport')

  if !Locomotor:
    print('No Locomotor for ', self.get_class(), ' in ', Parent.get_class())
  else:
    Locomotor = get_node(Locomotor)
    Locomotor.init_connections(self)


func _physics_process(_delta):
  if not frozen:
    process_basic_movement()
    process_run()


func _on_Freeze_timer_timeout():
  frozen = false


func _on_Teleport():
  frozen = true
  FreezeTimer.start(FREEZE_TIME)


func process_basic_movement():
  if Input.is_action_pressed('ui_left'):
    emit_signal('ui_left')
  elif Input.is_action_pressed('ui_right'):
    emit_signal('ui_right')
  
  if Input.is_action_pressed('ui_up'):
    emit_signal('ui_up')
  elif Input.is_action_pressed('ui_down'):
    emit_signal('ui_down')
  
  # Scaling jump
  if Input.is_action_just_released('ui_up'):
    emit_signal('stop_jump')

func process_run():
  if Input.is_action_just_pressed('run'):
    emit_signal('start_run')
  elif Input.is_action_just_released('run'):
    emit_signal('stop_run')

func set_locomotor(new_locomotor):
  Locomotor = new_locomotor