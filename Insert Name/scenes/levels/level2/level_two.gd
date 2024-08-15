# Inspired by https://github.com/foopod/godot-bsp-trees-dungeon
extends Node2D

@onready var tilemap: TileMap = $FloorAndWalls
@onready var playerSpawn: Marker2D = $PlayerSpawn
@export var levelSize: Vector2i
@onready var exit: Area2D = $TransitionArea
@onready var weaponPickup: Area2D = $WeaponPickup
@onready var healthPickup: PackedScene = preload("res://scenes/characters/player/pickups/healthPickup.tscn")

@export var debug: bool = false

var player: Player
var rootNode: TreeBranch
var tileSize: int =  16
var nodes: Array = []
var path: AStar2D
var padding = Vector4i(8,8,8,8)
var corridorTiles: Dictionary = {}
var corridorsDataInitialized: bool = false
var corridorsFilled: bool = false

func _ready() -> void:
	rootNode  = TreeBranch.new(Vector2i(0, 0), levelSize)
	rootNode.split()
	var leaves: Array = rootNode.get_leaves()
	set_spawn_position(leaves[0])
	setup_special_rooms(leaves)
	for leaf in leaves:
		nodes.append(leaf.get_center())
	path = find_mst(nodes)
	initialize_dungeon()
	player = get_node("/root/Game World/Player")

func _process(_delta) -> void:
	# Check if the player instance is valid
	if is_instance_valid(player):
		# Get the global position of the player
		var playerGlobalPos: Vector2 = player.global_position
		# Get the current room the player is in
		var currentRoom: TreeBranch = get_player_room(playerGlobalPos)
		# Check if there is a current room
		if currentRoom:
			# Check if the current room is not completed and the corridors are not filled
			if currentRoom.completed == false and corridorsFilled == false:
				fill_connections()
				corridorsFilled = true
				# Check if the current room is not the final room
				if not currentRoom.isFinal:
					# Spawn enemies in the current room
					var enemies: Array = currentRoom.spawn_enemies(padding*2)
					# Add the enemies as children of the current room
					for enemy in enemies:
						call_deferred("add_child", enemy)
						# Connect the "tree_exited" signal of the enemies to the "_on_enemy_killed" method of the current room
						enemy.connect("tree_exited", Callable(currentRoom, "_on_enemy_killed"))
				else:
					# Spawn the boss in the current room
					var boss: Boss = currentRoom.spawn_boss(padding*2, currentRoom.get_room_rect(padding))
					call_deferred("add_child", boss)
					# Connect the "tree_exited" signal of the boss to the "_on_enemy_killed" method of the current room
					boss.connect("tree_exited", Callable(currentRoom, "_on_enemy_killed"))
			# Check if the current room is completed and the corridors are filled
			elif currentRoom.completed == true and corridorsFilled == true:
				setup_corridors()
				corridorsFilled = false
				# Check if a health pickup should be spawned
				if randi() % 4 == 0:
					var healthPos: Vector2i = currentRoom.get_center()
					var health: Area2D = healthPickup.instantiate()
					health.position = healthPos * tileSize
					add_child(health)
				# Check if the current room is a special room
				if currentRoom.isSpecial:
					var weaponPos: Vector2i = currentRoom.get_center()
					weaponPickup.visible = true
					weaponPickup.monitoring = true
					weaponPickup.position = weaponPos * tileSize
				# Check if the current room is the final room
				if currentRoom.isFinal:
					var exitPos: Vector2i = currentRoom.get_center()
					add_child(exit)
					exit.visible = true
					exit.position = exitPos * tileSize

func initialize_dungeon() -> void:
	# Loop through each leaf in the root node
	for leaf in rootNode.get_leaves():
		setup_room(leaf)
	setup_corridors()
		
# This function sets up the tiles for a room based on the given leaf
func setup_room(leaf) -> void:
	for x in range(leaf.size.x):
		for y in range(leaf.size.y):
			# Check if the current position is inside the padding area
			if not is_inside_padding(x,y, leaf, padding):
				# Set the tile to be a floor tile
				tilemap.set_cell(0, Vector2i(x + leaf.position.x,y + leaf.position.y), 0, Vector2i(1, 0))
			else:
				# Set the tile to be a wall tile
				tilemap.set_cell(0, Vector2i(x + leaf.position.x,y + leaf.position.y), 0, Vector2i(0, 0))

