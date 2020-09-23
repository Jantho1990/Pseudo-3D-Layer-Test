extends Node

class_name StackQueue


var _stack = [] setget __private_set,__private_get


func __private_set(_throwaway_):
  print('Private property, cannot set.')


func __private_get():
  print('Private property, cannot get.')


func get_top():
  return _stack[0]


func pop():
  return _stack.pop_front()


func push(value):
  _stack.push_front(value)