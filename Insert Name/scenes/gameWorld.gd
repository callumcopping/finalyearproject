extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var timerLabel: Label = $CanvasLayer/TimerLabel

var currentLevel: Node2D = null
var beatenLevels: Array = []
var startTime: float = 0
var endTime: float
var totalTime: float = 0 

signal level_completed(level_name)

func _ready() -> void:
	# Start the game by loading the hub world
	load_level("res://scenes/levels/hubWorld.tscn")
	start_timer()
	
func _process(delta: float) -> void:
	if endTime == 0:
		update_timer_ui()

func load_level(path: String) -> void:
	# Clean up the current level if there is one
	if currentLevel != null:
		currentLevel.queue_free()

	# Load and instantiate the new level
	var levelScene = load(path)
	if levelScene:
		var level: Node2D = levelScene.instantiate()
		$Levels.call_deferred("add_child", level)
		currentLevel = level
		call_deferred("set_player_position", level)
	else:
		print("Failed to load level from path: ", path)

func set_player_position(level: Node2D) -> void:
	# Assuming each level has a Position2D node named "PlayerSpawn"
	var spawnPoint: Marker2D = level.get_node("PlayerSpawn")
	if spawnPoint:
		player.global_position = spawnPoint.global_position
	else:
		print("No PlayerSpawn node found in the level")

# This function is called when a level is completed
func _on_level_completed(levelName: Variant) -> void:
	if levelName:
		# Check if the level has already been beaten
		if levelName not in beatenLevels:
			# Add the level to the beatenLevels array
			beatenLevels.append(levelName)
			# Print the name of the completed level
			print("Just completed: ", levelName)
			
func start_timer():
	# Get the current system time in seconds
	startTime = Time.get_unix_time_from_system()

func stop_timer():
	# Get the current system time in seconds
	endTime = Time.get_unix_time_from_system()
	# Calculate the total play time
	totalTime = endTime - startTime
	print("Total play time: %s seconds." % totalTime)
	
func update_timer_ui():
	var currentTime: float
	# If the timer has stopped, use the end time
	if endTime:
		currentTime = endTime
	# Otherwise, use the current system time
	else:
		currentTime = Time.get_unix_time_from_system()

	# Calculate the elapsed time in minutes and seconds
	var elapsedTime: float = currentTime - startTime
	# Cast to an int as we only want whole minutes and seconds
	var minutes: int = (elapsedTime / 60)
	var seconds: int = (int(elapsedTime) % 60)
	# Update the timer label text
	timerLabel.text = "Time: %02d:%02d" % [minutes, seconds]

