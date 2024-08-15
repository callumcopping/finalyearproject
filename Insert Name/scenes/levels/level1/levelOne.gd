#Code inspired from https://github.com/MateuSai/Godot-Roguelike-Tutorial/tree/main
extends Node2D

const SPAWN_ROOM: PackedScene = preload("res://scenes/levels/level1/rooms/spawnRoom.tscn")
const ROOMS: Array[PackedScene] = [
	preload("res://scenes/levels/level1/rooms/roomOne.tscn"),
	preload("res://scenes/levels/level1/rooms/roomTwo.tscn"),
	preload("res://scenes/levels/level1/rooms/roomThree.tscn"),
	preload("res://scenes/levels/level1/rooms/roomFour.tscn")
]
const FLOOR_EXIT: PackedScene = preload("res://scenes/levels/level1/rooms/exitRoom.tscn")

# Some constants defined for room spawning and randomization
const X_POSITION_RANGE: Vector2 = Vector2(-10, 10)
const Y_POSITION_RANGE: Vector2 = Vector2(5, 10)
const TILE_SIZE: int = 16
const FLOOR_ATLAS_COORDS: Vector2i = Vector2i(1, 0)
const WALL_ATLAS_COORDS: Vector2i = Vector2i(0, 0)
var numberOfRooms: int = 5
var playerSpawn: Marker2D

func _ready() -> void:
	randomize()
	playerSpawn = $"../PlayerSpawn"
	spawner()

func spawner() -> void:
	var startPosition: Vector2 = playerSpawn.global_position
	var lastRoom: Node2D = spawn_room(SPAWN_ROOM, startPosition)
	var corridor: Vector2
	var availableRooms = ROOMS.duplicate()
	var lastSpawnedRoomType: PackedScene = null 
	# Flag to track if we've just reset the available rooms.
	var justReset = false 

	for i in range(numberOfRooms):
		if availableRooms.is_empty():
			# Reset if all rooms have been used.
			availableRooms = ROOMS.duplicate() 
			justReset = true 
			if lastSpawnedRoomType != null and availableRooms.size() > 1:
				# Exclude the last spawned room temporarily.
				availableRooms.erase(lastSpawnedRoomType)

		var roomIndex = randi() % availableRooms.size() 
		var nextRoomType: PackedScene = availableRooms[roomIndex]
		lastSpawnedRoomType = nextRoomType 
		availableRooms.remove_at(roomIndex) 
		
		# Reintroduce the last room type after resetting.
		if justReset and lastSpawnedRoomType != null:
			availableRooms.append(lastSpawnedRoomType) 
			justReset = false

		corridor = spawn_corridor(lastRoom)
		var nextRoom: Node2D = spawn_room(nextRoomType, corridor)
		lastRoom = nextRoom

	corridor = spawn_corridor(lastRoom)
	# Spawn exit room
	spawn_room(FLOOR_EXIT, corridor)


func spawn_room(roomType: PackedScene, spawnPosition: Vector2) -> Node2D:
	var roomInstance: Node2D = roomType.instantiate()
	# Use the position of the first child of the Entrance node for alignment.
	if roomInstance.has_node("Entrance"):
		var entranceMarkerLocalPos: Vector2 = roomInstance.get_node("Entrance").position
		roomInstance.global_position = spawnPosition - entranceMarkerLocalPos + Vector2(TILE_SIZE, 0)
	else:
		roomInstance.position = spawnPosition
	add_child(roomInstance)
	return roomInstance


func spawn_corridor(lastRoom: Node2D) -> Vector2:
	var startPos: Vector2 = lastRoom.get_node("Exit").get_child(0).global_position
	var upwardsLength1: int = floor(randf_range(Y_POSITION_RANGE.x, Y_POSITION_RANGE.y))
	var sidewaysLength: int = floor(randf_range(X_POSITION_RANGE.x, X_POSITION_RANGE.y))
	var upwardsLength2: int = floor(randf_range(Y_POSITION_RANGE.x, Y_POSITION_RANGE.y))
	var curPos: Vector2 = startPos
	curPos.x -= TILE_SIZE

	# Generate the first upwards corridor segment
	for i in range(upwardsLength1):
		place_corridor_vertical(lastRoom, curPos + Vector2(0, -i * TILE_SIZE))
	curPos.y -= upwardsLength1 * TILE_SIZE

	# Determine the direction for the sideways segment
	var direction: int = 1 if sidewaysLength >= 0 else -1
	curPos.x += TILE_SIZE if direction == -1 else 0
	# Generate the sideways corridor segment
	for i in range(abs(sidewaysLength)):
		place_corridor_horizontal(lastRoom, curPos + Vector2(i * direction * TILE_SIZE, 0), direction)
	curPos.x += sidewaysLength * TILE_SIZE

	# Generate the second upwards corridor segment
	for i in range(upwardsLength2):
		place_corridor_vertical(lastRoom, curPos + Vector2(0, -i * TILE_SIZE))
	curPos.y -= upwardsLength2 * TILE_SIZE

	return curPos

