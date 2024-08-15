extends Node2D

@onready var levelTwo: Area2D = $"Level 2"

var gameWorld: Node2D

# Called when the node enters the scene tree
func _ready() -> void:
	# Get a reference to the game world node
	gameWorld = get_tree().get_root().get_node("Game World")
	
	# Check if "levelOne" is in the list of beaten levels in the "Game World" node
	check_unlocked()

func check_unlocked() -> void:
	if "levelOne" in gameWorld.beatenLevels:
		# Make "Level 2" visible and enable monitoring, allowing player progression to level 2
		levelTwo.visible = true
		levelTwo.monitoring = true
	
	# Check if "levelTwo" is beaten and the end time hasnt been set, stop the timer
	if "levelTwo" in gameWorld.beatenLevels:
		if gameWorld.endTime == 0:
			# Stop the timer in "Game World"
			gameWorld.stop_timer()
