extends MarginContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
  print('Lines: ', $RichTextLabel.get_line_count())
  print('Visible Lines: ', $RichTextLabel.get_visible_line_count())
  print('Content height: ', $RichTextLabel.get_content_height())
  # $RichTextLabel.bbcode_text = 'Oh phooey'
  # print('Lines: ', $RichTextLabel.get_line_count())  
  # print('Visible Lines: ', $RichTextLabel.get_visible_line_count())
  # print('Content height: ', $RichTextLabel.get_content_height())


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#  pass
