extends Control


var constructs_list = []


onready var SelectionWheel = $SelectionWheel


# Called when the node enters the scene tree for the first time.
func _ready():
  GlobalSignal.listen('unit_loaded', self, '_on_Unit_loaded')


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#  pass


func _on_Unit_loaded(data):
  var unit = data.unit
  constructs_list.push_back({
    'name': unit.name,
    'selected': false
  })