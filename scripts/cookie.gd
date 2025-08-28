extends RigidBody2D

@onready var cookie_throw_distance_timer := $CookieThrowDistanceTimer
@onready var cookie_throw_delay_timer := $CookieThrowDelayTimer

var follow_speed := 25
var selected := false
var thrown := false
var throw_velocity := Vector2.ZERO
var throw_velocity_reduce := 3
var base_angle := 90.0 # Aim straight down
var spread_angle := 70.0  # cone half-angle on either side
var random_angle
var speed := 100
var min_cookie_throw_delay := 0.5
var max_cookie_throw_delay := 1.5
var min_cookie_throw_distance := 0.5
var max_cookie_throw_distance := 2.0

func _ready() -> void:
	linear_damp = 5.0
	random_angle = deg_to_rad(base_angle + randf_range(-spread_angle, spread_angle))
	cookie_throw_delay_timer.start(randf_range(min_cookie_throw_delay, max_cookie_throw_delay))

func _on_area_2d_input_event(_viewport, _event, _shape_idx) -> void:
	if (Input.is_action_just_pressed("left_click") 
	and not thrown 
	and linear_velocity == Vector2.ZERO
	and PhaseManager.current_state == PhaseManager.Phase.BETTING_PHASE
	and not self.is_in_group("enemy_cookie")):
		selected = true

func _process(delta) -> void:
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(), delta * follow_speed)
		throw_velocity = Input.get_last_mouse_velocity()
	
	if not selected and linear_velocity.length() < 1:
		linear_velocity = Vector2.ZERO
	
	if self.is_in_group("enemy_cookie") and cookie_throw_delay_timer.is_stopped():
		linear_velocity = Vector2.RIGHT.rotated(random_angle) * speed

func _input(event) -> void:
	if event is InputEventMouseButton:
		if selected and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			selected = false
			thrown = true
			
			linear_velocity = throw_velocity / throw_velocity_reduce

func _on_cookie_throw_delay_timer_timeout():
	cookie_throw_distance_timer.start(randf_range(min_cookie_throw_distance, max_cookie_throw_distance))

func _on_cookie_throw_distance_timer_timeout():
	self.remove_from_group("enemy_cookie")
