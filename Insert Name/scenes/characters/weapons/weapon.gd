extends Node2D
class_name Weapon

# Enumeration of weapon types.
enum WeaponTypes {
	PISTOL, # Represents a pistol weapon.
	SHOTGUN, # Represents a shotgun weapon.
	DOUBLE # Represents a double pistol
}

# Dictionary containing data for each weapon type.
var weaponsData: Dictionary = {
	WeaponTypes.PISTOL: {
		"cooldown": 0.3, 
		"spread": 0, 
		"projectile_count": 1 # 
	},
	WeaponTypes.SHOTGUN: {
		"cooldown": 1.0, 
		"spread": 30, 
		"projectile_count": 5 
	},
	WeaponTypes.DOUBLE: {
		"cooldown": 0.6, 
		"spread": 10, 
		"projectile_count": 2 
	}
}

@onready var projectileScene: PackedScene = preload("res://scenes/characters/weapons/bullet.tscn")

var curWeapon: WeaponTypes = WeaponTypes.PISTOL

var curWeaponData: Dictionary = weaponsData[curWeapon]

var canShoot: bool = true

var timeSinceLastShot: float = 0.0

func _process(delta: float) -> void:
	if not canShoot:
		timeSinceLastShot += delta
		if timeSinceLastShot >= curWeaponData.cooldown:
			canShoot = true

func shoot() -> void:
	var baseDirection = $ShootPoint.global_transform.x.normalized()

	# Loop through the number of projectiles specified by the current weapon's projectile_count.
	for i in range(curWeaponData.projectile_count):
		# Instantiate a new projectile instance from the projectileScene.
		var projectileInstance: Area2D = projectileScene.instantiate()
		# Add the projectile instance as a child of the parent node.

		get_parent().add_child(projectileInstance)

		# Calculate a random spread value within the range specified by the current weapon's spread.
		var spread = randf_range(-curWeaponData.spread, curWeaponData.spread)
		# Convert the spread value from degrees to radians.
		var spreadRadians = deg_to_rad(spread)
		# Rotate the base direction by the spread radians to get the final direction of the projectile.
		var rotatedDirection = baseDirection.rotated(spreadRadians)

		# Set the global transform of the projectile instance to match the ShootPoint's global transform.
		projectileInstance.global_transform = $ShootPoint.global_transform
		# Set the travel direction of the projectile instance to the rotated direction.
		projectileInstance.travel_direction = rotatedDirection
		# Set the rotation of the projectile instance to the angle of the rotated direction.
		projectileInstance.rotation = rotatedDirection.angle()

	# Reset the cooldown timer
	canShoot = false
	timeSinceLastShot = 0.0

# Sets the weapon type.
func set_weapon_type(weaponType: WeaponTypes) -> void:
	curWeapon = weaponType
	curWeaponData = weaponsData[curWeapon]
