extends State
class_name EnemyWander

@onready var enemy: CharacterBody2D = owner as baseCharacter

var wanderDirection: Vector2 = Vector2.ZERO
var wanderTime: float = 0
var timer: float = 0

# Randomizes the wander direction and time
func randomize_wander():
	wanderDirection = Vector2(randf_range(1, -1), randf_range(1, -1)).normalized()
	wanderTime = randf_range(0, 1)
	timer = 0

func enter():
	randomize_wander()

func state_process(delta: float) -> void:
	if enemy.animator.get_animation() != "wander":
		enemy.animator.play("wander")
	timer += delta
	if timer > wanderTime:
		randomize_wander()

func state_physics_process(_delta: float) -> void:
	var chaseState: State = stateMachine.states["enemychase"] as EnemyChase
	var chaseDistance: float = chaseState.chaseDistance

	if enemy and is_instance_valid(enemy.player):
		var direction: Vector2 = enemy.player.global_position - enemy.global_position
		if direction.length() <= chaseDistance:
			emit_signal("Transitioned", self, "EnemyChase") # Transition to chase when player is within range
		else:
			enemy.moveDirection = wanderDirection
			enemy.move()
