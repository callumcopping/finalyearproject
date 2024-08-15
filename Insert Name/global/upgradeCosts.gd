extends Node

var healCost: int = 5
var increaseHpCost: int = 10
var inreaseSpeedCost: int = 10
var decreaseDashCooldown: int = 20

# Reset all costs to their initial values
func reset_costs() -> void:
	healCost = 5
	increaseHpCost = 10
	inreaseSpeedCost = 10
	decreaseDashCooldown = 20

# Increase the cost of healing
func increase_heal_cost() -> void:
	healCost += 1

# Increase the cost of increasing HP
func increase_increaseHp_cost() -> void:
	increaseHpCost += 5

# Increase the cost of increasing speed
func increase_increaseSpeed_cost() -> void:
	inreaseSpeedCost += 5

# Increase the cost of decreasing dash cooldown
func increase_decreaseDashCooldown_cost() -> void:
	decreaseDashCooldown += 10
