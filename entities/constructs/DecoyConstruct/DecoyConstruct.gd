extends Construct


class_name DecoyConstruct


signal decoy_destroyed


const GRAVITY = 20 # TODO: Replace with universal constant
const MAX_GRAVITY = 1960
const UP = Vector2(0, -1)

var motion = Vector2(0, 0)

onready var EffectArea = $EffectArea


# Called when the node enters the scene tree for the first time.
func _ready():
  EffectArea.connect('body_entered', self, '_on_Body_entered')
  connect('tree_exiting', self, '_on_DecoyConstruct_Tree_exiting')


func _physics_process(_delta):
  if not is_on_floor():
    motion.y += GRAVITY
  else:
    motion.y = 0
  motion = move_and_slide(motion, UP)


func _on_Body_entered(body):
  if body.has_method('decoy_detected'):
    body.decoy_detected(self)
    connect('decoy_destroyed', body, '_on_Decoy_destroyed')


func _on_DecoyConstruct_Tree_exiting():
  emit_signal('decoy_destroyed')
