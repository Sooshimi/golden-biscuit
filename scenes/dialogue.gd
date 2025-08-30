class_name Dialogue
extends Control

@onready var content := $Content
@onready var type_timer := $TypeTimer
var last_index := -1

func _ready() -> void:
	type_timer.wait_time = 0.04

func _process(_delta) -> void:
	$LiamIcon.play("liam_animation")

func update_message(message: Array) -> void:
	content.text = message[pick_random_message(message)]
	content.visible_characters = 0
	type_timer.start()

func pick_random_message(message: Array) -> int:
	if message.size() <= 1:
		return 0  # or -1 if empty
	
	var new_index = last_index
	
	while new_index == last_index:
		new_index = randi() % message.size()
	
	last_index = new_index
	
	return new_index

func _on_type_timer_timeout():
	if content.visible_characters < content.text.length():
		content.visible_characters += 1
		type_timer.start()
	else:
		type_timer.stop()

func _on_delay_timer_timeout():
	if $"..".player_win:
		update_message(Global.lose_message)
	else:
		update_message(Global.win_message)
