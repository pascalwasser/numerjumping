extends Node
class_name GameManager

signal level_complete(multiplier: int)
signal game_over
signal step_correct(step: int)
signal step_wrong

const TOTAL_STEPS := 9
const MULTIPLIERS := [2, 3, 4, 5, 6, 7, 8, 9, 10]

var current_multiplier: int = 2
var current_step: int = 0      # 0 = start platform, 1..10 = jumps

func start_level(multiplier: int) -> void:
	current_multiplier = multiplier
	current_step = 0

func start_value() -> int:
	return current_multiplier

func correct_value_at(step: int) -> int:
	return current_multiplier * (step + 1)

func next_correct_value() -> int:
	return correct_value_at(current_step + 1)

func wrong_value_at(step: int) -> int:
	# Pick a nearby wrong number that is not the correct answer
	var correct := correct_value_at(step)
	var offset := (randi() % 3 + 1) * current_multiplier
	if randi() % 2 == 0:
		return correct + offset
	else:
		return maxi(1, correct - offset)

func on_platform_landed(value: int) -> void:
	var expected := correct_value_at(current_step + 1)
	if value == expected:
		current_step += 1
		if current_step == TOTAL_STEPS:
			emit_signal("level_complete", current_multiplier)
		else:
			emit_signal("step_correct", current_step)
	else:
		emit_signal("step_wrong")
