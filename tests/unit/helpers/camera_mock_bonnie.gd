extends CharacterBody2D

## Headless helper: [method get_movement_state] for [BonnieCamera] tests.

var mock_movement_state: int = 0


func get_movement_state() -> int:
	return mock_movement_state
