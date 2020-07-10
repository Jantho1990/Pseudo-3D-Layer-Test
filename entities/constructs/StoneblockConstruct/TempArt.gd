extends Node2D


func _physics_process(_delta):
  update()

func _draw():
  var ext = $"../CollisionShape2D".shape.extents
  var rec = Rect2($"../CollisionShape2D".position - Vector2(ext.x, ext.y), ext * 2)
  draw_rect(rec, Color(0, 0, 1))
