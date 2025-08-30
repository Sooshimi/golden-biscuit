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
@onready var result_timer := $ResultTimer

var cookie_scene: PackedScene = preload("res://scenes/cookie.tscn")

var enemy_choice := ""
var player_choice := ""
const choices := ["paw", "claw", "roar"]
var player_thrown_cookies_counter := 0
var minimum_bet := 5
var minimum_bet_penalty := 10
var enemy_panel_default_position_y := 162.0
var player_panel_default_position_y := 306.0
var trinity_default_position_x := 77.0
var cookie_collect_speed = 500
var player_win: bool
var enemy_win: bool
var liam_dialogue_hide_position := Vector2(0.0, -190.0)
var cookie_collect_trigger := false
var player_total_cookies_at_round_start: int

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
	PhaseManager.current_state = 0
	$BetPenalty.text = str("-", minimum_bet_penalty)
	player_total_cookies_at_round_start = Global.player_total_cookies

func _process(delta: float) -> void:
	if bet_phase_timer.time_left > 0:
		timer_label.text = str(int(bet_phase_timer.time_left + 1))
	else:
		timer_label.text = ""
	
	if start_game_button_pressed:
		camera_zoom(delta)
		panels_slide_in(delta)
		if $MainMenuMusic.volume_db > main_loop_bus_volume:
			$MainMenuMusic.volume_db -= 0.05
		if $BackgroundMusic.volume_db < background_bus_volume:
			$BackgroundMusic.volume_db += 1.0
	
	# COLLECT COOKIES
	if PhaseManager.current_state == 2 and player_win:
		if cookie_collect_trigger:
			liam_dialogue_slide_in(delta)
		if player_choice == "paw":
			remove_paw_cookies()
			collect_cookies(paw_cookie_area)
		elif player_choice == "claw":
			remove_claw_cookies()
			collect_cookies(claw_cookie_area)
		elif player_choice == "roar":
			remove_roar_cookies()
			collect_cookies(roar_cookie_area)
	elif PhaseManager.current_state == 2 and enemy_win:
		if cookie_collect_trigger:
			liam_dialogue_slide_in(delta)
		if enemy_choice == "paw":
			remove_paw_cookies()
			collect_cookies(paw_cookie_area)
		elif enemy_choice == "claw":
			remove_claw_cookies()
			collect_cookies(claw_cookie_area)
		elif enemy_choice == "roar":
			remove_roar_cookies()
			collect_cookies(roar_cookie_area)
	elif PhaseManager.current_state == 2 and not player_win and not enemy_win and cookie_collect_trigger:
		$UI/DrawInstructionLabel.text = "Draw!"
		check_game_over()

	if PhaseManager.current_state == 0 and not cookie_collect_trigger:
		liam_dialogue_slide_out(delta)

func check_game_over() -> void:
	if Global.player_total_cookies < 0 or Global.enemy_total_cookies < 0:
		print("GAME OVER")
		PhaseManager.current_state = 3
		game_over.show()
		$ResultTimer.stop()
	
	if Global.enemy_total_cookies < 0:
		game_over_result.text = "You win!"
		$WinMusic.play()
	elif Global.player_total_cookies < 0:
		game_over_result.text = "You lose!"
		$LoseMusic.play()

func liam_dialogue_slide_in(delta: float) -> void:
	$LiamDialogueUI.global_position = lerp($LiamDialogueUI.global_position, Vector2.ZERO, delta * 5)

func liam_dialogue_slide_out(delta: float) -> void:
	$LiamDialogueUI.global_position = lerp($LiamDialogueUI.global_position, liam_dialogue_hide_position, delta * 5)

func collect_cookies(cookie_area: Node) -> void:
	check_game_over()
	
	if cookie_collect_trigger:
		for body in cookie_area.get_overlapping_bodies():
			body.add_to_group("cookie_won")
			body.set_collision_mask(0)
			body.set_collision_layer(0)
			
		for body in get_tree().get_nodes_in_group("cookie_won"):
			if enemy_win or (player_thrown_cookies_counter < minimum_bet and player_total_cookies_at_round_start > minimum_bet):
				var direction = ($EnemyCookieCollector.global_position - body.global_position).normalized()
				body.linear_velocity = direction * cookie_collect_speed
			else:
				var direction = ($PlayerCookieCollector.global_position - body.global_position).normalized()
				body.linear_velocity = direction * cookie_collect_speed

func _on_start_game_button_pressed() -> void:
	start_game_button_pressed = true
	bet_area.show()
	menu.hide()
	$BackgroundMusic.volume_db = -30.0
	$BackgroundMusic.play()
	$EnterRingSFX.play()
	menu_transition_timer.start()

func start_game() -> void:
	#menu_transition_timer.start()
	pass

func _on_menu_transition_timer_timeout() -> void:
	Global.game_start = true
	spawn_player_cookie()
	spawn_enemy_cookie()
	print("Current Phase: ", PhaseManager.current_state)
	bet_phase_timer.start()
	$BetTickingIncrement.play()
	$UI.show()

