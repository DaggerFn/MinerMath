extends Node2D

# Referência para o nosso nó Label na tela
# @onready var label_da_tela: Label = $CanvasLayer/Label
# Altere esta linha!
@export var label_da_tela: Label

func _ready() -> void:
	# 1. Prepara o gerador de números aleatórios.
	# É importante chamar isso uma vez no início do jogo.
	randomize()

	# 2. Gera um número inteiro aleatório.
	# randi_range(min, max) sorteia um número entre min e max (inclusos).
	# Vamos sortear um número entre 1 e 100 como exemplo.
	var numero_aleatorio = randi_range(1, 100)

	# 3. Monta o texto final e o exibe no Label.
	# Usamos str() para converter o número em texto.
	label_da_tela.text = "Multiplo: " + str(numero_aleatorio)

func _process(delta: float) -> void:
		pass
