extends baseCharacter
class_name Enemy

# Reference to the player node, to be set when the enemy is spawned.
@onready var player: CharacterBody2D = get_tree().current_scene.get_node("Player") 
@onready var navAgent: NavigationAgent2D = $NavigationAgent2D
@export var enemyAccerelation: int = 40
@export var enemyMaxSpeed: int = 100
@export var contactDamage: int = 1
var strength: float = 600

func _ready() -> void:
	accerelation = enemyAccerelation
	maxSpeed = enemyMaxSpeed
	super()

# Called when a enemy makes contact with something.
func _on_area_2d_body_entered(body: Node2D) -> void:
	if canDmg:
		if body != self and not body is Enemy and body.has_method("take_damage"):
			var direction = (body.global_position - global_position).normalized()
			body.take_damage(contactDamage, direction, strength)
