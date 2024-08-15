extends Control

var paused: bool = false
@onready var pauseContainer: MarginContainer = $PauseContainer
@onready var inputRemap: Control = $"../InputRemap"

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		pause()
func pause() -> void:
	if paused:
		self.visible = false
		get_tree().paused = false
	else:
		self.visible = true
		get_tree().paused = true
	# Set pause value to opposite of what it was
	paused = !paused

func _on_resume_pressed() -> void:
	self.visible = false
	get_tree().paused = false

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_input_remap_pressed() -> void:
	pauseContainer.visible = false
	inputRemap.visible = true
