extends Node

var config: ConfigFile = ConfigFile.new()
const SETTINGS_FILE = "user://settings.cfg"

func _ready() -> void:
	# Check if the settings file exists
	if !FileAccess.file_exists(SETTINGS_FILE):
		# Set default keymap values
		config.set_value("keymap", "moveUp", "W")
		config.set_value("keymap", "moveDown", "S")
		config.set_value("keymap", "moveLeft", "A")
		config.set_value("keymap", "moveRight", "D")
		config.set_value("keymap", "dash", "Shift")
		config.set_value("keymap", "shoot", "Mouse_1")
		config.set_value("keymap", "pause", "Escape")
		# Save the config file
		config.save(SETTINGS_FILE)
	else:
		# Load the existing config file
		config.load(SETTINGS_FILE)
		
func save_key_binding(action: StringName, event: InputEvent) -> void:
	var eventStr: String
	if event is InputEventKey:
		# Get the string representation of the key code
		eventStr = OS.get_keycode_string(event.physical_keycode)
	elif event is InputEventMouseButton:
		# Get the string representation of the mouse button index
		eventStr = "Mouse_" + str(event.button_index)
	
	# Set the keymap value for the given action
	config.set_value("keymap", action, eventStr)
	# Save the config file
	config.save(SETTINGS_FILE)
	
func load_key_bindings() -> Dictionary:
	var keybindings = {}
	# Get all the keys in the "keymap" section of the config file
	var keys = config.get_section_keys("keymap")
	for key in keys:
		var inputEvent
		var eventStr = config.get_value("keymap", key)
		
		if eventStr.contains("Mouse_"):
			# Create a new InputEventMouseButton and set the button index
			inputEvent = InputEventMouseButton.new()
			inputEvent.button_index = int(eventStr.split("_")[1])
		else:
			# Create a new InputEventKey and set the keycode
			inputEvent = InputEventKey.new()
			inputEvent.keycode = OS.find_keycode_from_string(eventStr)
			
		# Add the key and input event to the keybindings dictionary
		keybindings[key] = inputEvent
		
	return keybindings
