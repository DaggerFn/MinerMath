# Player.gd (Anexar a um CharacterBody2D)

extends CharacterBody2D

# Configurações de Movimento
const SPEED = 200.0
const JUMP_VELOCITY = -450.0

# Gravidade padrão (Você deve configurá-la nas configurações do projeto!)
var gravity = 980 

# Referência ao nó RayCast2D que você adicionou
# Ele busca o nó chamado "RayCast2D" que é filho deste CharacterBody2D
@onready var block_detector = $RayCast2D 

func _ready():
	# Obtém a gravidade definida nas configurações do projeto
	gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# --- 1. Aplicar Gravidade ---
	if not is_on_floor():
		velocity.y += gravity * delta

	# --- 2. Pulo (Jump) ---
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# --- 3. Movimento Horizontal ---
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# --- 4. Quebrar Bloco (Ação de Interação) ---
	if Input.is_action_just_pressed("interact"): 
		
		check_and_break_block() # Chama a nova função de quebra

	# --- 5. Mover e Colidir ---
	move_and_slide()

# --- NOVO CÓDIGO DE QUEBRA USANDO O NÓ RAYCAST2D ---
func check_and_break_block():
	# Força o raycast a verificar colisões imediatamente (importante!)
	block_detector.force_raycast_update()
	
	if block_detector.is_colliding():
		# Pega o objeto (nó) que o raio atingiu
		var object = block_detector.get_collider()
		
		# Verifica se o objeto atingido tem o método "break_block" (que está no Bloco.gd)
		if object.has_method("break_block"):
			print("Bloco atingido e quebrado!")
			object.break_block()
		else:
			print("Atingiu algo, mas não é um bloco destrutível.")
	else:
		print("Nenhum objeto encontrado na direção do raio.")
