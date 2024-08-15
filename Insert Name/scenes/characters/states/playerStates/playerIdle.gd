extends State
class_name PlayerIdle
@onready var player: CharacterBody2D = owner as Player

func enter():
	pass

func state_process(_delta: float) -> void:
	if player.animator.get_animation() != "idle":
		player.animator.play("idle")
	if player.isMovingInput() or player.velocity.length() > 10:
		emit_signal("Transitioned", self, "PlayerMoveAndShoot")		
