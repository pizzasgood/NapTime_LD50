extends CenterContainer


onready var label : Label = $Label
onready var timer : Timer = $Timer
onready var main := find_parent("Main")


func _process(delta: float) -> void:
	label.text = "%d" % ceil(timer.time_left)


func _on_Timer_timeout() -> void:
	visible = false
	main.start()
