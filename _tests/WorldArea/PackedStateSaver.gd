extends Node

class_name PackedStateSaver


export(Array, String) var parent_properties = [] # Defines which properties from the parent we want to pack.

export(Dictionary) var packed_state = {} # Used to store the packed state of the parent node.


func __private_set(_throwaway1_):
  print('Private property. (', _throwaway1_, ')')

func __private_get():
  print('Private property')

func pack_parent_properties():
  var parent = get_parent()
  for property in parent_properties:
    if property in parent:
      packed_state[property] = parent[property]
    else:
      push_error('Packed state property "' + property + '" does not exist in parent "' + parent.name + '"')


func unpack_parent_properties():
  var parent = get_parent()
  for key in packed_state.keys():
    parent.set(key, packed_state[key])
