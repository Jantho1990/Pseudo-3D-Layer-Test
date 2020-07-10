extends Spatial

func _ready():
  # Clear the viewport.
  var layer1 = $Layer1
  var layer2 = $Layer2
  $Layer1.set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
  $Layer2.set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)

  # Let two frames pass to make sure the vieport is captured.
  yield(get_tree(), "idle_frame")
  yield(get_tree(), "idle_frame")

  var layer1Quad = $Layer1QuadMesh
  var layer2Quad = $Layer2QuadMesh

  # Retrieve the texture and set it to the viewport quad.
  $Layer1QuadMesh.mesh.material.albedo_texture = layer1.get_texture()
  $Layer2QuadMesh.mesh.material.albedo_texture = layer2.get_texture()