func place_corridor_vertical(lastRoom: Node2D, globalPos: Vector2) -> void:
	var tilemap : TileMap = lastRoom.get_node("FloorAndWalls")
	#Convert the global position to the tilemap's local space
	var localPos: Vector2 = lastRoom.to_local(globalPos)
	#Convert the local position to the map coordinates
	var mapPos: Vector2i = tilemap.local_to_map(localPos)
	
	#Place the floor & wall tiles vertically
	if tilemap.get_cell_atlas_coords(0, mapPos) != FLOOR_ATLAS_COORDS:	
		tilemap.set_cell(0, mapPos, 0, FLOOR_ATLAS_COORDS)
	if tilemap.get_cell_atlas_coords(0, mapPos + Vector2i(1,0)) != FLOOR_ATLAS_COORDS:			
		tilemap.set_cell(0, mapPos + Vector2i(1, 0), 0, FLOOR_ATLAS_COORDS)	
	if tilemap.get_cell_atlas_coords(0, mapPos + Vector2i(-1,0)) != FLOOR_ATLAS_COORDS:	
		tilemap.set_cell(0, mapPos + Vector2i(-1, 0), 0, WALL_ATLAS_COORDS)
	if tilemap.get_cell_atlas_coords(0, mapPos + Vector2i(2,0)) != FLOOR_ATLAS_COORDS:	
		tilemap.set_cell(0, mapPos + Vector2i(2, 0), 0, WALL_ATLAS_COORDS)
			
func place_corridor_horizontal(lastRoom: Node2D, globalPos: Vector2, direction: int) -> void:
	var tilemap : TileMap = lastRoom.get_node("FloorAndWalls")
	#Convert the global position to the tilemap's local space
	var localPos: Vector2 = lastRoom.to_local(globalPos)
	#Convert the local position to the map coordinates
	var mapPos: Vector2i = tilemap.local_to_map(localPos)
	#Place the floor & wall tiles horizontally
	if tilemap.get_cell_atlas_coords(0, mapPos) != FLOOR_ATLAS_COORDS:	
		tilemap.set_cell(0, mapPos, 0, FLOOR_ATLAS_COORDS)
	if tilemap.get_cell_atlas_coords(0, mapPos + Vector2i(0, -1)) != FLOOR_ATLAS_COORDS:	
		tilemap.set_cell(0, mapPos + Vector2i(0, -1), 0, FLOOR_ATLAS_COORDS)
		
	if tilemap.get_cell_atlas_coords(0, mapPos + Vector2i(-direction,0)) != FLOOR_ATLAS_COORDS:
		tilemap.set_cell(0, mapPos + Vector2i(-direction, 0), 0, WALL_ATLAS_COORDS)
	if tilemap.get_cell_atlas_coords(0, mapPos + Vector2i(-direction,-1)) != FLOOR_ATLAS_COORDS:
		tilemap.set_cell(0, mapPos + Vector2i(-direction, -1), 0, WALL_ATLAS_COORDS)	
	if tilemap.get_cell_atlas_coords(0, mapPos + Vector2i(-direction,-2)) != FLOOR_ATLAS_COORDS:
		tilemap.set_cell(0, mapPos + Vector2i(-direction, -2), 0, WALL_ATLAS_COORDS)
		
	if tilemap.get_cell_atlas_coords(0, mapPos + Vector2i(-direction,1)) != FLOOR_ATLAS_COORDS:
		tilemap.set_cell(0, mapPos + Vector2i(-direction, 1), 0, WALL_ATLAS_COORDS)		
	
	if direction == -1:
		if tilemap.get_cell_atlas_coords(0, mapPos + Vector2i(direction*2,1)) != FLOOR_ATLAS_COORDS:
			tilemap.set_cell(0, mapPos + Vector2i(direction*2, 1), 0, WALL_ATLAS_COORDS)
	else:
		if tilemap.get_cell_atlas_coords(0, mapPos + Vector2i(direction*3,1)) != FLOOR_ATLAS_COORDS:
			tilemap.set_cell(0, mapPos + Vector2i(direction*3, 1), 0, WALL_ATLAS_COORDS)
