## Representa uma única pergunta do quiz.
## Responsabilidade única: guardar os dados de uma pergunta. Não sabe nada
## sobre UI, som ou regras de pontuação.
class_name QuestionData
extends RefCounted

var question_text: String
var options: Array[String]
var correct_answer_index: int
var explanation: String
var category_id: String
var category_name: String

func _init(
	p_question: String = "",
	p_options: Array[String] = [],
	p_correct_index: int = 0,
	p_explanation: String = "",
	p_category_id: String = "",
	p_category_name: String = ""
) -> void:
	question_text = p_question
	options = p_options
	correct_answer_index = p_correct_index
	explanation = p_explanation
	category_id = p_category_id
	category_name = p_category_name

## Cria uma QuestionData a partir de um dicionário (vindo do JSON) + dados da categoria.
static func from_dict(dict: Dictionary, category_id: String, category_name: String) -> QuestionData:
	var opts: Array[String] = []
	for o in dict.get("options", []):
		opts.append(str(o))

	return QuestionData.new(
		dict.get("question", ""),
		opts,
		dict.get("correct_answer", 0),
		dict.get("explanation", ""),
		category_id,
		category_name
	)

func get_display_category() -> String:
	return category_name
