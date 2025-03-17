#Boton para salir 
extends Button

func _ready():
	pressed.connect(on_exit_pressed)

func on_exit_pressed() -> void:
	get_tree().quit()
