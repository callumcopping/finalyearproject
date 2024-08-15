extends State
class_name BossDecide

@onready var boss: Boss = owner as baseCharacter
var decisionTimer: float = 0.0
var decisionCooldown: float = 2.0 
var availableStates: Array = ["BossBurrow", "BossDash", "BossProjectile", "BossSummon"]

func enter() -> void:
	decisionTimer = decisionCooldown  # Reset the timer every time we enter the state

func state_process(delta: float) -> void:
	if boss.phaseTwo and not availableStates.has("BossCharge"):
		# In phase 2, add BossCharge to the list of available states
		availableStates.append("BossCharge")
	
	decisionTimer -= delta  # Decrement the timer

	if decisionTimer <= 0.0:
		make_decision()

func state_physics_process(_delta: float) -> void:
		boss.navAgent.set_target_position(boss.player.global_position)
		var nextPosition: Vector2 = boss.navAgent.get_next_path_position()
		boss.moveDirection = (nextPosition - boss.global_position).normalized()
		# Call the move method from baseCharacter to apply movement
		boss.move() 

func make_decision() -> void:
	var nextState = "BossBurrow"  # Default next state
	# Randomly select the next state from the available states
	nextState = availableStates[randi() % availableStates.size()]
	emit_signal("Transitioned", self, nextState)
	decisionTimer = decisionCooldown
