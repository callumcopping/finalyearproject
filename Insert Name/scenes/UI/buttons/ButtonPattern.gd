extends Button

var destination: String
@onready var command: Node = get_node("ButtonCommand")

func _ready() -> void:
	destination = self.get_text()

func _on_pressed() -> void:
	if destination:
		command.execute(destination)
	else:
		print("no text on button")
