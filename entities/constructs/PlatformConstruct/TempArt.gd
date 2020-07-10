extends Node2D


func _physics_process(_delta):
  update()

func _draw():
  var ext = $"../CollisionShape2D".shape.extents
  var pos = $"../CollisionShape2D".position
  var rec = Rect2(pos - Vector2(ext.x, ext.y), ext * 2)
  draw_rect(rec, Color(1, 1, 1))
