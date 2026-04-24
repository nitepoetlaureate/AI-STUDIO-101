extends Node

## Autoload: provisional relay for environmental chaos (8) and pest/survival (15). Contracts finalized in S1-14.

@warning_ignore("unused_signal")
signal object_chaos_event(value: float)
@warning_ignore("unused_signal")
signal pest_caught(pest_type: int)

func _ready() -> void:
	print_verbose("[ChaosEventBus] scaffold loaded")
