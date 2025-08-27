extends Node2D

@onready var paw_button := $CanvasLayer/paw_button
@onready var claw_button := $CanvasLayer/claw_button
@onready var roar_button := $CanvasLayer/roar_button
@onready var cookie_counter := $CanvasLayer/cookie_counter
@onready var paw_cookie_counter := $CanvasLayer/paw_cookie_counter
@onready var claw_cookie_counter := $CanvasLayer/claw_cookie_counter
@onready var roar_cookie_counter := $CanvasLayer/roar_cookie_counter

var cookie_scene: PackedScene = preload("res://scenes/cookie.tscn")

var enemy_choice := ""
var player_choice := ""
var choices := ["paw", "claw", "roar"]

var paw_cookie_pot := []
var claw_cookie_pot := []
var roar_cookie_pot := []

func _ready() -> void:
	update_score()
	spawn_cookie()

func _process(_delta) -> void:
	for body in paw_cookie_pot:
		if not body.selected and body.linear_velocity == Vector2.ZERO:
			update_paw_cookie_counter(body)
	
	for body in claw_cookie_pot:
		if not body.selected and body.linear_velocity == Vector2.ZERO:
			update_claw_cookie_counter(body)
	
	for body in roar_cookie_pot:
		if not body.selected and body.linear_velocity == Vector2.ZERO:
			update_roar_cookie_counter(body)

func spawn_cookie() -> void:
	var cookie = cookie_scene.instantiate()
	cookie.global_position = Vector2(315,274)
	cookie.collision_mask = 0
	add_child(cookie)

func update_score() -> void:
	cookie_counter.text = str(Global.total_cookies)

func enemy_turn() -> String:
	enemy_choice = choices[randi() % choices.size()]
	return enemy_choice

func battle() -> void:
	enemy_turn()
	print("enemy_chooses: ", enemy_choice)
	
	if player_choice == enemy_choice:
		print("draw")
	elif player_choice == "roar" and enemy_choice == "paw":
		print("player win")
		Global.total_cookies += roar_cookie_pot.size()
	elif player_choice == "paw" and enemy_choice == "claw":
		print("player win")
		Global.total_cookies += paw_cookie_pot.size()
	elif player_choice == "claw" and enemy_choice == "roar":
		print("player win")
		Global.total_cookies += claw_cookie_pot.size()
	elif enemy_choice == "roar" and player_choice == "paw":
		print("player lose")
	elif enemy_choice == "paw" and player_choice == "claw":
		print("player lose")
	elif enemy_choice == "claw" and player_choice == "roar":
		print("player lose")
	
	update_score()

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
	if body.is_in_group("cookies"):
		paw_cookie_pot.append(body)

# COOKIES EXITS PAW AREA
func _on_paw_area_body_exited(body: RigidBody2D) -> void:
	if body.is_in_group("cookies") and paw_cookie_pot.size() > 0:
		paw_cookie_pot.remove_at(0)

# COOKIES ENTERS CLAW AREA
func _on_claw_area_body_entered(body: RigidBody2D) -> void:
	if body.is_in_group("cookies"):
		claw_cookie_pot.append(body)

# COOKIES EXITS CLAW AREA
func _on_claw_area_body_exited(body: RigidBody2D) -> void:
	if body.is_in_group("cookies") and claw_cookie_pot.size() > 0:
		claw_cookie_pot.remove_at(0)

# COOKIES ENTERS ROAR AREA
func _on_roar_area_body_entered(body: RigidBody2D) -> void:
	if body.is_in_group("cookies"):
		roar_cookie_pot.append(body)

# COOKIES EXITS ROAR AREA
func _on_roar_area_body_exited(body: RigidBody2D) -> void:
	if body.is_in_group("cookies") and roar_cookie_pot.size() > 0:
		roar_cookie_pot.remove_at(0)

func update_paw_cookie_counter(body: RigidBody2D) -> void:
	paw_cookie_counter.text = str(paw_cookie_pot.size())

func update_claw_cookie_counter(body: RigidBody2D) -> void:
	claw_cookie_counter.text = str(claw_cookie_pot.size())

func update_roar_cookie_counter(body: RigidBody2D) -> void:
	roar_cookie_counter.text = str(roar_cookie_pot.size())

func _on_cookier_spawn_area_body_exited(body: RigidBody2D) -> void:
	body.collision_mask = 1
	
	spawn_cookie()

func _on_cookier_spawn_area_body_entered(body: RigidBody2D) -> void:
	pass
