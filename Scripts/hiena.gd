extends CharacterBody2D

var velocidad: int = 100
var salud_maxima: int = 3
var salud_actual: int = 3
var is_hit: bool = false
var knockback_force: int = -200
var knockback_duration: float = 0.3
var knockback_timer: float = 0.0
var knockback_direction: Vector2 = Vector2.ZERO
var blink_timer: float = 0.0
var blink_duration: float = 0.6
var blink_interval: float = 0.1
const DEATH_TIMER = 1.0  # Tiempo de espera antes de desaparecer
var is_dying: bool = false
var death_timer: float = 0.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var health_bar = $HealthBar

func _ready():
	velocity.x = -velocidad
	add_to_group("enemies")
	
	if health_bar:
		health_bar.max_value = salud_maxima
		health_bar.value = salud_actual
		health_bar.visible = true

	if animated_sprite:
		animated_sprite.play("walk")
	
	print("Hiena inicializada. Salud: ", salud_actual)

func _physics_process(delta):
	if is_dying:
		death_timer -= delta
		if death_timer <= 0:
			queue_free()
			return
		move_and_slide()
		return
	
	if is_hit:
		knockback_timer -= delta
		
		if not is_on_floor():
			velocity.y += 980 * delta
		
		if knockback_timer <= 0:
			is_hit = false
			velocity.x = -velocidad if not animated_sprite.flip_h else velocidad
			velocity.y = 0
			animated_sprite.play("walk")
	else:
		if is_on_wall():
			velocity.x = velocidad if not animated_sprite.flip_h else -velocidad
		
		if not is_on_floor():
			velocity.y += 980 * delta
		
		if velocity.x < 0:
			animated_sprite.flip_h = false
		elif velocity.x > 0:
			animated_sprite.flip_h = true
	
	move_and_slide()

func _on_hitbox_area_entered(area):
	if area.get_parent().is_in_group("personaje") and area.name == "Area2D":
		print("La hiena recibió un golpe del área del jugador")
		var player_position = area.get_parent().global_position
		print("Posición del jugador:", player_position)
		take_damage(1, player_position)

func _on_area_2d_body_entered(body):
	if is_dying:
		return
	if body.is_in_group("personaje"):
		print("La hiena atacó al jugador")
		if body.has_method("take_damage"):
			body.take_damage(1)

func take_damage(damage: int, attacker_position: Vector2 = Vector2.ZERO) -> void:
	if is_dying:
		return

	salud_actual -= damage
	print("Hiena recibió daño. Salud restante: ", salud_actual)
	
	# AÑADIMOS INFORMACIÓN DE DEPURACIÓN
	print("Posición de la hiena: ", global_position)
	print("Posición del atacante: ", attacker_position)
	print("Dirección actual de la hiena: ", "izquierda" if velocity.x < 0 else "derecha")
	
	if health_bar:
		health_bar.value = salud_actual
	
	blink_timer = blink_duration
	is_hit = true
	knockback_timer = knockback_duration
	
	# Guardamos la dirección actual de la hiena para restaurarla después
	var original_direction = velocity.x
	
	# Aplicamos knockback en dirección opuesta al movimiento de la hiena
	if velocity.x < 0:  # Si va hacia la izquierda
		velocity.x = abs(knockback_force)  # Knockback hacia la derecha
		print("Hiena va a la izquierda, knockback a la derecha")
	else:  # Si va hacia la derecha
		velocity.x = -abs(knockback_force)  # Knockback hacia la izquierda
		print("Hiena va a la derecha, knockback a la izquierda")
	
	velocity.y = -150  # Impulso vertical
	print("Velocidad de knockback aplicada: ", velocity)
	
	if animated_sprite.sprite_frames != null and animated_sprite.sprite_frames.has_animation("Injured"):
		animated_sprite.play("Injured")
	
	if salud_actual <= 0:
		die()

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite.animation == "Injured" and not is_dying:
		animated_sprite.play("walk")
	elif animated_sprite.animation == "Death":
		queue_free()

func die() -> void:
	if is_dying:
		return
		
	is_dying = true
	death_timer = DEATH_TIMER

	var collision_shape = get_node_or_null("CollisionShape2D")
	if collision_shape:
		collision_shape.disabled = true
	else:
		print("No se encontró CollisionShape2D en la escena.")
		
	var hitbox = get_node_or_null("HitBox")
	if hitbox:
		hitbox.set_deferred("disabled", true)
	
	velocity = Vector2.ZERO
	is_hit = false
	
	blink_timer = 0
	animated_sprite.modulate = Color(1, 1, 1, 1)
	
	print("Hiena muriendo, desaparecerá en", DEATH_TIMER, "segundos")
	
	if animated_sprite.sprite_frames != null and animated_sprite.sprite_frames.has_animation("Death"):
		animated_sprite.play("Death")
	else:
		print("No hay animación de muerte disponible")
