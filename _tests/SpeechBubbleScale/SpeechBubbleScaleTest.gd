extends Spatial


onready var SpeechBubble = $SpeechBubble
onready var TE = $Control/TextEdit
onready var L1 = $Control/HBoxContainer/L1
onready var L2 = $Control/HBoxContainer/L2


# Called when the node enters the scene tree for the first time.
func _ready():
  TE.connect('text_changed', self, '_on_text_changed')


func _on_text_changed():
  SpeechBubble.raw_text = TE.text
  L1.text = 'Content Size: ' + String(SpeechBubble.TextboxContainer.content_size)
  L2.text = 'Total Lines: ' + String(SpeechBubble.TextboxContainer.content_total_lines)
