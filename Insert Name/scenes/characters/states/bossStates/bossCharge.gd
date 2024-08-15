extends State
class_name BossCharge

@onready var boss: baseCharacter = owner as baseCharacter

var chargeSpeed: float = 500
var chargeDirection: Vector2
var chargePrepareTime: float = 0.2  # Time before the first charge starts
var timer: float = 0
var chargeCount: int = 0
var maxCharges: int = 3

func enter() -> void:
	boss.isDashing = true 
	timer = chargePrepareTime
	chargeCount = 0
	# Calculate the direction to charge towards
	chargeDirection = (boss.player.global_position - boss.global_position).normalized()
	boss.velocity = Vector2.ZERO  # Stop any ongoing movement

func state_process(delta: float) -> void:
	if chargeCount >= maxCharges:
		end_charge()
		return

	# Wait until the preparation time is over for the first charge
	if chargeCount == 0:
		if timer > 0:
			timer -= delta
			return
	
	# Start charging
	var collision = boss.move_and_collide(chargeDirection * chargeSpeed * delta)
	if collision:
		chargeCount += 1
		if collision.get_collider() == boss.player:
			# If hit the player, end the charges
			end_charge()
			return
		if chargeCount < maxCharges:
			# If more charges left, immediately prepare for the next one
			chargeDirection = (boss.player.global_position - boss.global_position).normalized()

func end_charge() -> void:
	boss.isDashing = false
	boss.velocity = Vector2.ZERO
	emit_signal("Transitioned", self, "BossDecide")
