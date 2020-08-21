extends Control

# Huge help from https://gist.github.com/Pilvinen/c3a858e2fabe87f3ead967dd15a25d98

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const DELIMITERS = [' ', '\n']


onready var TE = $VBoxContainer/HBoxContainer/TextEdit
onready var RTL = $VBoxContainer/RichTextLabel
onready var L1 = $VBoxContainer/VBoxContainer/Label1
onready var L2 = $VBoxContainer/VBoxContainer/Label2
onready var L3 = $VBoxContainer/VBoxContainer/Label3
onready var L4 = $VBoxContainer/VBoxContainer/Label4
onready var L5 = $VBoxContainer/VBoxContainer/Label5
onready var L6 = $VBoxContainer/VBoxContainer/Label6
onready var L7 = $VBoxContainer/VBoxContainer/Label7
onready var L8 = $VBoxContainer/VBoxContainer/Label8
onready var L9 = $VBoxContainer/VBoxContainer/Label9


# Called when the node enters the scene tree for the first time.
func _ready():
  TE.connect('text_changed', self, '_on_text_changed')


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#  pass


func _on_text_changed():
  RTL.bbcode_text = TE.text
  var original_text = RTL.text
  # RTL.set_h_size_flags(SIZE_EXPAND_FILL)
  # RTL.set_v_size_flags(SIZE_EXPAND_FILL)
  L1.text = String(RTL.get_line_count())
  L2.text = String(RTL.get_visible_line_count())
  L3.text = String(RTL.get_content_height())
  L4.text = String(RTL.rect_size)
  var split_text = split_and_keep_delimiters(original_text, DELIMITERS)
  var font = RTL.get_font('normal_font')
  var calc_lines = calculate_lines(split_text, font, RTL.rect_size.x)
  var raw_text = original_text
  raw_text = format_text_with_line_breaks(raw_text, font, RTL.rect_size.x)
  RTL.bbcode_text = raw_text
  L5.text = String(split_text)
  L6.text = 'Split Text size: ' + String(split_text.size())
  L7.text = 'Calculated lines: ' + String(calc_lines)
  L8.text = String(font.get_wordwrap_string_size(RTL.text, RTL.rect_size.x))
  L9.text = 'Pixel Height: ' + String(get_pixel_height_for_text(RTL.text, font, RTL.rect_size.x))


###
# The following are converted from the C++ gist posted by Pilvinen
# https://gist.github.com/Pilvinen/c3a858e2fabe87f3ead967dd15a25d98
###

func get_pixel_height_for_text(text : String, font : DynamicFont, container_width : int):
  var font_height = font.get_height()

  var split_text = split_and_keep_delimiters(text, DELIMITERS)

  var line_count = calculate_lines(split_text, font, container_width)

  var pixel_height = line_count * font_height

  pixel_height += font.outline_size * line_count

  return pixel_height


func split_and_keep_delimiters(text : String, delimiters : Array):
  var parts = text.split('')
  
  if text.length() > 0:
    var finished = false
    var i = 0
    while not finished:
      for delimiter in delimiters:
        var index = parts[i].find(delimiter)
        if index > -1 and parts[i].length() > index + 1:
          var left_part = parts[i].substr(0, index + delimiter.length())
          var right_part = parts[i].substr(index + delimiter.length())
          parts[i] = left_part
          parts.insert(i + 1, right_part)
      if i == parts.size() - 1:
        finished = true
      else:
        i += 1
  
  return parts


func calculate_lines(split_text : Array, font : DynamicFont, container_width: int):
  # print('WIDTH: ', container_width)
  # How many pixels until we need to wrap to next line
  var width_until_next_line = container_width

  # Keep track of last index
  var last_index = split_text.size() - 1

  # Keep track of current index
  var index_ct = 0

  # Keep track of total lines, starting with an assumed first line
  var total_lines = 1

  # Iterate through the split text and find out how many lines it will be split into
  for word in split_text:
    var pixels_in_word = get_word_pixel_width(word, font)
    # print('Line count: ', total_lines, '. Next line:', width_until_next_line, ', Word: ', word, ' -- ', pixels_in_word, ' pixels wide')

    # If amount of pixels is more than one line can handle, go to next line.
    if pixels_in_word > width_until_next_line or word.find('\n') > -1:
      total_lines += 1

      # Subtract word pixel length from next line.
      width_until_next_line = container_width - pixels_in_word
    elif pixels_in_word == width_until_next_line:
      # Increment line counter if we aren't on the last line
      if index_ct != last_index:
        total_lines += 1
      width_until_next_line -= pixels_in_word
    else:
      # Subtract word pixel length from next line.
      width_until_next_line -= pixels_in_word
    
    index_ct += 1
  
  return total_lines


func get_word_pixel_width(word : String, font : DynamicFont) -> int:
  return int(font.get_string_size(word).x)


func format_text_with_line_breaks(text : String, font: DynamicFont, container_width : int):
  # TODO: Make delimiters a global constant
  var split_text = split_and_keep_delimiters(text, DELIMITERS)

  # The final returned text
  var formatted_text = ''

  # How many pixels until we need to wrap to next line
  var width_until_next_line = container_width

  # Keep track of last index
  var last_index = split_text.size() - 1

  # Keep track of current index
  var index_ct = 0

  # Keep track of total lines, starting with an assumed first line
  var total_lines = 1

  # Iterate through the split text and find out how many lines it will be split into
  for word in split_text:
    var pixels_in_word = get_word_pixel_width(word, font)
    # print('Line count: ', total_lines, '. Next line:', width_until_next_line, ', Word: ', word, ' -- ', pixels_in_word, ' pixels wide')

    # If amount of pixels is more than one line can handle, go to next line.
    if pixels_in_word > width_until_next_line:
      total_lines += 1

      # Inject a line break, because the calculations are not quite accurate enough.
      # We just need to guarantee that the textbox shows a new line if it calculates it should.
      word = '\n' + word

      # Subtract word pixel length from next line.
      width_until_next_line = container_width - pixels_in_word
    elif word.find('\n') > -1:
      total_lines += 1
      width_until_next_line = container_width - pixels_in_word
    elif pixels_in_word == width_until_next_line:
      # Increment line counter if we aren't on the last line
      if index_ct != last_index:
        total_lines += 1
      width_until_next_line -= pixels_in_word
    else:
      # Subtract word pixel length from next line.
      width_until_next_line -= pixels_in_word
    
    index_ct += 1
    formatted_text += word
  
  return formatted_text
