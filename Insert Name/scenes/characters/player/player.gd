extends baseCharacter
class_name Player

# Reference to the weapon node in the scene
@onready var weapon: Node2D = $Weapon

# Player attributes
@export var playerAccerelation: int = 100
@export var playerMaxAcc: int = 400
@export var playerSpeed: int = 300
@export var playerMaxSpeed: int = 600
@export var playerMaxHp: int = 3
@export var maxMaxHp: int = 8
@export var dashDuration: float = 0.4
@export var dashSpeed: int = 1000
@export var dashCooldown: float = 1.0
@export var minDashColldown: float = 0.5
@export var essence: int = 25

# Array to store available weapons
var availableWeapons: Array
var weaponIndex: int = 0

# Timer and flag for dashing
var dashTimer: float = 0.0
var canDash: bool = true

func _ready() -> void:
	# Set player attributes
	accerelation = playerAccerelation
	maxSpeed = playerSpeed
	hp = playerMaxHp
	
	# Add the current weapon to the available weapons array
	availableWeapons.append(weapon.curWeapon)
	
	# Call the parent _ready function
	super()
	
func _process(delta: float) -> void:
	# Make the weapon look at the mouse position
	$Weapon.look_at(get_global_mouse_position())
	
	# Update dash timer and reset canDash flag if cooldown is over
	if not canDash:
		dashTimer += delta
		if dashTimer >= dashCooldown:
			canDash = true
			dashTimer = 0.0
	
# Check if the player is moving
func isMovingInput() -> bool:
	return (Input.is_action_pressed("moveDown") 
		or Input.is_action_pressed("moveLeft") 
		or Input.is_action_pressed("moveRight") 
		or Input.is_action_pressed("moveUp")
		or (Input.is_action_pressed("shoot") and weapon.canShoot))
	
# Add a new weapon to the available weapons array
func add_weapon(newWeapon: Weapon.WeaponTypes) -> void:
	if newWeapon not in availableWeapons:
		availableWeapons.append(newWeapon)
		weaponIndex = availableWeapons.size() - 1
		weapon.set_weapon_type(newWeapon)
		
# Change the current weapon
func change_weapon(weaponChange: Weapon.WeaponTypes) -> void:
	weapon.set_weapon_type(weaponChange)
	
# Cycle through the available weapons
func cycle_weapon() -> void:
	weaponIndex += 1
	if weaponIndex >= availableWeapons.size():
		weaponIndex = 0 # Reset to the first weapon if at the end
	change_weapon(availableWeapons[weaponIndex])
	
# Increase the player's health
func heal(amount: int) -> void:
	hp += amount
	hp = min(hp, playerMaxHp)
	update_hp_display()
	
# Increase the player's maximum health
func increase_max_hp(amount: int) -> void:
	playerMaxHp += amount
	
# Increase the player's speed
func increase_speed(amount: int) -> void:
	maxSpeed += amount
	accerelation += amount
	maxSpeed = min(maxSpeed, playerMaxSpeed)
	accerelation = min(accerelation, playerMaxAcc)

# Decrease the dash cooldown
func decrease_dash(amount: float) -> void:
	dashCooldown -= amount
	dashCooldown = max(dashCooldown, minDashColldown)
