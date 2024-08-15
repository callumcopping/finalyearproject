extends BasePickup
class_name WeaponPickup

# The type of weapon to give the player, set in editor
@export var weaponType: Weapon.WeaponTypes

# Give the player the weapon
func apply_effect(body: Node2D) -> void:
	if body.has_method("add_weapon") and body is Player:
		body.add_weapon(weaponType)

