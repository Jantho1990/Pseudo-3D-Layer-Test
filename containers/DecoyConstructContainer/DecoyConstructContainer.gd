extends "res://containers/EntityContainer/EntityContainer.gd"

class_name DecoyConstructContainer

func _init().():
  container_type = "DecoyConstruct"
  container_callback = "on_Add_DecoyConstruct"
  container_callback_remove = "on_Remove_DecoyConstruct"

func _ready():
  ._ready()
  GlobalSignal.listen('delete_all_units', self, '_on_Delete_all_units')

func on_Add_DecoyConstruct(data):
  # breakpoint
  if data.container_id == container_id:
    var entity = data.entity
    if data.instance == true:
      entity = entity.instance()
  
    add_child(entity)
    entity.position = data.position

func on_Remove_DecoyConstruct(data):
  on_Remove_entity(data)

func _on_Delete_all_units():
  clear_children()
