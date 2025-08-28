extends Node2D

@onready var paw_button := $CanvasLayer/PawButton
@onready var claw_button := $CanvasLayer/ClawButton
@onready var roar_button := $CanvasLayer/RoarButton
@onready var player_cookie_counter := $CanvasLayer/PlayerCookieCounter
@onready var paw_cookie_counter := $CanvasLayer/PawCookieCounter
@onready var claw_cookie_counter := $CanvasLayer/ClawCookieCounter
@onready var roar_cookie_counter := $CanvasLayer/RoarCookieCounter
@onready var paw_cookie_area := $bet_area/PawArea
@onready var claw_cookie_area := $bet_area/ClawArea
@onready var roar_cookie_area := $bet_area/RoarArea
@onready var player_cookie_spawn_area := $CanvasLayer/PlayerCookieSpawnArea
@onready var enemy_cookie_spawn_area := $CanvasLayer/EnemyCookieSpawnArea
@onready var bet_phase_timer := $BetPhaseTimer
@onready var timer_label := $TimerLabel
@onready var bet_phase_label := $BetPhaseLabel

var cookie_scene: PackedScene = preload("res://scenes/cookie.tscn")

var enemy_choice := ""
var player_choice := ""
const choices := ["paw", "claw", "roar"]

var paw_cookie_pot := []
var claw_cookie_pot := []
var roar_cookie_pot := []
var cookie_holder_pot := []

func _ready() -> void:
	update_score()
	spawn_player_cookie()
	print("Current Phase: ", PhaseManager.current_state)
	bet_phase_timer.start()

func _process(delta) -> void:
	timer_label.text = str(int(bet_phase_timer.time_left))
	
	if bet_phase_timer.time_left == 0:
		timer_label.text = "Choose Paw, Claw, or Roar!"

func spawn_player_cookie() -> void:
	var cookie = cookie_scene.instantiate()
	cookie.global_position = player_cookie_spawn_area.global_position
	cookie.collision_mask = 0
	add_child(cookie)

func spawn_enemy_cookie() -> void:
	var cookie = cookie_scene.instantiate()
	cookie.global_position = enemy_cookie_spawn_area.global_position
	cookie.collision_mask = 0
	add_child(cookie)

func update_score() -> void:
	player_cookie_counter.text = str(Global.total_cookies)

func enemy_turn() -> String:
	enemy_choice = choices[randi() % choices.size()]
	return enemy_choice

func battle() -> void:
	if PhaseManager.current_state == 1:
		enemy_turn()
		print("enemy_chooses: ", enemy_choice)
		
		if player_choice == enemy_choice:
			print("draw")
		elif player_choice == "roar" and enemy_choice == "paw":
			if Global.total_cookies == 0:
				spawn_player_cookie()
			print("player win")
			Global.total_cookies += roar_cookie_pot.size()
			remove_roar_cookies()
		elif player_choice == "paw" and enemy_choice == "claw":
			if Global.total_cookies == 0:
				spawn_player_cookie()
			print("player win")
			Global.total_cookies += paw_cookie_pot.size()
			remove_paw_cookies()
		elif player_choice == "claw" and enemy_choice == "roar":
			if Global.total_cookies == 0:
				spawn_player_cookie()
			print("player win")
			Global.total_cookies += claw_cookie_pot.size()
			remove_claw_cookies()
		elif enemy_choice == "roar" and player_choice == "paw":
			print("player lose")
			remove_roar_cookies()
		elif enemy_choice == "paw" and player_choice == "claw":
			print("player lose")
			remove_paw_cookies()
		elif enemy_choice == "claw" and player_choice == "roar":
			print("player lose")
			remove_claw_cookies()

func remove_roar_cookies() -> void:
	roar_cookie_pot = []
	roar_cookie_counter.text = str(0)
	
	for body in roar_cookie_area.get_overlapping_bodies():
		body.queue_free()
		roar_cookie_area.get_overlapping_bodies().erase(0)
	
	update_roar_cookie_counter()
	update_score()
	
	PhaseManager.current_state = 0
	bet_phase_label.text = "Place your cookies!"
	bet_phase_timer.start()

func remove_claw_cookies() -> void:
	claw_cookie_pot = []
	claw_cookie_counter.text = str(0)
	
	for body in claw_cookie_area.get_overlapping_bodies():
		body.queue_free()
		claw_cookie_area.get_overlapping_bodies().erase(0)
	
	update_claw_cookie_counter()
	update_score()
	
	PhaseManager.current_state = 0
	bet_phase_label.text = "Place your cookies!"
	bet_phase_timer.start()

func remove_paw_cookies() -> void:
	paw_cookie_pot = []
	paw_cookie_counter.text = str(0)
	
	for body in paw_cookie_area.get_overlapping_bodies():
		body.queue_free()
		paw_cookie_area.get_overlapping_bodies().erase(0)
	
	update_roar_cookie_counter()
	update_score()
	
	PhaseManager.current_state = 0
	bet_phase_label.text = "Place your cookies!"
	bet_phase_timer.start()

func _on_paw_button_pressed() -> void:
	player_choice = "paw"
	battle()

func _on_claw_button_pressed() -> void:
	player_choice = "claw"
	battle()

func _on_roar_button_pressed() -> void:
	player_choice = "roar"
	battle()

# COOKIES ENTERS PAW AREA
func _on_paw_area_body_entered(body: RigidBody2D) -> void:
	paw_cookie_pot.append(body)
	update_paw_cookie_counter()

# COOKIES EXITS PAW AREA
func _on_paw_area_body_exited(body: RigidBody2D) -> void:
	if paw_cookie_pot.size() > 0:
		paw_cookie_pot.remove_at(0)
	update_paw_cookie_counter()

# COOKIES ENTERS CLAW AREA
func _on_claw_area_body_entered(body: RigidBody2D) -> void:
	claw_cookie_pot.append(body)
	update_claw_cookie_counter()

# COOKIES EXITS CLAW AREA
func _on_claw_area_body_exited(body: RigidBody2D) -> void:
	if claw_cookie_pot.size() > 0:
		claw_cookie_pot.remove_at(0)
	update_claw_cookie_counter()

# COOKIES ENTERS ROAR AREA
func _on_roar_area_body_entered(body: RigidBody2D) -> void:
	roar_cookie_pot.append(body)
	update_roar_cookie_counter()

# COOKIES EXITS ROAR AREA
func _on_roar_area_body_exited(body: RigidBody2D) -> void:
	if roar_cookie_pot.size() > 0:
		roar_cookie_pot.remove_at(0)
	update_roar_cookie_counter()

func update_paw_cookie_counter() -> void:
	paw_cookie_counter.text = str(paw_cookie_pot.size())

func update_claw_cookie_counter() -> void:
	claw_cookie_counter.text = str(claw_cookie_pot.size())

func update_roar_cookie_counter() -> void:
	roar_cookie_counter.text = str(roar_cookie_pot.size())

func _on_player_cookie_spawn_area_body_exited(body: RigidBody2D) -> void:
	body.collision_mask = 1
	cookie_holder_pot.remove_at(0)
	
	if cookie_holder_pot.size() < 1:
		Global.total_cookies -= 1
	
	if Global.total_cookies > 0 and cookie_holder_pot.size() < 1:
		spawn_player_cookie()
	
	update_score()

func _on_player_cookie_spawn_area_body_entered(body: RigidBody2D) -> void:
	cookie_holder_pot.append(body)

func _on_bet_phase_timer_timeout():
	PhaseManager.current_state = 1
	bet_phase_label.text = ""
	print("Current Phase: ", PhaseManager.current_state)
