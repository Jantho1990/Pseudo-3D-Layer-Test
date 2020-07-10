extends AnimationPlayer


var direction = Vector2(0, 0)
var moving = false

var Controller

onready var Parent = get_parent()


func _physics_process(delta):
  calculate_direction()
  if not moving:
    play('idle')
  else:
    play('walk')


func init_connections(controller):
  Controller = controller
  Controller.connect('ui_left', self, 'move_left')
  Controller.connect('ui_right', self, 'move_right')
  Controller.connect('ui_up', self, 'move_up')
  Controller.connect('ui_idle', self, 'idle')


func calculate_direction():
  var mouse_position = Parent.get_local_mouse_position()
  if sign(Vector2(0, 0).direction_to(mouse_position).x) < 0:
    direction = Vector2(-1, 0)
  else:
    direction = Vector2(1, 0)


func idle():
  moving = false


func move_left():
  if not moving:
    moving = true
  play('walk')


func move_right():
  if not moving:
    moving = true
  play('walk')


func move_up():
  pass


func test_func():
  print('I RAN')
