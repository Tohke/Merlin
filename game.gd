extends Control

# Conectando o código aos elementos da tela
@onready var question_text = $QuestionText
@onready var options_container = $OptionsContainer
@onready var feedback_text = $FeedbackText

# Variável para controlar em qual pergunta estamos
var current_question_index = 0

# Nosso banco de dados "Vibe Coding" de perguntas
var quiz_data = [
	{
		"question": "Ele _____ atrás de mim ontem.",
		"options": ["corre", "correria", "correu"],
		"correct_answer": 2 # Índice da resposta certa: 0=corre, 1=correria, 2=correu
	},
	{
		"question": "Nós _____ uma pizza deliciosa no jantar.",
		"options": ["comemos", "comerão", "comerei"],
		"correct_answer": 0 
	},
	{
		"question": "Se eu tivesse dinheiro, eu _____ o mundo.",
		"options": ["viajo", "viajaria", "viajei"],
		"correct_answer": 1
	}
]

func _ready():
	# Isso roda assim que você dá Play no jogo
	load_question()

func load_question():
	# Verifica se já respondemos todas as perguntas
	if current_question_index >= quiz_data.size():
		question_text.text = "Fim de jogo! Você zerou o quiz."
		options_container.hide() # Esconde os botões
		feedback_text.text = ""
		return

	# Pega a pergunta atual do nosso banco de dados
	var current_q = quiz_data[current_question_index]
	
	# Atualiza os textos na tela
	question_text.text = current_q["question"]
	feedback_text.text = ""

	# Limpa os botões da pergunta anterior (se houver)
	for child in options_container.get_children():
		child.queue_free()

	# Cria os novos botões automaticamente com base nas opções
	for i in range(current_q["options"].size()):
		var btn = Button.new()
		btn.text = current_q["options"][i]
		# Configura o botão para rodar uma função quando clicado
		btn.pressed.connect(_on_option_selected.bind(i))
		options_container.add_child(btn)

func _on_option_selected(selected_index):
	var correct_index = quiz_data[current_question_index]["correct_answer"]

	if selected_index == correct_index:
		feedback_text.text = "Correto! Mandou muito."
		feedback_text.modulate = Color.GREEN # Fica verde
		
		current_question_index += 1 # Vai para a próxima pergunta
		
		# Espera 1 segundo para o jogador ler que acertou e carrega a próxima
		await get_tree().create_timer(1.0).timeout
		load_question()
	else:
		feedback_text.text = "Ops, quase! Tente outra."
		feedback_text.modulate = Color.RED # Fica vermelho
