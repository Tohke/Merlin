extends Control

@onready var question_text = $QuestionText
@onready var options_container = $OptionsContainer
@onready var feedback_text = $FeedbackText

var current_question_index = 0
var score = 0

var quiz_data = [
	# --- COMPLETAR ---
	{"question": "[Completar] Ele _____ atrás de mim ontem.", "options": ["corre", "correria", "correu"], "correct_answer": 2},
	{"question": "[Completar] Nós _____ uma pizza no jantar de amanhã.", "options": ["comemos", "comeremos", "comíamos"], "correct_answer": 1},
	{"question": "[Completar] Se eu tivesse dinheiro, eu _____ o mundo.", "options": ["viajo", "viajaria", "viajei"], "correct_answer": 1},
	# --- PREFIXO/SUFIXO ---
	{"question": "[Prefixo/Sufixo] Sufixo para base 'Feliz':", "options": ["-mente", "-ção", "-ismo"], "correct_answer": 0},
	{"question": "[Prefixo/Sufixo] Prefixo para 'Fazer' (reverter):", "options": ["Re-", "Des-", "In-"], "correct_answer": 1}
	# Você pode adicionar as outras aqui depois!
]

func _ready():
	quiz_data.shuffle() 
	load_question()

func load_question():
	# Limpa a tela
	for child in options_container.get_children():
		child.queue_free()

	# Se chegou ao fim de todas as perguntas sem errar: VITÓRIA!
	if current_question_index >= quiz_data.size():
		show_end_screen("Você Venceu! Parabéns!")
		return

	var current_q = quiz_data[current_question_index]
	question_text.text = current_q["question"]
	feedback_text.text = "Pontos: " + str(score)
	feedback_text.modulate = Color.WHITE # Reseta a cor para branco

	for i in range(current_q["options"].size()):
		var btn = Button.new()
		btn.text = current_q["options"][i]
		btn.pressed.connect(_on_option_selected.bind(i))
		options_container.add_child(btn)

func _on_option_selected(selected_index):
	var correct_index = quiz_data[current_question_index]["correct_answer"]

	if selected_index == correct_index:
		score += 1 
		feedback_text.text = "Correto!"
		feedback_text.modulate = Color.GREEN
		
		current_question_index += 1
		await get_tree().create_timer(0.5).timeout
		load_question()
	else:
		# ERROU: Fim de jogo imediato!
		feedback_text.text = "RESPOSTA ERRADA!"
		feedback_text.modulate = Color.RED
		
		# Pequena pausa para o jogador sentir o drama do erro antes da tela final
		await get_tree().create_timer(0.8).timeout
		show_end_screen("FIM DE JOGO")

# Função centralizada para mostrar o resultado final
func show_end_screen(title_message):
	# Limpa os botões de opções
	for child in options_container.get_children():
		child.queue_free()
	
	# Atualiza os textos da tela final
	question_text.text = title_message
	feedback_text.text = "Sua pontuação final: " + str(score)
	feedback_text.modulate = Color.YELLOW # Destaque para o placar
	
	# Cria o botão de reiniciar
	var restart_btn = Button.new()
	restart_btn.text = "Tentar Novamente"
	restart_btn.pressed.connect(func(): get_tree().reload_current_scene())
	options_container.add_child(restart_btn)
