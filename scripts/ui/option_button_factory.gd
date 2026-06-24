## Responsabilidade única: criar botões e estilos visuais consistentes,
## seguindo a paleta de cores do design de referência (cartão escuro,
## azul "sky" como cor primária, laranja como destaque).
class_name ButtonFactory
extends RefCounted

# --- Paleta de cores (baseada no HTML de referência) ---
const COLOR_BG       = Color("#0f172a") # fundo geral (slate-900)
const COLOR_CARD      = Color("#1e293b") # cartão (slate-800)
const COLOR_CARD2     = Color("#263348") # cartão secundário / opções
const COLOR_PRIMARY   = Color("#38bdf8") # azul "sky" (destaque, progresso)
const COLOR_PRIMARY_DARK = Color("#0284c7")
const COLOR_ACCENT    = Color("#f97316") # laranja (pontuação, destaque)
const COLOR_SUCCESS   = Color("#22c55e")
const COLOR_SUCCESS_DARK = Color("#16a34a")
const COLOR_DANGER    = Color("#ef4444")
const COLOR_DANGER_DARK = Color("#b91c1c")
const COLOR_BORDER    = Color("#334155")
const COLOR_TEXT      = Color("#f1f5f9")
const COLOR_MUTED     = Color("#94a3b8")

# --- Aliases usados pelo restante do código (mantém nomes já usados) ---
const COLOR_NORMAL  = COLOR_CARD2
const COLOR_CORRECT = COLOR_SUCCESS
const COLOR_WRONG   = COLOR_DANGER
const COLOR_DIM     = Color("#1a2333")
const COLOR_ACTION  = COLOR_PRIMARY

static func make_style(color: Color, border_color: Color = COLOR_BORDER, border_width: int = 2) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.border_color = border_color
	s.border_width_left = border_width
	s.border_width_right = border_width
	s.border_width_top = border_width
	s.border_width_bottom = border_width
	s.corner_radius_top_left = 14
	s.corner_radius_top_right = 14
	s.corner_radius_bottom_left = 14
	s.corner_radius_bottom_right = 14
	s.content_margin_left = 18
	s.content_margin_right = 18
	s.content_margin_top = 16
	s.content_margin_bottom = 16
	return s

## Cria um botão de opção/ação com o esquema de cores padrão e leve "juice"
## de hover (escala suave), igual à referência visual.
static func create_styled_button(text: String, base_color: Color = COLOR_NORMAL, font_size: int = 20) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.custom_minimum_size = Vector2(0, 58)
	btn.clip_text = false
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	var border := COLOR_BORDER if base_color == COLOR_NORMAL else base_color.darkened(0.2)

	btn.add_theme_stylebox_override("normal", make_style(base_color, border))
	btn.add_theme_stylebox_override("hover", make_style(base_color.lightened(0.08), COLOR_PRIMARY))
	btn.add_theme_stylebox_override("pressed", make_style(base_color.darkened(0.1), border))
	btn.add_theme_stylebox_override("disabled", make_style(COLOR_DIM, COLOR_BORDER))
	btn.add_theme_color_override("font_color", COLOR_TEXT)
	btn.add_theme_color_override("font_hover_color", Color.WHITE)
	btn.add_theme_color_override("font_disabled_color", COLOR_MUTED)
	btn.add_theme_font_size_override("font_size", font_size)

	# Hover "lift" sutil, como no CSS (translateY + scale).
	btn.mouse_entered.connect(func():
		if btn.disabled:
			return
		btn.pivot_offset = btn.size / 2
		var tween := btn.create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(btn, "scale", Vector2(1.03, 1.03), 0.15)
	)
	btn.mouse_exited.connect(func():
		var tween := btn.create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(btn, "scale", Vector2.ONE, 0.15)
	)

	return btn

## Aplica a cor de resultado (certo/errado) a um botão já existente, com
## leve "pulse" igual ao .correctPulse / .shake do CSS.
static func apply_result_color(btn: Button, color: Color, animate_correct: bool = false) -> void:
	btn.scale = Vector2.ONE
	var border := color.darkened(0.25)
	btn.add_theme_stylebox_override("normal", make_style(color, border))
	btn.add_theme_stylebox_override("disabled", make_style(color, border))
	btn.add_theme_color_override("font_disabled_color", Color.WHITE)

	if animate_correct:
		btn.pivot_offset = btn.size / 2
		var tween := btn.create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(btn, "scale", Vector2(1.07, 1.07), 0.12)
		tween.tween_property(btn, "scale", Vector2.ONE, 0.12)

## Cria o StyleBox de "cartão" usado na pergunta (fundo escuro + topo
## levemente destacado), espelhando o .card do CSS.
static func make_card_style(border_color: Color = COLOR_BORDER) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = COLOR_CARD
	s.border_color = border_color
	s.border_width_left = 2
	s.border_width_right = 2
	s.border_width_bottom = 2
	s.border_width_top = 4
	s.corner_radius_top_left = 18
	s.corner_radius_top_right = 18
	s.corner_radius_bottom_left = 18
	s.corner_radius_bottom_right = 18
	s.content_margin_left = 28
	s.content_margin_right = 28
	s.content_margin_top = 26
	s.content_margin_bottom = 22
	s.shadow_color = Color(0, 0, 0, 0.35)
	s.shadow_size = 18
	return s

## Cria o StyleBox da badge de pontuação (pílula arredondada).
static func make_badge_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = COLOR_CARD2
	s.border_color = COLOR_BORDER
	s.border_width_left = 2
	s.border_width_right = 2
	s.border_width_top = 2
	s.border_width_bottom = 2
	s.corner_radius_top_left = 50
	s.corner_radius_top_right = 50
	s.corner_radius_bottom_left = 50
	s.corner_radius_bottom_right = 50
	s.content_margin_left = 18
	s.content_margin_right = 18
	s.content_margin_top = 8
	s.content_margin_bottom = 8
	return s

## Cria o StyleBox da trilha da barra de progresso.
static func make_progress_track_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = COLOR_CARD2
	s.border_color = COLOR_BORDER
	s.border_width_left = 2
	s.border_width_right = 2
	s.border_width_top = 2
	s.border_width_bottom = 2
	s.corner_radius_top_left = 50
	s.corner_radius_top_right = 50
	s.corner_radius_bottom_left = 50
	s.corner_radius_bottom_right = 50
	return s

## Cria o StyleBox do preenchimento da barra de progresso (gradiente azul).
static func make_progress_fill_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = COLOR_PRIMARY
	s.corner_radius_top_left = 50
	s.corner_radius_top_right = 50
	s.corner_radius_bottom_left = 50
	s.corner_radius_bottom_right = 50
	return s
