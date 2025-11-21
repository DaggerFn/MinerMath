extends Node2D

# Usamos @export para criar um campo no Inspetor. É mais seguro!
@export var label_da_tela: Label

func _ready() -> void:
	# Esta parte do código está perfeita e não precisa mudar.
	randomize()
	var numero_aleatorio = randi_range(1, 100)
	
	# IMPORTANTE: Adicionamos uma verificação de segurança
	if label_da_tela: # Checa se o label foi realmente conectado
		label_da_tela.text = "Multiplo: " + str(numero_aleatorio)
	else:
		print("ERRO: O nó Label não foi conectado ao script no Inspetor!")

func _process(delta: float) -> void:
	pass
