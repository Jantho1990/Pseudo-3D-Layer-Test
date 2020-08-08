extends Control


const BLOCK_TYPES = {
  'TEXT': 'text',
  'CHOICE': 'choice'
}

var ChoiceButton = preload('res://systems/dialogue_handler/renderers/DBRChoiceButton.tscn')

export(String) var anonymous_name = '???' # The string used when displaying an anonymous character's name.
export(String) var next_command = 'ui_select'
export(float) var step_next_letter = 0.1 # How long to wait before advancing to the next letter.

var paused = false # Dialogue rendering is paused.
var typing = false # Is typewriter effect currently typing?
var step_content_percent_visible = 0.0 # How much of the text in the content box is currently visible.

var content
var current_block # The current block being processed.
var next_block_name # The next block to be processed.

onready var BackgroundScreen = $'./BackgroundScreen'
onready var ContentBox = $'./DialogueContainer/MarginContainer/VBoxContainer/DialogueContent'
onready var ChoiceBoxes = $'./ChoiceContainer/MarginContainer/VBoxContainer/ChoiceButtonContainer'
onready var ChoiceContainer = $'./ChoiceContainer'
onready var ChoiceDescription = $'./ChoiceContainer/MarginContainer/VBoxContainer/ChoiceDescription'
onready var DialogueContainer = $'./DialogueContainer/'
onready var NameBox = $'./DialogueContainer/MarginContainer/VBoxContainer/CharacterName'
onready var TypewriterTimer = $'./DialogueContainer/MarginContainer/VBoxContainer/DialogueContent/TypewriterTimer'


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


# Handle choice button press.
func _on_Choice_button_press(choice_next):
  next_block_name = choice_next
  next()


func _on_TypewriterTimer_timeout():
  if ContentBox.percent_visible < 1:
    ContentBox.percent_visible += step_content_percent_visible
    TypewriterTimer.start(step_next_letter)
  else:
    TypewriterTimer.stop() # Otherwise the timer doesn't seem to stop. /shrug
    typing = false


# Begin rendering a dialogue.
func begin():
  DialogueContainer.visible = true


# Clean exisiting data.
func clean():
  NameBox.bbcode_text = ''
  ContentBox.percent_visible = 0
  current_block = null
  screen_hide()
  ChoiceContainer.visible = false
  clean_choice_boxes()


# Get rid of the choice boxes.
func clean_choice_boxes():
  for child in ChoiceBoxes.get_children():
    child.queue_free()


# Finish the current dialogue.
func finish():
  DialogueContainer.visible = false


# Get the character name.
func get_character_name(block):
  if block.has('anonymous') and block.anonymous:
    return anonymous_name
  elif block.has('character_display_name'):
    return block.character_display_name
  elif block.has('character'):
    return block.character
  
  return null


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
  
  var signals : Array = block.signals
  print(signals)
  for dialogue_signal in signals:
    match dialogue_signal.has('data'):
      true: GlobalSignal.dispatch(dialogue_signal.name, dialogue_signal.data)
      false: GlobalSignal.dispatch(dialogue_signal.name)


# Renders a dialogue script in a dialogue box.
func render(dialogue):
  clean() # Make sure nothing is currently being shown.
  content = dialogue.content

  var first_block_name = dialogue.start if dialogue.has('start') else 'first_block'
  begin()
  render_block(first_block_name)


# Renders a block of content.
func render_block(block_name):
  var block = DialogueHandler.parse_block_story_data(content[block_name])
  current_block = block
  next_block_name = block.next if block.has('next') else ''
  match block.type:
    BLOCK_TYPES.TEXT: render_type_text(block_name, block)
    BLOCK_TYPES.CHOICE: render_type_choice(block_name, block)


# Render choice buttons.
func render_choice_buttons(choices):
  for choice in choices:
    var button = ChoiceButton.instance()
    button.text = choice.text
    ChoiceBoxes.add_child(button)
    button.connect('pressed', self, '_on_Choice_button_press', [ choice.next ])


# Render choice content.
func render_choice_content(block):
  ChoiceContainer.visible = true
  screen_show()
  var choice_description = block.choice_description if block.has('choice_description') else ''
  if choice_description: ChoiceDescription.bbcode_text = choice_description
  render_choice_buttons(block.choices)


# Renders the content in the text box.
func render_text_box_content(text):
  typing = true
  ContentBox.bbcode_text = text
  var raw_text = ContentBox.text
  var raw_text_length = raw_text.length()
  step_content_percent_visible = 1 / float(raw_text_length)
  ContentBox.percent_visible = 0
  TypewriterTimer.start(step_next_letter)


# Renders a choice-type block.
func render_type_choice(_block_name: String, block):
  process_signals(block)

  var character_name = get_character_name(block)
  if !!character_name: NameBox.bbcode_text = character_name
  if block.has('text'): render_text_box_content(block.text)

  # Render the choices.
  # TODO: Render choices in these conditions:
  # - after a normal text block where choice block has no text
  # - after typewriter finishes for choice block text
  render_choice_content(block)


# Renders text-type content.
func render_type_text(_block_name : String, block):
  process_signals(block)
  
  var character_name = get_character_name(block)
  var text = block.text

  # Render the character name
  NameBox.bbcode_text = character_name

  # Render the dialogue text.
  render_text_box_content(text)


func screen_hide():
  BackgroundScreen.visible = false


func screen_show():
  BackgroundScreen.visible = true


# Advance to the end of the current text block.
func skip_to_end():
  typing = false
  TypewriterTimer.stop()
  ContentBox.percent_visible = 1
