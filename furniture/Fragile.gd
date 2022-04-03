extends StaticBody2D


export var hp := 3
export var collision_cooldown := 1
export var disable_collision_when_broken := false

var collision_timer : Timer
onready var sprite = find_node("Sprite")
onready var broken_sprite = find_node("BrokenSprite")
onready var collision_shape : CollisionShape2D = find_node("CollisionShape2D")
onready var broken_collision_shape : CollisionShape2D = find_node("BrokenCollisionShape2D")
onready var sfx : AudioStreamPlayer = find_node("SFX")


func _ready() -> void:
	collision_timer = Timer.new()
	collision_timer.wait_time = collision_cooldown
	collision_timer.one_shot = true
	add_child(collision_timer)

	if is_instance_valid(broken_sprite):
		broken_sprite.visible = false
	if is_instance_valid(broken_collision_shape):
		broken_collision_shape.disabled = true


func process_collision(_body) -> void:
	if collision_timer.is_stopped():
		collision_timer.start()
		hp -= 1
		if hp == 0:
			die()

func die() -> void:
	if is_instance_valid(broken_sprite):
		sprite.visible = false
		broken_sprite.visible = true
	if is_instance_valid(broken_collision_shape):
		collision_shape.disabled = true
		broken_collision_shape.disabled = false
	if disable_collision_when_broken:
		collision_shape.disabled = true
	if is_instance_valid(sfx):
		sfx.play()