func setup_special_rooms(leaves) -> void:
	# Find the final room with the largest area
	var finalRoomOptions: Array = leaves.slice(leaves.size() - 3)
	var finalRoom: TreeBranch = finalRoomOptions[0]
	for leaf in finalRoomOptions:
		if leaf.area > finalRoom.area:
			finalRoom = leaf
	finalRoom.isFinal = true
	finalRoom.numEnemies = 1
	
	# Select a random room from the remaining pool as a special room
	var specialRoomPool: Array = leaves.duplicate()
	specialRoomPool.remove_at(0)
	specialRoomPool.erase(finalRoom)
	var specialRoom: TreeBranch = specialRoomPool.pick_random()
	specialRoom.isSpecial = true

func setup_corridors():
	for leaf in rootNode.get_leaves():
		var corridors: Array = []
		# Carve corridors
		var point: int = path.get_closest_point(leaf.get_center())
		for conn in path.get_point_connections(point):
			if not conn in corridors:
				var pointPos: Vector2 = path.get_point_position(point) * tileSize
				var connPos: Vector2 = path.get_point_position(conn) * tileSize
				if not corridorsDataInitialized:
					store_corridor_tiles(tilemap.local_to_map(pointPos), tilemap.local_to_map(connPos))
				call_deferred("carve_path", tilemap.local_to_map(pointPos), tilemap.local_to_map(connPos))
		corridors.append(point)
	corridorsDataInitialized = true
			
# This function returns the room in which the player is currently located
func get_player_room(playerGlobalPos) -> TreeBranch:
	for leaf in rootNode.get_leaves():
		var roomRect: Rect2 = leaf.get_room_rect(padding)
		if roomRect.has_point(playerGlobalPos):
			return leaf
	return null

# This function sets the spawn position of the player based on the given leaf
func set_spawn_position(spawnLeaf):
	var spawnPos: Vector2i = spawnLeaf.get_center()
	playerSpawn.position = Vector2(spawnPos.x * tileSize, spawnPos.y * tileSize)

func _draw():
	var leaves: Array = rootNode.get_leaves()
	for leaf in leaves:
		if leaf.isSpecial:
			draw_circle(Vector2(leaf.get_center().x * tileSize, leaf.get_center().y * tileSize), 35, Color.RED)
		if leaf.isFinal:
			draw_circle(Vector2(leaf.get_center().x * tileSize, leaf.get_center().y * tileSize), 35, Color.BLUE)
	draw_circle(Vector2(leaves[0].get_center().x * tileSize, leaves[0].get_center().y * tileSize), 35, Color.PINK)
	if debug:
		for leaf in rootNode.get_leaves():
			draw_rect(
				Rect2(
					leaf.get_room_rect(padding).position.x, # x
					leaf.get_room_rect(padding).position.y, # y
					leaf.get_room_rect(padding).size.x, # width
					leaf.get_room_rect(padding).size.y # height
				), 
				Color.PURPLE, # colour
				false, # is filled
				50 # wi
			)
		if path:
			for point in path.get_point_ids():
				for conn in path.get_point_connections(point):
						var pointPos: Vector2 = path.get_point_position(point) * tileSize
						var connPos: Vector2 = path.get_point_position(conn) * tileSize
						draw_line(Vector2(pointPos.x, pointPos.y),
								  Vector2(connPos.x, connPos.y),
								  Color.YELLOW, 5)

# This function checks if the given position is inside the padding area of a leaf
func is_inside_padding(x, y, leaf, padding) -> bool:
	return x <= padding.x or y <= padding.y or x >= leaf.size.x - padding.z or y >= leaf.size.y - padding.w

