extends State
class_name EnemyChase
@onready var enemy: CharacterBody2D = owner as baseCharacter

var chaseDistance: float = 250

func enter():
	pass
	
func state_process(_delta: float) -> void:
	if enemy.animator.get_animation() != "chase":
			enemy.animator.play("chase")

func state_physics_process(_delta: float) -> void:
	if enemy and is_instance_valid(enemy.player):
		var direction: Vector2 = enemy.player.global_position - enemy.global_position
		if direction.length() > chaseDistance:
			# If the player is beyond chase distance, stop the enemy
			enemy.velocity = Vector2.ZERO
			enemy.moveDirection = Vector2.ZERO
			# Transition to wander when player is out of range
			emit_signal("Transitioned", self, "EnemyWander")
		else:
			# If the player is within chase distance, move towards the player
			# Set the target position for the navigation agent
			enemy.navAgent.set_target_position(enemy.player.global_position)
			var nextPosition: Vector2 = enemy.navAgent.get_next_path_position()
			enemy.moveDirection = (nextPosition - enemy.global_position).normalized()
		# Call the move method from baseCharacter to apply movement
		enemy.move() 
