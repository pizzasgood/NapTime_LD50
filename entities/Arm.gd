extends Node2D


onready var sprite := $Sprite
onready var grab_zone := $GrabZone
onready var target : KinematicBody2D = get_tree().get_nodes_in_group("player")[0]
onready var game_over_menu := get_node("/root/Main").find_node("GameOver")


func set_flip(value : bool) -> void:
	if value != sprite.flip_h:
		sprite.flip_h = value
		sprite.position.x *= -1
		#grab_zone.position.x *= -1 # this is unnecessary since it has x positon of 0


func _process(_delta: float) -> void:
	var angle := global_position.angle_to_point(target.global_position)
	angle += TAU/4 # because default arm orientation is down, not forward
	rotation = angle


func _on_GrabZone_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	game_over_menu.game_over()
