extends Button


func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/node_2d.tscn")


func _on_button_salir_pressed() -> void:
	get_tree().quit()
