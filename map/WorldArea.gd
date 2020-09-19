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
      # print('Burger: ', child.get_serialized_chunk())
      if child.owner != self:
        child.owner = self
      add_chunk_to_chunk_areas(child)
      # child.unload_chunk_area()
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
    'zone': chunk_area.zone
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
    # print('CA: ', chunk_area)
    file.store_line(to_json(chunk_area))
    # ResourceSaver.save(chunks_file_path + String(chunk_area.id) + '.tscn', chunk_area.node)
    chunk_areas.insert(chunk_area.id, { "id": chunk_area.id })
    chunk_areas.remove(chunk_area.id + 1)
  file.close()


func load_chunk_area(chunk_id):
  # var chunk_area = load_chunk_area_from_file(chunk_id)
  # var scene = PackedScene.new()
  var chunk_area = world_area_resource.get_chunk_area(chunk_id).chunk_area.instance()
  # var chunk_area_node = chunk_area.node.instance()
  add_child(chunk_area)


func load_chunk_area_from_file(chunk_id):
  var file = File.new()
  if not file.file_exists(chunks_file_path): # No save file created yet.
    return
  file.open(chunks_file_path, File.READ)
  var i = 0
  var chunk_area
  var chunk_found = false
  while not file.eof_reached() and not chunk_found:
    var line = file.get_line()
    if i != chunk_id:
      continue
    chunk_area = parse_json(line)
    chunk_found = true
    break
  file.close()
  # breakpoint
  return chunk_area



# Prepare a chunk for packing.
func pack_chunk(chunk_node):
  # var packed_chunk = PackedScene.new()
  # packed_chunk.pack(chunk_node)
  # packed_chunk = inst2dict(packed_chunk)
  # var packed_chunk = inst2dict(chunk_node)
  var packed_chunk = chunk_node.get_serialized_chunk()
  # print('ffefe ', packed_chunk)
  return packed_chunk


# Check if this node 

func print_owner_tree(root_node):
  print(root_node.name, ' owned by ', root_node.get_owner().name)
  for child in root_node.get_children():
    if child.get_children().size() > 0:
      print_owner_tree(child)
    else:
      print(child.name, ' owned by ', child.get_owner().name)
