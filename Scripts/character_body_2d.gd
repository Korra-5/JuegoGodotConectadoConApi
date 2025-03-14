extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -300.0

@onready var animated_sprite = $AnimatedSprite2D
var attack: bool = false

func _ready():
	$Area2D/CollisionShape2D.disabled=true

func _physics_process(delta: float) -> void:
	# Add gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get input direction.
	var direction := Input.get_axis("move_left", "move_right")

	if Input.is_action_pressed("move_left"):
		$Area2D/CollisionShape2D.position.x=103
	if Input.is_action_pressed("move_right"):
		$Area2D/CollisionShape2D.position.x=128
		
	# Handle attack input.
	if Input.is_action_just_pressed("attackSword") and not attack:				
		attack = true		
		animated_sprite.play("Attack")
		$Area2D/CollisionShape2D.disabled=false
		await ($AnimatedSprite2D.animation_finished)
		$Area2D/CollisionShape2D.disabled=true



	# Flip sprite based on movement direction.
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	# Handle movement and animations if not attacking.
	if attack==false:
		if is_on_floor():
			if direction == 0:
				animated_sprite.play("Idle")
			else:
				animated_sprite.play("Walk")
		else:
			animated_sprite.play("Jump")

		# Update velocity based on input.
		if direction != 0:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	# Prevent movement during attack.
	if attack:
		velocity.x = 0

	move_and_slide()
	
func _on_animated_sprite_2d_animation_finished():
	if animated_sprite.animation == "Attack":
		animated_sprite.play("Idle") 
	attack = false

	

func _on_body_entered (body):
	if body.is_in_group("enemies"):
		body.queue_free()
		
var max_health: int = 3
var current_health: int = 3

func take_damage(amount: int) -> void:
	current_health -= amount
	if current_health == 0:
		get_tree().reload_current_scene()
	update_health_bar()


# Método para actualizar la barra de vida
func update_health_bar() -> void:
	var health_bar = $TextureProgressBar 
	if health_bar:
		health_bar.value = current_health

var time_elapsed = 0.0  # Tiempo transcurrido en segundos
