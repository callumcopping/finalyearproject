extends State
class_name PlayerMoveAndShoot
@onready var player: CharacterBody2D = owner as Player

func enter() -> void:
	pass

func state_process(delta: float) -> void:
	if player.animator.get_animation() != "move":
		player.animator.play("move")
	handleMovement()
	handleShooting(delta)
	# If dash key pressed, transition to dash state
	if Input.is_action_just_released("dash") and player.canDash:
		emit_signal("Transitioned", self, "PlayerDash")
	# If player is not moving and not shooting, transition to idle state
	if player.velocity.length() < 10 and not Input.is_action_pressed("shoot"):
		emit_signal("Transitioned", self, "PlayerIdle")

# Move player based on input
func handleMovement() -> void:
	player.moveDirection = Vector2.ZERO
	if Input.is_action_pressed("moveDown"):
		player.moveDirection += Vector2.DOWN
	if Input.is_action_pressed("moveLeft"):
		player.moveDirection += Vector2.LEFT
	if Input.is_action_pressed("moveRight"):
		player.moveDirection += Vector2.RIGHT
	if Input.is_action_pressed("moveUp"):
		player.moveDirection += Vector2.UP
	player.move()

# Shoot if player can shoot and is pressing shoot key
func handleShooting(_delta: float) -> void:
	if player.weapon.canShoot and player.canDmg and Input.is_action_pressed("shoot"):
		player.weapon.shoot()
