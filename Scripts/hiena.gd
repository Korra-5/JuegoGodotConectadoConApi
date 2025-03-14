extends CharacterBody2D

var velocidad: int = 100
var salud: int = 3
var is_hit: bool = false
var knockback_force: int = 200
var knockback_duration: float = 0.2
var knockback_timer: float = 0.0

func _ready():
	velocity.x = -velocidad
	add_to_group("enemies")
	
func _physics_process(delta):
	if knockback_timer > 0:
		knockback_timer -= delta
		if knockback_timer <= 0:
			is_hit = false
			# Restaurar velocidad normal después del knockback
			velocity.x = -velocidad if !$AnimatedSprite2D.flip_h else velocidad
	
	if not is_hit:
		if is_on_wall():
			if !$AnimatedSprite2D.flip_h:
				velocity.x = velocidad
			else:
				velocity.x = -velocidad
				
		move_and_slide()
		
		if velocity.x < 0:
			$AnimatedSprite2D.flip_h = false
		elif velocity.x > 0:
			$AnimatedSprite2D.flip_h = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("personaje"):
		body.take_damage(1)

func take_damage(damage: int) -> void:
	salud -= damage
	print("Hiena recibió daño. Salud restante: ", salud)
	
	# Aplicar retroceso (knockback)
	is_hit = true
	knockback_timer = knockback_duration
	
	# Dirección del knockback (retroceso opuesto a la dirección actual)
	var knockback_direction = Vector2(-1, 0) if velocity.x > 0 else Vector2(1, 0)
	velocity = knockback_direction * knockback_force
	move_and_slide()
	
	# Reproducir animación de daño si existe
	if $AnimatedSprite2D.has_animation("hit"):
		$AnimatedSprite2D.play("hit")
	
	# Verificar si murió
	if salud <= 0:
		die()

func die() -> void:
	# Reproducir animación de muerte si existe
	if $AnimatedSprite2D.has_animation("death"):
		$AnimatedSprite2D.play("death")
		# Esperar a que termine la animación antes de quitar
		await $AnimatedSprite2D.animation_finished
	
	# Eliminar el enemigo
	queue_free()
