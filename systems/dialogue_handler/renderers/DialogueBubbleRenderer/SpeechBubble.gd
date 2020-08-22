extends Spatial


export(String) var raw_text = 'This is an example of dialogue bubble text.' setget update_text


onready var Bubble = $Bubble
onready var TextViewport = $TextViewport
onready var TextboxContainer = $TextViewport/TextboxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
  pass
  # Bubble.mesh.material.albedo_texture = TextViewport.get_texture()

  
func update_text(new_text):
  if new_text != TextboxContainer.raw_text:
    TextboxContainer.raw_text = new_text
