extends Area2D

func _ready():
	# Conectar la señal correctamente
	connect("body_entered", Callable(self, "_on_body_entered"))

func _process(delta):
	# Lógica de actualización
	pass

# Corregido el nombre del método para que coincida con la señal
func _on_body_entered(body):
	print("Ítem recogido: Espada")
	# Llama al método para realizar la petición HTTP que guarda los datos
	hacer_peticion_guardar_datos()
	# Elimina la espada de la escena
	queue_free()
	# Cambia a la escena final
	get_tree().change_scene_to_file("res://Scenes/Fin.tscn")

func hacer_peticion_guardar_datos():
	print("Iniciando petición de guardado")
	
	# Obtén el nodo global "Global" (asegúrate de tener configurado el autoload)
	var global_node = null
	if ProjectSettings.has_setting("autoload/Global"):
		global_node = get_node("/root/Global")
	else:
		# Intenta cargar directamente
		global_node = get_tree().root.get_node_or_null("/root/Global")
		if global_node == null:
			# Intenta cargar el archivo global.gd
			global_node = load("res://Scripts/global.gd").new()
			add_child(global_node)
	
	# Intenta obtener los valores del script global
	var nombre
	var tiempo 
	
	# En GDScript el acceso a variables es más directo
	if global_node != null:
		if global_node.has_method("get_property"):
			# Si tiene el método get_property
			nombre = global_node.get_property("nombre_jugador")
			tiempo = global_node.get_property("tiempo_jugador")
		else:
			# Acceso directo a propiedades
			nombre = global_node.nombre_jugador
			tiempo = global_node.tiempo_jugador 
		print("Datos obtenidos del global: Nombre=%s, Tiempo=%s" % [nombre, tiempo])
	else:
		print("No se pudo encontrar el nodo Global")
	
	# Prepara un diccionario con los datos a enviar
	var datos = {
		"Name": nombre,
		"Time": tiempo
	}
	
	# Convierte el diccionario a JSON
	var json_data = JSON.stringify(datos)
	print("Datos a enviar: " + json_data)
	
	# Crea dinámicamente un nodo HttpRequest y añádelo a la escena
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	# Conecta la señal de finalización de la petición
	http_request.request_completed.connect(self._on_request_completed)
	
	# Define las cabeceras de la petición
	var headers = ["Content-Type: application/json"]
	
	# Endpoint de tu API
	var url = "https://api-juegogodot.onrender.com/api/JuegoItems"
	
	# Envía la petición POST
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, json_data)
	if error != OK:
		print("Error al enviar la petición HTTP: " + str(error))
	else:
		print("Petición HTTP enviada correctamente.")

func _on_request_completed(result, response_code, headers, body):
	print("Petición completada. Código de respuesta: " + str(response_code))
	if response_code == 200 or response_code == 201:
		print("Datos guardados correctamente")
	else:
		print("Error al guardar datos: " + str(response_code))
