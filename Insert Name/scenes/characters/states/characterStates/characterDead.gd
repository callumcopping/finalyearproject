extends State
class_name CharacterDead

@onready var character: CharacterBody2D = owner
@onready var gameWorld: Node2D = get_tree().get_root().get_node("Game World")

func enter() -> void:
	character.canDmg = false
	character.animator.play("hurt")
	# Only run death related code when animation has completed
	character.animator.connect("animation_finished", Callable(self, "_on_Animation_Finished"))
	if character is Enemy:
		# Logic for when an enemy dies
		var essence_reward = randi_range(1, 5)
		if is_instance_valid(character.player):
			character.player.essence += essence_reward
	if character is Boss:
		# Logic for when the boss dies
		if is_instance_valid(character.player):
			character.player.essence += 100
	
func _on_Animation_Finished() -> void:
	character.animator.disconnect("animation_finished", Callable(self, "_on_Animation_Finished"))
	if character is Player:
		character.hp = character.playerMaxHp
		character.canDmg = true
		character.update_hp_display()
		emit_signal("Transitioned", self, "PlayerIdle")
		gameWorld.load_level("res://scenes/levels/hubWorld.tscn")
	else:
		character.queue_free()
