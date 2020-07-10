extends Locomotor


signal target_reached


export(float) var ACCELERATION = 50.0
export(float) var MAX_FLY_SPEED = 200.0

onready var Parent : KinematicBody2D = get_parent()


# Called when the node enters the scene tree for the first time.
func _ready():
  Parent.connect('move_entity', self, 'move')

# Calculate parent movement and apply it.
func move(target_position, source_delta):
  # var speed = min(Parent.motion.length() + ACCELERATION, MAX_FLY_SPEED)
  var speed = MAX_FLY_SPEED * source_delta
  var distance_to_next = Parent.position.distance_to(target_position)

  var next_position
  if speed <= distance_to_next and speed >= 0.0:
    next_position = Parent.position.linear_interpolate(target_position, speed / distance_to_next)
  else:
    next_position = target_position
    emit_signal('target_reached')
  
  Parent.motion = next_position - Parent.position
  Parent.motion = Parent.move_and_slide(Parent.motion / source_delta, Vector2.UP)
