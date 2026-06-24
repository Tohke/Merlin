## Responsabilidade única: regras de pontuação do quiz.
## Sem sistema de vidas — o jogo é amigável para sala de aula: o aluno
## responde todas as perguntas e vê o resultado final.
class_name ScoreService
extends RefCounted

var correct_count := 0
var wrong_count := 0
var total_questions := 0

func start(p_total_questions: int) -> void:
	correct_count = 0
	wrong_count = 0
	total_questions = p_total_questions

func register_answer(was_correct: bool) -> void:
	if was_correct:
		correct_count += 1
	else:
		wrong_count += 1

func get_answered_count() -> int:
	return correct_count + wrong_count

func is_finished() -> bool:
	return get_answered_count() >= total_questions

func get_percentage() -> int:
	if total_questions == 0:
		return 0
	return int((float(correct_count) / float(total_questions)) * 100.0)

## Retorna uma mensagem de incentivo de acordo com o desempenho.
## Pensado para o público infanto-juvenil: sempre positivo, nunca punitivo.
func get_feedback_message() -> String:
	var pct := get_percentage()
	if pct == 100:
		return "🏆 Perfeito! Você é um mestre da gramática!"
	elif pct >= 70:
		return "🌟 Muito bem! Você está ótimo em gramática!"
	elif pct >= 40:
		return "💪 Bom esforço! Continue praticando!"
	else:
		return "📚 Vamos estudar mais um pouco e tentar de novo!"
