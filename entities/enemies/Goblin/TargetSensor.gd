extends Area2D


signal target_acquired
signal target_lost


var target = null

onready var Parent = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
  connect('body_entered', self, '_on_Body_entered')
  connect('body_exited', self, '_on_Body_exited')



func _physics_process(_delta):
  match sign(Parent.direction.x):
    -1.0: rotation = PI
    1.0: rotation = 0


func _on_Body_entered(body):
  if body == Parent: return
  
    
  if 'Health' in body and target == null:
    # GlobalSignal.dispatch('debug_label', { 'text': body.name })
    # GlobalSignal.dispatch('debug_label2', { 'text': '' })
    target = body
    emit_signal('target_acquired', body)
  
func _on_Body_exited(body):
  if body == Parent: return
    
  if body == target:
    # GlobalSignal.dispatch('debug_label2', { 'text': body.name })
    target = null
    emit_signal('target_lost')
    # GlobalSignal.dispatch('debug_label', { 'text': '' })
  
