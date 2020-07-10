extends TextureButton


export(String) var construct_name = 'ConstructName'


func _on_SelectionButton_pressed():
  GlobalSignal.dispatch('change_construct', { 'name': construct_name })
