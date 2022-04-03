extends CenterContainer


onready var retry_button : Button = find_node("RetryButton")
onready var score_label : Label = find_node("Score")
onready var main := find_parent("Main")


func game_over() -> void:
	get_tree().paused = true
	visible = true
	var score = (OS.get_ticks_msec() - main.start_time) / 1000
	score_label.text = "Score: %0.1f seconds" % score
	retry_button.grab_focus()


func _on_RetryButton_pressed() -> void:
	visible = false
	get_tree().paused = false
	get_tree().change_scene("res://Main.tscn")


func _on_QuitButton_pressed() -> void:
	visible = false
	get_tree().paused = false
	get_tree().change_scene("res://TitleScreen.tscn")


func _ready() -> void:
	visible = false


func _unhandled_input(_event) -> void:
	if visible:
		get_tree().set_input_as_handled()
