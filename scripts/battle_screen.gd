extends Node2D

@onready var paw_button := $CanvasLayer/paw_button
@onready var claw_button := $CanvasLayer/claw_button
@onready var roar_button := $CanvasLayer/roat_button
@onready var cookie_counter := $CanvasLayer/cookie_counter

func _ready() -> void:
	update_score()

func update_score() -> void:
	cookie_counter.text = str(Global.total_cookies)

func _on_paw_button_pressed():
	pass
