extends GutTest

var EnemyScene = preload("res://scenes/characters/enemies/enemy.tscn")
var enemyInstance

func before_each():
	enemyInstance = EnemyScene.instantiate()
	add_child_autofree(enemyInstance)

func test_enemy_initialized_correctly():
	# Check enemy is initialized with correct properties
	assert_not_null(enemyInstance, "Enemy instance should not be null.")
	assert_eq(enemyInstance.hp, 3, "Initial HP should be 3.")
	assert_eq(enemyInstance.moveDirection, Vector2.ZERO, "Initial move direction should be Vector2.ZERO.")
	assert_eq(enemyInstance.velocity, Vector2.ZERO, "Initial velocity should be Vector2.ZERO.")
	assert_eq(enemyInstance.stateMachine.curState, enemyInstance.stateMachine.states.enemywander, "Inital state should be 'idle")

func test_enemy_take_damage():
	# Simulate taking damage
	var initial_hp = enemyInstance.hp
	enemyInstance.take_damage(1, Vector2.UP, 100)

	assert_eq(enemyInstance.hp, initial_hp - 1, "Enemy HP should decrease by 1.")
	assert_eq(enemyInstance.stateMachine.curState, enemyInstance.stateMachine.states.characterhurt, "Inital state should be 'idle")

func test_enemy_death():
	# Simulate death
	enemyInstance.take_damage(enemyInstance.hp, Vector2.UP, 100)

	assert_eq(enemyInstance.hp, 0, "Enemy HP should be 0 after fatal damage.")
	assert_eq(enemyInstance.stateMachine.curState, enemyInstance.stateMachine.states.characterdead, "Inital state should be 'idle")
