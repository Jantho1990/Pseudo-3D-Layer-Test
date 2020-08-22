extends MarginContainer


const DELIMITERS = [' ', '\n']
const LINE_BREAK = '\n'

export(String) var raw_text = ''
export(int) var max_lines = 5
export(int) var max_content_width = 360

var old_raw_text = ''
var processed_text = ''
var content_height = 0.0
var content_width = 0.0
var content_size = Vector2(0.0, 0.0)
var content_total_lines = 0

onready var TextContent = $RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready():
  update_text()


func _process(_delta):
  if old_raw_text != raw_text:
    update_text()


func get_longest_line_width(text : String, font: DynamicFont, container_width : int):
  var lines_array = get_lines_array(processed_text, font, container_width)
  
  var longest_line_length = 0.0
  for line in lines_array:
    var line_length = get_line_pixel_width(line, font)
    if line_length > longest_line_length: longest_line_length = line_length
  
  return longest_line_length


func get_content_total_lines(text : String, font: DynamicFont, container_width : int):
  var split_text = split_and_keep_delimiters(text, DELIMITERS)

  var line_count = calculate_lines(split_text, font, container_width)

  return line_count


###
# The following are inspired by and converted from the C++ gist posted by Pilvinen
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

  # Iterate through the split text and find out how many lines it will be split into
  for word in split_text:
    var pixels_in_word = get_word_pixel_width(word, font)

    # If amount of pixels is more than one line can handle, go to next line.
    if pixels_in_word > width_until_next_line:
      # Inject a line break, because the calculations are not quite accurate enough.
      # We just need to guarantee that the textbox shows a new line if it calculates it should.
      word = LINE_BREAK + word

      # Subtract word pixel length from next line.
      width_until_next_line = container_width - pixels_in_word
    elif word.find(LINE_BREAK) > -1:
      width_until_next_line = container_width - pixels_in_word
    else:
      width_until_next_line -= pixels_in_word
    
    formatted_text += word
  
  return formatted_text


func get_lines_array(text : String, font: DynamicFont, container_width : int):
  var formatted_text = format_text_with_line_breaks(text, font, container_width)
  return formatted_text.split(LINE_BREAK)


func get_line_pixel_width(line : String, font: DynamicFont):
  var split_text = split_and_keep_delimiters(line, DELIMITERS)
  
  var total_pixel_width = 0
  
  for word in split_text:
    total_pixel_width += get_word_pixel_width(word, font)
  
  return total_pixel_width


func update_text():
  old_raw_text = raw_text
    
  var font = TextContent.get_font('normal_font')
  processed_text = format_text_with_line_breaks(raw_text, font, int(rect_size.x))
  TextContent.bbcode_text = processed_text

  content_total_lines = get_content_total_lines(processed_text, font, int(rect_size.x))
  content_height = get_pixel_height_for_text(processed_text, font, int(rect_size.x))
  content_size = Vector2(
    get_longest_line_width(processed_text, font, int(rect_size.x)),
    get_pixel_height_for_text(processed_text, font, int(rect_size.x))
  )
