extends Control


const BLOCK_TYPES = {
  'TEXT': 'text'
}


export(float) var step_next_letter = 0.1


var content
var current_block # The current block being processed.
var step_content_percent_visible = 0.0

onready var ContentBox = get_node('./DialogueContainer/MarginContainer/VBoxContainer/DialogueContent')
onready var NameBox = get_node('./DialogueContainer/MarginContainer/VBoxContainer/CharacterName')
onready var TypewriterTimer = get_node('./DialogueContainer/MarginContainer/VBoxContainer/DialogueContent/TypewriterTimer')


# Called when the node enters the scene tree for the first time.
func _ready():
  DialogueHandler.register_renderer(self, 'dialogue', true)
  TypewriterTimer.connect('timeout', self, '_on_TypewriterTimer_timeout')


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#  pass


func _on_TypewriterTimer_timeout():
  if ContentBox.percent_visible < 1:
    ContentBox.percent_visible += step_content_percent_visible
    print(ContentBox.percent_visible, ' ', step_content_percent_visible)
    TypewriterTimer.start(step_next_letter)


# Renders a dialogue script in a dialogue box.
func render(dialogue):
  content = dialogue.content

  var first_block_name = dialogue.start if dialogue.has('start') else 'first_block'
  var block = content[first_block_name]
  current_block = block
  match block.type:
    BLOCK_TYPES.TEXT: render_type_text(first_block_name, block)


# Renders a block of content.
func render_block(block):
  pass


# Renders text-type content.
func render_type_text(block_name : String, block):
  var character_name = block.character_display_name if block.has('character_display_name') \
    else block.character
  var text = block.text

  # Render the character name
  NameBox.bbcode_text = character_name

  # Render the dialogue text.
  ContentBox.bbcode_text = text
  var raw_text = ContentBox.text
  var raw_text_length = raw_text.length()
  step_content_percent_visible = 1 / float(raw_text_length)
  print(raw_text_length, ' ', step_content_percent_visible, 1 / raw_text_length)
  ContentBox.percent_visible = 0
  TypewriterTimer.start(step_next_letter)
