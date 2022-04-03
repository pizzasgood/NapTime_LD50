extends Node2D


var rider : Node2D
var rider_gravity : float
var rider_parent : Node

var omega := 0.0
var max_omega := TAU
var swing_thrust := TAU
var friction := 0.2 * swing_thrust
var pendulum_gravity := swing_thrust / 1.25

export var hp : float = 5
var fall_velocity := Vector2.ZERO

onready var grab_cooldown : Timer = $GrabCooldown
onready var sprite : Sprite = $Sprite


func _process(delta: float) -> void:
	handle_input(delta)

	if hp > 0:
		if is_instance_valid(rider):
			hp -= delta
			if hp < 0:
				call_deferred("release_body")
				fall_velocity = omega * Vector2.DOWN.tangent().rotated(rotation) * sprite.texture.get_height()
				# TODO: play snapping sound

	# release_body assumes we're swinging and may be call_deferred, so ensure we continue swinging until rider is gone
	if hp > 0 or is_instance_valid(rider):
		handle_swinging(delta)
	else:
		handle_falling(delta)


func handle_swinging(delta: float) -> void:
	var angle = fposmod(rotation, TAU)
	if angle != 0:
		if angle < TAU/2:
			omega += pendulum_gravity * delta
		elif angle > TAU/2:
			omega -= pendulum_gravity * delta
	var degredation = friction * delta
	if omega > 0:
		omega = min(max(0, omega - degredation), max_omega)
	elif omega < 0:
		omega = max(min(0, omega + degredation), -max_omega)

	rotate(-omega * delta)


func handle_falling(delta: float) -> void:
	fall_velocity += delta * rider_gravity * Vector2.DOWN
	position += delta * fall_velocity
	# TODO: explode when hitting floor


func _on_Area2D_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if is_instance_valid(rider):
		return
	if not grab_cooldown.is_stopped():
		return
	call_deferred("take_body", body)


func handle_input(delta: float) -> void:
	if not is_instance_valid(rider):
		return
	if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down"):
		call_deferred("release_body")
	if Input.is_action_pressed("ui_left"):
		omega -= swing_thrust * delta
	if Input.is_action_pressed("ui_right"):
		omega += swing_thrust * delta


func take_body(body: Node2D) -> void:
	rider = body
	rider.mobile = false
	var rider_pos = to_local(rider.global_position)
	omega = get_angular_velocity(rider_pos, rider.velocity)
	rider_gravity = rider.gravity
	rider.gravity = 0
	rider.velocity = Vector2.ZERO
	rider_parent = rider.get_parent()
	rider_parent.remove_child(rider)
	add_child(rider)
	rider.position = rider_pos


func release_body() ->void:
	rider.velocity = get_tangential_velocity(rider.position)
	var rider_pos = rider.global_position
	remove_child(rider)
	rider_parent.add_child(rider)
	rider.global_position = rider_pos
	rider.gravity = rider_gravity
	rider.mobility_reactivation_timer.start()
	rider = null
	grab_cooldown.start()


func get_tangential_velocity(point: Vector2) -> Vector2:
	return point.tangent() * omega


func get_angular_velocity(point: Vector2, velocity: Vector2) -> float:
	return point.tangent().dot(velocity) / point.length_squared()
