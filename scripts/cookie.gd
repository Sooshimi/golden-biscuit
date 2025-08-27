extends RigidBody2D

var follow_speed := 25
var selected := false
var thrown := false
var bet_counted := false
var throw_velocity := Vector2.ZERO
var throw_velocity_reduce := 3

func _ready() -> void:
	linear_damp = 5.0

func _on_area_2d_input_event(_viewport, _event, _shape_idx) -> void:
	if Input.is_action_just_pressed("left_click") and not thrown:
		selected = true

func _process(delta) -> void:
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(), delta * follow_speed)
		throw_velocity = Input.get_last_mouse_velocity()
	
	if not selected and linear_velocity.length() < 1:
		linear_velocity = Vector2.ZERO

func _input(event) -> void:
	if event is InputEventMouseButton:
		if selected and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			selected = false
			thrown = true
			
			linear_velocity = throw_velocity / throw_velocity_reduce
