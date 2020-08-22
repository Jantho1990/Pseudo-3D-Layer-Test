extends Spatial


export(String) var raw_text = 'This is an example of dialogue bubble text.' setget update_text
export(Vector2) var size = Vector2(500, 300) setget update_size # The size in pixels. This is the master control for all other sizing variables.
export(Vector2) var content_padding = Vector2(20, 20) # Extra space added to content size when updating bubble dimensions.
export(int) var max_lines = 5
export(float) var max_content_width = 500 # The maximum width the content is allowed to be.

var mesh_scale = 100.0 # This determines how much to scale the viewport sizes based on the mesh size.

onready var Bubble = $TextQuad/BubbleContainer
onready var TextQuad = $TextQuad
onready var TextViewport = $TextViewport
onready var TextboxContainer = $TextViewport/TextboxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
  TextboxContainer.max_lines = max_lines
  TextboxContainer.max_content_width = max_content_width
  # Bubble.mesh.material.albedo_texture = TextViewport.get_texture()

  
func get_textbox_font_size(font_name : String = 'normal'):
  var font = TextboxContainer.TextContent.get_font(font_name)
  return font.get_height()


func update_bubble_dimensions(new_dimensions):
  var new_size = new_dimensions + content_padding

  # If there are multiple lines, content should always be at maximum width.
  if TextboxContainer.content_total_lines > 1:
    new_size.x = max_content_width
  
  if TextboxContainer.content_total_lines <= max_lines:
    update_size(new_size)


func update_size(new_size):
  size = new_size
  TextViewport.size = size
  TextQuad.mesh.size = size / int(mesh_scale)
  TextboxContainer.update_size(size)


func update_text(new_text):
  if new_text != TextboxContainer.raw_text:
    TextboxContainer.raw_text = new_text
    update_bubble_dimensions(TextboxContainer.content_size)
