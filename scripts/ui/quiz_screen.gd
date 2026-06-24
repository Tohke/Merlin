## Tela do quiz: orquestra QuestionRepository, ScoreService e AudioService.
## Visual inspirado no design de referência (cartão com glow, badge de
## pontuação, barra de progresso, modal de explicação, confete/estrelas).
extends Control

const TITLE_SCENE_PATH := "res://scenes/TitleScreen.tscn"

@onready var question_text: Label = $MarginContainer/VBoxContainer/Card/CardMargin/CardVBox/QuestionText
@onready var question_label: Label = $MarginContainer/VBoxContainer/Card/CardMargin/CardVBox/QuestionLabel
@onready var card_panel: PanelContainer = $MarginContainer/VBoxContainer/Card
@onready var options_container: VBoxContainer = $MarginContainer/VBoxContainer/OptionsContainer
@onready var progress_text: Label = $MarginContainer/VBoxContainer/ProgressWrap/ProgressInfo/ProgressLabel
@onready var progress_pct: Label = $MarginContainer/VBoxContainer/ProgressWrap/ProgressInfo/ProgressPercent
@onready var progress_track: PanelContainer = $MarginContainer/VBoxContainer/ProgressWrap/ProgressTrack
@onready var progress_fill: ColorRect = $MarginContainer/VBoxContainer/ProgressWrap/ProgressTrack/ProgressFill
@onready var score_badge: PanelContainer = $MarginContainer/VBoxContainer/Header/ScoreBadge
@onready var score_label: Label = $MarginContainer/VBoxContainer/Header/ScoreBadge/ScoreLabel
@onready var menu_button: Button = $MarginContainer/VBoxContainer/Header/MenuButton

var _repository: QuestionRepository
var _score_service: ScoreService
var _questions: Array[QuestionData] = []
var _current_index := 0
var _can_answer := true
var _pending_pct := 0

func _ready() -> void:
	_repository = QuestionRepository.new()
	_score_service = ScoreService.new()

	_questions = _repository.get_shuffled_questions(GameState.selected_category_id)
	_score_service.start(_questions.size())

	# Estilo dos elementos que precisam de StyleBox em runtime
	card_panel.add_theme_stylebox_override("panel", ButtonFactory.make_card_style())
	score_badge.add_theme_stylebox_override("panel", ButtonFactory.make_badge_style())
	progress_track.add_theme_stylebox_override("panel", ButtonFactory.make_progress_track_style())

	menu_button.pressed.connect(_on_menu_pressed)

	AudioService.play_background_music()

	# Garante que o layout já calculou tamanhos reais antes da 1ª pergunta
	# (evita barra de progresso com largura 0 no primeiro frame).
	await get_tree().process_frame
	_load_question()

func _on_menu_pressed() -> void:
	AudioService.play_click()
	get_tree().change_scene_to_file(TITLE_SCENE_PATH)

func _load_question() -> void:
	_can_answer = true
	_clear_options()
	card_panel.add_theme_stylebox_override("panel", ButtonFactory.make_card_style())

	if _score_service.is_finished() or _current_index >= _questions.size():
		_show_end_screen()
		return

	var q: QuestionData = _questions[_current_index]
	var total := _questions.size()
	var pct := int((float(_current_index) / float(total)) * 100.0)

	progress_text.text = "Questão %d de %d" % [_current_index + 1, total]
	progress_pct.text = "%d%%" % pct
	_animate_progress_fill(pct)

	score_label.text = "%d pts" % (_score_service.correct_count * 10)

	question_label.text = "🧩  %s" % q.get_display_category()
	question_text.text = q.question_text
	question_text.modulate = Color.WHITE

	_animate_card_enter()

	for i in range(q.options.size()):
		var btn := ButtonFactory.create_styled_button(q.options[i], ButtonFactory.COLOR_CARD2)
		btn.pressed.connect(_on_option_selected.bind(i))
		options_container.add_child(btn)

func _animate_card_enter() -> void:
	card_panel.modulate.a = 0.0
	card_panel.position.y += 18
	var tween := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	tween.tween_property(card_panel, "modulate:a", 1.0, 0.3)
	tween.tween_property(card_panel, "position:y", card_panel.position.y - 18, 0.3)

## Anima a largura do preenchimento da barra de progresso (ColorRect simples,
## ancorado manualmente dentro da track — evita conflitos de container que
## faziam a barra "desaparecer" atrás do cartão).
func _animate_progress_fill(target_pct: int) -> void:
	var track_width: float = progress_track.size.x
	if track_width <= 0.0:
		# Layout ainda não calculado neste frame; tenta no próximo.
		await get_tree().process_frame
		track_width = progress_track.size.x

	var target_width: float = track_width * (target_pct / 100.0)
	var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(progress_fill, "size:x", target_width, 0.4)

