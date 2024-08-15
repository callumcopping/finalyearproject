extends CanvasLayer

@onready var animator: AnimationPlayer = $AnimationPlayer
var playerInstance: Player

func display(player: Player) -> void:
	playerInstance = player
	self.visible = true
	animator.play("transitonIn")
	update_display()
	
func _on_close_pressed() -> void:
	animator.play("transitonOut")
	
func _on_animation_player_animation_finished(animName: StringName) -> void:
	if animName == "transitonOut":
		get_tree().paused = false
		self.visible = false
		
func update_display() -> void:
	$essenceDisplay.text = "Essence: " + str(playerInstance.essence)
	$Heal/Desc.text = "Heal 1 hp\nCost: " + str(UpgradeCosts.healCost)
	$IncreaseHp/Desc.text = "Increase max hp by 1\nCost: " + str(UpgradeCosts.increaseHpCost)
	$IncreaseSpeed/Desc.text = "Increase speed\nCost: " + str(UpgradeCosts.inreaseSpeedCost)
	$DashCooldown/Desc.text = "Decrease cooldown\nby 0.1 sec\nCost: " + str(UpgradeCosts.decreaseDashCooldown)

func upgrade(cost: int, upgrade: Callable, costIncrease: Callable) -> void:
	if playerInstance.essence >= cost:
		upgrade.call()
		playerInstance.essence -= UpgradeCosts.healCost
		costIncrease.call()
		update_display()

func _on_heal_pressed() -> void:
	if playerInstance.hp < playerInstance.playerMaxHp:
		upgrade(UpgradeCosts.healCost, Callable(playerInstance, "heal").bind(1), Callable(UpgradeCosts, "increase_heal_cost"))

func _on_increase_hp_pressed() -> void:
	if playerInstance.playerMaxHp < playerInstance.maxMaxHp:
		upgrade(UpgradeCosts.increaseHpCost, Callable(playerInstance, "increase_max_hp").bind(1), Callable(UpgradeCosts, "increase_increaseHp_cost"))		

func _on_increase_speed_pressed() -> void:
	if playerInstance.maxSpeed < playerInstance.playerMaxSpeed:
		upgrade(UpgradeCosts.inreaseSpeedCost, Callable(playerInstance, "increase_speed").bind(100), Callable(UpgradeCosts, "increase_increaseSpeed_cost"))		

func _on_dash_cooldown_pressed() -> void:
	if playerInstance.dashCooldown > playerInstance.minDashColldown:
		upgrade(UpgradeCosts.decreaseDashCooldown, Callable(playerInstance, "decrease_dash").bind(0.1), Callable(UpgradeCosts, "increase_decreaseDashCooldown_cost"))		
