extends baseNPC
class_name  timeNPC
@onready var timeSubmit: CanvasLayer = $ScoreSubmit
@onready var gameWorld: Node2D = get_tree().get_root().get_node("Game World")

func interact() -> void:
	if gameWorld.totalTime != 0:
		timeSubmit.fetch_player_time(gameWorld.totalTime) # Fetch player's time
		timeSubmit.visible = true # Show the time submission UI
		get_tree().paused = true # Pause the game
	else:
		inRangePrompt.text = "No time set\nbeat the game to set" # Display message if no time is set
		
func _on_area_2d_body_exited(body: Node2D) -> void:
	inRangePrompt.text = "Press enter 2 \nsubmit score" # Display prompt to submit score
	super(body) # Call the parent function
