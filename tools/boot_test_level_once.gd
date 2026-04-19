extends SceneTree

func _init() -> void:
	var packed: PackedScene = load("res://prototypes/bonnie-traversal/TestLevel.tscn") as PackedScene
	var inst: Node = packed.instantiate()
	root.add_child(inst)
	quit(0)
