## Tela de título: exibe o nome do jogo e os botões de categoria
## (incluindo "Todas as Categorias"). Ao escolher, salva a categoria em
## GameState e troca para a cena do quiz.
extends Control

const QUIZ_SCENE_PATH := "res://scenes/QuizScreen.tscn"

@onready var category_list: VBoxContainer = $MarginContainer/VBoxContainer/ScrollContainer/CategoryList

var _repository: QuestionRepository

func _ready() -> void:
	_repository = QuestionRepository.new()
	AudioService.play_background_music()
	_populate_categories()

func _populate_categories() -> void:
	for child in category_list.get_children():
		child.queue_free()

	var categories := _repository.get_categories_with_all_option()

	for category in categories:
		var is_all := category.is_all_category()
		var color := ButtonFactory.COLOR_ACCENT if is_all else ButtonFactory.COLOR_ACTION
		var count_label := "%d perguntas" % category.question_count if category.question_count != 1 else "1 pergunta"

		var btn := ButtonFactory.create_styled_button(
			"%s\n%s" % [category.get_display_name(), count_label],
			color,
			20
		)
		btn.custom_minimum_size = Vector2(0, 66)
		btn.pressed.connect(_on_category_selected.bind(category.id))
		category_list.add_child(btn)

func _on_category_selected(category_id: String) -> void:
	AudioService.play_click()
	GameState.selected_category_id = category_id
	get_tree().change_scene_to_file(QUIZ_SCENE_PATH)
