extends Area2D


export(float) var damage = 1.0

var offset = Vector2(10, 0)
var damage_applied = false

onready var Parent = get_parent()


# Called when the node enters the scene tree for the first time.
func _ready():
  connect('body_entered', self, '_on_Body_entered')


func _physics_process(_delta):
  # GlobalSignal.dispatch('debug_label', { 'text': position })
  pass


func _on_Body_entered(body):
  if not damage_applied and 'Health' in body:
    body.Health.hurt(damage)
    damage_applied = true


func reset_damage_applied():
  damage_applied = false
  print('RESET PAIN')
