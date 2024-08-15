extends State
class_name BossBurrow

@onready var boss: baseCharacter = owner as baseCharacter
var timeUnder: float = 2.0
var timeUnderCounter: float = 0.0
var isUnder: bool = false
var emergencePosition: Vector2

func enter() -> void:
	# Play the "burrow" animation and connect to its finished signal
	boss.animator.play("burrow")
	boss.animator.connect("animation_finished", Callable(self, "_on_Burrow_Animation_Finished"))

func _on_Burrow_Animation_Finished() -> void:
	# Disconnect from the finished signal and set the boss properties
	boss.animator.disconnect("animation_finished", Callable(self, "_on_Burrow_Animation_Finished"))
	boss.canDmg = false
	isUnder = true
	# Hide the boss as is under
	$"../../Sprite".visible = false
	$"../../HpDisplay".visible = false
	$"../../CollisionShape2D".disabled = true
	$"../../PlayerCollisonDetector".monitoring = false
	timeUnderCounter = timeUnder
	# Calculate the emergence position near the player when entering the burrow state
	emergencePosition = calculate_emergence_position()

func state_process(delta: float) -> void:
	if isUnder:
		timeUnderCounter -= delta
		if timeUnderCounter <= 0.0:
			emerge()

func state_physics_process(_delta: float) -> void:
	if isUnder:
		# Move the boss towards the emergence position using linear interpolation
		boss.global_position = boss.global_position.lerp(emergencePosition, 0.05)

func calculate_emergence_position() -> Vector2:
	var safeDistance = 50
	var potentialPosition = Vector2()
	var attempts = 0
	var bossCollisionSize = Vector2(64, 64)

	# Calculate the inner bounds the boss can safely emerge within, accounting for its size
	var innerRoomRect = Rect2(
		boss.roomRect.position + bossCollisionSize / 2,
		boss.roomRect.size - bossCollisionSize
	)

	# Try to find a safe emergence position within the inner bounds
	while attempts < 10:
		var offset = Vector2(randf_range(-75, 75), randf_range(-75, 75))
		potentialPosition.x = clamp(boss.player.global_position.x + offset.x, innerRoomRect.position.x, innerRoomRect.position.x + innerRoomRect.size.x)
		potentialPosition.y = clamp(boss.player.global_position.y + offset.y, innerRoomRect.position.y, innerRoomRect.position.y + innerRoomRect.size.y)

		# Check if the position is a safe distance away from the player
		if potentialPosition.distance_to(boss.player.global_position) >= safeDistance:
			break
		attempts += 1

	# If after 10 attempts it fails to find a safe position, it'll just use the last calculated one.
	return potentialPosition

func emerge() -> void:
	isUnder = false
	# Show the boss
	$"../../Sprite".visible = true
	$"../../HpDisplay".visible = true
	$"../../CollisionShape2D".disabled = false
	$"../../PlayerCollisonDetector".monitoring = true
	boss.global_position = emergencePosition
	boss.canDmg = true
	# Play the "unburrow" animation and connect to its finished signal
	boss.animator.play("unburrow")
	boss.animator.connect("animation_finished", Callable(self, "_on_Unburrow_Animation_Finished"))
	emit_signal("Transitioned", self, "BossDecide")

func _on_Unburrow_Animation_Finished() -> void:
	# Disconnect from the finished signal and play the "default" animation
	boss.animator.disconnect("animation_finished", Callable(self, "_on_Unburrow_Animation_Finished"))
	boss.animator.play("default")
