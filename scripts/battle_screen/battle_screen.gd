extends Node2D

@onready var camera := $Camera2D
@onready var ui := $UI
@onready var menu := $Menu
@onready var menu_transition_timer := $MenuTransitionTimer
@onready var game_over := $GameOver
@onready var game_over_result := $GameOver/GameOverResult

@onready var bet_area := $BetArea
@onready var paw_button := $UI/PawButton
@onready var claw_button := $UI/ClawButton
@onready var roar_button := $UI/RoarButton
@onready var player_cookie_counter := $UI/PlayerCookieCounter
@onready var enemy_cookie_counter := $UI/EnemyCookieCounter
@onready var paw_cookie_counter := $UI/PawCookieCounter
@onready var claw_cookie_counter := $UI/ClawCookieCounter
@onready var roar_cookie_counter := $UI/RoarCookieCounter
@onready var paw_cookie_area := $BetArea/PawArea
@onready var claw_cookie_area := $BetArea/ClawArea
@onready var roar_cookie_area := $BetArea/RoarArea
@onready var player_cookie_spawn_area := $UI/PlayerCookieSpawnArea
@onready var enemy_cookie_spawn_area := $UI/EnemyCookieSpawnArea
@onready var bet_phase_timer := $BetPhaseTimer
@onready var timer_label := $UI/TimerLabel
@onready var bet_phase_label := $UI/BetPhaseLabel
@onready var player_result_label := $UI/PlayerResultLabel
@onready var enemy_result_label := $UI/EnemyResultLabel
@onready var result_timer := $ResultTimer

var cookie_scene: PackedScene = preload("res://scenes/cookie.tscn")

var enemy_choice := ""
var player_choice := ""
const choices := ["paw", "claw", "roar"]
var player_thrown_cookies_counter := 0

var paw_cookie_pot := []
var claw_cookie_pot := []
var roar_cookie_pot := []
var player_cookie_holder_pot := []
var enemy_cookie_holder_pot := []

var start_game_button_pressed := false
var background_bus = AudioServer.get_bus_index("Background")
var background_bus_volume = AudioServer.get_bus_volume_db(background_bus)
var main_loop_bus = AudioServer.get_bus_index("Main Loop")
var main_loop_bus_volume = AudioServer.get_bus_volume_db(main_loop_bus)

func _ready() -> void:
	Global.game_start = false
	update_score()
	bet_area.hide()
	$MainMenuMusic.play()

func _process(delta) -> void:
	if bet_phase_timer.time_left > 0:
		timer_label.text = str(int(bet_phase_timer.time_left + 1))
	else:
		timer_label.text = ""
	
	if start_game_button_pressed:
		camera_zoom(delta)
		print($MainMenuMusic.volume_db)
		if $MainMenuMusic.volume_db > main_loop_bus_volume:
			$MainMenuMusic.volume_db -= 0.05
		if $BackgroundMusic.volume_db <= background_bus_volume:
			$BackgroundMusic.volume_db += 1.0
			

func _on_start_game_button_pressed() -> void:
	start_game_button_pressed = true
	menu_transition_timer.start()
	bet_area.show()
	menu.hide()
	$BackgroundMusic.volume_db = -80.0
	$BackgroundMusic.play()
	$EnterRingSFX.play()

func _on_menu_transition_timer_timeout():
	Global.game_start = true
	print("SO")
	spawn_player_cookie()
	spawn_enemy_cookie()
	print("Current Phase: ", PhaseManager.current_state)
	bet_phase_timer.start()
	$BetTickingIncrement.play()
	$UI.show()

func camera_zoom(delta) -> void:
	camera.zoom.x = lerp(camera.zoom.x, 1.0, delta * 2)
	camera.zoom.y = lerp(camera.zoom.y, 1.0, delta * 2)

func spawn_player_cookie() -> void:
	var cookie = cookie_scene.instantiate()
	cookie.global_position = player_cookie_spawn_area.global_position
	cookie.collision_mask = 0
	add_child(cookie)

func spawn_enemy_cookie() -> void:
	if PhaseManager.current_state == 0:
		var cookie = cookie_scene.instantiate()
		cookie.global_position = enemy_cookie_spawn_area.global_position
		cookie.collision_mask = 0
		add_child(cookie)

func update_score() -> void:
	player_cookie_counter.text = str(Global.player_total_cookies)
	enemy_cookie_counter.text = str(Global.enemy_total_cookies)

func enemy_turn() -> String:
	enemy_choice = choices[randi() % choices.size()]
	return enemy_choice

