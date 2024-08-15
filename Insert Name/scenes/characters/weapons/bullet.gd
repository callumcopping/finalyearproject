extends Area2D
class_name Bullet

var speed: int = 350
var strength: float = 400
var travel_direction: Vector2 = Vector2()

func _physics_process(delta: float) -> void:
	# Update the bullet's position based on its speed and delta time.
	var movement = transform.x * speed * delta
	position += movement
	travel_direction = movement.normalized()

func _on_body_entered(body: Node2D) -> void:
	# Check if the colliding body can take damage and is not the bullet's parent.
	if body.has_method("take_damage") and body != get_parent():
		# Call the take_damage method on the colliding body, passing in the damage, travel direction, and strength.
		body.take_damage(1, travel_direction, strength)
	
	# Destroy the bullet object.
	if body != get_parent():
		queue_free()
