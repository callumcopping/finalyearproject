extends Control

@onready var inputRemap: Control = $InputRemap

func _on_settings_pressed() -> void:
	inputRemap.visible = true


func _on_leaderboard_pressed() -> void:
	var _sw_result: Dictionary = await SilentWolf.Scores.get_scores(0).sw_get_scores_complete
	get_tree().change_scene_to_file("res://scenes/UI/leaderboard/leaderboard.tscn")
