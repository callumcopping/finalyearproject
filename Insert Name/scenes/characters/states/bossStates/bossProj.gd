extends State
class_name BossProjectile

@onready var boss: baseCharacter = owner as baseCharacter
var bulletScene = preload("res://scenes/characters/weapons/bullet.tscn")
var shootingDuration: float = 2.0  # Duration of the shooting phase in seconds
var shootInterval: float = 0.2  # Interval between shots in seconds
var timeSinceLastShot: float = 0.0
var elapsedTime: float = 0.0

func enter() -> void:
	elapsedTime = 0.0
	timeSinceLastShot = shootInterval 

func state_process(_delta: float) -> void:
	elapsedTime += _delta
	timeSinceLastShot += _delta
	
	if elapsedTime <= shootingDuration:
		if timeSinceLastShot >= shootInterval:
			shoot_projectiles()
			timeSinceLastShot = 0.0
	else:
		emit_signal("Transitioned", self, "BossDecide")  # Transition out after 2 seconds

# Shoot projectiles in 8 directions
func shoot_projectiles() -> void:
	var directions = [
		Vector2.UP,
		Vector2.UP + Vector2.RIGHT,
		Vector2.RIGHT,
		Vector2.DOWN + Vector2.RIGHT,
		Vector2.DOWN,
		Vector2.DOWN + Vector2.LEFT,
		Vector2.LEFT,
		Vector2.UP + Vector2.LEFT
	]
	
	for direction in directions:
		var bulletInstance = bulletScene.instantiate()
		boss.add_child(bulletInstance)
		bulletInstance.global_position = boss.global_position  
		bulletInstance.rotation = direction.angle()
		bulletInstance.speed = 200
		bulletInstance.scale.x = 0.5
		bulletInstance.scale.y = 0.5

		
