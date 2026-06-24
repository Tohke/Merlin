## Representa uma categoria de perguntas (ex: "Tempo Verbal").
## Responsabilidade única: guardar metadados da categoria.
class_name CategoryData
extends RefCounted

const ALL_CATEGORIES_ID = "__all__"

var id: String
var name: String
var question_count: int

func _init(p_id: String = "", p_name: String = "", p_question_count: int = 0) -> void:
	id = p_id
	name = p_name
	question_count = p_question_count

func get_display_name() -> String:
	return "%s" % [name]

## Categoria especial que representa "jogar com todas as categorias misturadas".
static func create_all_category(total_questions: int) -> CategoryData:
	return CategoryData.new(ALL_CATEGORIES_ID, "Todas as Categorias", total_questions)

func is_all_category() -> bool:
	return id == ALL_CATEGORIES_ID
