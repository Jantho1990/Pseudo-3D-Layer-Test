extends Node

class_name Cutscene3D


export(String) var dialogue_name

var dolly_tracks = {}


# Called when the node enters the scene tree for the first time.
func _ready():
  assign_dolly_tracks(get_children())


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#  pass


# Assign all the dolly track children of the cutscene to the dolly_tracks object.
func assign_dolly_tracks(nodes):
  for node in nodes:
    if node is DollyTrack3D:
      dolly_tracks[node.name] = node
      