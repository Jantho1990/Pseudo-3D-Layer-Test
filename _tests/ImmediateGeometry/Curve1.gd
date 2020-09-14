extends ImmediateGeometry

enum primitive_types {
  PRIMITVE_POINTS,
  PRIMITIVE_LINES,
  PRIMITIVE_LINE_STRIP,
  PRIMITIVE_LINE_LOOP,
  PRIMITIVE_TRIANGLES,
  PRIMITIVE_TRIANGLE_STRIP,
  PRIMITIVE_TRIANGLE_FAN
}

export(Curve3D) var curve = Curve3D.new()
export(primitive_types) var primitive_type = primitive_types.PRIMITIVE_LINE_STRIP

var current_path

export(Array) var path_points = [
  [Vector3(-2, 0, 0), Vector3(0, 0, 0), Vector3(0, 0, 0)],
  [Vector3(0, -1, 0), Vector3(0, 0, 0), Vector3(0, 0, 0)],
  [Vector3(2, 0, 0), Vector3(0, 0, 0), Vector3(0, 0, 0)],
  [Vector3(0, 0, 0), Vector3(0, 0, 0), Vector3(0, 0, 0)],
  [Vector3(-2, 0, 0), Vector3(0, 0, 0), Vector3(0, 0, 0)],
]

# Called when the node enters the scene tree for the first time.
func _ready():
  for point in path_points:
    curve.add_point(point[0], point[1], point[2])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  if current_path != path_points:
    current_path = path_points
    update_curve(current_path)
  render_curve()
  # rotation.y += 0.01


func render_curve():
  clear()
  begin(primitive_type)
  
  for point in curve.get_baked_points():
    # print(point, typeof(point))
    add_vertex(point)
  
  end()


func update_curve(path):
  curve.clear_points()
  for point in path:
    curve.add_point(point[0], point[1], point[2])