func _clear_options() -> void:
	for child in options_container.get_children():
		child.queue_free()

func _on_option_selected(selected_index: int) -> void:
	if not _can_answer:
		return
	_can_answer = false

	AudioService.play_click()

	var q: QuestionData = _questions[_current_index]
	var correct_index := q.correct_answer_index
	var is_correct := selected_index == correct_index
	var buttons := options_container.get_children()

	for i in range(buttons.size()):
		var color: Color
		if i == correct_index:
			color = ButtonFactory.COLOR_CORRECT
		elif i == selected_index:
			color = ButtonFactory.COLOR_WRONG
		else:
			color = ButtonFactory.COLOR_DIM
		ButtonFactory.apply_result_color(buttons[i], color, i == correct_index)
		buttons[i].disabled = true

	# Glow no cartão (igual .card.correct / .card.wrong do CSS)
	var glow_color := ButtonFactory.COLOR_SUCCESS if is_correct else ButtonFactory.COLOR_DANGER
	card_panel.add_theme_stylebox_override("panel", ButtonFactory.make_card_style(glow_color))

	_score_service.register_answer(is_correct)
	_current_index += 1

	if is_correct:
		_pop_score()
		_spawn_stars(buttons[selected_index])
	else:
		_shake_node(card_panel)

	_show_explanation_alert(is_correct, q.explanation)

func _show_end_screen() -> void:
	_clear_options()

	var pct := _score_service.get_percentage()
	AudioService.stop_music()
	if pct >= 70:
		_spawn_confetti()

	var medal := "🏆" if pct >= 80 else ("🥈" if pct >= 50 else "🎯")

	question_label.text = "🎉  Resultado"
	question_text.text = "%s\n%s" % [medal, _score_service.get_feedback_message()]
	question_text.modulate = ButtonFactory.COLOR_ACCENT

	progress_text.text = "Pontuação final"
	progress_pct.text = ""
	_animate_progress_fill(pct)

	score_label.text = "%d pts" % (_score_service.correct_count * 10)

	var summary := ButtonFactory.create_styled_button(
		"Acertos: %d / %d  (%d%%)" % [_score_service.correct_count, _score_service.total_questions, pct],
		ButtonFactory.COLOR_CARD2,
		18
	)
	summary.disabled = true
	summary.custom_minimum_size = Vector2(0, 50)
	options_container.add_child(summary)

	var retry_btn := ButtonFactory.create_styled_button("🔄  Jogar de Novo", ButtonFactory.COLOR_ACTION, 22)
	retry_btn.custom_minimum_size = Vector2(0, 58)
	retry_btn.pressed.connect(func():
		AudioService.play_click()
		get_tree().reload_current_scene()
	)
	options_container.add_child(retry_btn)

	var menu_btn := ButtonFactory.create_styled_button("🏠  Escolher Outra Categoria", ButtonFactory.COLOR_NORMAL, 22)
	menu_btn.custom_minimum_size = Vector2(0, 58)
	menu_btn.pressed.connect(func():
		AudioService.play_click()
		get_tree().change_scene_to_file(TITLE_SCENE_PATH)
	)
	options_container.add_child(menu_btn)


# =====================================================================
#             MODAL DE EXPLICAÇÃO (centralização corrigida)
# =====================================================================

