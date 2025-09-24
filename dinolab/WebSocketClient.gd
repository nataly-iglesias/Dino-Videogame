extends Node2D

@export var websocket_url = "ws://localhost:8765"
var socket = WebSocketPeer.new()

@onready var command_label = $ComandoLabel # Nodo para mostrar los comandos en pantalla
@export var victory_position : Vector2 # Posición de victoria en el laberinto
@onready var victory_label = $VictoriaLabel # Nodo para mostrar el mensaje de victoria
var game_over : bool = false  # Indica si el juego ha terminado
@onready var victory_area = $Meta # Referencia al área de la meta

@onready var sonido_victoria = $Sonido_Victoria

# Datos del dinosaurio
@onready var animated = $Dinosaurio/Dino
var dino : Node2D
var move_speed : float = 50
var sensitivity : String = "media"  # Nivel de sensibilidad predeterminado
var initial_position : Vector2
var current_command = ""  # Comando actual para mover al dinosaurio

func _ready():
	# Configura el WebSocketPeer
	socket = WebSocketPeer.new()
	
	# Conecta al servidor WebSocket
	var err = socket.connect_to_url(websocket_url)
	if err != OK:
		print("No es posible conectar")
		set_process(false)
	else:
		print("Intentando conectar con el servidor...")
		await get_tree().create_timer(2).timeout
		if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
			print("Conexión exitosa. Iniciando reconocimiento de voz...")
			start_voice_recognition()  # Llama a la función automáticamente
		else:
			print("No se pudo establecer la conexión.")
	
	# Referencia al nodo del dinosaurio
	dino = $Dinosaurio
	initial_position = dino.position
	adjust_sensitivity(sensitivity)  # Configura la sensibilidad inicial


func _process(delta):
	# Poll para recibir datos
	socket.poll()

	# Verificar si hay mensajes disponibles
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count() > 0:
			var message = socket.get_packet().get_string_from_utf8()
			print("Mensaje recibido del servidor: ", message)
			process_voice_command(message)
	elif socket.get_ready_state() == WebSocketPeer.STATE_CLOSED:
		print("Conexión cerrada por el servidor")
		set_process(false)
		
# Verificar si el juego no ha terminado
	if not game_over:
		move_dino(delta)

func move_dino(delta):
	# Movimiento continuo según el comando actual
	if current_command == "arriba":
		dino.position += Vector2(0, -move_speed * delta)
		animated.play("up")
	elif current_command == "abajo":
		dino.position += Vector2(0, move_speed * delta)
		animated.play("down")
	elif current_command == "izquierda":
		dino.position += Vector2(-move_speed * delta, 0)
		animated.play("left")
	elif current_command == "derecha":
		dino.position += Vector2(move_speed * delta, 0)
		animated.play("rigth")

# Inicia el reconocimiento de voz
func start_voice_recognition():
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		print("Iniciando reconocimiento de voz...")
		socket.send_text("reconocer")

# Procesa los comandos de voz recibidos
func process_voice_command(command: String):
	if command in ["alta", "media", "baja"]:
		adjust_sensitivity(command)  # Cambia la sensibilidad
	else:
		current_command = command  # Actualiza el comando actual
	print("Comando procesado:", command)
	# Mostrar el comando en la pantalla
	command_label.text = "Comando: " + command
	# Solicitar nuevo reconocimiento de voz
	start_voice_recognition()

# Ajusta la sensibilidad del dinosaurio
func adjust_sensitivity(level: String):
	sensitivity = level
	match sensitivity:
		"alta":
			move_speed = 80
		"media":
			move_speed = 50
		"baja":
			move_speed = 20
	print("Sensibilidad ajustada a:", sensitivity)
	command_label.text = "Sensibilidad: " + sensitivity

# Función que se ejecuta cuando el dinosaurio entra en el área de la meta
func _on_meta_body_entered(body: Node2D) -> void:
	if body == dino:  # Verificar si el cuerpo que entra es el dinosaurio
		game_over = true
		current_command = ""  # Detener comandos
		
		victory_label.text = "¡Victoria!"
		victory_label.visible = true
		dino.queue_free()
		sonido_victoria.play()
		
