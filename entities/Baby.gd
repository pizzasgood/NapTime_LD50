extends KinematicBody2D


var mobile := false
var speed := 500.0
var jumping := false
var jump_speed := 400.0
var jump_control_time := 200 #ms
var jump_started := 0
var gravity := 2500
var velocity := Vector2.ZERO
var item : Node2D

onready var sprite : Sprite = $Sprite
onready var grab_zone : Area2D = $GrabZone
onready var hands : Node2D = $Hands
onready var mobility_reactivation_timer : Timer = $MobilityReactivationTimer
onready var jump_sfx : AudioStreamPlayer = $JumpSFX


func _physics_process(delta: float) -> void:
	if mobile:
		handle_input()

	if is_on_ceiling():
		jumping = false
		if velocity.y < 0:
			velocity.y = 0
	if jumping:
		move_and_slide(velocity, Vector2.UP)
	else:
		if is_on_floor():
			velocity.y = 0
		else:
			velocity.y += gravity * delta
		move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)

	if get_slide_count() > 0:
		for i in range(get_slide_count()):
			var c = get_slide_collision(i)
			if c.collider.has_method("process_collision"):
				c.collider.process_collision(self)


func _process(_delta: float) -> void:
	if velocity.x > 0:
		sprite.flip_h = false
		hands.scale.x = 1
	if velocity.x < 0:
		sprite.flip_h = true
		hands.scale.x = -1


func handle_input() -> void:
	# running
	velocity.x = 0.0
	if Input.is_action_pressed("ui_right"):
		velocity.x += speed
	if Input.is_action_pressed("ui_left"):
		velocity.x -= speed

	# jumping
	if Input.is_action_pressed("ui_up"):
		if is_on_floor():
			jumping = true
			jump_started = OS.get_ticks_msec()
			jump_sfx.play()
		if jumping and OS.get_ticks_msec() < jump_started + jump_control_time:
			velocity.y = -jump_speed
		else:
			jumping = false
	else:
		jumping = false

	# items
	if Input.is_action_just_pressed("ui_accept"):
		if Input.is_action_pressed("ui_down"):
			release_item()
		elif item != null:
			use_item()
		else:
			grab_item()
	if Input.is_action_just_released("ui_accept") and item != null:
		stop_using_item()


func grab_item() -> void:
	if item != null:
		return
	for a in grab_zone.get_overlapping_areas():
		item = find_parent_item_of_node(a)
		if item != null:
			item.get_parent().remove_child(item)
			hands.add_child(item)
			item.position = Vector2.ZERO
			break
	if item == null:
		return
	if item.has_node("GripHere"):
		item.position = -item.get_node("GripHere").position
	if item.has_node("AnimationPlayer"):
			item.get_node("AnimationPlayer").play("carry")


func find_parent_item_of_node(node: Node):
	if node.is_in_group("pickups"):
		return node
	if node.get_parent() != null:
		return find_parent_item_of_node(node.get_parent())
	return null


func release_item() -> void:
	if item == null:
		return
	hands.remove_child(item)
	get_parent().add_child(item)
	item.position = position
	if item.has_node("AnimationPlayer"):
		item.get_node("AnimationPlayer").play("dropped")
	item = null


func use_item() -> void:
	if item == null:
		return


func stop_using_item() -> void:
	if item == null:
		return


func _on_MobilityReactivationTimer_timeout() -> void:
	mobile = true
