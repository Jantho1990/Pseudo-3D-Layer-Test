extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
  $Timer.connect('timeout', self, '_on_Timer_timeout')
  $Timer.start(0.5)
  GlobalSignal.listen('test_signal', self, '_on_Test_signal')
  
  
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#  pass
  
  
func _on_Test_signal():
  print('Test signal received!')
    
    
func _on_Timer_timeout():
  DialogueHandler.show_dialogue('Test Dialogue 0')
      