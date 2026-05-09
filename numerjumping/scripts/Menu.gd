extends Control

const VIEWPORT_W    := 390.0
const SPEED_LABELS  := ["1", "2", "3", "4", "5"]
const SERIES_STARTS := [1, 11, 21, 31, 41]
const SERIES_LABELS := ["1-10", "11-20", "21-30", "31-40", "41-50"]

var _speed_btns  : Array = []
var _series_btns : Array = []

func _ready() -> void:
	_build_ui()
	_refresh()

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.12, 0.15, 0.28, 1)
	add_child(bg)

	_add_label("NumerJumping", 42, 90)
	_add_label("Multiplication Training", 20, 152)

	_add_section("Speed", 262)
	_add_hint("Slow", "Fast", 312)
	_speed_btns = _add_row(SPEED_LABELS, 308, 56)
	for i in _speed_btns.size():
		var idx := i
		_speed_btns[i].pressed.connect(func(): _pick_speed(idx))

	_add_section("Series", 416)
	_series_btns = _add_row(SERIES_LABELS, 458, 64)
	for i in _series_btns.size():
		var idx := i
		_series_btns[i].pressed.connect(func(): _pick_series(idx))

	var play := Button.new()
	play.text = "PLAY"
	play.add_theme_font_size_override("font_size", 32)
	play.set_position(Vector2(95, 590))
	play.set_size(Vector2(200, 72))
	_apply_style(play, Color(0.28, 0.72, 0.42, 1), 16)
	play.pressed.connect(_on_play)
	add_child(play)

func _add_label(text: String, size: int, y: float) -> void:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.set_position(Vector2(0, y))
	l.set_size(Vector2(VIEWPORT_W, size + 10))
	add_child(l)

func _add_section(text: String, y: float) -> void:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 22)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_color_override("font_color", Color(0.7, 0.8, 1.0))
	l.set_position(Vector2(0, y))
	l.set_size(Vector2(VIEWPORT_W, 30))
	add_child(l)

func _add_hint(left: String, right: String, y: float) -> void:
	for pair in [[left, HORIZONTAL_ALIGNMENT_LEFT, 20.0], [right, HORIZONTAL_ALIGNMENT_RIGHT, VIEWPORT_W - 20.0 - 60.0]]:
		var l := Label.new()
		l.text = pair[0]
		l.add_theme_font_size_override("font_size", 13)
		l.add_theme_color_override("font_color", Color(0.55, 0.65, 0.85))
		l.set_position(Vector2(pair[2], y))
		l.set_size(Vector2(60, 18))
		l.horizontal_alignment = pair[1]
		add_child(l)

func _add_row(labels: Array, y: float, btn_w: float) -> Array:
	var btns  := []
	var gap   := 8.0
	var count := labels.size()
	var total := count * btn_w + (count - 1) * gap
	var x0    := (VIEWPORT_W - total) / 2.0
	for i in count:
		var b := Button.new()
		b.text = str(labels[i])
		b.add_theme_font_size_override("font_size", 15)
		b.set_position(Vector2(x0 + i * (btn_w + gap), y))
		b.set_size(Vector2(btn_w, 44))
		add_child(b)
		btns.append(b)
	return btns

func _pick_speed(idx: int) -> void:
	GameSettings.speed_level = idx
	_refresh()

func _pick_series(idx: int) -> void:
	GameSettings.series_start = SERIES_STARTS[idx]
	_refresh()

func _refresh() -> void:
	for i in _speed_btns.size():
		var sel := i == GameSettings.speed_level
		_apply_style(_speed_btns[i], Color(0.28, 0.72, 0.42, 1) if sel else Color(0.22, 0.27, 0.45, 1), 10)
	var si := SERIES_STARTS.find(GameSettings.series_start)
	for i in _series_btns.size():
		var sel := i == si
		_apply_style(_series_btns[i], Color(0.28, 0.72, 0.42, 1) if sel else Color(0.22, 0.27, 0.45, 1), 10)

func _apply_style(btn: Button, color: Color, radius: int) -> void:
	var s := StyleBoxFlat.new()
	s.bg_color                   = color
	s.corner_radius_top_left     = radius
	s.corner_radius_top_right    = radius
	s.corner_radius_bottom_left  = radius
	s.corner_radius_bottom_right = radius
	for state in ["normal", "hover", "pressed", "focus"]:
		btn.add_theme_stylebox_override(state, s)

func _on_play() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
