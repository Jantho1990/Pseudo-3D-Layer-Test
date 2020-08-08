extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
  # $Timer.connect('timeout', self, '_on_Timer_timeout')
  # $Timer.start(0.5)
  GlobalSignal.listen('test_signal', self, '_on_Test_signal')
  DialogueHandler.create_story_data('test0', 'fish')
  DialogueHandler.create_story_data('test1.test1c', 'shark')
  DialogueHandler.create_story_data('test1.test1b', 'petunia')
  DialogueHandler.create_story_data('test1.test1a.test1b', 'rabbit')


func _unhandled_input(_event):
  if Input.is_action_just_pressed('start_dialogue_test'):
    DialogueHandler.show_dialogue('Test Dialogue 0')
  
  
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#  pass
  
  
func _on_Test_signal(data):
  print('Test signal received!')
  print(data.text)
  GlobalSignal.dispatch('debug_label', { 'text': data.text })
    
    
func _on_Timer_timeout():
  DialogueHandler.show_dialogue('Test Dialogue 0')
      