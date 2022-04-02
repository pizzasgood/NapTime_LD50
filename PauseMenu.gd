extends CenterContainer


onready var resume_button : Button = find_node("ResumeButton")
onready var options_window : PopupPanel = get_parent().find_node("OptionsWindow")


func _on_ResumeButton_pressed() -> void:
	visible = false
	get_tree().paused = false


func _on_OptionsButton_pressed() -> void:
	options_window.popup_centered()


func _on_QuitButton_pressed() -> void:
	visible = false
	get_tree().paused = false
	get_tree().change_scene("res://TitleScreen.tscn")


func _ready() -> void:
	visible = false


func _unhandled_input(event) -> void:
	if event.is_action_pressed("menu"):
		if visible:
			_on_ResumeButton_pressed()
		else:
			visible = true
			resume_button.grab_focus()
			get_tree().paused = true
		get_tree().set_input_as_handled()
