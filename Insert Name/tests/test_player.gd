extends GutTest

var PlayerScene = preload("res://scenes/characters/player/player.tscn")
var playerInstance
var sender
var initialHp

func before_each():
	playerInstance = PlayerScene.instantiate()
	add_child_autofree(playerInstance)
	sender = InputSender.new(playerInstance)

func test_player_initialized_correctly():
	#Check player is initialized with correct properties
	assert_not_null(playerInstance, "Player instance should not be null.")
	assert_eq(playerInstance.hp, 3, "Initial HP should be 3.")
	assert_eq(playerInstance.moveDirection, Vector2.ZERO, "Initial move direction should be Vector2.ZERO.")
	assert_eq(playerInstance.velocity, Vector2.ZERO, "Initial velocity should be Vector2.ZERO.")
	assert_eq(playerInstance.stateMachine.curState, playerInstance.stateMachine.states.playeridle, "Inital state should be 'idle")

func test_player_movement():
	#Simulate movement input
	var move_input = Vector2.RIGHT
	playerInstance.moveDirection = move_input
	playerInstance.move()

	assert_gt(playerInstance.velocity.length(), 0.0, "Player should have some velocity after moving.")
	assert_eq(playerInstance.velocity.normalized(), move_input, "Player velocity should be in the direction of movement input.")
	#Simulate to let the state machine update
	simulate(playerInstance, 10, 0.1)
	assert_eq(playerInstance.stateMachine.curState, playerInstance.stateMachine.states.playermoveandshoot, "Player state should be 'idle' as despite movement, no key presses means stay in idle.")


func test_player_take_damage():
	initialHp = playerInstance.hp
	playerInstance.take_damage(1, Vector2.UP, 100)

	assert_eq(playerInstance.hp, initialHp - 1, "Player HP should decrease by 1.")
	assert_eq(playerInstance.stateMachine.curState, playerInstance.stateMachine.states.characterhurt, "Player state should be 'hurt'.")
	
func test_player_death():
	initialHp = playerInstance.hp
	playerInstance.take_damage(initialHp, Vector2.UP, 100)

	assert_eq(playerInstance.hp, initialHp - 3, "Player HP should decrease to zero.")
	assert_eq(playerInstance.stateMachine.curState, playerInstance.stateMachine.states.characterdead, "Player state should be 'dead'.")
