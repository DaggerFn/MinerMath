extends Node2D

# Usamos @export para criar um campo no Inspetor. É mais seguro!
@export var label_da_tela: Label
signal multiplo_alvo_pronto(numero_multiplo: int)

var multiplo_alvo: int = 0

func _ready() -> void:
	# Esta parte do código está perfeita e não precisa mudar.
	randomize()
	multiplo_alvo = randi_range(2, 9)
	
	# IMPORTANTE: Adicionamos uma verificação de segurança
	if label_da_tela: # Checa se o label foi realmente conectado
		label_da_tela.text = "Multiplo: " + str(multiplo_alvo)
	else:
		print("ERRO: O nó Label não foi conectado ao script no Inspetor!")
		
	multiplo_alvo_pronto.emit(multiplo_alvo)
