extends CharacterBody2D

signal landed_on(platform: Node)

const JUMP_VELOCITY   := -900.0
const GRAVITY         := 2200.0
const HORIZONTAL_SPEED := 320.0

var target_x: float = 0.0
var jumping: bool   = false
var locked: bool    = false

@onready var sprite_root: Node2D = $SpriteRoot

func _ready() -> void:
	_start_idle_bob()

func _start_idle_bob() -> void:
	var tween := create_tween().set_loops()
	tween.tween_property(sprite_root, "position:y", -4.0, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite_root, "position:y",  0.0, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

func jump_to(target_platform: Node2D) -> void:
	if locked:
		return
	locked = true
	target_x = target_platform.global_position.x
	velocity.y = JUMP_VELOCITY
	velocity.x = sign(target_x - global_position.x) * HORIZONTAL_SPEED
	jumping = true

func _physics_process(delta: float) -> void:
	if not jumping:
		return

	velocity.y += GRAVITY * delta

	var diff_x := target_x - global_position.x
	if abs(diff_x) < 8.0:
		velocity.x = 0.0
		global_position.x = target_x
	else:
		velocity.x = sign(diff_x) * HORIZONTAL_SPEED

	move_and_slide()

	if is_on_floor():
		velocity = Vector2.ZERO
		jumping = false
		for i in get_slide_collision_count():
			var col      := get_slide_collision(i)
			var collider := col.get_collider()
			if collider and collider.is_in_group("platforms"):
				emit_signal("landed_on", collider)
				break
