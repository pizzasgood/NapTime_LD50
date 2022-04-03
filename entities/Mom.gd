extends KinematicBody2D


var mobile := false
var speed := 400.0
var jumping := false
var jump_speed := 400.0
var jump_control_time := 200 #ms
var jump_started := 0
var gravity := 32
var velocity := Vector2.ZERO

var reaction_time := 200 #ms
var ai_actions = []
var ai_actions_buffer = []
var ai_virtual_actions = []

onready var sprite : Sprite = $Sprite
onready var arms = [$FrontArm, $BackArm]
onready var arm_offsets = [arms[0].position.x, arms[1].position.x]
onready var target : KinematicBody2D = get_tree().get_nodes_in_group("player")[0]


func _physics_process(_delta: float) -> void:
	if mobile:
		handle_ai()
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
			velocity.y += gravity
		move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)


func _process(_delta: float) -> void:
	if velocity.x > 0:
		sprite.flip_h = false
		for arm in arms:
			arm.set_flip(false)
		arms[0].position.x = arm_offsets[0]
		arms[1].position.x = arm_offsets[1]
	if velocity.x < 0:
		sprite.flip_h = true
		for arm in arms:
			arm.set_flip(true)
		arms[0].position.x = -arm_offsets[0]
		arms[1].position.x = -arm_offsets[1]


func handle_input() -> void:
	# running
	velocity.x = 0.0
	if "ui_right" in ai_actions:
		velocity.x += speed
	if "ui_left" in ai_actions:
		velocity.x -= speed

	# jumping
	if "ui_up" in ai_actions:
		if is_on_floor():
			jumping = true
			jump_started = OS.get_ticks_msec()
		if jumping and OS.get_ticks_msec() < jump_started + jump_control_time:
			velocity.y = -jump_speed
		else:
			jumping = false
	else:
		jumping = false


func update_reaction_buffer() -> void:
	var now = OS.get_ticks_msec()
	for pair in ai_actions_buffer:
		if pair[1] <= now:
			ai_actions = pair[0]
			ai_actions_buffer.erase(pair)


func handle_ai() -> void:
	update_reaction_buffer()
	var now = OS.get_ticks_msec()
	var new_state = ai_virtual_actions.duplicate(true)
	var x_diff = target.global_position.x - self.global_position.x #TODO: maybe add prediction to compensate for reaction time and mitigate overshoot
	if abs(x_diff) < 24:
			new_state.erase("ui_right")
			new_state.erase("ui_left")
	elif x_diff > 0:
		if not "ui_right" in new_state:
			new_state.append("ui_right")
			new_state.erase("ui_left")
	else:
		if not "ui_left" in new_state:
			new_state.append("ui_left")
			new_state.erase("ui_right")
	new_state.sort()
	if new_state != ai_virtual_actions:
		ai_virtual_actions = new_state.duplicate(true)
		ai_actions_buffer.append([new_state.duplicate(true), now + reaction_time])
