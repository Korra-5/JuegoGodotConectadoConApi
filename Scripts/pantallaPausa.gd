extends Node

# Referencias a los botones
@onready var resume_button = $Button
@onready var retry_button = $Button2
@onready var exit_button = $Button3

func _ready():
	# Make buttons visible when needed
	resume_button.visible = false  # Initially hide all buttons
	retry_button.visible = false
	exit_button.visible = false
	
	# Set button positions to center of screen
	var screen_size = get_viewport().get_visible_rect().size
	var center_x = screen_size.x / 2
	var center_y = screen_size.y / 2
	
	# Position buttons vertically centered with proper spacing
	resume_button.position = Vector2(center_x - resume_button.size.x / 2, center_y - 100)
	retry_button.position = Vector2(center_x - retry_button.size.x / 2, center_y)
	exit_button.position = Vector2(center_x - exit_button.size.x / 2, center_y + 100)
	
	# Make buttons larger
	var scale_factor = 2.5  # Adjust as needed
	resume_button.scale = Vector2(scale_factor, scale_factor)
	retry_button.scale = Vector2(scale_factor, scale_factor)
	exit_button.scale = Vector2(scale_factor, scale_factor)
	
	print("Botones inicializados y ocultos")

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		# Cambiar el estado de pausa
		get_tree().paused = not get_tree().paused
		
		# Debug
		print("Pausa cambiada: ", get_tree().paused)
		
		if get_tree().paused:
			# Mostrar los botones
			resume_button.visible = true
			retry_button.visible = true  # Make sure this is set to true
			exit_button.visible = true   # Make sure this is set to true
			print("Botones mostrados")
		else:
			# Ocultar los botones
			resume_button.visible = false
			retry_button.visible = false
			exit_button.visible = false
			print("Botones ocultados")

func _on_button_pressed() -> void:
	# Resume - Quitar la pausa
	get_tree().paused = false
	
	# Ocultar los botones
	resume_button.visible = false
	retry_button.visible = false
	exit_button.visible = false

func _on_button_2_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_button_3_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/control.tscn")