func camera_zoom(delta: float) -> void:
	camera.zoom.x = lerp(camera.zoom.x, 1.0, delta * 3)
	camera.zoom.y = lerp(camera.zoom.y, 1.0, delta * 3)

func panels_slide_in(delta: float) -> void:
	$PlayerPanel.global_position.y = lerp($PlayerPanel.global_position.y, player_panel_default_position_y, delta * 3)
	$EnemyPanel.global_position.y = lerp($EnemyPanel.global_position.y, enemy_panel_default_position_y, delta * 3)
	$Trinity.global_position.x = lerp($Trinity.global_position.x, trinity_default_position_x, delta * 3)

func spawn_player_cookie() -> void:
	var cookie = cookie_scene.instantiate()
	cookie.global_position = player_cookie_spawn_area.global_position
	cookie.collision_mask = 0
	call_deferred("add_child", cookie)

func spawn_enemy_cookie() -> void:
	if PhaseManager.current_state == 0:
		var cookie = cookie_scene.instantiate()
		cookie.global_position = enemy_cookie_spawn_area.global_position
		cookie.collision_mask = 0
		call_deferred("add_child", cookie)

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
			disable_buttons(true)
			player_win = false
			enemy_win = false
			start_result_phase()
		elif player_choice == "roar" and enemy_choice == "claw":
			if Global.player_total_cookies == 0:
				spawn_player_cookie()
			player_win = true
			enemy_win = false
			disable_buttons(true)
			$LiamDialogueUI/DelayTimer.start()
			if not (player_thrown_cookies_counter <= minimum_bet and player_total_cookies_at_round_start > minimum_bet):
				Global.player_total_cookies += roar_cookie_pot.size()
			#remove_roar_cookies()
			start_result_phase()
		elif player_choice == "paw" and enemy_choice == "roar":
			if Global.player_total_cookies == 0:
				spawn_player_cookie()
			player_win = true
			enemy_win = false
			disable_buttons(true)
			$LiamDialogueUI/DelayTimer.start()
			if not (player_thrown_cookies_counter <= minimum_bet and player_total_cookies_at_round_start > minimum_bet):
				Global.player_total_cookies += paw_cookie_pot.size()
			#remove_paw_cookies()
			start_result_phase()
		elif player_choice == "claw" and enemy_choice == "paw":
			if Global.player_total_cookies == 0:
				spawn_player_cookie()
			player_win = true
			enemy_win = false
			disable_buttons(true)
			$LiamDialogueUI/DelayTimer.start()
			if not (player_thrown_cookies_counter <= minimum_bet and player_total_cookies_at_round_start > minimum_bet):
				Global.player_total_cookies += claw_cookie_pot.size()
			#remove_claw_cookies()
			start_result_phase()
		elif enemy_choice == "roar" and player_choice == "claw" or (player_thrown_cookies_counter <= minimum_bet and player_total_cookies_at_round_start > minimum_bet):
			if Global.enemy_total_cookies == 0:
				spawn_enemy_cookie()
			player_win = false
			enemy_win = true
			disable_buttons(true)
			$LiamDialogueUI/DelayTimer.start()
			if (player_thrown_cookies_counter <= minimum_bet and player_total_cookies_at_round_start > minimum_bet):
				Global.enemy_total_cookies += roar_cookie_pot.size()
			#remove_roar_cookies()
			start_result_phase()
		elif enemy_choice == "paw" and player_choice == "roar" or (player_thrown_cookies_counter <= minimum_bet and player_total_cookies_at_round_start > minimum_bet):
			if Global.enemy_total_cookies == 0:
				spawn_enemy_cookie()
			player_win = false
			enemy_win = true
			disable_buttons(true)
			$LiamDialogueUI/DelayTimer.start()
			if (player_thrown_cookies_counter < minimum_bet and player_total_cookies_at_round_start > minimum_bet):
				Global.enemy_total_cookies += paw_cookie_pot.size()
			#remove_paw_cookies()
			start_result_phase()
		elif enemy_choice == "claw" and player_choice == "paw" or (player_thrown_cookies_counter < minimum_bet and player_total_cookies_at_round_start > minimum_bet):
			if Global.enemy_total_cookies == 0:
				spawn_enemy_cookie()
			player_win = false
			enemy_win = true
			disable_buttons(true)
			$LiamDialogueUI/DelayTimer.start()
			Global.enemy_total_cookies += claw_cookie_pot.size()
			#remove_claw_cookies()
			start_result_phase()

func start_result_phase() -> void:
	PhaseManager.current_state = 2
	print("Current Phase: ", PhaseManager.current_state, " - result phase starts")
	$UI/PickInstructions.hide()
	
	# BATTLE PHASE STARTS
	result_timer.start()
	$PlayerChoiceTimer.start()

func remove_roar_cookies() -> void:
	if cookie_collect_trigger:
		roar_cookie_pot = []
		roar_cookie_counter.text = str(0)
		
		update_roar_cookie_counter()
		update_score()

func remove_claw_cookies() -> void:
	if cookie_collect_trigger:
		claw_cookie_pot = []
		claw_cookie_counter.text = str(0)
		
		update_claw_cookie_counter()
		update_score()

