extends Control


func _input(event):
  if Input.is_action_pressed('open_construct_selection_menu'):
    show()
  elif Input.is_action_just_released('open_construct_selection_menu'):
    hide()