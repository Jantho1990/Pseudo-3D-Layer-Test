extends Control


const BLOCK_TYPES = {
  'TEXT': 'text'
}


export(String) var anonymous_name = '???' # The string used when displaying an anonymous character's name.
export(String) var next_command = 'ui_select'
export(float) var step_next_letter = 0.1 # How long to wait before advancing to the next letter.

var paused = false # Dialogue rendering is paused.
var typing = false # Is typewriter effect currently typing?
var step_content_percent_visible = 0.0 # How much of the text in the content box is currently visible.

var content
var current_block # The current block being processed.
var next_block_name # The next block to be processed.

onready var ContentBox = get_node('./DialogueContainer/MarginContainer/VBoxContainer/DialogueContent')
onready var DialogueContainer = get_node('./DialogueContainer/')
onready var NameBox = get_node('./DialogueContainer/MarginContainer/VBoxContainer/CharacterName')
onready var TypewriterTimer = get_node('./DialogueContainer/MarginContainer/VBoxContainer/DialogueContent/TypewriterTimer')


func _input(event):
  if event.is_action_pressed(next_command):
    if typing:
      skip_to_end()
    else:
      next()
    


# Called when the node enters the scene tree for the first time.
func _ready():
  DialogueHandler.register_renderer(self, 'dialogue', true)
  TypewriterTimer.connect('timeout', self, '_on_TypewriterTimer_timeout')
  DialogueContainer.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#  pass


func _on_TypewriterTimer_timeout():
  if ContentBox.percent_visible < 1:
    ContentBox.percent_visible += step_content_percent_visible
    print(ContentBox.percent_visible, ' ', step_content_percent_visible)
    TypewriterTimer.start(step_next_letter)
  else:
    TypewriterTimer.stop() # Otherwise the timer doesn't seem to stop. /shrug
    typing = false
    print('WAAAAH')


# Begin rendering a dialogue.
func begin():
  DialogueContainer.visible = true


# Clean exisiting data.
func clean():
  ContentBox.percent_visible = 0
  current_block = null


# Finish the current dialogue.
func finish():
  DialogueContainer.visible = false


# Advance to the next block.
func next():
  clean()
  if next_block_name != '':
    render_block(next_block_name)
  else:
    finish()


# Handle any signals present in a block.
func process_signals(block):
  if not block.has('signals'): return
  
  var signals = block.signals
  for dialogue_signal in signals:
    match dialogue_signal.has('data'):
      true: GlobalSignal.dispatch(dialogue_signal.name, dialogue_signal.data)
      false: GlobalSignal.dispatch(dialogue_signal.name, dialogue_signal.data)


# Renders a dialogue script in a dialogue box.
func render(dialogue):
  content = dialogue.content

  var first_block_name = dialogue.start if dialogue.has('start') else 'first_block'
  begin()
  render_block(first_block_name)


# Renders a block of content.
func render_block(block_name):
  var block = content[block_name]
  current_block = block
  next_block_name = block.next if block.has('next') else ''
  match block.type:
    BLOCK_TYPES.TEXT: render_type_text(block_name, block)


# Renders text-type content.
func render_type_text(block_name : String, block):
  process_signals(block)
  
  var character_name
  if block.has('anonymous') and block.anonymous:
    character_name = anonymous_name
  elif block.has('character_display_name'):
    character_name = block.character_display_name
  else:
    character_name = block.character
  var text = block.text

  # Render the character name
  NameBox.bbcode_text = character_name

  # Render the dialogue text.
  typing = true
  ContentBox.bbcode_text = text
  var raw_text = ContentBox.text
  var raw_text_length = raw_text.length()
  step_content_percent_visible = 1 / float(raw_text_length)
  print(raw_text_length, ' ', step_content_percent_visible, 1 / raw_text_length)
  ContentBox.percent_visible = 0
  TypewriterTimer.start(step_next_letter)


# Advance to the end of the current text block.
func skip_to_end():
  typing = false
  TypewriterTimer.stop()
  ContentBox.percent_visible = 1
