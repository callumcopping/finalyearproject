extends State
class_name BossSummon

@onready var boss: baseCharacter = owner as baseCharacter
var summonTimer: float = 0.0
var summonInterval: float = 3.0
var enemiesSpawned: int = 0
var maxEnemies: int = 5
var startingHp: int
var minHp: int

func enter() -> void:
	summonTimer = summonInterval
	enemiesSpawned = 0
	startingHp = boss.hp
	minHp = startingHp - 5

func state_process(delta: float) -> void:
	if enemiesSpawned < maxEnemies and boss.hp > minHp:
		summonTimer -= delta
		if summonTimer <= 0.0:
			spawn_enemy()
			summonTimer = summonInterval
	else:
		# Once 5 enemies have been spawned or the boss takes 5 damage, transition back to decide
		emit_signal("Transitioned", self, "BossDecide")

func spawn_enemy() -> void:
	enemiesSpawned += 1
	var enemyInstance = preload("res://scenes/characters/enemies/enemy.tscn").instantiate()
	# Spawn enemies around the boss
	enemyInstance.global_position = boss.global_position + Vector2(randf_range(-50, 50), randf_range(-50, 50))
	get_tree().current_scene.add_child(enemyInstance)
