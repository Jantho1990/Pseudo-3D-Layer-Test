extends Control


onready var HealthProgressBar = $ProgressBar


# Called when the node enters the scene tree for the first time.
func _ready():
  GlobalSignal.listen('set_health', self, '_on_Set_health')
  GlobalSignal.listen('health_change', self, '_on_Health_change')
  GlobalSignal.listen('reduce_health', self, '_on_Reduce_health')
  GlobalSignal.listen('increase_health', self, '_on_Increase_health')


func _on_Set_health(data):
  if data.has('health'):
    var health = data.health
    HealthProgressBar.value = health
  
  if data.has('max_health'):
    var max_health = data.max_health
    HealthProgressBar.max_value = max_health
  
  if data.has('min_health'):
    var min_health = data.min_health
    HealthProgressBar.min_value = min_health

func _on_Health_change(data):
  var health = data.health
  HealthProgressBar.value = health
