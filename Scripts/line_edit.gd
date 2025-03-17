# Script para LineEdit
extends LineEdit

var global_node
var jugar_button

func _ready():
	# Conecta las señales
	text_changed.connect(_on_text_changed)
	
	# Obtiene la referencia al nodo global
	global_node = get_node("/root/Global")
	
	# Busca el botón de una manera más segura - buscando por nombre
	jugar_button = get_tree().get_root().find_child("Button", true, false)
	
	# Si ya hay un nombre guardado, lo muestra
	if global_node != null and global_node.nombre_jugador != "":
		text = global_node.nombre_jugador
	
	# Actualiza el estado del botón inmediatamente
	call_deferred("_check_button_state")

func _on_text_changed(new_text):
	guardar_nombre(new_text)
	_check_button_state()

func _check_button_state():
	if jugar_button != null:
		var esta_vacio = text.strip_edges().is_empty()
		jugar_button.disabled = esta_vacio
		jugar_button.modulate = Color(0.5, 0.5, 0.5) if esta_vacio else Color(1, 1, 1)
		print("Estado del botón: " + ("deshabilitado" if esta_vacio else "habilitado"))

func guardar_nombre(nombre):
	if nombre.strip_edges() != "" and global_node != null:
		global_node.nombre_jugador = nombre
		print("Nombre guardado: %s" % nombre)
