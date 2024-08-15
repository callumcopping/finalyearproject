extends GutTest

var GameScene = preload("res://scenes/gameWorld.tscn")
var level
var hub
var gameInstance

func before_all():
	# Instantiate the game scene before running any tests
	gameInstance = GameScene.instantiate()
	add_child(gameInstance)
	level = get_node("Game World/Levels")
	var gameWorld = get_node("Game World/Levels")
	await wait_frames(1)

func test_hubworld():
	# Check if the RoomSpawner node exists
	assert_not_null(level, "Level node should not be null.")
	hub = get_node("Game World/Levels/HubWorld")
	assert_not_null(hub, "HUB node should not be null.")

func test_player_spawned():
	# Check if the Player node exists
	var playerNode = get_node("Game World/Player")
	assert_not_null(playerNode, "Player node should be spawned and not null.")

func test_gotolevel():
	gameInstance.load_level("res://scenes/levels/level1/levelOne.tscn")
	await wait_frames(1)
	level = get_node("Game World/Levels/levelOne")
	assert_not_null(level, "level node should not be null.")
