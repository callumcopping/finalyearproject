extends Node

# This script is responsible for tracking time and configuring the SilentWolf plugin.

func _ready() -> void:
	# Configure the SilentWolf plugin with the specified API key, game ID, and log level.

	SilentWolf.configure({
		"api_key": "i1HMaglq1e3y3dPX5xtjGa1gVYAyxUHv6kCZB8DH",
		"game_id": "insertname",
		"log_level": 1
		})

	# Configure the SilentWolf plugin to open the main menu scene when leaderboard is closed.

	SilentWolf.configure_scores({
		"open_scene_on_close": "res://scenes/UI/main menu/MainMenu.tscn"
		})
