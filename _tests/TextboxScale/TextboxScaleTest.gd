extends Control

# Huge help from https://gist.github.com/Pilvinen/c3a858e2fabe87f3ead967dd15a25d98

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


onready var TE = $VBoxContainer/HBoxContainer/TextEdit
onready var RTL = $RichTextLabel
onready var L1 = $VBoxContainer/VBoxContainer/Label1
onready var L2 = $VBoxContainer/VBoxContainer/Label2
onready var L3 = $VBoxContainer/VBoxContainer/Label3
onready var L4 = $VBoxContainer/VBoxContainer/Label4
onready var L5 = $VBoxContainer/VBoxContainer/Label5
onready var L6 = $VBoxContainer/VBoxContainer/Label6


# Called when the node enters the scene tree for the first time.
func _ready():
  TE.connect('text_changed', self, '_on_text_changed')


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#  pass


func _on_text_changed():
  RTL.bbcode_text = TE.text
  # RTL.set_h_size_flags(SIZE_EXPAND_FILL)
  # RTL.set_v_size_flags(SIZE_EXPAND_FILL)
  L1.text = String(RTL.get_line_count())
  L2.text = String(RTL.get_visible_line_count())
  L3.text = String(RTL.get_content_height())
  L4.text = String(RTL.rect_size)
  var split_text = split_and_keep_delimiters(TE.text, [' '])
  L5.text = String(split_text)
  L6.text = String(split_text.size())


###
# The following are converted from the C++ gist posted by Pilvinen
# https://gist.github.com/Pilvinen/c3a858e2fabe87f3ead967dd15a25d98
###

func get_pixel_height_for_text(text : String, font : DynamicFont):
  var font_height = font.get_height()


func split_and_keep_delimiters(text : String, delimiters: Array):
  var parts = text.split('')
  
  if text.length() > 0:
    for delimiter in delimiters:
      var finished = false
      var i = 0

      while not finished:
        var index = parts[i].find(delimiter)

        if index > -1 and parts[i].length() > index + 1:
          var left_part = parts[i].substr(0, index + delimiter.length())
          var right_part = parts[i].substr(index + delimiter.length())
          parts[i] = left_part
          parts.insert(i + 1, right_part)
          i += 1
        else:
          finished = true
  
  return parts
