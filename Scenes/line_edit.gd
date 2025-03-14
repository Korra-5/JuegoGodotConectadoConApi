extends LineEdit

var global_node

func _ready():
	# Conecta las señales
	text_submitted.connect(Callable(self, "_on_text_submitted"))
	text_changed.connect(Callable(self, "_on_text_changed"))
	
	# Obtiene la referencia al nodo global
	global_node = get_node("/root/Global")
	
	# Si ya hay un nombre guardado, lo muestra
	if global_node != null and global_node.nombre_jugador != "":
		text = global_node.nombre_jugador

func _on_text_submitted(new_text):
	guardar_nombre(new_text)

func _on_text_changed(new_text):
	# Opcionalmente guarda el nombre mientras se escribe
	guardar_nombre(new_text)

func guardar_nombre(nombre):
	if nombre != "" and global_node != null:
		global_node.nombre_jugador = nombre
		print("Nombre guardado: %s" % nombre)
