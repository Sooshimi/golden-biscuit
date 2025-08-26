extends CharacterBody2D

@export var speed := 100
@onready var animated_sprite := $AnimatedSprite2D

var last_direction := "south"

func get_input() -> void:
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

func _physics_process(delta: float) -> void:
	get_input()
	
	if Input.is_action_pressed("left"):
		animated_sprite.play("walk_west")
		last_direction = "west"
	elif Input.is_action_pressed("right"):
		animated_sprite.play("walk_east")
		last_direction = "east"
	elif Input.is_action_pressed("up"):
		animated_sprite.play("walk_north")
		last_direction = "north"
	elif Input.is_action_pressed("down"):
		animated_sprite.play("walk_south")
		last_direction = "south"
	else:
		animated_sprite.play("idle_%s" % last_direction)
	
	move_and_slide()
