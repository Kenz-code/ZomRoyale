extends Node

var save_path = "user://save.dat"

var wave = 1

var guns = {
	#[frame,shot_pause,distance till decay,muzzle,damage,iconpath]
	"defal": [0,0.23,240,22,20,"res://Art/tiny_gun_icons/seven-seven.png"],
	"defal3": [6,0.22,250,22,30,"res://Art/tiny_gun_icons/desert_hawk.png"],
	"x90": [1,0.09,200,24,10,"res://Art/tiny_gun_icons/x90.png"],
	"ak 35": [8,0.10,280,24,20,"res://Art/tiny_gun_icons/mg6000.png"],
	"pow9": [2,0.5,640,25,75,"res://Art/tiny_gun_icons/pow9.png"],
	"ak 109": [3,0.06,250,24,8,"res://Art/tiny_gun_icons/poshlinov.png"],
	"pickr": [9,0.15,330,24,50,"res://Art/tiny_gun_icons/gh55b.png"],
	"flare": [7,0.21,360,22,100,"res://Art/tiny_gun_icons/jb007.png"],
	"zom49": [4,0.25,300,22,200,"res://Art/tiny_gun_icons/pn21.png"],
	"zom-om": [5,0.07,400,25,50,"res://Art/tiny_gun_icons/storm.png"]
}

var current_gun = guns["defal"]
var current_gun_name = "defal"

var marathon = false

var save = {
	"wave_reached": 1,
	"first_time": true,
	"name": "",
}

var jump_s = load("res://Sounds/Jump.wav")
var hurt_s = load("res://Sounds/Hurt.wav")
var shoot_s = load("res://Sounds/Shoot.wav")

func save_game():
	var file = File.new()
	var error = file.open(save_path, File.WRITE)
	if error == OK:
		file.store_var(save)
		file.close()
	else:
		print(error)

func load_game():
	var file = File.new()
	if file.file_exists(save_path):
		var error = file.open(save_path, File.READ)
		if error == OK:
			var new_save = file.get_var()
			if new_save.size() == save.size():
				save = new_save
			file.close()
		else:
			print(error)
	else:
		save_game()

func _ready() -> void:
	pass
