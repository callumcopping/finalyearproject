extends State
class_name PlayerDash
@onready var player: CharacterBody2D = owner as Player

func enter() -> void:
	if player.canDash:
		player.isDashing = true
		player.velocity = player.moveDirection.normalized() * player.dashSpeed
		player.canDash = false
		player.dashTimer = 0.0
		player.canDmg = false
		player.modulate = Color.SALMON
		# Disable collisons
		player.set_collision_mask_value(2, false) # Enemies
		player.set_collision_mask_value(4, false) # WorldObjects
		player.set_collision_mask_value(6, false) #NPCs

func state_physics_process(delta: float) -> void:
	player.dashTimer += delta
	if player.dashTimer >= player.dashDuration:
		player.isDashing = false
		player.canDmg = true
		# Enable collisons
		player.set_collision_mask_value(2, true)
		player.set_collision_mask_value(4, true)
		player.set_collision_mask_value(6, true)
		player.modulate = Color(1, 1, 1, 1)
		emit_signal("Transitioned", self, "PlayerMoveAndShoot")

