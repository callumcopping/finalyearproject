extends Node
class_name ButtonCommand

const SCENES: Dictionary = {
	"Start": "res://scenes/gameWorld.tscn",
	"Debug": "res://scenes/_debug/debug.tscn",
}

func execute(dest: String) -> void:
	if SCENES.has(dest):
		var loadingScreenScene: Control = preload("res://scenes/UI/loading/LoadingScreen.tscn").instantiate()
		loadingScreenScene.set_scene_to_load(SCENES[dest])
		
		#Clear the main menu before adding a new scene
		get_tree().current_scene.queue_free()
		
		#Add the loading screen to the scene tree
		get_tree().root.add_child(loadingScreenScene)
		get_tree().set_current_scene(loadingScreenScene)

	elif dest == "Quit":
		get_tree().quit()
	else:
		print("No scene for: " + dest)
