extends Node
class_name StateBrain

# The initial state of the state machine.
@export var initialState: State

# A dictionary that stores the available states.
var states: Dictionary = {}

# The current state of the state machine.
var curState: State

func _ready() -> void:
	# Iterate through the children of the state machine.
	for child in get_children():
		# Check if the child is a State node.
		if child is State:
			# Add the state to the dictionary using its lowercase name as the key.
			states[child.name.to_lower()] = child
			# Set the state machine reference for the child state.
			child.stateMachine = self
			# Connect the child state's Transitioned signal to the _on_child_transition method.
			child.Transitioned.connect(_on_child_transition)
	
	# If an initial state is defined, enter the initial state and set it as the current state.
	if initialState:
		initialState.enter()
		curState = initialState

func _process(delta: float) -> void:
	# If there is a current state, call its state_process method.
	if curState:
		curState.state_process(delta)
		
func _physics_process(delta: float) -> void:
	# If there is a current state, call its state_physics_process method.
	if curState:
		curState.state_physics_process(delta)
		
func _on_child_transition(prevState: State, newStateName: String) -> void:
	# If the previous state is not the current state, return.
	if prevState != curState:
		return

	# Get the new state from the dictionary using the lowercase new state name.
	var newState: State = states.get(newStateName.to_lower())
	# If the new state does not exist, return.
	if !newState:
		return

	# If there is a current state, exit it.
	if curState:
		curState.exit()

	# Enter the new state and set it as the current state.
	newState.enter()
	curState = newState
