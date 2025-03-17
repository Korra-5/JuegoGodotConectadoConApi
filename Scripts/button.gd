# Boton para jugar que verifica que el jugador haya insertado un nombre en el LineEdit primero
extends Button

func _ready():
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)
	
	var line_edit = get_tree().get_root().find_child("LineEdit", true, false)
	if line_edit != null:
		var esta_vacio = line_edit.text.strip_edges().is_empty()
		disabled = esta_vacio
		modulate = Color(0.5, 0.5, 0.5) if esta_vacio else Color(1, 1, 1)

func _on_pressed() -> void:
	var line_edit = get_tree().get_root().find_child("LineEdit", true, false)
	if line_edit != null and not line_edit.text.strip_edges().is_empty():
		get_tree().change_scene_to_file("res://Scenes/node_2d.tscn")
	else:
		print("No se puede jugar sin nombre")
