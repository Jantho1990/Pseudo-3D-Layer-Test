extends Node


const ROOT_DIRECTORY = 'res://'
const SEPARATOR = '/' # Godot only supports forward slash.


func create_file(full_path):
    var path_array = full_path.split(SEPARATOR)
    for path in path_array:
        pass