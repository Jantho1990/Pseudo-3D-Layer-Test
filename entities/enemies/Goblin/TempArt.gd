extends Node2D


func _physics_process(_delta):
  update()

func _draw():
  var ext = $"../CollisionShape2D".shape.extents
  var pos = $"../CollisionShape2D".position
  var rec = Rect2(pos - Vector2(ext.x, ext.y), ext * 2)
  draw_rect(rec, Color(0.1, 0.2, 0.3))

  # Draw attack
  var weapon = $"../BiteAttack"
  var weapon_ext = weapon.get_node('CollisionShape2D').shape.extents
  var weapon_pos = weapon.position
  var weapon_rec = Rect2(weapon_pos - Vector2(weapon_ext.x, weapon_ext.y), weapon_ext * 2)
  draw_rect(weapon_rec, Color(0.5, 0.5, 0.1))
