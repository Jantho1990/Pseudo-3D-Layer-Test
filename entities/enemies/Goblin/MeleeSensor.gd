extends Area2D


signal melee_range_entered
signal melee_range_exited


var target = null

onready var Parent = get_parent()


# Called when the node enters the scene tree for the first time.
func _ready():
  connect('body_entered', self, '_on_Body_entered')
  connect('body_exited', self, '_on_Body_exited')


func _physics_process(_delta):
  match sign(Parent.direction.x):
    -1.0: position = position.abs() * Parent.direction
    1.0: position = position.abs() * Parent.direction


func _on_Body_entered(body):
  if body == Parent: return
  
  if 'Health' in body and body == Parent.target:
    target = Parent.target
    emit_signal('melee_range_entered')
  
func _on_Body_exited(body):
  if body == Parent: return
  
  if body == target:
    target = null
    emit_signal('melee_range_exited')
