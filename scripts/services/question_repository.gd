## Responsabilidade única: carregar o arquivo de perguntas e fornecer
## listas de perguntas (filtradas por categoria e/ou embaralhadas).
## Nenhuma outra classe do jogo deve ler o JSON diretamente — tudo passa
## por aqui (Single Responsibility + facilita troca de fonte de dados no futuro).
class_name QuestionRepository
extends RefCounted

const QUESTIONS_FILE_PATH := "res://data/questions.json"

## Quantidade de perguntas sorteadas quando o jogador escolhe "Todas as Categorias".
const QUESTION_COUNT_ALL := 10
## Quantidade de perguntas sorteadas quando o jogador escolhe uma categoria específica.
const QUESTION_COUNT_CATEGORY := 5

var _categories: Array[CategoryData] = []
var _questions_by_category: Dictionary = {} # category_id -> Array[QuestionData]
var _all_questions: Array[QuestionData] = []
var _loaded := false

func _init() -> void:
	_load_from_file(QUESTIONS_FILE_PATH)

func _load_from_file(path: String) -> void:
	if not FileAccess.file_exists(path):
		push_error("QuestionRepository: arquivo não encontrado em %s" % path)
		return

	var file := FileAccess.open(path, FileAccess.READ)
	var content := file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(content)
	if parsed == null:
		push_error("QuestionRepository: falha ao fazer parse do JSON em %s" % path)
		return

	_parse_data(parsed)
	_loaded = true

func _parse_data(data: Dictionary) -> void:
	_categories.clear()
	_questions_by_category.clear()
	_all_questions.clear()

	var raw_categories = data.get("categories", [])
	for raw_category in raw_categories:
		var cat_id: String = raw_category.get("id", "")
		var cat_name: String = raw_category.get("name", "")
		var raw_questions: Array = raw_category.get("questions", [])

		var questions: Array[QuestionData] = []
		for raw_question in raw_questions:
			var q := QuestionData.from_dict(raw_question, cat_id, cat_name)
			questions.append(q)
			_all_questions.append(q)

		_questions_by_category[cat_id] = questions
		_categories.append(CategoryData.new(cat_id, cat_name, questions.size()))

func is_loaded() -> bool:
	return _loaded

## Retorna todas as categorias disponíveis (sem incluir a opção "Todas").
func get_categories() -> Array[CategoryData]:
	return _categories.duplicate()

## Retorna a categoria especial "Todas as Categorias" + as categorias normais,
## pronta para popular a tela de título.
func get_categories_with_all_option() -> Array[CategoryData]:
	var result: Array[CategoryData] = []
	result.append(CategoryData.create_all_category(_all_questions.size()))
	result.append_array(_categories)
	return result

## Retorna uma seleção embaralhada e limitada de perguntas para uma rodada.
## - Categoria "Todas": sorteia min(10, total_geral) perguntas.
## - Categoria específica: sorteia min(5, total_da_categoria) perguntas.
## Cada chamada gera uma ordem diferente (rejogabilidade).
func get_shuffled_questions(category_id: String) -> Array[QuestionData]:
	var source: Array[QuestionData]
	var limit: int

	if category_id == CategoryData.ALL_CATEGORIES_ID:
		source = _all_questions.duplicate()
		limit = QUESTION_COUNT_ALL
	else:
		source = _questions_by_category.get(category_id, []).duplicate()
		limit = QUESTION_COUNT_CATEGORY

	source.shuffle()

	var count: int = min(limit, source.size())
	return source.slice(0, count)
