extends BasePickup
class_name HealthPickup

# Increases the player's health by a random amount between 2 and 4
func apply_effect(player: Node2D) -> void:
	player.heal(randi_range(2,4))
	player.update_hp_display()
