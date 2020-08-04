extends Node

# Keeps track of all characters being used in the game, allowing them to be accessed by the dialogue handler.


var characters = {}


func get_character(character_name):
  return characters[character_name]


func register_character(character):
  characters[character.name] = character