extends Navigation2D


class_name NavigationNode


export(bool) var show_generated_navigation_polygons = false # Shows any automatically-generated navigation polygons.

onready var Level = get_parent()
onready var Line = $Line2D


func _ready():
  for node in get_navigator_nodes(Level):
    node.NavigationNode = self
  for nav_poly in get_navigation_polygons():
    navpoly_add(nav_poly, Transform2D()) # We must pass in a Transform2D because navpoly_add requires it, but we don't want to actually do a transform because the coordinates are already correct.


func _process(delta):
  update()


func _draw():
  if show_generated_navigation_polygons:
    var tile_color = Color(1, 0, 1, 0.25)
    for nav_poly in get_navigation_polygons():
      for i in nav_poly.get_outline_count():
        var outline = nav_poly.get_outline(i)
        draw_rect(Rect2(transform.xform(outline[0]), outline[2] - outline[0]), tile_color, true)


# Get all Navigator nodes present in the specified node.
func get_navigator_nodes(node):
  var ret = []
  for child in node.get_children():
    if child.get_children().size() > 0:
      var child_navigator_nodes = get_navigator_nodes(child)
      for child_navigator_node in child_navigator_nodes:
        ret.push_back(child_navigator_node)
    else:
      if child is Navigator:
        ret.push_back(child)
  return ret


# Get auto-generated navigation polygons from child tilemaps, if they have any.
func get_navigation_polygons():
  var ret = []
  for child in get_children():
    if child is TileMap and 'navigation_polygons' in child:
      for nav_poly in child.navigation_polygons:
        ret.push_back(nav_poly)
  return ret
