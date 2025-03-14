extends Label

# Función que se ejecuta cuando la escena está lista
func _ready():
	# Inicializar etiquetas con mensajes de carga
	text = "Cargando mejores puntuaciones..."
	
	# Cargar las 5 mejores puntuaciones
	cargar_mejores_puntuaciones()

# Función para cargar las 5 mejores puntuaciones desde la API
func cargar_mejores_puntuaciones():
	# Crear petición HTTP
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	# Conectar la señal de finalización
	http_request.request_completed.connect(_on_top_scores_request_completed)
	
	# URL del endpoint para obtener las 5 mejores puntuaciones
	var url = "https://api-juegogodot.onrender.com/api/JuegoItems/top5"
	
	# Enviar petición GET
	var error = http_request.request(url)
	if error != OK:
		text = "Error al cargar puntuaciones: " + str(error)
func _on_top_scores_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		text = "Error de conexión"
		return
		
	if response_code != 200:
		text = "Error del servidor: " + str(response_code)
		return
	
	# Procesar la respuesta JSON y añadir depuración detallada
	var json_result = JSON.parse_string(body.get_string_from_utf8())
	
	# Verificar si json_result es válido
	if json_result == null:
		text = "Error: JSON nulo"
		return
		
	# Verificar tipo de json_result
	print("Tipo de json_result: ", typeof(json_result))
	if typeof(json_result) != TYPE_ARRAY:
		text = "Error: No es un array, es tipo " + str(typeof(json_result))
		return
	
	# Depurar la estructura del JSON
	print("Contenido completo del JSON: ", json_result)
	
	# Construir el texto para mostrar las puntuaciones
	var scores_text = "TOP 5 MEJORES TIEMPOS:\n\n"
	
	var posicion = 1
	for item in json_result:
		print("Tipo de item: ", typeof(item))
		print("Contenido de item: ", item)
		
		# Verificar si las claves existen
		print("Claves disponibles: ", item.keys())
		
		# Intenta acceder utilizando diferentes métodos
		var nombre = ""
		var tiempo = 0.0
		
		if item.has("Name"):
			nombre = item["Name"]
		elif item.has("name"):
			nombre = item["name"]  # Comprueba con minúsculas también
		else:
			nombre = "Desconocido"
			
		if item.has("Time"):
			tiempo = item["Time"]
		elif item.has("time"):
			tiempo = item["time"]  # Comprueba con minúsculas también
		else:
			tiempo = 0.0
			
		scores_text += "%d. %s: %.2f segundos\n" % [posicion, nombre, tiempo]
		posicion += 1
	
	# Mostrar las puntuaciones en la etiqueta
	text = scores_text
