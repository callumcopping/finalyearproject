extends CharacterBody2D
class_name baseCharacter

@onready var hpDisplay: Label = $HpDisplay
@onready var stateMachine: StateBrain = $StateBrain
@onready var animator: AnimatedSprite2D = $Sprite

#Friction so player dosent come to instant stop
const FRICTION: float = 0.15
#Default values
var accerelation: int = 80
var maxSpeed: int = 200
var hp: int = 3
var canDmg: bool = true
var isDashing: bool = false

var moveDirection: Vector2 = Vector2.ZERO

func _ready() -> void:
	print(hp)
	update_hp_display()

func _physics_process(delta: float) -> void:
	#Handles movement and collisions, based of velocity property
	#of CharacterBody2D
	var collision_info = move_and_collide(velocity * delta)
	if collision_info:
		if collision_info.get_collider():
			var slide_vector = velocity.slide(collision_info.get_normal())
			move_and_collide(slide_vector * delta)
			
	if not isDashing:
		#Applies friction to gradually slow down the character
		#Note: lerp means linear interpolation
		velocity = lerp(velocity, Vector2.ZERO, FRICTION)
	
func move() -> void:
	#Normalize the movement direction to ensure consistent speed
	moveDirection = moveDirection.normalized()
	velocity += moveDirection * accerelation
	#Limit the velocity to the maximum speed
	velocity = velocity.limit_length(maxSpeed)

func take_damage(dam: int, knockbackDirection: Vector2, knockbackStrength: float) -> void:
	if canDmg:
		self.hp -= dam
		# Max value between 0 and hp
		self.hp = max(self.hp, 0)
		update_hp_display()
		if hp <= 0:
			apply_knockback(knockbackDirection, knockbackStrength * 2)
			stateMachine._on_child_transition(stateMachine.curState, "CharacterDead")
		else:
			apply_knockback(knockbackDirection, knockbackStrength)
			stateMachine._on_child_transition(stateMachine.curState, "CharacterHurt")

func update_hp_display() -> void:
	hpDisplay.text = "HP:" + str(self.hp)
	
func apply_knockback(direction: Vector2, strength: float) -> void:
	velocity += direction.normalized() * strength
	
