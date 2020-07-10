extends Node


signal dead
signal hurt
signal heal


export var current = 10
export var maximum = 10
export var invincible = false

var invincibility_duration = 0
var invincibility_remaining = 0


func _physics_process(delta):
  if invincibility_remaining > 0:
    invincibility_remaining -= delta


func full_heal():
  current = maximum


func heal(amount):
  current = current + amount if maximum - amount > current else maximum
  emit_signal('heal')
  

func hurt(amount):
  if not invincible:
    current = current - amount if current - amount > 0 else 0
    emit_signal('hurt')
  if current == 0:
    emit_signal('dead')


func make_invincible(duration = 3):
  if not invincible:
    invincible = true
    invincibility_duration = duration
    invincibility_remaining = duration


func set_health(amount):
  current = amount
