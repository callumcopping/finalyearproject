extends Control

@onready var pannelCheck = $Panel
@onready var pauseMenu: Control = $"../PauseMenu"
@onready var remapperScene: PackedScene = preload("res://scenes/UI/settings/remaper.tscn")
@onready var actionList: VBoxContainer = $Panel/VBoxContainer/ActionList

var isRemapping: bool = false
var actionToRemap = null
var remappingButton = null

var inputActions: Dictionary = {
	"moveUp": "Move Up",
	"moveDown": "Move Down",
	"moveLeft": "Move Left",
	"moveRight": "Move Right",
	"dash": "Dash",
	"shoot": "Shoot",
	"pause": "Pause"
}

func _ready() -> void:
	load_key_bindings_from_config()
	create_actions()
	
func load_key_bindings_from_config():
	var keybindings = ConfigHandler.load_key_bindings()
	for action in keybindings.keys():
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, keybindings[action])
	
func _process(_delta: float) -> void:	if !isRemapping:
		if Input.is_action_just_pressed("pause"):
			_on_back_pressed()
	
func create_actions() -> void:
	#InputMap.load_from_project_settings()
	for item in actionList.get_children():
		item.queue_free()
		
	for action in inputActions:
		var remapper = remapperScene.instantiate()
		var button = remapper.find_child("RemapButton")
		var actionLabel = remapper.find_child("ActionName")
		
		actionLabel.text = inputActions[action]
		
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			button.text = events[0].as_text().trim_suffix(" (Physical)")
		else:
			button.text = "Key Not Set"
		
		actionList.add_child(remapper)
		button.pressed.connect(_on_input_remap_pressed.bind(button, action))

func _on_input_remap_pressed(button, action) -> void:
	if !isRemapping:
		isRemapping = true
		actionToRemap = action
		remappingButton = button
		button.text = "Press key to bind..."
		
func _input(event: InputEvent) -> void:
	if isRemapping:
		if actionToRemap == "pause" and event is InputEventMouseButton and event.pressed:
			show_remap_error_dialog("Remapping 'Pause' to a mouse button is not allowed.")
			return				
		# Change double click ino single click
		if event is InputEventMouseButton and event.double_click:
			event.double_click = false
			
		# Check if the event is already mapped to another action by comparing text representations
		var eventText = event.as_text()
		# Check if the current action is already mapped to the event
		var currentEvents = InputMap.action_get_events(actionToRemap)
		for e in currentEvents:
			if e.as_text() == eventText:
				# This is a remap to the same key, so just close the remapping process as successful
				isRemapping = false
				actionToRemap = null
				remappingButton.text = eventText.trim_suffix(" (Physical)")
				remappingButton = null
				accept_event()
				return
						
		for action in inputActions.keys():
			var events = InputMap.action_get_events(action)
			for e in events:
				if e.as_text() == eventText:
					# The event is already assigned to another action, ignore this remapping
					show_remap_error_dialog("Remapping two actions to one button is not allowed")
					return
			
		if (event is InputEventKey or event is InputEventMouseButton and event.pressed):
			InputMap.action_erase_events(actionToRemap)
			InputMap.action_add_event(actionToRemap, event)
			ConfigHandler.save_key_binding(actionToRemap, event)
			update_list(remappingButton, event)
			
			isRemapping = false
			actionToRemap = null
			remappingButton = null
			
			accept_event()
		
func update_list(button, event) -> void:
	button.text = event.as_text().trim_suffix(" (Physical)")

func _on_back_pressed() -> void:
	if !isRemapping:
		self.visible = false
		if pauseMenu:
			pauseMenu.pauseContainer.visible = true

func _on_reset_pressed() -> void:
	InputMap.load_from_project_settings()
	for action in inputActions:
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			ConfigHandler.save_key_binding(action, events[0])
	create_actions()

func show_remap_error_dialog(message: String) -> void:
	var dialog = $InvalidRemapDialog
	dialog.dialog_text = message
	dialog.popup_centered()
