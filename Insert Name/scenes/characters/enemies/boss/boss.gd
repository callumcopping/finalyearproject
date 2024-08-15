extends baseCharacter 
class_name Boss

@onready var player: CharacterBody2D = get_tree().current_scene.get_node("Player")
@onready var navAgent: NavigationAgent2D = $NavigationAgent2D

var bossaccerelation: int = 10
var bossSpeed: int = 200
var maxHp: int = 25
var roomRect: Rect2
var contactDmg: int = 2
var contactKnockback: int = 1000

# Boss-specific properties
var phaseTwo: bool = false  # Keep track of the boss phase

func _ready() -> void:
	accerelation = bossaccerelation
	maxSpeed = bossSpeed
	hp = maxHp
	super()

func _process(_delta: float) -> void:
	if hp <= maxHp * 0.4 and not phaseTwo:
		switch_to_phase_two()
	
	if player.global_position.x < self.position.x:
		# Player is to the left, flip the boss sprite
		$Sprite.flip_v = true
	else:
		# Player is to the right, no flip needed
		$Sprite.flip_v = false

# Function for switching to phase two
func switch_to_phase_two() -> void:
	if !phaseTwo:
		phaseTwo = true
		accerelation = bossaccerelation * 1.2
		maxSpeed = bossSpeed * 1.2

# On contact with the player, deal damage
func _on_area_2d_body_entered(body: Node2D) -> void:
	if canDmg:
		if body is Player and body.has_method("take_damage"):
			var direction = (body.global_position - global_position).normalized()
			body.take_damage(contactDmg, direction, contactKnockback)
			
# Override the take_damage method from the baseCharacter class
func take_damage(dam: int, knockbackDirection: Vector2, knockbackStrength: float) -> void:
	self.hp -= dam
	self.hp = max(self.hp, 0)
	update_hp_display()
	if hp <= 0:
		apply_knockback(knockbackDirection, knockbackStrength)
		stateMachine._on_child_transition(stateMachine.curState, "CharacterDead")

# Function for getting the room rect, to stop boss escaping
func get_room_rect(room: Rect2) -> void:
	roomRect = room
