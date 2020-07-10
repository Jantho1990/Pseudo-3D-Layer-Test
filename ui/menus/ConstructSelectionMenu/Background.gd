extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.


func _draw():
  var radius = rect_size.x / 2
  var arc_width = 10
  var pos = rect_size / 2
  draw_circle_outline(pos, radius, Color(1, 1, 0), arc_width)
  draw_circle(pos, radius - (arc_width / 2) + 1, Color(0.6, 0.1, 0.1))


func draw_circle_outline(center, radius, color, width):
	var points = 2048
	var points_arc = PoolVector2Array()
	
	for i in range(points + 1):
		var angle_point = deg2rad(0 + i * 360 / points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	
	for index_point in range(points):
		draw_line(points_arc[index_point], points_arc[index_point + 1], color, width, true)