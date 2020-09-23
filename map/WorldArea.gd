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
  for child in get_children():
    if child is ChunkArea:
      if child.owner != self:
        child.owner = self
      add_chunk_to_chunk_areas(child)
    else:
      # Must only have ChunkArea nodes as direct children.
      push_error('Child of WorldArea "' + name + '" is not a ChunkArea (' + child.name + ')')
  
  # print_owner_tree(self)
  ResourceSaver.save(chunks_file_path + '.tres', world_area_resource)
  world_area_resource = null


func add_chunk_to_chunk_areas(chunk_area):
  chunk_area.chunk_id = chunk_areas.size()
  var unloaded_chunk_area = create_unloaded_chunk_area(chunk_area)
  world_area_resource.save_chunk_area(chunk_area)
  var data = {
    'chunk_id': chunk_area.chunk_id,
    'zone': chunk_area.zone,
    'is_loaded': false,
    'node': null,
    'load_zone': unloaded_chunk_area
  }
  chunk_areas.push_back(data)
  chunk_area.unload_chunk_area()
  add_child(unloaded_chunk_area)


func create_world_areas_dir():
  var dir = Directory.new()
  if not dir.dir_exists(WORLD_AREAS_DIR):
    dir.make_dir_recursive(WORLD_AREAS_DIR)


func create_unloaded_chunk_area(chunk_area):
  var unloaded_chunk_area = UnloadedChunkArea.new()
  unloaded_chunk_area.transform = chunk_area.transform
  unloaded_chunk_area.translation = chunk_area.translation
  unloaded_chunk_area.rotation = chunk_area.rotation
  unloaded_chunk_area.scale = chunk_area.scale
  var loading_zones = chunk_area.extract_loading_zones()
  for loading_zone in loading_zones:
    unloaded_chunk_area.add_child(loading_zone)
    loading_zone.connect_area_signals()
  return unloaded_chunk_area

func create_chunk_file():
  var file = File.new()
  file.open(chunks_file_path, File.WRITE)
  for chunk_area in chunk_areas:
    chunk_areas.insert(chunk_area.id, { "id": chunk_area.id })
    chunk_areas.remove(chunk_area.id + 1)
  file.close()


func is_chunk_area_loaded(chunk_id):
  for chunk_area in chunk_areas:
    if chunk_area.chunk_id == chunk_id and chunk_area.is_loaded:
      return true

  return false


func load_chunk_area(chunk_id):
  world_area_resource = ResourceLoader.load(chunks_file_path + '.tres', '', true)
  var loaded_chunk_area = world_area_resource.get_chunk_area(chunk_id).chunk_area
  for chunk_area in chunk_areas:
    if chunk_area.chunk_id == chunk_id:
      chunk_area.is_loaded = true
      chunk_area.node = loaded_chunk_area
  add_child(loaded_chunk_area)
  ResourceSaver.save(chunks_file_path + '.tres', world_area_resource)
  world_area_resource = null


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
      world_area_resource = ResourceLoader.load(chunks_file_path + '.tres', '', true)
      chunk_area.is_loaded = false
      world_area_resource.save_chunk_area(chunk_area.node)
      chunk_area.node.unload_chunk_area()
      chunk_area.node = null
      ResourceSaver.save(chunks_file_path + '.tres', world_area_resource)
      world_area_resource = null