func battle() -> void:
	if PhaseManager.current_state == 1:
		enemy_turn()
		print("enemy_chooses: ", enemy_choice)
		
		if player_choice == enemy_choice:
			player_result_label.text = "Draw!"
			enemy_result_label.text = "Draw!"
		elif player_choice == "roar" and enemy_choice == "paw":
			if Global.player_total_cookies == 0:
				spawn_player_cookie()
			player_result_label.text = "Win!"
			enemy_result_label.text = "Lose!"
			Global.player_total_cookies += roar_cookie_pot.size()
			remove_roar_cookies()
			start_result_phase()
		elif player_choice == "paw" and enemy_choice == "claw":
			if Global.player_total_cookies == 0:
				spawn_player_cookie()
			player_result_label.text = "Win!"
			enemy_result_label.text = "Lose!"
			Global.player_total_cookies += paw_cookie_pot.size()
			remove_paw_cookies()
			start_result_phase()
		elif player_choice == "claw" and enemy_choice == "roar":
			if Global.player_total_cookies == 0:
				spawn_player_cookie()
			player_result_label.text = "Win!"
			enemy_result_label.text = "Lose!"
			Global.player_total_cookies += claw_cookie_pot.size()
			remove_claw_cookies()
			start_result_phase()
		elif enemy_choice == "roar" and player_choice == "paw":
			if Global.enemy_total_cookies == 0:
				spawn_enemy_cookie()
			player_result_label.text = "Lose!"
			enemy_result_label.text = "Win!"
			Global.enemy_total_cookies += roar_cookie_pot.size()
			remove_roar_cookies()
			start_result_phase()
		elif enemy_choice == "paw" and player_choice == "claw":
			if Global.enemy_total_cookies == 0:
				spawn_enemy_cookie()
			player_result_label.text = "Lose!"
			enemy_result_label.text = "Win!"
			Global.enemy_total_cookies += paw_cookie_pot.size()
			remove_paw_cookies()
			start_result_phase()
		elif enemy_choice == "claw" and player_choice == "roar":
			if Global.enemy_total_cookies == 0:
				spawn_enemy_cookie()
			player_result_label.text = "Lose!"
			enemy_result_label.text = "Win!"
			Global.enemy_total_cookies += claw_cookie_pot.size()
			remove_claw_cookies()
			start_result_phase()

func start_result_phase() -> void:
	PhaseManager.current_state = 2
	print("Current Phase: ", PhaseManager.current_state, " - result phase starts")
	$UI/PickInstructions.hide()
	
	# MINIMUM BET
	if player_thrown_cookies_counter <= 5 and Global.player_total_cookies > 5:
		Global.player_total_cookies -= 5
		update_score()
	
	# GAME OVER
	if PhaseManager.current_state == 2:
		if Global.player_total_cookies == 0 or Global.enemy_total_cookies == 0:
			print("GAME OVER")
			PhaseManager.current_state = 3
			game_over.show()
			if Global.player_total_cookies > Global.enemy_total_cookies:
				game_over_result.text = "You win!"
				$WinSound.play()
			else:
				game_over_result.text = "You lose!"
				$LoseSound.play()
		else:
			result_timer.start()

func remove_roar_cookies() -> void:
	roar_cookie_pot = []
	roar_cookie_counter.text = str(0)
	
	for body in roar_cookie_area.get_overlapping_bodies():
		body.queue_free()
		roar_cookie_area.get_overlapping_bodies().erase(0)
	
	update_roar_cookie_counter()
	update_score()

func remove_claw_cookies() -> void:
	claw_cookie_pot = []
	claw_cookie_counter.text = str(0)
	
	for body in claw_cookie_area.get_overlapping_bodies():
		body.queue_free()
		claw_cookie_area.get_overlapping_bodies().erase(0)
	
	update_claw_cookie_counter()
	update_score()

func remove_paw_cookies() -> void:
	paw_cookie_pot = []
	paw_cookie_counter.text = str(0)
	
	for body in paw_cookie_area.get_overlapping_bodies():
		body.queue_free()
		paw_cookie_area.get_overlapping_bodies().erase(0)
	
	update_roar_cookie_counter()
	update_score()

func _on_paw_button_pressed() -> void:
	if PhaseManager.current_state == 1:
		player_choice = "paw"
		$PawButtonClick.play()
		$UI/PickInstructions.hide()
		battle()

func _on_claw_button_pressed() -> void:
	if PhaseManager.current_state == 1:
		player_choice = "claw"
		$ClawButtonClick.play()
		$UI/PickInstructions.hide()
		battle()

func _on_roar_button_pressed() -> void:
	if PhaseManager.current_state == 1:
		player_choice = "roar"
		$RoarButtonClick.play()
		$UI/PickInstructions.hide()
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
	player_cookie_holder_pot.remove_at(0)
	
	if player_cookie_holder_pot.size() < 1:
		Global.player_total_cookies -= 1
	
	if Global.player_total_cookies > 0 and player_cookie_holder_pot.size() < 1:
		spawn_player_cookie()
		player_thrown_cookies_counter += 1
	
	body.thrown = true
	update_score()

func _on_player_cookie_spawn_area_body_entered(body: RigidBody2D) -> void:
	player_cookie_holder_pot.append(body)
	body.thrown = false

func _on_enemy_cookie_spawn_area_body_exited(body: RigidBody2D) -> void:
	body.collision_mask = 1
	enemy_cookie_holder_pot.remove_at(0)
	
	if enemy_cookie_holder_pot.size() < 1:
		Global.enemy_total_cookies -= 1
	
	if Global.enemy_total_cookies > 0 and enemy_cookie_holder_pot.size() < 1:
		spawn_enemy_cookie()
	
	body.thrown = true
	update_score()

func _on_enemy_cookie_spawn_area_body_entered(body: RigidBody2D) -> void:
	enemy_cookie_holder_pot.append(body)
	body.thrown = false
	body.add_to_group("enemy_cookie")

func _on_bet_phase_timer_timeout() -> void:
	PhaseManager.current_state = 1
	bet_phase_label.text = ""
	print("Current Phase: ", PhaseManager.current_state, " - bet timer time out")
	$UI/PickInstructions.show()

func _on_result_timer_timeout() -> void:
	PhaseManager.current_state = 0
	print("Current Phase: ", PhaseManager.current_state, " - result timer time out")
	player_thrown_cookies_counter = 0
	player_result_label.text = ""
	enemy_result_label.text = ""
	bet_phase_label.text = "Place your cookies!"
	bet_phase_timer.start()
	$BetTickingIncrement.play()
	spawn_enemy_cookie()

func _on_play_again_button_pressed():
	get_tree().reload_current_scene()
	Global.player_total_cookies = Global.default
	Global.player_total_cookies = Global.default
