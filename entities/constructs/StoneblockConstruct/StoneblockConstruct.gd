extends Construct


class_name StoneblockConstruct


const GRAVITY = 20 # TODO: Replace with universal constant
const MAX_GRAVITY = 1960
const UP = Vector2(0, -1)

var motion = Vector2(0, 0)

const MAX_DAMAGE = 6
const FALL_DAMAGE_INCREMENT = MAX_GRAVITY / MAX_DAMAGE
var damage = 1


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(_delta):
  set_damage() # Placed here because otherwise is_on_floor messes with the calculation
  if not is_on_floor():
    motion.y += GRAVITY
  else:
    motion.y = 0
  motion = move_and_slide(motion, UP)

  calculate_entity_damages()


func set_damage():
  damage = ceil(motion.y / FALL_DAMAGE_INCREMENT)


func calculate_entity_damages():
  var collisions = get_slide_count()
  for i in collisions:
    var collision = get_slide_collision(i)
    if collision.collider.has_node('Health'):
      collision.collider.get_node('Health').hurt(damage)
