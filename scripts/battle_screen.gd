extends Node2D

@onready var paw_button := $CanvasLayer/paw_button
@onready var claw_button := $CanvasLayer/claw_button
@onready var roar_button := $CanvasLayer/roar_button
@onready var cookie_counter := $CanvasLayer/cookie_counter
@onready var paw_cookie_counter := $CanvasLayer/paw_cookie_counter
@onready var claw_cookie_counter := $CanvasLayer/claw_cookie_counter
@onready var roar_cookie_counter := $CanvasLayer/roar_cookie_counter

var enemy_choice := ""
var player_choice := ""
var choices := ["paw", "claw", "roar"]
var paw_cookie_counter_int := 0
var claw_cookie_counter_int := 0
var roar_cookie_counter_int := 0

func _ready() -> void:
	update_score()

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
	elif (player_choice == "roar" and enemy_choice == "paw" 
	or player_choice == "paw" and enemy_choice == "claw" 
	or player_choice == "claw" and enemy_choice == "roar"):
		print("player win")
		Global.total_cookies += 1
	else:
		print("player lose")
		Global.total_cookies -= 1
	
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
