extends Node2D

const ENEMY_SCENES: Dictionary = {"BASE": preload("res://scenes/characters/enemies/enemy.tscn"),
								  "FAST": preload("res://scenes/characters/enemies/fastEnemy.tscn")}
									
var numEnemies: int

# Flag indicating whether the room is a spawn or exit room
@export var isSpawnOrExit: bool = false

@onready var floorAndWalls: TileMap = get_node("FloorAndWalls")

@onready var enemyPosContainer: Node2D = get_node("EnemyPos")

@onready var entranceDetector: Area2D = get_node("EntranceDetector")

@onready var healthPickup: Area2D = get_node("HealthPickup")

func _ready() -> void:
	# Initialize the number of enemies based on the number of child nodes in the enemy position container
	numEnemies = enemyPosContainer.get_child_count()

	# Open the entrance and disable its collision shape
	$Entrance.visible = false
	$Entrance/CollisionShape2D.set_deferred("disabled", true)

func block_entrance() -> void:
	# Bloc the entrance and enable its collision shape
	$Entrance.visible = true
	$Entrance/CollisionShape2D.set_deferred("disabled", false)

func open_exit() -> void:
	# Open the exit and disable its collision shape
	$Exit.visible = false
	$Exit/CollisionShape2D.set_deferred("disabled", true)

func _on_entrance_detector_body_entered(_body: CharacterBody2D) -> void:
	# Remove the entrance detector, block the entrance, and spawn enemies
	entranceDetector.queue_free()
	block_entrance()
	spawn_enemies()

func _on_enemy_killed() -> void:
	# Decrease the number of enemies and check if all enemies are killed
	numEnemies -= 1
	if numEnemies == 0:
		# Open the exit and check if a health pickup should be spawned
		open_exit()
		if not isSpawnOrExit:
			if randi() % 2 == 0:
				healthPickup.position = $Exit.position
				healthPickup.visible = true
				healthPickup.monitoring = true

func spawn_enemies() -> void:
	# Convert dictionary keys to an array
	var enemyKeys = ENEMY_SCENES.keys()
	# Loop through the enemy positions and spawn enemies
	for enemyPosition in enemyPosContainer.get_children():
		# Randomly select a key
		var randomKey = enemyKeys[randi() % enemyKeys.size()]
		# Use the key to get the corresponding scene from the dictionary
		var enemy_scene = ENEMY_SCENES[randomKey]
		var enemy = enemy_scene.instantiate()
		enemy.position = enemyPosition.position
		call_deferred("add_child", enemy)
		enemy.connect("tree_exited", Callable(self, "_on_enemy_killed"))

