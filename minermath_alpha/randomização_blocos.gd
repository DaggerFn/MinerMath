# RandomizacaoBlocos.gd 
extends Node2D 

# --- VARIÁVEIS DO GERADOR DE NÍVEL ---
const LEVEL_BLOCK_NUMBERS = [2, 3, 6, 8, 9, 10, 12, 15, 14, 16, 18, 20, 21, 24, 25] 

# MAPA DE SPRITES (Catálogo que associa número ao arquivo)
const NUMBER_TO_SPRITE = {
	2: preload("res://assets/imagens_blocos/2.png"),
	3: preload("res://assets/imagens_blocos/3.png"),
	6: preload("res://assets/imagens_blocos/6.png"),
	8: preload("res://assets/imagens_blocos/8.png"),
	9: preload("res://assets/imagens_blocos/9.png"),
	10: preload("res://assets/imagens_blocos/10.png"),
	12: preload("res://assets/imagens_blocos/12.png"),
	14: preload("res://assets/imagens_blocos/14.png"),
	15: preload("res://assets/imagens_blocos/15.png"),
	16: preload("res://assets/imagens_blocos/16.png"),
	18: preload("res://assets/imagens_blocos/18.png"),
	20: preload("res://assets/imagens_blocos/20.png"),
	21: preload("res://assets/imagens_blocos/21.png"),
	24: preload("res://assets/imagens_blocos/24.png"),
	25: preload("res://assets/imagens_blocos/25.png"),
}

# CENA GENÉRICA DO BLOCO
const BLOCK_SCENE = preload("res://block.tscn") # ⚠️ Verifique o caminho exato!

func _ready():
	randomize() 

# RandomizacaoBlocos.gd

# ... (outros códigos) ...

# Esta função é chamada pelo Player/Gerenciador de Nível
func generate_level(position_markers: Array, parent_to_add_to: Node):
	
	print("--- INICIANDO GERAÇÃO ---")
	print("Marcadores encontrados: ", position_markers.size()) # DEBUG
	
	var shuffled_numbers = LEVEL_BLOCK_NUMBERS.duplicate()
	
	shuffled_numbers.shuffle() 
	
	var count = min(shuffled_numbers.size(), position_markers.size())
	
	print("Total de blocos a serem criados: ", count) # DEBUG
	
	if count == 0:
		print("AVISO: Nenhum bloco será criado (zero marcadores ou zero números na lista).")
		return
		
	for i in range(count):
		var block_number = shuffled_numbers[i]
		var marker = position_markers[i]
		
		# 🔑 Chamada com o nome do parâmetro corrigido
		spawn_block(block_number, marker.global_position, parent_to_add_to)
		
	print("--- GERAÇÃO CONCLUÍDA ---")
		
# 🔑 Função spawn_block com parâmetro renomeado
func spawn_block(block_number: int, block_global_position: Vector2, parent_node: Node):
	# 'block_instance_root' é o nó raiz da cena Block.tscn
	var block_instance_root = BLOCK_SCENE.instantiate()
	
	# Busca o StaticBody2D que contém o script Block.gd
	var block_script_node = block_instance_root.get_node_or_null("StaticBody2D") 
	
	if block_script_node == null:
		push_error("ERRO: StaticBody2D não encontrado na cena do bloco!")
		return

	# 1. SINCRONIA LÓGICA
	block_script_node.block_number = block_number 
	
	# 2. SINCRONIA VISUAL
	if NUMBER_TO_SPRITE.has(block_number):
		var texture = NUMBER_TO_SPRITE[block_number]
		
		if texture == null:
			push_error("ERRO GRAVE: O preload da textura para o número %d falhou! Verifique o caminho." % block_number)
			return
			
		block_script_node.set_visual(texture) 
	else:
		push_error("ERRO: Número %d não mapeado no catálogo de sprites!" % block_number)
		return
	
	# 3. Posiciona e Adiciona (Usamos a raiz da instância para posicionar)
	# 🔑 Uso do novo nome do parâmetro
	block_instance_root.global_position = block_global_position 
	parent_node.call_deferred("add_child", block_instance_root)
