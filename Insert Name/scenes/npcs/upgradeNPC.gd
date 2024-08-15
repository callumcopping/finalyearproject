extends baseNPC
class_name upgradeNPC

@onready var shop: CanvasLayer = $UpgradeShop

func interact() -> void:
	# Display the shop, and pause the game
	shop.display(playerInstance)
	get_tree().paused = true
