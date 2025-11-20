# Player.gd (Anexar a um CharacterBody2D)
extends CharacterBody2D

# --- VARIÁVEIS DE JOGO E CONFIGURAÇÕES ---

# Configurações de Movimento
const SPEED = 200.0
const JUMP_VELOCITY = -450.0

# Gravidade padrão (obtida nas settings)
var gravity = 980 

# 🎯 Variável temporária para o Número Alvo da Tela.
# ⚠️ No jogo final, este valor viria de um nó GameManager!
var current_target_number: int = 3 

# Referência ao nó RayCast2D
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
	# Certifique-se de que o input 'interact' está configurado em Project Settings > Input Map
	if Input.is_action_just_pressed("interact"): 
		check_and_break_block() # Chama a função ajustada

	# --- 5. Mover e Colidir ---
	move_and_slide()



## 💥 Função Ajustada de Quebra (RayCast2D)

func check_and_break_block():
	# Força o raycast a verificar colisões imediatamente
	block_detector.force_raycast_update()
	
	if block_detector.is_colliding():
		var object = block_detector.get_collider()
		
		# Verifica se o objeto atingido tem a função de checagem de múltiplos
		if object.has_method("try_break"):
			
			# 🔑 ESSENCIAL: Chama a função do bloco e passa o número alvo
			# O bloco (Block.gd) usará este número para fazer a checagem de múltiplo.
			object.try_break(current_target_number) 
			
		else:
			print("Atingiu algo, mas não é um bloco numérico.")
	else:
		print("Nenhum objeto encontrado na direção do raio.")