func _show_explanation_alert(is_correct: bool, explanation_text: String) -> void:
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.6)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	# Centralizador dedicado: um Control full-rect que usa um CenterContainer
	# para garantir centralização correta independente do tamanho do painel
	# (evita o bug de PRESET_CENTER aplicado antes do layout calcular o
	# custom_minimum_size, que deslocava o modal para o canto).
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)

	var alert_panel := PanelContainer.new()
	var accent := ButtonFactory.COLOR_SUCCESS if is_correct else ButtonFactory.COLOR_DANGER
	var style := StyleBoxFlat.new()
	style.bg_color = ButtonFactory.COLOR_CARD
	style.border_color = accent
	style.border_width_top = 5
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_left = 18
	style.corner_radius_bottom_right = 18
	style.shadow_color = accent * Color(1, 1, 1, 0.35)
	style.shadow_size = 24
	alert_panel.add_theme_stylebox_override("panel", style)
	alert_panel.custom_minimum_size = Vector2(460, 260)
	center.add_child(alert_panel)

	var margin_container := MarginContainer.new()
	margin_container.add_theme_constant_override("margin_left", 28)
	margin_container.add_theme_constant_override("margin_right", 28)
	margin_container.add_theme_constant_override("margin_top", 24)
	margin_container.add_theme_constant_override("margin_bottom", 24)
	alert_panel.add_child(margin_container)

	var alert_vbox := VBoxContainer.new()
	alert_vbox.add_theme_constant_override("separation", 18)
	margin_container.add_child(alert_vbox)

	var title_label := Label.new()
	title_label.text = "✅ Resposta Correta!" if is_correct else "❌ Resposta Errada!"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 25)
	title_label.add_theme_color_override("font_color", accent)
	alert_vbox.add_child(title_label)

	var desc_label := Label.new()
	desc_label.text = explanation_text
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	desc_label.add_theme_font_size_override("font_size", 16)
	desc_label.add_theme_color_override("font_color", ButtonFactory.COLOR_TEXT)
	alert_vbox.add_child(desc_label)

	var color_btn = ButtonFactory.COLOR_SUCCESS if is_correct else ButtonFactory.COLOR_ACTION
	var next_btn := ButtonFactory.create_styled_button("Avançar  ➡️", color_btn, 18)
	next_btn.custom_minimum_size = Vector2(190, 48)
	next_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	alert_vbox.add_child(next_btn)

	next_btn.pressed.connect(func():
		AudioService.play_click()
		var fade_out := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		fade_out.tween_property(overlay, "modulate:a", 0.0, 0.15)
		fade_out.tween_callback(overlay.queue_free)
		fade_out.tween_callback(_load_question)
	)

	overlay.modulate.a = 0.0
	alert_panel.scale = Vector2(0.85, 0.85)
	alert_panel.pivot_offset = alert_panel.size / 2
	var tween := create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(overlay, "modulate:a", 1.0, 0.2)
	tween.tween_property(alert_panel, "scale", Vector2.ONE, 0.28)


# =====================================================================
#                     SISTEMA DE JUICE ADICIONAL
# =====================================================================

func _shake_node(node: Control) -> void:
	var original_pos = node.position
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var shake_intensity := 10.0
	for i in range(6):
		var direction = 1 if i % 2 == 0 else -1
		var offset = Vector2(shake_intensity * direction, 0)
		tween.tween_property(node, "position", original_pos + offset, 0.04)
		shake_intensity *= 0.75
	tween.tween_property(node, "position", original_pos, 0.04)

func _pop_score() -> void:
	score_badge.pivot_offset = score_badge.size / 2
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(score_badge, "scale", Vector2(1.3, 1.3), 0.15)
	tween.tween_property(score_badge, "scale", Vector2.ONE, 0.2)

func _spawn_stars(button: Button) -> void:
	var btn_global_pos = button.global_position
	var btn_size = button.size
	for i in range(5):
		var star := Label.new()
		star.text = ["✨", "⭐", "🌟", "💫"].pick_random()
		star.add_theme_font_size_override("font_size", randi_range(16, 24))
		star.global_position = btn_global_pos + Vector2(randf_range(0, btn_size.x), randf_range(0, btn_size.y))
		add_child(star)

		var target_pos = star.global_position + Vector2(randf_range(-30, 30), randf_range(-80, -140))
		var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(star, "global_position", target_pos, randf_range(0.5, 0.8))
		tween.tween_property(star, "modulate:a", 0.0, randf_range(0.5, 0.8))
		tween.chain().tween_callback(star.queue_free)

func _spawn_confetti() -> void:
	var view_size = get_viewport_rect().size
	var colors := [
		ButtonFactory.COLOR_PRIMARY, ButtonFactory.COLOR_ACCENT, ButtonFactory.COLOR_SUCCESS,
		Color("#818cf8"), Color("#fbbf24"), Color("#ec4899"), Color("#a3e635")
	]
	for i in range(50):
		var confetti := ColorRect.new()
		confetti.custom_minimum_size = Vector2(randf_range(6, 12), randf_range(6, 12))
		confetti.pivot_offset = confetti.custom_minimum_size / 2
		confetti.color = colors.pick_random()
		confetti.global_position = Vector2(randf_range(0, view_size.x), -20)
		add_child(confetti)

		var target_y = view_size.y + 20
		var target_x = confetti.global_position.x + randf_range(-100, 100)
		var duration = randf_range(1.8, 3.2)

		var tween = create_tween().set_parallel(true)
		tween.tween_property(confetti, "global_position:y", target_y, duration).set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(confetti, "global_position:x", target_x, duration).set_trans(Tween.TRANS_SINE)
		tween.tween_property(confetti, "rotation", randf_range(4.0, 12.0), duration)
		tween.chain().tween_callback(confetti.queue_free)
