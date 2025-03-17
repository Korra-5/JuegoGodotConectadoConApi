extends Label

func _ready():
	# Inicializar etiqueta con mensaje de carga
	text = "Cargando tu puntuación..."
	
	# Obtener datos del jugador del nodo global
	var global_node = get_node("/root/Global")
	if global_node:
		var nombre_jugador = global_node.nombre_jugador
		var tiempo_jugador = global_node.tiempo_jugador
		
		# Mostrar la puntuación del jugador actual
		text = "Tu puntuación:\n%s: %.2f segundos" % [nombre_jugador, tiempo_jugador]
	else:
		text = "Error: No se pudo acceder a los datos del jugador"
