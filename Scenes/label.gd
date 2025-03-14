extends Label

# Hacemos esta variable pública para acceder desde otros scripts
var tiempo_jugador: float = 0.0
var timer: Timer

func _ready():
	# Crear un Timer como hijo del Label
	timer = Timer.new()
	add_child(timer)
	
	# Configurar el Timer
	timer.wait_time = 0.01  # Actualizar cada centésima de segundo
	timer.autostart = true
	timer.one_shot = false  # Para que se repita continuamente
	
	# Conectar la señal timeout del Timer a nuestro método
	timer.timeout.connect(Callable(self, "_on_timer_timeout"))
	
	# Iniciar el Timer
	timer.start()
	
	update_global_time()
	


func _on_timer_timeout():
	# Incrementa el tiempo transcurrido
	tiempo_jugador += timer.wait_time
	
	# Actualiza el texto del Label
	text = str(floor(tiempo_jugador * 100) / 100.0) + " s"
	
	# Actualiza la variable global
	update_global_time()

func update_global_time():
	Global.tiempo_jugador = tiempo_jugador
