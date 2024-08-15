extends Node2D

@export_file var levelToPreview

func _ready() -> void:
	var level_scene = load(levelToPreview).instantiate()
	add_child(level_scene)

