extends MarginContainer


###
# Word pixel length and line calculations inspired by
# and converted from this C++ gist posted by Pilvinen:
# https://gist.github.com/Pilvinen/c3a858e2fabe87f3ead967dd15a25d98
###

const DELIMITERS = [' ', '\n'] # Used when detecting delimiters in the raw_text.
const LINE_BREAK = '\n' # When inserting line breaks, use this character.

export(String) var raw_text = '' setget update_text # The text to display in the textbox.
export(int) var max_lines = 5 # How many lines of text to allow to be displayed.
export(int) var max_content_width = 360 # The maximum size of the textbox.
export(bool) var use_typewriter = true # Renders text updates using a typewriter effect.
export(float) var step_next_letter = 0.1 # How long to wait before advancing to the next letter.

var content_size = Vector2(0.0, 0.0) # The size of the textbox, as shown to external components.
var content_total_lines = 0 # The total lines of text.
var processed_text = '' # Processed raw text.
var step_content_percent_visible = 0.0 # How much of the text in the content box is currently visible.
var typing = false # Is typewriter effect currently typing?

# Used with word and line width calculations.
var border = {
  "left": 0,
  "top": 0,
  "right": 0,
  "bottom": 0
}

onready var TextContainer = $MarginContainer
onready var TextContent = $MarginContainer/RichTextLabel
onready var TypewriterTimer = $TypewriterTimer


# Called when the node enters the scene tree for the first time.
func _ready():
  TypewriterTimer.connect('timeout', self, '_on_TypewriterTimer_timeout')
  border = {
    "left": $MarginContainer.get('custom_constants/margin_left'),
    "top": $MarginContainer.get('custom_constants/margin_top'),
    "right": $MarginContainer.get('custom_constants/margin_right'),
    "bottom": $MarginContainer.get('custom_constants/margin_bottom')
  }
  update_text(raw_text)


func _on_TypewriterTimer_timeout():
  if TextContent.percent_visible < 1:
    TextContent.percent_visible += step_content_percent_visible
    TypewriterTimer.start(step_next_letter)
  else:
    TypewriterTimer.stop() # Otherwise the timer doesn't seem to stop. /shrug
    typing = false


# Figure out how many lines an array of processed text has within given container width.
func calculate_lines(split_text : Array, font : DynamicFont, container_width: int):
  # Shrink container width by the size of the TextContent's border,
  # since that cuts in to our available width.
  container_width = container_width - border.left - border.right

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


# Format a text string, inserting line breaks where the line length would exceed container width.
func format_text_with_line_breaks(text : String, font: DynamicFont, container_width : int):
  # Shrink container width by the size of the TextContent's border,
  # since that cuts in to our available width.
  container_width = container_width - border.left - border.right

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


# Get the number of lines in a given text within given container width.
func get_content_total_lines(text : String, font: DynamicFont, container_width : int):
  var split_text = split_and_keep_delimiters(text, DELIMITERS)

  var line_count = calculate_lines(split_text, font, container_width)

  return line_count


# Get the pixel width of a line.
func get_line_pixel_width(line : String, font: DynamicFont):
  var split_text = split_and_keep_delimiters(line, DELIMITERS)
  
  var total_pixel_width = 0
  
  for word in split_text:
    total_pixel_width += get_word_pixel_width(word, font)
  
  return total_pixel_width


# Return each line for a text string in an array.
func get_lines_array(text : String, font: DynamicFont, container_width : int):
  var formatted_text = format_text_with_line_breaks(text, font, container_width)
  return formatted_text.split(LINE_BREAK)


# Get the line with the longest pixel width.
func get_longest_line_width(text : String, font: DynamicFont, container_width : int):
  var lines_array = get_lines_array(text, font, container_width)
  
  var longest_line_length = 0.0
  for line in lines_array:
    var line_length = get_line_pixel_width(line, font)
    if line_length > longest_line_length: longest_line_length = line_length
  
  return longest_line_length


# Get the pixel height of a given string of text.
func get_pixel_height_for_text(text : String, font : DynamicFont, container_width : int):
  var font_height = font.get_height()

  var split_text = split_and_keep_delimiters(text, DELIMITERS)

  var line_count = calculate_lines(split_text, font, container_width)

  var pixel_height = line_count * font_height

  pixel_height += font.outline_size * line_count

  return pixel_height


# Get the pixel width for a given word in specified font.
func get_word_pixel_width(word : String, font : DynamicFont) -> int:
  return int(font.get_string_size(word).x)


# Renders text with the typewriter effect.
func render_typewriter():
  var text_length = processed_text.length()
  if text_length <= 0: return
  
  step_content_percent_visible = 1 / float(text_length)
  typing = true
  TextContent.percent_visible = 0
  TypewriterTimer.start(step_next_letter)


# Split text by the delimiters, but without removing the delimiter characters.
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


# Called externally when updating the textbox size.
func update_size(new_size : Vector2):
  rect_size = new_size


# Run whenever the speech bubble's text is changed.
func update_text(new_text : String):
  raw_text = new_text
    
  var font = TextContent.get_font('normal_font')
  processed_text = format_text_with_line_breaks(raw_text, font, int(max_content_width))
  TextContent.bbcode_text = processed_text

  content_total_lines = get_content_total_lines(processed_text, font, int(max_content_width))
  content_size = Vector2(
    get_longest_line_width(processed_text, font, int(max_content_width)),
    get_pixel_height_for_text(processed_text, font, int(max_content_width)) + border.top + border.bottom
  )

  if use_typewriter:
    render_typewriter()
