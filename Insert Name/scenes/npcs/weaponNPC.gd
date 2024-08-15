extends baseNPC
class_name weaponNPC

# Cycle the player's weapon
func interact() -> void:
	playerInstance.cycle_weapon()