func carve_path(start: Vector2, end: Vector2) -> void:
	# Carve a path between two points
	if start.y == end.y:
		for i in range(start.x - end.x):
			tilemap.set_cell(0, Vector2i(start.x - i, start.y), 0, Vector2i(1, 0), 1)
			tilemap.set_cell(0, Vector2i(start.x - i, start.y + 1), 0, Vector2i(1, 0), 1)
	elif start.x == end.x:
		for i in range(start.y - end.y):
			tilemap.set_cell(0, Vector2i(start.x, start.y - i), 0, Vector2i(1, 0), 1)
			tilemap.set_cell(0, Vector2i(start.x + 1, start.y - i), 0, Vector2i(1, 0), 1)
	else: # L shape
		var posStore = start
		for x in range(start.x - end.x):
			tilemap.set_cell(0, Vector2i(start.x - x, start.y), 0, Vector2i(1, 0), 1)
			tilemap.set_cell(0, Vector2i(start.x - x, start.y + 1), 0, Vector2i(1, 0), 1)
			posStore.x =  start.x - x
		for y in range(start.y - end.y):
			tilemap.set_cell(0, Vector2i(posStore.x, start.y - y), 0, Vector2i(1, 0), 1)
			tilemap.set_cell(0, Vector2i(posStore.x + 1, start.y - y), 0, Vector2i(1, 0), 1)

func store_corridor_tiles(start, end) -> void:
	var pos
	# Determine if a straight corridor was used
	if start.y == end.y:
		for i in range(start.x - end.x):
			pos = Vector2i(start.x - i, start.y)
			corridorTiles[pos] = tilemap.get_cell_atlas_coords(0, Vector2i(start.x - i, start.y))
			pos = Vector2i(start.x - i, start.y + 1)
			corridorTiles[pos] = tilemap.get_cell_atlas_coords(0, Vector2i(start.x - i, start.y + 1))
	elif start.x == end.x:
		for i in range(start.y - end.y):
			pos = Vector2i(start.x, start.y - i)
			corridorTiles[pos] = tilemap.get_cell_atlas_coords(0, Vector2i(start.x, start.y - i))
			pos = Vector2i(start.x + 1, start.y - i)
			corridorTiles[pos] = tilemap.get_cell_atlas_coords(0, Vector2i(start.x + 1, start.y - i))
	else: # L shape
		var posStore = start
		for x in range(start.x - end.x):
			pos = Vector2i(start.x - x, start.y)
			corridorTiles[pos] = tilemap.get_cell_atlas_coords(0, Vector2i(start.x - x, start.y))
			pos = Vector2i(start.x - x, start.y + 1)
			corridorTiles[pos] = tilemap.get_cell_atlas_coords(0, Vector2i(start.x - x, start.y + 1))
			posStore.x = start.x - x
		for y in range(start.y - end.y):
			pos = Vector2i(posStore.x, start.y - y)
			corridorTiles[pos] = tilemap.get_cell_atlas_coords(0, Vector2i(posStore.x, start.y - y))
			pos = Vector2i(posStore.x + 1, start.y - y)
			corridorTiles[pos] = tilemap.get_cell_atlas_coords(0, Vector2i(posStore.x + 1, start.y - y))

func fill_connections() -> void:
	# Loop through each position in the corridorTiles dictionary to fill in carved corridors
	for position in corridorTiles:
		var tileData = corridorTiles[position]
		tilemap.set_cell(0, position, 0, tileData)
		
func find_mst(nodes) -> AStar2D:
	# Utilizes Prim's algorithm to find a minimum spanning tree (MST) from a set of nodes
	# Initialize AStar2D for pathfinding and add the first node to start the MST
	var mstPath: AStar2D = AStar2D.new()
	mstPath.add_point(mstPath.get_available_point_id(), nodes.pop_front())

	# Iterate until all nodes are included in the MST
	while nodes:
		var closestDistance: float = INF  # Holds the shortest distance found
		var closestNodePosition: Variant = null  # Holds the position of the closest node
		var currentNodePosition: Variant = null  # Temporary variable to hold current node position during comparison
		
		# Iterate through each point already in the MST
		for currentPointId in mstPath.get_point_ids():
			var currentMstPosition: Vector2 = mstPath.get_point_position(currentPointId)
			# Compare with each remaining node to find the closest one
			for potentialNode in nodes:
				var distanceToPotentialNode: float = currentMstPosition.distance_to(potentialNode)
				# Update if a closer node is found
				if distanceToPotentialNode < closestDistance:
					closestDistance = distanceToPotentialNode
					closestNodePosition = potentialNode
					currentNodePosition = currentMstPosition

		# Add the closest node found to the MST and connect it
		var newPointId: int = mstPath.get_available_point_id()
		mstPath.add_point(newPointId, closestNodePosition)
		mstPath.connect_points(mstPath.get_closest_point(currentNodePosition), newPointId)
		# Remove the node from the list to avoid revisiting
		nodes.erase(closestNodePosition)
	return mstPath

