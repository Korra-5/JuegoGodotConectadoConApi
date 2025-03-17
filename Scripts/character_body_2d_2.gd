extends CharacterBody2D

var velocidad: int = 60


func _ready():
	velocity.x = -velocidad

func _physics_process(delta):
	$AnimatedSprite2D.flip_h
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
