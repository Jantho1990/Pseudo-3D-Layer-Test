extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
  # $DollyTrack3D.dolly_direction = DollyTrack3D.dolly_directions.DOLLY_REVERSE
  $DollyTrack3D.dolly_active = true
  # $DollyTrack3D.connect('dolly_movement', self, '_on_Dolly_movement')


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#  pass


func _physics_process(delta):
  $DollyTrack3D.get_camera().focus_on_focal_point()


func _on_Dolly_movement(data):
  var dolly_advancement = data.relative_position
  if dolly_advancement < 0.5:
    $DollyTrack3D.dolly_direction = DollyTrack3D.dolly_directions.DOLLY_FORWARD
