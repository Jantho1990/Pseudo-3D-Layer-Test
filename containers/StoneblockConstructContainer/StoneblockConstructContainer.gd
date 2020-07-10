extends "res://containers/EntityContainer/EntityContainer.gd"

class_name StoneblockConstructContainer

func _init().():
  container_type = "StoneblockConstruct"
  container_callback = "on_Add_StoneblockConstruct"
  container_callback_remove = "on_Remove_StoneblockConstruct"

func _ready():
  ._ready()
  GlobalSignal.listen('delete_all_units', self, '_on_Delete_all_units')

func on_Add_StoneblockConstruct(data):
  # breakpoint
  if data.container_id == container_id:
    var entity = data.entity
    if data.instance == true:
      entity = entity.instance()
  
    add_child(entity)
    entity.position = data.position

func on_Remove_StoneblockConstruct(data):
  on_Remove_entity(data)

func _on_Delete_all_units():
  clear_children()
