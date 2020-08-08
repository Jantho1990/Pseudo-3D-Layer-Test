extends Node

# Loads dialogue script files, stores them, and exposes methods to run the scripts.


const SCRIPT_PATH = 'res://dialogue_scripts'
const DIALOGUE_PATH = '/dialogue'
const LORE_PATH = '/lore'

###
# Dialogue and lore store
###
var dialogue_scripts_dict = {} # Stores all the dialogue scripts.
var lore_scripts_dict = {} # Stores all the lore scripts.

###
# Dialogue and lore renderers
###
var dialogue_renderers = {}
var dialogue_default_renderer = ''
var lore_renderers = {}
var lore_default_renderer = ''


###
# Story global data store.
###
var story_data = preload('res://scripts/DataStore.gd')
var story_markup_regex = RegEx.new()


func _ready():
  load_dialogues()
  load_lore()
  story_data = story_data.new()
  story_markup_regex.compile('(?:{{)([A-z0-9\\.]*)(?:}})')


# Create a new value in the story data global.
func create_story_data(key, value):
  # Prevents us from overriding existing data value.
  if story_data.has(key):
    # This might be broken, test map let me overwrite a key.
    # Which is what the global data store is supposed to do,
    # but this check is supposed to prevent that for our case.
    # /shrug
    print('Key "', key, '" already exists in global story data')
    return
  
  story_data.set(key, value)


func get_key_from_store(key, store_type):
  match store_type:
    'dialogue':
      if dialogue_scripts_dict.has(key): return dialogue_scripts_dict[key]
    'lore':
      if lore_scripts_dict.has(key): return lore_scripts_dict[key]
    _:
      print('Store "', store_type, '" not found for "', key ,'".')
  
  print('Key "', key, '" not found in "', store_type ,'".')


# Get story data.
func get_story_data(key):
  if story_data.has(key):
    return story_data.get(key)
  
  return null


# Load all dialogue scripts from the dialogues directory.
func load_dialogues():
  store_data_from_dir(SCRIPT_PATH + DIALOGUE_PATH, dialogue_scripts_dict)


# Load all lore scripts from the lore directory.
func load_lore():
  store_data_from_dir(SCRIPT_PATH + LORE_PATH, lore_scripts_dict)


# Parse a line of text and replace markup with story data values.
func parse_text_story_data(text):
  var ret = text
  for result in story_markup_regex.search_all(text):
    var target = result.get_string(0) # Using 0 to get the brackets with the value.
    var key = result.get_string(1) # Using 1 to get the actual value, which is our key.
    var story_data_value = story_data.get(key)
    ret = ret.replace(target, story_data_value)
  return ret


# Called by a renderer to register itself in the list of renderers.
func register_renderer(renderer_node, renderer_type : String, mark_as_default := false):
  match renderer_type:
    'dialogue':
      dialogue_renderers[renderer_node.name] = renderer_node
      if mark_as_default or dialogue_renderers.size() == 1: dialogue_default_renderer = renderer_node.name
    'lore':
      lore_renderers[renderer_node.name] = renderer_node
      if mark_as_default or dialogue_renderers.size() == 1: lore_default_renderer = renderer_node.name
    _:
      print('Renderer type "', renderer_type, '" not found.')


# Set a value for an existing value in the story data global.
func set_story_data(key, value):
  # Can only set data to values that have already been created.
  if not story_data.has('key'):
    print('Key "', key, '" not found in global story data.')
    return
  
  story_data.set(key, value)


# Begins the process of rendering a dialogue script.
func show_dialogue(dialogue_name):
  var dialogue = get_key_from_store(dialogue_name, 'dialogue')
  if not dialogue: return
  
  var renderer = dialogue_renderers[dialogue_default_renderer] \
    if !dialogue.has('renderer') \
    else dialogue_renderers[dialogue.renderer]

  renderer.render(dialogue)
  GlobalSignal.dispatch('dialogue_render', dialogue)


# Begins the process of rendering a lore script.
func show_lore(lore_name):
  pass


# Load all scripts from a directory and store them in the target data store.
func store_data_from_dir(dir_path, data_store):
  var dir = Directory.new()
  if dir.open(dir_path) == OK:
    dir.list_dir_begin(true)
    var file = File.new()
    var file_name = dir.get_next()
    while file_name != '':
      if dir.current_is_dir():
        file_name = dir.get_next()
        continue
      file.open(dir_path + '/' + file_name, file.READ)
      var json_string = file.get_as_text()
      var json = JSON.parse(json_string).result
      var key = file_name if !json.has('key') else json.key
      data_store[key] = json
      file.close()
      file_name = dir.get_next()
