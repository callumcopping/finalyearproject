extends Area2D
class_name BasePickup

var playerInstance: Player

# Called when player enters the pickup area
func _on_pickup(body: Node2D) -> void:
	if body is Player:
		playerInstance = body
		apply_effect(playerInstance)
		queue_free()

# This function is meant to be overridden by the child class
func apply_effect(body: Node2D) -> void:
	pass
