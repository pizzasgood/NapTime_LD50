extends Node


var start_time : float


func start() -> void:
	find_node("Baby").mobile = true
	find_node("Mom").mobile = true
	$BGM.play()
	start_time = OS.get_ticks_msec()
