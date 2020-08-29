extends ImmediateGeometry


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    # Clean up before drawing.
    clear()

    # Begin draw.
    begin(Mesh.PRIMITIVE_TRIANGLES)

    # Prepare attributes for add_vertex.
    set_normal(Vector3(0, 0, 1))
    set_uv(Vector2(0, 0))
    # Call last for each vertex, adds the above attributes.
    add_vertex(Vector3(-1, -1, 0))

    set_normal(Vector3(0, 0, 1))
    set_uv(Vector2(0, 1))
    add_vertex(Vector3(-1, 1, 0))

    set_normal(Vector3(0, 0, 1))
    set_uv(Vector2(1, 1))
    add_vertex(Vector3(1, 1, 0))

    # End drawing.
    end()