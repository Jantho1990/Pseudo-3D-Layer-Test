extends Spatial


onready var SpeechBubble = $SpeechBubble
onready var TE = $Control/TextEdit


# Called when the node enters the scene tree for the first time.
func _ready():
  TE.connect('text_changed', self, '_on_text_changed')


func _on_text_changed():
  SpeechBubble.raw_text = TE.text