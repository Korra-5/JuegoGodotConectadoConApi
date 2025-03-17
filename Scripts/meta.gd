extends Area2D

func _ready():
	# Conecta la señal para detectar cuando un cuerpo ingresa al área.
	body_entered.connect(_on_body_entered)
	print("Espada lista para ser recogida")

func _process(delta):
	pass

# Se ejecuta cuando un cuerpo (por ejemplo, el jugador) entra en el área.
func _on_body_entered(body):
	detener_cronometro()
	print("Colisión detectada con:", body.name)
	
	if body.is_in_group("Player") or body.name == "CharacterBody2D":
		print("Ítem recogido: Espada")
		
		# Oculta la espada y desactiva sus colisiones para evitar múltiples activaciones.
		visible = false
		set_deferred("monitoring", false)
		set_deferred("monitorable", false)
		
		# Llamamos a la función de guardado SIN diferir la llamada;
		# de este modo se ejecuta antes de cambiar la escena.
		hacer_peticion_guardar_datos()
		
		# Cambiamos a la escena final.
		get_tree().change_scene_to_file("res://Scenes/Fin.tscn")
		
		# Liberamos este nodo ya que no se necesita conservarlo.
		queue_free()

func hacer_peticion_guardar_datos():
	print("Iniciando petición de guardado")
	
	# Accedemos a nuestro autoload Global (asegúrate de que esté configurado como autoload y extienda de Node).
	if Global == null:
		print("No se pudo encontrar el nodo Global. Revisa la configuración del autoload.")
		return
	
	var nombre = Global.nombre_jugador
	var tiempo = Global.tiempo_jugador
	
	# Convertimos el tiempo a string con 2 decimales y volvemos a formatearlo a float.
	var tiempo_str = "%.2f" % tiempo
	var tiempo_formateado = float(tiempo_str)
	
	print("Datos obtenidos del Global: Nombre=%s, Tiempo=%s (formateado: %s)" % [nombre, tiempo, tiempo_formateado])
	
	# Preparamos los datos a enviar.
	var datos = {
		"Name": nombre,
		"Time": tiempo_formateado
	}
	var json_data = JSON.stringify(datos)
	print("Datos a enviar: " + json_data)
	
	# Creamos la instancia del HTTPRequest.
	var http_request = HTTPRequest.new()
	# En lugar de usar get_tree().get_root(), agregamos el HTTPRequest como hijo de Global,
	# que al ser un autoload (Node) siempre estará en la SceneTree.
	Global.add_child(http_request)
	
	# Conectamos la señal de finalización de la petición.
	http_request.request_completed.connect(_on_request_completed)
	
	# Configuramos las cabeceras y el endpoint de la API.
	var headers = ["Content-Type: application/json"]
	var url = "https://api-juegogodot.onrender.com/api/JuegoItems"
	
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, json_data)
	if error != OK:
		print("Error al enviar la petición HTTP: " + str(error))
	else:
		print("Petición HTTP enviada correctamente.")

func _on_request_completed(result, response_code, headers, body):
	print("Petición completada. Código de respuesta: " + str(response_code))
	if response_code == 200 or response_code == 201:
		print("Datos guardados correctamente")
		if body.size() > 0:
			var json_result = JSON.parse_string(body.get_string_from_utf8())
			print("Respuesta del servidor:", json_result)
	else:
		print("Error al guardar datos: " + str(response_code))
		if body.size() > 0:
			print("Cuerpo de respuesta:", body.get_string_from_utf8())

func detener_cronometro():
	var cronometro = get_tree().get_nodes_in_group("cronometro")
	if cronometro.size() > 0:
		if cronometro[0].has_method("stop_timer"):
			cronometro[0].stop_timer()
			print("Cronómetro detenido correctamente")
	else:
		print("No se pudo encontrar el cronómetro")
