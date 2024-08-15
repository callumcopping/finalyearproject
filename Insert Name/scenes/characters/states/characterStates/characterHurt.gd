extends State
class_name CharacterHurt

@onready var character: CharacterBody2D = owner

var hurtDuration: float = 0.5
var timer: float = 0.0

func enter() -> void:
	timer = 0.0
	character.canDmg = false

func state_process(delta: float) -> void:
	if character.animator.get_animation() != "hurt":
		character.animator.play("hurt")
	timer += delta
	if timer >= hurtDuration:
		# Return to default state
		character.canDmg = true		
		var initialState = stateMachine.initialState
		emit_signal("Transitioned", self, initialState.name)
