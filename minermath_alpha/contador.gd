extends Node2D

# Variável exportada para o Label que mostra o múltiplo alvo
@export var label_da_tela: Label

# Usa @onready para referenciar seu nó "pontuacao" pelo caminho
@onready var label_da_pontuacao: Label = $CanvasLayer/pontuacao 

signal multiplo_alvo_pronto(numero_multiplo: int)

var multiplo_alvo: int = 0
var pontuacao: int = 0 # Variável para armazenar a pontuação atual

func _ready() -> void:
	randomize()
	multiplo_alvo = randi_range(2, 9)
	
	# 1. Configura e checa o Label do Múltiplo Alvo
	if label_da_tela: 
		label_da_tela.text = "Multiplo: " + str(multiplo_alvo)
	else:
		print("ERRO: O nó Label do alvo não foi conectado!")

	# 2. Inicializa a exibição da pontuação
	if label_da_pontuacao:
		_atualizar_exibicao_pontuacao()
	else:
		print("ERRO: O nó Label da pontuação NÃO FOI ENCONTRADO no caminho: $CanvasLayer/pontuacao")
		
	multiplo_alvo_pronto.emit(multiplo_alvo)

# --- Funções de Pontuação ---

## Função chamada ao acertar um múltiplo
func acertou_multiplo():
	pontuacao += 1
	_atualizar_exibicao_pontuacao()
	print("Acerto! Pontuação: " + str(pontuacao))

## Função chamada ao selecionar o número errado
func errou_multiplo():
	pontuacao -= 1
	_atualizar_exibicao_pontuacao()
	print("Erro! Pontuação: " + str(pontuacao))

# --- Função de Exibição ---

## Atualiza o texto do Label da pontuação na tela
func _atualizar_exibicao_pontuacao():
	if label_da_pontuacao:
		label_da_pontuacao.text = "PONTOS: " + str(pontuacao)
