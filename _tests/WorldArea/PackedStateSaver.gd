extends Node

class_name PackedStateSaver


export(Array, String) var parent_properties setget set_parent_properties,get_parent_properties # Defines which properties from the parent we want to pack.

export(Dictionary) var packed_state setget set_packed_state,get_packed_state # Used to store the packed state of the parent node.

var _parent_properties
var _packed_state


func __private_set(_throwaway1_):
  print('Private property. (', _throwaway1_, ')')

func __private_get():
  print('Private property')


func _ready():
  _parent_properties = parent_properties
  _packed_state = packed_state


func add_parent_property(value):
  _parent_properties.push_back(value)


func set_parent_properties(value):
  if not get_parent():
    yield(self, 'ready')
  _parent_properties = value


func get_parent_properties():
  return _parent_properties


func set_packed_state(value):
  _packed_state = value


func get_packed_state():
  return _packed_state


func pack_parent_properties():
  var parent = get_parent()
  for property in get_parent_properties():
    if property in parent:
      self.packed_state[property] = parent[property]
    else:
      push_error('Packed state property "' + property + '" does not exist in parent "' + parent.name + '"')


func unpack_parent_properties():
  var parent = get_parent()
  for key in self.packed_state.keys():
    parent.set(key, self.packed_state[key])
