# Inspired by https://github.com/foopod/godot-bsp-trees-dungeon
extends Node

class_name TreeBranch

const ENEMY_SCENES: Dictionary = {"BASE": preload("res://scenes/characters/enemies/enemy.tscn"),
								  "FAST": preload("res://scenes/characters/enemies/fastEnemy.tscn")}
const BOSS_SCENE: PackedScene = preload("res://scenes/characters/enemies/boss/boss.tscn")
const TILE_SIZE: int = 16

# Variables to store child branches, position, size, area, number of enemies, completion status, and special/final flags
var leftChild: TreeBranch
var rightChild: TreeBranch
var position: Vector2i
var size: Vector2i
var area: int
var numEnemies: int
var completed: bool
var isSpecial: bool
var isFinal: bool
const MIN_SIZE: int = 40

func _init(position: Vector2i, size: Vector2i) -> void:
	self.position = position
	self.size = size
	self.area = size.x * size.y
	self.numEnemies = randi_range(3, area/1000)
	self.completed = false
	self.isSpecial = false
	self.isFinal = false
	
# Get all the leaves of the tree
func get_leaves() -> Array:
	if not (is_instance_valid(leftChild) && is_instance_valid(rightChild)):
		return [self]
	else:
		return leftChild.get_leaves() + rightChild.get_leaves()
		
# Split the branch into two child branches
func split() -> void:
	randomize()
	var splitPercent: float = randf_range(0.3, 0.7)
	var splitHorizontal: bool = size.y >= size.x
	
	if size.x <= MIN_SIZE or size.y <= MIN_SIZE:
		return
	
	if splitHorizontal and size.y >= MIN_SIZE * 2:
		# As splitting horizontally the width (x) of the rooms are equal to the width of the orignal rectangle
		var leftHeight: int = int(size.y * splitPercent)
		var leftSize: Vector2i = Vector2i(size.x, leftHeight)
		# Lower the positon of the right child room by the height of the left room
		var rightPosition: Vector2i = Vector2i(position.x, position.y + leftHeight)
		# Height of room is remainder of original room - height of left
		var rightSize: Vector2i = Vector2i(size.x, size.y - leftHeight)
		# Create children
		leftChild = TreeBranch.new(position, leftSize)
		rightChild = TreeBranch.new(rightPosition, rightSize)
	elif size.x >= MIN_SIZE * 2:
		# As splitting vertically the height (y) of the rooms are equal to the height of the original rectangle
		var leftWidth: int = int(size.x * splitPercent)
		var leftSize: Vector2i = Vector2i(leftWidth, size.y)
		# Move the position of the right child room to the right by the width of the left room
		var rightPosition: Vector2i = Vector2i(position.x + leftWidth, position.y)
		# Width of room is remainder of original room - width of left
		var rightSize: Vector2i = Vector2i(size.x - leftWidth, size.y)
		# Create children
		leftChild = TreeBranch.new(position, leftSize)
		rightChild = TreeBranch.new(rightPosition, rightSize)

	if leftChild and rightChild:
		leftChild.split()
		rightChild.split()
		
func get_center() -> Vector2i:
	return Vector2i(position.x + size.x / 2, position.y + size.y / 2)

func spawn_enemies(padding: Vector4i) -> Array:
	var enemies = []
	if not self.isFinal:
		# Convert dictionary keys to an array
		var enemyKeys = ENEMY_SCENES.keys()
		for i in range(numEnemies):
			# Calculate spawn position within the room, excluding the padding
			var spawnPosX = randi_range(position.x + padding.x, position.x + size.x - padding.z) * TILE_SIZE
			var spawnPosY = randi_range(position.y + padding.y, position.y + size.y - padding.w) * TILE_SIZE
			var spawnPos = Vector2(spawnPosX, spawnPosY)
			
			# Randomly select a key
			var randomKey = enemyKeys[randi() % enemyKeys.size()]
			# Use the key to get the corresponding scene from the dictionary
			var enemy_scene = ENEMY_SCENES[randomKey]
			var enemy = enemy_scene.instantiate()
			enemy.position = spawnPos
			enemies.append(enemy)
	return enemies


func spawn_boss(padding: Vector4i, roomRect: Rect2) -> Boss:
	var spawnPosX = randi_range(position.x + padding.x, position.x + size.x - padding.z) * TILE_SIZE
	var spawnPosY = randi_range(position.y + padding.y, position.y + size.y - padding.w) * TILE_SIZE
	var spawnPos = Vector2(spawnPosX, spawnPosY)
	var boss: Boss = BOSS_SCENE.instantiate()
	boss.position = spawnPos
	boss.get_room_rect(roomRect)
	return boss

func get_room_rect(padding: Vector4i, extra_margin = Vector2(1, 1)) -> Rect2:
	var padded_position: Vector2 = Vector2(
		position.x + padding.x + extra_margin.x, 
		position.y + padding.y + extra_margin.y
	)
	var padded_size: Vector2 = Vector2(
		size.x - padding.x - padding.z - extra_margin.x,
		size.y - padding.y - padding.w - extra_margin.y
	)
	padded_position *= TILE_SIZE
	padded_size *= TILE_SIZE

	return Rect2(padded_position, padded_size)

func _on_enemy_killed() -> void:
	numEnemies -= 1
	if numEnemies == 0:
		completed = true
