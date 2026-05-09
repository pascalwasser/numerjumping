extends Node2D

const PLATFORM_VERTICAL_GAP := 150.0
const SCROLL_SPEED           := 60.0

const VIEWPORT_W := 390.0
const VIEWPORT_H := 844.0
const START_Y    := 680.0
const LEFT_X     := VIEWPORT_W * 0.27
const RIGHT_X    := VIEWPORT_W * 0.73
const CENTER_X   := VIEWPORT_W * 0.5
const MAX_LIVES  := 4

@onready var gm           : GameManager     = $GameManager
@onready var player       : CharacterBody2D = $World/Player
@onready var camera       : Camera2D        = $World/Camera2D
@onready var world        : Node2D          = $World
@onready var label_series : Label           = $HUD/LabelSeries
@onready var label_step   : Label           = $HUD/LabelStep
@onready var label_lives  : Label           = $HUD/LabelLives
@onready var panel_result : Control         = $HUD/PanelResult
@onready var label_result : Label           = $HUD/PanelResult/LabelResult
@onready var btn_next     : Button          = $HUD/PanelResult/BtnNext

var platforms           : Array = []
var current_row         : int   = 0
var highest_spawned_row : int   = 0
var camera_target_y     : float = 0.0
var lives               : int   = MAX_LIVES
var falling_back        : bool  = false
var last_platform       : Node  = null
var fell_off            : bool  = false

func _ready() -> void:
	panel_result.hide()
	gm.connect("level_complete", _on_level_complete)
	gm.connect("step_correct",   _on_step_correct)
	gm.connect("step_wrong",     _on_step_wrong)
	player.connect("landed_on",  _on_landed_on)
	btn_next.connect("pressed",  _on_btn_next)
	_update_lives_display()
	_start_level(2)

func _start_level(multiplier: int) -> void:
	current_row         = 0
	highest_spawned_row = 0
	falling_back        = false
	last_platform       = null
	fell_off            = false

	for p in platforms:
		p.queue_free()
	platforms.clear()

	gm.start_level(multiplier)
	label_series.text = "× " + str(multiplier)
	label_step.text   = "0 / " + str(gm.TOTAL_STEPS)

	_spawn_start_platform()
	_spawn_challenge_row(1)
	_spawn_challenge_row(2)

	player.global_position = Vector2(CENTER_X, START_Y - 40)
	player.locked          = false
	player.jumping         = false

	camera_target_y    = START_Y - VIEWPORT_H * 0.25
	camera.position.y  = camera_target_y

func _process(delta: float) -> void:
	camera_target_y -= SCROLL_SPEED * delta
	camera.position.y = move_toward(camera.position.y, camera_target_y, 300.0 * delta)

	if not panel_result.visible and not fell_off:
		var screen_bottom := camera.position.y + VIEWPORT_H / 2.0
		if player.global_position.y > screen_bottom + 50.0:
			_on_fell_off_screen()

func _spawn_start_platform() -> void:
	platforms.append(_make_platform(CENTER_X, START_Y, gm.start_value(), true, 0))

func _spawn_challenge_row(row: int) -> void:
	if row > gm.TOTAL_STEPS:
		return
	var y            := START_Y - row * PLATFORM_VERTICAL_GAP
	var correct_val  := gm.correct_value_at(row)
	var wrong_val    := gm.wrong_value_at(row)
	var correct_left := randi() % 2 == 0
	var lv := correct_val if correct_left else wrong_val
	var rv := wrong_val   if correct_left else correct_val
	platforms.append(_make_platform(LEFT_X,  y, lv, correct_left,     row))
	platforms.append(_make_platform(RIGHT_X, y, rv, not correct_left, row))
	highest_spawned_row = row

func _make_platform(x: float, y: float, value: int, is_correct: bool, row: int) -> Node2D:
	var p := preload("res://scenes/Platform.tscn").instantiate()
	world.add_child(p)
	p.position = Vector2(x, y)
	p.set_meta("row_index", row)
	p.call("setup", value, is_correct)
	p.add_to_group("platforms")
	return p

