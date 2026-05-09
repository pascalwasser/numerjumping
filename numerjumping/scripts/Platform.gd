extends StaticBody2D

@onready var label  : Label     = $Label
@onready var sprite : ColorRect = $Sprite

var value      : int  = 0
var is_correct : bool = false

func setup(v: int, correct: bool) -> void:
	value      = v
	is_correct = correct
	label.text = str(v)

func flash_correct() -> void:
	var tween := create_tween()
	tween.tween_property(sprite, "color", Color(0.3, 0.9, 0.4), 0.15)
	tween.tween_property(sprite, "color", Color(0.35, 0.6, 0.9), 0.15)

func break_platform() -> void:
	$CollisionShape2D.set_deferred("disabled", true)
	sprite.color = Color(0.9, 0.2, 0.2, 1)
	var ox := position.x
	var oy := position.y
	var tween := create_tween()
	tween.tween_property(self, "position:x", ox + 8,  0.05)
	tween.tween_property(self, "position:x", ox - 8,  0.05)
	tween.tween_property(self, "position:x", ox + 5,  0.04)
	tween.tween_property(self, "position:x", ox - 5,  0.04)
	tween.tween_property(self, "position:x", ox,       0.03)
	tween.tween_property(self, "position:y", oy + 110, 0.30).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "modulate:a", 0.0,   0.30)
	tween.tween_callback(queue_free)
