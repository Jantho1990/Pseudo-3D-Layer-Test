extends ImmediateGeometry


export(Curve3D) var curve = Curve3D.new()

var path_points = [
  [Vector3(-2, 0, 0)],
  [Vector3(0, -1, 0)],
  [Vector3(2, 0, 0)]
]


# Called when the node enters the scene tree for the first time.
func _ready():
  for point in path_points:
    curve.add_point(point[0])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
 render_curve()


func render_curve():
  clear()
  begin(Mesh.PRIMITIVE_LINE_STRIP)
  
  for point in curve.get_baked_points():
    # print(point, typeof(point))
    add_vertex(point)
  
  end()