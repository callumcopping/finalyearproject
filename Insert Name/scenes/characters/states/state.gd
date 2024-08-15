extends Node
class_name State

signal Transitioned

var stateMachine: Node = null

func state_process(_delta: float) -> void:
	pass

func state_physics_process(_delta: float) -> void:
	pass

func enter() -> void:
	pass

func exit() -> void:
	pass
