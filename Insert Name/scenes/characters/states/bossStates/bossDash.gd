extends State
class_name BossDash

@onready var boss: baseCharacter = owner as baseCharacter

var dashSpeed: float = 500 
var dashDirection: Vector2
var dashPrepareTime: float = 0.2  # Time before the dash starts
var timer: float = 0

func enter() -> void:
	boss.isDashing = true
	timer = dashPrepareTime
	# Calculate the direction to dash towards
	dashDirection = (boss.player.global_position - boss.global_position).normalized()
	boss.velocity = Vector2.ZERO  # Stop any ongoing movement

func state_process(delta: float) -> void:
	if timer > 0:
		timer -= delta
		return  # Wait until the preparation time is over
	
	# Start dashing
	var collision = boss.move_and_collide(dashDirection * dashSpeed * delta)
	if collision:
			end_dash()

func end_dash() -> void:
	boss.isDashing = false
	boss.velocity = Vector2.ZERO 
	emit_signal("Transitioned", self, "BossDecide")
