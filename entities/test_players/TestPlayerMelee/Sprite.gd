extends Sprite


onready var Parent = get_parent()
onready var position_offset = position


func _physics_process(delta):
  update_sprite_face()


func update_sprite_face():
  var direction = Parent.direction
  match direction:
    Vector2(-1, 0):
      flip_h = true
      position = position_offset * Vector2(-1, 1)
    _:
      flip_h = false
      position = position_offset * Vector2(1, 1) 
