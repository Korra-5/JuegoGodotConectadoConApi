extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -300.0
const GRAVITY = 980.0
const KNOCKBACK_FORCE = 200.0
const KNOCKBACK_DURATION = 0.3
const DEATH_TIMER = 1.0 

@onready var animated_sprite = $AnimatedSprite2D
var attack: bool = false
var double_jump_available: bool = false
var is_knockback: bool = false
var knockback_timer: float = 0.0
var knockback_direction: int = 0
var is_dying: bool = false
var death_timer: float = 0.0

func _ready():
	$Area2D/CollisionShape2D.disabled = true
	add_to_group("personaje")

func _physics_process(delta: float) -> void:
	if is_dying:
		death_timer -= delta
		if death_timer <= 0:
			# Reiniciar la escena después del temporizador
			get_tree().reload_current_scene()
		return
		
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		# Resetear doble salto cuando toca el suelo
		double_jump_available = true
	
	# Manejar el retroceso cuando recibe daño
	if is_knockback:
		knockback_timer -= delta
		velocity.x = knockback_direction * KNOCKBACK_FORCE
		
		if knockback_timer <= 0:
			is_knockback = false
			attack = false
			animated_sprite.play("Idle")
			
		move_and_slide()
		return 
		
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif double_jump_available:
			velocity.y = JUMP_VELOCITY
			double_jump_available = false
			animated_sprite.play("Jump")
			
			#Para saber a donde se dirige el knockback
	var direction := Input.get_axis("move_left", "move_right")
	if Input.is_action_pressed("move_left"):
		$Area2D/CollisionShape2D.position.x = 103
	if Input.is_action_pressed("move_right"):
		$Area2D/CollisionShape2D.position.x = 128
		
	if Input.is_action_just_pressed("attackSword") and not attack:				
		attack = true		
		animated_sprite.play("Attack")
		$Area2D/CollisionShape2D.disabled = false
		await animated_sprite.animation_finished
		$Area2D/CollisionShape2D.disabled = true
		attack = false
		
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
		
	if attack == false:
		if is_on_floor():
			if direction == 0:
				animated_sprite.play("Idle")
			else:
				animated_sprite.play("Walk")
		else:
			animated_sprite.play("Jump")
		if direction != 0:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
	if attack:
		velocity.x = 0
		
	move_and_slide()

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite.animation == "Attack":
		animated_sprite.play("Idle")
	elif animated_sprite.animation == "Injured":
		is_knockback = false
		attack = false
		animated_sprite.play("Idle")
	
func _on_body_entered(body):
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(1, global_position)
		
var max_health: int = 3
var current_health: int = 3

func take_damage(amount: int) -> void:
	current_health -= amount
	
	is_knockback = true
	knockback_timer = KNOCKBACK_DURATION
	attack = true  # Para impedir movimiento durante la animación de daño
	
	knockback_direction = 1 if animated_sprite.flip_h else -1
	
	animated_sprite.play("Injured")
	
	if current_health <= 0:
		current_health = 0
		die()
	
	update_health_bar()

func die() -> void:
	if is_dying:
		return
		
	# Marcar como muriendo e iniciar temporizador
	is_dying = true
	death_timer = DEATH_TIMER
	
	$CollisionShape2D.disabled = true
	if has_node("Area2D"):
		$Area2D/CollisionShape2D.disabled = true
	
	# Detener completamente el movimiento
	velocity = Vector2.ZERO
	
	# Reproducir animación de muerte una sola vez
	animated_sprite.play("Death")
	print("Muerte iniciada, reiniciando escena en ", DEATH_TIMER, " segundos")

# Método para actualizar la barra de vida
func update_health_bar() -> void:
	var health_bar = $TextureProgressBar 
	if health_bar:
		health_bar.value = current_health
