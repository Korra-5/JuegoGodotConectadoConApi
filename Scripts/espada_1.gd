extends Area2D

func _ready():
	# Conectar la señal correctamente
	body_entered.connect(_on_body_entered)
	print("Espada lista para ser recogida")

func _process(delta):
	# Lógica de actualización si es necesaria
	pass

# Función que se ejecuta cuando el cuerpo del jugador entra en el área
func _on_body_entered(body):
	detener_cronometro()
	print("Colisión detectada con: ", body.name)
	
	# Verificar si el cuerpo es el jugador
	if body.is_in_group("Player") or body.name == "CharacterBody2D":
		print("Ítem recogido: Espada")
		
		# 1. Primero, ocultar la espada visualmente o reproducir una animación
		visible = false  # Oculta la espada inmediatamente
		
		# 2. Desactivar colisiones para evitar activaciones múltiples
		set_deferred("monitoring", false)
		set_deferred("monitorable", false)
		
		# 3. Luego, guardar los datos
		hacer_peticion_guardar_datos()

func hacer_peticion_guardar_datos():
	print("Iniciando petición de guardado")
	
	# Obtén el nodo global
	var global_node = get_node("/root/Global")
	
	if global_node == null:
		print("No se pudo encontrar el nodo Global")
		finalizar_recogida()
		return
	
	# Obtén los datos del jugador
	var nombre = global_node.nombre_jugador
	var tiempo = global_node.tiempo_jugador
	
	# Convertir a string con exactamente 2 decimales para mantener la precisión
	var tiempo_str = "%.2f" % tiempo
	# Convertir de nuevo a float para asegurar formato correcto
	var tiempo_formateado = float(tiempo_str)
	
	print("Datos obtenidos del global: Nombre=%s, Tiempo=%s (formateado: %s)" % [nombre, tiempo, tiempo_formateado])
	
	# Prepara los datos a enviar
	var datos = {
		"Name": nombre,
		"Time": tiempo_formateado
	}
	
	var json_data = JSON.stringify(datos)
	print("Datos a enviar: " + json_data)
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	# Conecta la señal de finalización
	http_request.request_completed.connect(_on_request_completed)
	
	# Define las cabeceras
	var headers = ["Content-Type: application/json"]
	
	# Endpoint de tu API
	var url = "https://api-juegogodot.onrender.com/api/JuegoItems"
	
	# Envía la petición POST
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, json_data)
	if error != OK:
		print("Error al enviar la petición HTTP: " + str(error))
		finalizar_recogida()
	else:
		print("Petición HTTP enviada correctamente.")

func _on_request_completed(result, response_code, headers, body):
	print("Petición completada. Código de respuesta: " + str(response_code))
	
	if response_code == 200 or response_code == 201:
		print("Datos guardados correctamente")
		# Puedes imprimir la respuesta del servidor si quieres
		if body.size() > 0:
			var json_result = JSON.parse_string(body.get_string_from_utf8())
			print("Respuesta del servidor: ", json_result)
	else:
		print("Error al guardar datos: " + str(response_code))
		if body.size() > 0:
			print("Cuerpo de respuesta: ", body.get_string_from_utf8())
	
	# Finalmente, continuar con la secuencia de recoger objeto
	finalizar_recogida()

# Función que finaliza la secuencia de recoger el objeto
func finalizar_recogida():
	# Cambiar a la escena final
	get_tree().change_scene_to_file("res://Scenes/Fin.tscn")
	
	# Eliminar esta instancia (espada)
	queue_free()
	
func detener_cronometro():
	# Buscar el nodo del cronómetro en la escena
	var cronometro = get_tree().get_nodes_in_group("cronometro")
	
	if cronometro.size() > 0:
		if cronometro[0].has_method("stop_timer"):
			cronometro[0].stop_timer()
			print("Cronómetro detenido correctamente")
	else:
		print("No se pudo encontrar el cronómetro")
