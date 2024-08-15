extends Control

var sceneToLoad: String
var progress: Array = []
var loadStatus: int = 0
var loadedScene: PackedScene
@onready var loadPercent: Node = get_node("LoadPercent")
	
func set_scene_to_load(dest_scene: String) -> void:
	sceneToLoad = dest_scene
	# Load scene in background using a thread
	ResourceLoader.load_threaded_request(dest_scene)

func _process(_delta: float) -> void:
	if sceneToLoad:
		# Get load status and %
		loadStatus = ResourceLoader.load_threaded_get_status(sceneToLoad, progress)
		# Round for display
		loadPercent.text = str(floor(progress[0]*100)) + "%"
		# If loaded switch to scene
		if loadStatus == ResourceLoader.THREAD_LOAD_LOADED:
			loadedScene = ResourceLoader.load_threaded_get(sceneToLoad)
			get_tree().change_scene_to_packed(loadedScene)
