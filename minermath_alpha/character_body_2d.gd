# Player.gd (Anexado ao CharacterBody2D)
extends CharacterBody2D

# --- VARIÁVEIS DE MOVIMENTO ---
const SPEED = 500.0
const JUMP_VELOCITY = -450.0
var gravity = 980 
var current_target_number: int = 3

@onready var block_detector = $RayCast2D 
@onready var animated_sprite = $AnimatedSprite2D


# --- VARIÁVEIS DO GERADOR DE NÍVEL ---
# Pré-carrega a CENA SEPARADA de randomização
const RandomizerScene = preload("res://randomização_blocos.tscn") # ⚠️ Verifique o caminho exato!

var is_breaking = false

func _ready():
	gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	randomize() 
	
	var contador_node = get_parent()
	if contador_node.has_signal("multiplo_alvo_pronto"):
		contador_node.multiplo_alvo_pronto.connect(_on_multiplo_alvo_pronto)
	else:
		print("AVISO: Nó Pai não tem o sinal 'multiplo_alvo_pronto'. Usando valor padrão 3.")
	
	# 🔑 CHAMA O GERADOR DE NÍVEL, passando a raiz da cena (Node2D) como referência.
	instantiate_and_generate_level(get_parent())

func _on_multiplo_alvo_pronto(numero_multiplo: int):
	current_target_number = numero_multiplo
	print("Player RECEBEU o novo Múltiplo Alvo via Sinal: ", current_target_number)

func _physics_process(delta):
	# Tem que ficar aqui em cima para funcionar mesmo se o personagem estiver travado
	if Input.is_action_just_pressed("restart"):
		print("Reiniciando...") # Debug para sabermos que funcionou
		get_tree().reload_current_scene()
		return # Opcional: para de processar o resto já que vai reiniciar
		
	# 1. Aplica a gravidade sempre
	if not is_on_floor(): 
		velocity.y += gravity * delta
	
	# 2. SE ESTIVER QUEBRANDO, saia (só permite a gravidade e o move_and_slide)
	if is_breaking:
		# Define a velocidade horizontal como zero enquanto quebra
		velocity.x = 0
		update_movement_animation()
		move_and_slide()
		return # <-- IMPEDE TODAS AS ENTRADAS DE MOVIMENTO ABAIXO
	
	# 3. Lógica de Pulo
	if Input.is_action_just_pressed("ui_accept") and is_on_floor(): 
		velocity.y = JUMP_VELOCITY
	
	# 4. Lógica de Movimento
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction: 
		velocity.x = direction * SPEED
	else: 
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# 5. Lógica de Interação/Quebra
	if Input.is_action_just_pressed("interact"):
		# Agora chama a função que verifica a colisão e SÓ INICIA a animação
		# se a colisão ocorrer.
		check_and_break_block()
	
	# 6. Atualiza Animação e Movimento
	update_movement_animation()
	move_and_slide()
	
	# ... seu código de movimento e pulo ...

	# 7. Lógica de Reinício
	if Input.is_action_just_pressed("reiniciar"):
		# Opção A: Recarrega a cena atual (Mais prático)
		get_tree().reload_current_scene()
		
		# Opção B: Se você preferir carregar o arquivo específico como mencionou:
		# get_tree().change_scene_to_file("res://character_body_2d.tscn")
	
func update_movement_animation():
	if is_breaking:
		return
	
	if velocity.x != 0:
		animated_sprite.flip_h = velocity.x < 0
		
	if is_on_floor():
		if velocity.x != 0:
			if animated_sprite.animation != "Andando":
				animated_sprite.play("Andando")
		else:
			if animated_sprite.animation != "Parado":
				animated_sprite.play("Parado")
	else:
		if animated_sprite.animation != "Andando" and animated_sprite.animation != "Parado":
			animated_sprite.play("Andando")

func start_break_animation():
	if is_breaking:
			return
	
	is_breaking = true
	animated_sprite.play("Quebrando bloco")
	
	if animated_sprite.animation_finished.is_connected(on_break_animation_finished):
		animated_sprite.animation_finished.disconnect(on_break_animation_finished)
	
	animated_sprite.animation_finished.connect(on_break_animation_finished)
	
	block_detector.target_position.x = 25 if !animated_sprite.flip_h else -25

func on_break_animation_finished():
	animated_sprite.animation_finished.disconnect(on_break_animation_finished)
	is_breaking = false
	update_movement_animation()

## 💥 Lógica de Detecção e Geração

func check_and_break_block():
	block_detector.force_raycast_update()
	
	if block_detector.is_colliding():
		var object = block_detector.get_collider()
		
		if object.has_method("try_break"):
			# 1. Inicia a animação DEPOIS de saber que há algo para quebrar
			start_break_animation()
			
			# 2. O Player informa o alvo e o bloco decide a quebra
			object.try_break(current_target_number)

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
