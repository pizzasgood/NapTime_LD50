extends Node


onready var start_button : Button = find_node("StartButton")
onready var exit_button : Button = find_node("ExitButton")
onready var intro_label : Label = find_node("Introduction")

onready var about_window : PopupPanel = find_node("AboutWindow")
onready var options_window : PopupPanel = find_node("OptionsWindow")


func _on_StartButton_pressed() -> void:
	get_tree().change_scene("res://Main.tscn")


func _on_OptionsButton_pressed() -> void:
	options_window.popup_centered()


func _on_AboutButton_pressed() -> void:
	about_window.popup_centered()


func _on_ExitButton_pressed() -> void:
	get_tree().quit()


func _ready() -> void:
	start_button.grab_focus()

	if OS.get_name() == "HTML5":
		exit_button.queue_free()
		intro_label.text = intro_label.text.replace("ESC", "Backspace")

