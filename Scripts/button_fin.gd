#Boton que te devuelve a la pantalla principal
extends Button


func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/control.tscn")
