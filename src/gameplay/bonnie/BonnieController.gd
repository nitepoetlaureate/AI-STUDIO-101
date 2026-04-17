extends CharacterBody2D

## Production BONNIE traversal (System 6). Implemented in S1-09.
## Does not declare [code]class_name BonnieController[/code] while the prototype
## (`prototypes/bonnie-traversal/BonnieController.gd`) still owns that global class.

func _ready() -> void:
	print_verbose("[BonnieController production] scaffold loaded")
