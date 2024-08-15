extends GutTest

var mainMenuScene = preload("res://scenes/UI/main menu/MainMenu.tscn")
var mainMenuInstance

func before_all():
	# Instantiate the main menu scene before running any tests
	mainMenuInstance = mainMenuScene.instantiate()
	add_child(mainMenuInstance)

func test_buttons_exist():
	# Check if the buttons and container exist
	assert_not_null(get_node("MainMenu/VBoxContainer"), "button container should exist.")
	assert_not_null(get_node("MainMenu/VBoxContainer/Start"), "Start button should exist.")
	assert_not_null(get_node("MainMenu/VBoxContainer/Settings"), "Settings button should exist.")
	assert_not_null(get_node("MainMenu/VBoxContainer/Leaderboard"), "Leaderboard button should exist.")
	assert_not_null(get_node("MainMenu/VBoxContainer/Quit"), "Exit button should exist.")

func test_buttons_have_correct_text():
	# Check if the buttons have the correct text
	assert_eq(get_node("MainMenu/VBoxContainer/Start").get_text(), "Start", "Start button should have the correct text.")
	assert_eq(get_node("MainMenu/VBoxContainer/Settings").get_text(), "Settings", "Settings button should have the correct text.")
	assert_eq(get_node("MainMenu/VBoxContainer/Leaderboard").get_text(), "Leaderboard", "Leaderboard button should have the correct text.")
	assert_eq(get_node("MainMenu/VBoxContainer/Quit").get_text(), "Quit", "Exit button should have the correct text.")

