extends CharacterBody2D  # Usar CharacterBody2D en Godot 4.x

# Velocidad de movimiento
var speed = 200  # Ajusta este valor según sea necesario

func _process(delta):
	# Reinicia la velocidad en cada fotograma
	velocity.x = 0

	# Detecta si se presiona la tecla derecha
	if Input.is_action_pressed("Derecha"):
		velocity.x = speed  # Mover hacia la derecha
	if Input.is_action_pressed("Izquierda"):
		velocity.x = - speed  # Mover hacia la derecha
	if Input.is_action_pressed("Arriba"):
		velocity.y = - speed  # Mover hacia la derecha

	# Aplica el movimiento
	move_and_slide()