func remove_paw_cookies() -> void:
	if cookie_collect_trigger:
		paw_cookie_pot = []
		paw_cookie_counter.text = str(0)
		
		update_roar_cookie_counter()
		update_score()

func disable_buttons(toggle: bool) -> void:
	for button in get_tree().get_nodes_in_group("button"):
		button.disabled = toggle

func _on_paw_button_pressed() -> void:
	if PhaseManager.current_state == 1:
		player_choice = "paw"
		$UI/DrawInstructionLabel.text = ""
		$PawButtonClick.play()
		$PawSound.play()
		battle()
		$PlayerPanel/PawButtonDefault.hide()
		$PlayerPanel/PawButtonPressed.show()
		$PawEmblem.show()
		$UI/PickInstructions.hide()

func _on_claw_button_pressed() -> void:
	if PhaseManager.current_state == 1:
		player_choice = "claw"
		$UI/DrawInstructionLabel.text = ""
		$ClawButtonClick.play()
		$ClawSound.play()
		battle()
		$PlayerPanel/ClawButtonDefault.hide()
		$PlayerPanel/ClawButtonPressed.show()
		$ClawEmblem.show()
		$UI/PickInstructions.hide()

func _on_roar_button_pressed() -> void:
	if PhaseManager.current_state == 1:
		player_choice = "roar"
		$UI/DrawInstructionLabel.text = ""
		$RoarButtonClick.play()
		$RoarSound.play()
		battle()
		$PlayerPanel/RoarButtonDefault.hide()
		$PlayerPanel/RoarButtonPressed.show()
		$RoarEmblem.show()
		$UI/PickInstructions.hide()

# COOKIES ENTERS PAW AREA
func _on_paw_area_body_entered(body: RigidBody2D) -> void:
	paw_cookie_pot.append(body)
	update_paw_cookie_counter()

# COOKIES EXITS PAW AREA
func _on_paw_area_body_exited(_body: RigidBody2D) -> void:
	if paw_cookie_pot.size() > 0:
		paw_cookie_pot.remove_at(0)
	update_paw_cookie_counter()

# COOKIES ENTERS CLAW AREA
func _on_claw_area_body_entered(body: RigidBody2D) -> void:
	claw_cookie_pot.append(body)
	update_claw_cookie_counter()

# COOKIES EXITS CLAW AREA
func _on_claw_area_body_exited(_body: RigidBody2D) -> void:
	if claw_cookie_pot.size() > 0:
		claw_cookie_pot.remove_at(0)
	update_claw_cookie_counter()

# COOKIES ENTERS ROAR AREA
func _on_roar_area_body_entered(body: RigidBody2D) -> void:
	roar_cookie_pot.append(body)
	update_roar_cookie_counter()

# COOKIES EXITS ROAR AREA
func _on_roar_area_body_exited(_body: RigidBody2D) -> void:
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
	player_thrown_cookies_counter = 0
	player_total_cookies_at_round_start = Global.player_total_cookies
	print("Current Phase: ", PhaseManager.current_state, " - result timer time out")
	player_win = false
	enemy_win = false
	bet_phase_label.text = "Place your cookies!"
	disable_buttons(false)
	cookie_collect_trigger = false
	$BetPenalty.hide()
	$PawEmblem.hide()
	$ClawEmblem.hide()
	$RoarEmblem.hide()
	$LiamPawChoice.hide()
	$LiamClawChoice.hide()
	$LiamRoarChoice.hide()
	$UI/PawResultLabel.text = ""
	$UI/ClawResultLabel.text = ""
	$UI/RoarResultLabel.text = ""
	$UI/DrawInstructionLabel.text = ""
	$PlayerPanel/PawButtonDefault.show()
	$PlayerPanel/PawButtonPressed.hide()
	$PlayerPanel/ClawButtonDefault.show()
	$PlayerPanel/ClawButtonPressed.hide()
	$PlayerPanel/RoarButtonDefault.show()
	$PlayerPanel/RoarButtonPressed.hide()
	bet_phase_timer.start()
	$BetTickingIncrement.play()
	spawn_enemy_cookie()

func _on_play_again_button_pressed():
	get_tree().reload_current_scene()
	Global.player_total_cookies = Global.default
	Global.enemy_total_cookies = Global.default

func _on_player_choice_timer_timeout():
	$LiamChoiceTimer.start()

func _on_liam_choice_timer_timeout():
	if enemy_choice == "paw":
		$PawSound.play()
		$PawEmblem.show()
		$LiamPawChoice.show()
	elif enemy_choice == "claw":
		$ClawSound.play()
		$ClawEmblem.show()
		$LiamClawChoice.show()
	else:
		$RoarSound.play()
		$RoarEmblem.show()
		$LiamRoarChoice.show()
	
	$CookieCollectTimer.start()

func _on_cookie_collect_timer_timeout():
	cookie_collect_trigger = true
	
	# MINIMUM BET WITH PENALTY
	if player_thrown_cookies_counter < minimum_bet and player_total_cookies_at_round_start > minimum_bet:
		print(player_thrown_cookies_counter)
		Global.player_total_cookies -= minimum_bet_penalty
		$BetPenalty.show()
		update_score()
