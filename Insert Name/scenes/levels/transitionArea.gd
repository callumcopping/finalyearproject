extends Area2D

@export_file var targetLevel: String
var gameWorld: Node2D
var levelIdentifier

func _ready() -> void:
	gameWorld = get_tree().get_root().get_node("Game World")
	
func find_level():
	var levels = get_tree().get_nodes_in_group("levels")
	if levels.size() > 0:
		levelIdentifier = levels[0].name
		
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		find_level()
		gameWorld.load_level(targetLevel)
		gameWorld.emit_signal("level_completed", levelIdentifier)
