extends Spatial

class_name WorldArea


const WORLD_AREAS_DIR = 'user://_world_areas/'

var WorldAreaResource = preload('res://map/WorldAreaResource.gd')

var chunk_areas = []

onready var chunks_file_path = WORLD_AREAS_DIR + name + '.chunkdata'
onready var world_area_resource = WorldAreaResource.new()

# Called when the node enters the scene tree for the first time.
func _ready():
  create_world_areas_dir()
  # Put all the chunk areas into an array.
  print('ffff')
  for child in get_children():
    print('derp')
    if child is ChunkArea:
      if child.owner != self:
        child.owner = self
      add_chunk_to_chunk_areas(child)
    else:
      # Must only have ChunkArea nodes as children.
      push_error('Child of WorldArea "' + name + '" is not a ChunkArea (' + child.name + ')')
  print('fin dat')
  print_owner_tree(self)
  # create_chunk_file()
  print(chunk_areas)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  pass


func add_chunk_to_chunk_areas(chunk_area):
  chunk_area.chunk_id = chunk_areas.size()
  world_area_resource.save_chunk_area(chunk_area)
  var data = {
    'chunk_id': chunk_area.chunk_id,
    'zone': chunk_area.zone,
    'is_loaded': false,
    'node': null
  }
  chunk_areas.push_back(data)
  chunk_area.unload_chunk_area()


func create_world_areas_dir():
  var dir = Directory.new()
  if not dir.dir_exists(WORLD_AREAS_DIR):
    dir.make_dir_recursive(WORLD_AREAS_DIR)


func create_chunk_file():
  # return
  var file = File.new()
  file.open(chunks_file_path, File.WRITE)
  print(chunks_file_path)
  print('FP: ', file.get_path_absolute(), file.is_open())
  for chunk_area in chunk_areas:
    chunk_areas.insert(chunk_area.id, { "id": chunk_area.id })
    chunk_areas.remove(chunk_area.id + 1)
  file.close()


func is_chunk_area_loaded(chunk_id):
  print(chunk_areas)
  for chunk_area in chunk_areas:
    if chunk_area.chunk_id == chunk_id and chunk_area.is_loaded:
      print('YEP')
      return true

  print('NOPE')
  return false


func load_chunk_area(chunk_id):
  var loaded_chunk_area = world_area_resource.get_chunk_area(chunk_id).chunk_area.instance()
  for chunk_area in chunk_areas:
    if chunk_area.chunk_id == chunk_id:
      chunk_area.is_loaded = true
      chunk_area.node = loaded_chunk_area
  add_child(loaded_chunk_area)


# Prepare a chunk for packing.
func pack_chunk(chunk_node):
  var packed_chunk = chunk_node.get_serialized_chunk()
  return packed_chunk


func print_owner_tree(root_node):
  print(root_node.name, ' owned by ', root_node.get_owner().name)
  for child in root_node.get_children():
    if child.get_children().size() > 0:
      print_owner_tree(child)
    else:
      print(child.name, ' owned by ', child.get_owner().name)


func unload_chunk_area(chunk_id):
  for chunk_area in chunk_areas:
    if chunk_area.chunk_id == chunk_id:
      chunk_area.is_loaded = false
      world_area_resource.save_chunk_area(chunk_area.node)
      chunk_area.node.unload_chunk_area()
      chunk_area.node = null