func _on_landed_on(platform: Node) -> void:
	if falling_back:
		falling_back  = false
		player.locked = false
		return
	last_platform = platform
	gm.on_platform_landed(platform.get("value") as int)

func _on_step_correct(step: int) -> void:
	label_step.text = str(step) + " / " + str(gm.TOTAL_STEPS)
	current_row     = step
	var ahead_y := START_Y - step * PLATFORM_VERTICAL_GAP - VIEWPORT_H * 0.25
	camera_target_y = min(camera_target_y, ahead_y)

	while highest_spawned_row < current_row + 2 and highest_spawned_row < gm.TOTAL_STEPS:
		_spawn_challenge_row(highest_spawned_row + 1)

	var cutoff_y := camera_target_y + VIEWPORT_H + 100.0
	var to_remove : Array = []
	for p in platforms:
		if p.position.y > cutoff_y:
			to_remove.append(p)
	for p in to_remove:
		platforms.erase(p)
		p.queue_free()

	await get_tree().create_timer(0.5).timeout
	player.locked = false

func _on_step_wrong() -> void:
	lives -= 1
	_update_lives_display()

	# Break the wrong platform
	if is_instance_valid(last_platform):
		last_platform.call("break_platform")
		platforms.erase(last_platform)
	last_platform = null

	if lives <= 0:
		_show_game_over()
		return

	# Let physics carry the player back down
	falling_back   = true
	player.velocity = Vector2(0.0, 60.0)
	player.jumping  = true

func _on_fell_off_screen() -> void:
	fell_off = true
	lives -= 1
	_update_lives_display()
	if lives <= 0:
		_show_game_over()
	else:
		_start_level(gm.current_multiplier)

func _on_level_complete(multiplier: int) -> void:
	label_step.text = str(gm.TOTAL_STEPS) + " / " + str(gm.TOTAL_STEPS)
	panel_result.show()
	var next_m := multiplier + 1
	if next_m > 10:
		label_result.text = "All done!\nYou're a number master!"
		btn_next.text     = "Play Again"
	else:
		label_result.text = "Great job!\n×" + str(multiplier) + " complete!\nReady for ×" + str(next_m) + "?"
		btn_next.text     = "Next: ×" + str(next_m)

func _show_game_over() -> void:
	panel_result.show()
	label_result.text = "Game Over!\n\nNo lives left."
	btn_next.text     = "Try Again"

func _on_btn_next() -> void:
	panel_result.hide()
	if lives <= 0:
		lives = MAX_LIVES
		_update_lives_display()
		_start_level(2)
	else:
		var next_m := gm.current_multiplier + 1
		if next_m > 10:
			next_m = 2
		_start_level(next_m)

func _update_lives_display() -> void:
	var s := ""
	for i in MAX_LIVES:
		s += "♥" if i < lives else "♡"
	label_lives.text = s

func _unhandled_input(event: InputEvent) -> void:
	if player.locked or player.jumping:
		return
	if panel_result.visible:
		return

	var tap_pos := Vector2(-1.0, -1.0)
	if event is InputEventScreenTouch and event.pressed:
		tap_pos = event.position
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		tap_pos = event.position
	else:
		return

	var target_row := current_row + 1
	if target_row > gm.TOTAL_STEPS:
		return

	var row_plats : Array = []
	for p in platforms:
		if p.get_meta("row_index", -1) == target_row:
			row_plats.append(p)

	if row_plats.size() == 0:
		return

	if row_plats.size() == 1:
		player.jump_to(row_plats[0])
		return

	row_plats.sort_custom(func(a, b): return a.global_position.x < b.global_position.x)
	var jumped_to : Node2D = row_plats[0] if tap_pos.x < VIEWPORT_W / 2.0 else row_plats[1]
	player.jump_to(jumped_to)
