extends CanvasLayer

var playerName  # Variable to store the player's name
var score  # Variable to store the player's score

func fetch_player_time(time: float) -> void:
	score = time  # Assign the passed time value to the score variable

func _on_button_pressed() -> void:
	playerName = $LineEdit.text  # Get the text entered in the LineEdit node and assign it to the playerName variable
	SilentWolf.Scores.save_score(playerName, score) 
	# Wait for 0.2 seconds using a timer to allow the save_score function to complete before proceeding
	await get_tree().create_timer(0.2).timeout  
	# Agrument 0 in the get_scores function specifies the number of scores to retrieve, in this case all scores
	var _sw_result: Dictionary = await SilentWolf.Scores.get_scores(0).sw_get_scores_complete 
	get_tree().paused = false  # Set the paused property of the tree to false, allowing the game to continue
	get_tree().change_scene_to_file("res://scenes/UI/leaderboard/leaderboard.tscn") # Change the scene to the leaderboard scene
