extends Node

onready var body_sprite = $body
onready var hair_sprite = $hair
onready var shirt_sprite = $shirt
onready var pants_sprite = $pants
onready var curr_hair = Global.curr_hair
onready var curr_shirt = Global.curr_shirt
onready var curr_pants = Global.curr_pants
onready var curr_skin = Global.curr_skin
onready var curr_hair_color = Global.curr_hair_color

onready var hair_spritesheet = Global.hair_spritesheet
onready var shirt_spritesheet = Global.shirt_spritesheet
onready var pants_spritesheet = Global.pants_spritesheet

func _ready() -> void:
	#composite sprites
	hair_sprite.texture = hair_spritesheet[curr_hair]
	shirt_sprite.texture = shirt_spritesheet[curr_shirt]
	pants_sprite.texture = pants_spritesheet[curr_pants]
	hair_sprite.modulate = curr_hair_color
	body_sprite.modulate = curr_skin

func _physics_process(_delta: float) -> void:
	curr_skin = Global.curr_skin
	curr_hair = Global.curr_hair
	curr_shirt = Global.curr_shirt
	curr_pants = Global.curr_pants
	curr_hair_color = Global.curr_hair_color
	#composite sprites
	hair_sprite.texture = hair_spritesheet[curr_hair]
	shirt_sprite.texture = shirt_spritesheet[curr_shirt]
	pants_sprite.texture = pants_spritesheet[curr_pants]
	hair_sprite.modulate = curr_hair_color
	body_sprite.modulate = curr_skin

func play_run():
	$AnimationPlayer.play("run")

func play_idle():
	$AnimationPlayer.play("idle")

func stop():
	$AnimationPlayer.stop(true)
