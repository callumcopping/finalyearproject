extends CharacterBody2D
class_name baseNPC

# Variable to track if the player is in range
var playerInRange: bool = false

# Reference to the player instance
var playerInstance: Player

# Reference to the in-range prompt label
@onready var inRangePrompt: Label = $InRangePrompt

func _process(_delta: float) -> void:
	# Check if the player is in range and the accept button is pressed
	if playerInRange and Input.is_action_just_released("ui_accept"):
		interact()

func _on_area_2d_body_entered(body: Node2D) -> void:
	# Check if the entered body is the player
	if body.name == "Player":
		playerInRange = true
		playerInstance = body
		inRangePrompt.visible = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	# Check if the exited body is the player
	if body.name == "Player":
		playerInRange = false
		playerInstance = null
		inRangePrompt.visible = false

# Placeholder method for interaction with the player
func interact() -> void:
	print("player interacted with NPC")
