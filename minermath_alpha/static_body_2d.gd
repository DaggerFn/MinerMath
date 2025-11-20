# static_body_2d.gd (Script do Bloco)
extends StaticBody2D

# Variável para armazenar a textura ANTES que o sprite_node seja encontrado
var pending_texture: Texture2D = null

@export var block_number: int = 0
var sprite_node: Sprite2D = null 

signal block_broken(is_correct_multiple: bool)

# A nova função _ready()
func _ready():
	# 🔑 CHAVE: Usamos call_deferred para buscar o Sprite2D no próximo frame
	call_deferred("find_sprite_node") 
	
# Função que será chamada no próximo frame
func find_sprite_node():
	# 1. Busca o Sprite2D
	sprite_node = get_node_or_null("Sprite2D")
	
	if sprite_node == null:
		push_error("ERRO GRAVE: Sprite2D não encontrado no find_sprite_node. Cheque o nome do nó!")
		return
		
	# 2. Se a textura já foi enviada (antes do Sprite2D existir)
	if pending_texture != null:
		print("DEBUG: Aplicando textura pendente.")
		set_visual_internal(pending_texture)


# Esta é a função que o Randomizer chama
func set_visual(texture_to_set: Texture2D):
	
	if texture_to_set == null:
		push_error("ERRO CRÍTICO: A textura recebida é NULA. Caminho errado no RandomizacaoBlocos.gd.")
		return
		
	# Se o nó já foi encontrado (find_sprite_node já rodou)
	if sprite_node != null:
		set_visual_internal(texture_to_set)
	else:
		# Se o nó ainda não foi encontrado (find_sprite_node ainda não rodou)
		pending_texture = texture_to_set
		print("DEBUG: Textura salva como pendente.")
		
# Função interna que realmente define a textura
func set_visual_internal(texture_to_set: Texture2D):
	if sprite_node != null:
		sprite_node.texture = texture_to_set
		print("DEBUG: Textura aplicada com sucesso ao bloco.")
	else:
		# Esta mensagem de erro não deve mais aparecer!
		push_error("ERRO DE LÓGICA: set_visual_internal chamado com sprite_node nulo.")
		
# ... (mantenha o try_break e break_block originais) ...
func try_break(target_number: int):
	var is_multiple = (block_number % target_number) == 0
	
	if is_multiple:
		break_block(true)
	else:
		break_block(false)

func break_block(was_correct: bool):
	emit_signal("block_broken", was_correct)
	
	if was_correct:
		queue_free()
	else:
		pass
