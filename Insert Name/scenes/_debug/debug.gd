extends Node2D

@onready var tilemap: TileMap = $TileMap
@onready var boss: Boss = $Boss
var tileSize = 16
var roomRect

func _ready() -> void:
	var usedRect = tilemap.get_used_rect()
	roomRect = Rect2(
				usedRect.position.x * tileSize, # x
				usedRect.position.y * tileSize, # y
				usedRect.size.x * tileSize, # width
				usedRect.size.y * tileSize # height
				)
	#boss.get_room_rect(roomRect)
