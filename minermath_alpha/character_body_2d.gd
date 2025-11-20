# Player.gd (Anexado ao CharacterBody2D)
extends CharacterBody2D

# --- VARIÁVEIS DE MOVIMENTO ---
const SPEED = 200.0
const JUMP_VELOCITY = -450.0
var gravity = 980 
var current_target_number: int = 2 # O divisor que o jogador deve procurar

@onready var block_detector = $RayCast2D 

# --- VARIÁVEIS DO GERADOR DE NÍVEL ---
# Pré-carrega a CENA SEPARADA de randomização
const RandomizerScene = preload("res://randomização_blocos.tscn") # ⚠️ Verifique o caminho exato!


func _ready():
	gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	randomize() 
	
	# 🔑 CHAMA O GERADOR DE NÍVEL, passando a raiz da cena (Node2D) como referência.
	instantiate_and_generate_level(get_parent())


func _physics_process(delta):
	# (Lógica de Movimento, Pulo e Gravidade...)
	if not is_on_floor(): velocity.y += gravity * delta
	if Input.is_action_just_pressed("ui_accept") and is_on_floor(): velocity.y = JUMP_VELOCITY
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction: velocity.x = direction * SPEED
	else: velocity.x = move_toward(velocity.x, 0, SPEED)

	if Input.is_action_just_pressed("interact"): 
		check_and_break_block() 

	move_and_slide()

## 💥 Lógica de Detecção e Geração

func check_and_break_block():
	block_detector.force_raycast_update()
	
	if block_detector.is_colliding():
		var object = block_detector.get_collider()
		
		if object.has_method("try_break"):
			# O Player informa o alvo e o bloco decide a quebra
			object.try_break(current_target_number) 
		
# Player.gd

func instantiate_and_generate_level(main_root_node: Node):
	
	# 🚨 CHECAGEM CRÍTICA 1: O Randomizador foi carregado?
	if RandomizerScene == null:
		push_error("ERRO GRAVE: A cena 'randomização_blocos.tscn' não foi pré-carregada. Verifique o caminho no 'preload'!")
		return

	# ... (o restante do código é igual) ...
	var block_positions_node = main_root_node.get_node_or_null("Block_position")
	
	if not block_positions_node:
		push_error("ERRO GRAVE: O nó 'Block_position' não foi encontrado na raiz da cena!")
		return
		
	var randomizer = RandomizerScene.instantiate()
	
	# 🚨 CHECAGEM CRÍTICA 2: O Gerador foi instanciado corretamente?
	if not is_instance_valid(randomizer):
		push_error("ERRO GRAVE: Falha ao instanciar a cena do Randomizador!")
		return

	main_root_node.call_deferred("add_child", randomizer)
	
	var position_markers = block_positions_node.get_children()
	
	randomizer.generate_level(position_markers, main_root_node)

	# 🔑 Se você chegar a esta linha, a geração começou.
	print("Sucesso: A função de geração de nível foi chamada.")
