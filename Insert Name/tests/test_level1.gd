extends GutTest

var levelOne = preload("res://scenes/levels/level1/levelOne.tscn")
var levelInstance
var roomSpawner

func before_all():
	# Instantiate the game scene before running any tests
	levelInstance = levelOne.instantiate()
	add_child(levelInstance)
	roomSpawner = levelInstance.get_node("roomSpawner")

func test_spawnRoom():
	# Check if the first child of RoomSpawner is the spawn room and is the correct scene
	var spawnRoom = roomSpawner.get_child(0)
	assert_not_null(spawnRoom, "Spawn room should not be null.")
	assert_eq(spawnRoom.get_scene_file_path(), "res://scenes/levels/level1/rooms/spawnRoom.tscn", "Spawn room should be the correct scene.")

func test_end_room():
	# Check if the last child of RoomSpawner is the exit room and is the correct scene
	var exitRoom = roomSpawner.get_child(roomSpawner.get_child_count() - 1)
	assert_not_null(exitRoom, "Exit room should not be null.")
	assert_eq(exitRoom.get_scene_file_path(), "res://scenes/levels/level1/rooms/exitRoom.tscn", "Exit room should be the correct scene.")

func test_spawn_all_rooms():
	# Check if the RoomSpawner has the expected number of children (rooms)
	var expectedRoomCount = roomSpawner.numberOfRooms + 2  # Including spawn and exit rooms
	assert_eq(roomSpawner.get_child_count(), expectedRoomCount, "RoomSpawner should have the expected number of rooms.")
