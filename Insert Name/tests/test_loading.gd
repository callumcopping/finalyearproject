extends GutTest

var LoadingScreenScene = preload("res://scenes/UI/loading/LoadingScreen.tscn")
var loadingScreenInstance
var testScenePath = "res://scenes/_debug/debug.tscn"

func before_all():
	# Instantiate the loading screen scene before running any tests
	loadingScreenInstance = LoadingScreenScene.instantiate()
	add_child(loadingScreenInstance)

func test_loadingScreenInstance_not_null():
	# Check if the loading screen instance is successfully created
	assert_not_null(loadingScreenInstance, "LoadingScreen instance should not be null.")

func test_initial_load_status():
	# Check if initial load status is set correctly
	assert_eq(loadingScreenInstance.loadStatus, 0, "Initial load status should be 0.")

func test_initial_load_percent_text():
	# Check if LoadPercent label text is initially set to nothing
	assert_eq(loadingScreenInstance.loadPercent.text, "", "Initial load percent text should be nothing.")

func test_set_scene_to_load():
	# Call set_scene_to_load with a test scene and check if it's set correctly
	loadingScreenInstance.set_scene_to_load(testScenePath)
	assert_eq(loadingScreenInstance.sceneToLoad, testScenePath, "Scene to load should be set to the test scene path.")

func test_progress_while_loading():
	# Simulate loading process and check if progress is being updated
	# Simulate 1000 frames with 0.1 delta
	loadingScreenInstance.set_scene_to_load(testScenePath)
	simulate(loadingScreenInstance, 1000, 0.1)
	assert_ne(loadingScreenInstance.loadPercent.text, "0%", "Load percent text should not be zero.")
