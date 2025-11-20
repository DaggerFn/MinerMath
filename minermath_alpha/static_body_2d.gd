# Block.gd (Anexado ao StaticBody2D)
extends StaticBody2D

# Variável exportada para o número do bloco (ex: 18)
@export var block_number: int = 10

# 2. ⚠️ ADICIONE ESTA LINHA: Variável exportada para a imagem
@export var block_texture: Texture2D

# 3. ⚠️ ADICIONE ESTA LINHA: Referência ao nó Sprite2D
@onready var sprite_node = $Sprite2D

signal block_broken(is_multiple: bool)

func _ready():
	# 4. ⚠️ ADICIONE ESTA LINHA: Aplica a textura ao Sprite2D
	# Isso faz a imagem aparecer na cena quando o jogo roda.
	sprite_node.texture = block_texture

func try_break(target_number: int):
	# Lógica que decide se o bloco quebra ou não
	var is_multiple = (block_number % target_number) == 0
	
	if is_multiple:
		# Se for múltiplo, o bloco se destrói
		break_block(true)
	else:
		# Se não for múltiplo, não se destrói
		break_block(false)

func break_block(was_correct: bool):
	if was_correct:
		queue_free()
	else:
		# Tocar som/animação de erro
		pass
