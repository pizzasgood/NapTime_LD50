extends PopupPanel


onready var resume_button : Button = find_node("ResumeButton")


func _on_ResumeButton_pressed() -> void:
	visible = false


func _ready() -> void:
	visible = false
	resume_button.connect("pressed", self, "_on_ResumeButton_pressed")
