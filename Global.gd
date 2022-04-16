extends Node

var save_path = "user://save.dat"

var wave = 1

var guns = {
	#[frame,shot_pause,distance till decay,muzzle,damage,iconpath]
	"scar": [0,0.23,240,22,20,"res://Art/tiny_gun_icons/seven-seven.png"],
	"scar2": [6,0.22,250,22,30,"res://Art/tiny_gun_icons/desert_hawk.png"],
	"cruiser": [1,0.09,200,24,10,"res://Art/tiny_gun_icons/x90.png"],
	"wolf": [2,0.5,640,25,90,"res://Art/tiny_gun_icons/pow9.png"],
	"crimson": [8,0.10,280,24,20,"res://Art/tiny_gun_icons/mg6000.png"],
	"ash": [3,0.06,250,24,8,"res://Art/tiny_gun_icons/poshlinov.png"],
	"midnight": [9,0.15,330,24,50,"res://Art/tiny_gun_icons/gh55b.png"],
	"flare": [7,0.21,360,22,100,"res://Art/tiny_gun_icons/jb007.png"],
	"nightfall": [4,0.25,300,22,200,"res://Art/tiny_gun_icons/pn21.png"],
	"pulse": [5,0.07,400,25,50,"res://Art/tiny_gun_icons/storm.png"],
	"terminate": [10,0.5,640,24,750,"res://Art/tiny_gun_icons/gs49.png"]
}

var guns_og = {
	#[frame,shot_pause,distance till decay,muzzle,damage,iconpath]
	"scar": [0,0.23,240,22,20,"res://Art/tiny_gun_icons/seven-seven.png"],
	"scar2": [6,0.22,250,22,30,"res://Art/tiny_gun_icons/desert_hawk.png"],
	"cruiser": [1,0.09,200,24,10,"res://Art/tiny_gun_icons/x90.png"],
	"wolf": [2,0.5,640,25,90,"res://Art/tiny_gun_icons/pow9.png"],
	"crimson": [8,0.10,280,24,20,"res://Art/tiny_gun_icons/mg6000.png"],
	"ash": [3,0.06,250,24,8,"res://Art/tiny_gun_icons/poshlinov.png"],
	"midnight": [9,0.15,330,24,50,"res://Art/tiny_gun_icons/gh55b.png"],
	"flare": [7,0.21,360,22,100,"res://Art/tiny_gun_icons/jb007.png"],
	"nightfall": [4,0.25,300,22,200,"res://Art/tiny_gun_icons/pn21.png"],
	"pulse": [5,0.07,400,25,50,"res://Art/tiny_gun_icons/storm.png"],
	"terminate": [10,0.5,640,24,750,"res://Art/tiny_gun_icons/gs49.png"]
}

var current_gun = guns["scar"]
var current_gun_name = "scar"

var marathon = false

var save = {
	"wave_reached": 1,
	"first_time": true,
	"name": "",
	"xp": 0,
	"level": 1,
	"cloth": {
		"curr_hair": 0,
		"curr_skin": Color("c68642"),
		"curr_shirt": 0,
		"curr_pants": 0,
		"curr_hair_color": Color("#6b4f1f")
	},
	"ability": {
		"speed": 1,
		"steps": 0,
		"reload": 1,
		"reload_skill": 0,
	},
	"settings": {
		"fps": "Off",
		"sound": "On",
		"vsync": "On"
	}
}

var add_xp = 0

var jump_s = load("res://Sounds/Jump.wav")
var hurt_s = load("res://Sounds/Hurt.wav")
var shoot_s = load("res://Sounds/Shoot.wav")
var die_s = load("res://Sounds/ZomDie.wav")

var curr_hair_color:= Color("#6b4f1f")
var curr_hair: int = 0
var curr_shirt: int = 0
var curr_pants: int = 0
var curr_skin:= Color("c68642")
var body_spritesheet = {
	0 : preload("res://Art/Player/skin/body.png"),
	1 : preload("res://Art/Player/skin/body2.png")
}
var hair_spritesheet = {
	0 : preload("res://Art/Player/hair/hair1.png"),
	1 : preload("res://Art/Player/hair/hair2.png"),
	2 : preload("res://Art/Player/hair/hair3.png"),
	3 : preload("res://Art/Player/hair/hair4.png")
}
var shirt_spritesheet = {
	0 : preload("res://Art/Player/shirt/shirt1.png"),
	1 : preload("res://Art/Player/shirt/shirt2.png")
}
var pants_spritesheet = {
	0 : preload("res://Art/Player/pants/pants1.png"),
	1 : preload("res://Art/Player/pants/pants2.png")
}

func save_game():
	save["cloth"]["curr_hair"] = curr_hair
	save["cloth"]["curr_skin"] = curr_skin
	save["cloth"]["curr_shirt"] = curr_shirt
	save["cloth"]["curr_pants"] = curr_pants
	save["cloth"]["curr_hair_color"] = curr_hair_color
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
			if new_save.size() == save.size() and new_save["settings"].size() == save["settings"].size() and new_save["ability"].size() == save["ability"].size() and new_save["cloth"].size() == save["cloth"].size():
				save = new_save
			file.close()
		else:
			print(error)
		curr_hair = save["cloth"]["curr_hair"]
		curr_skin = save["cloth"]["curr_skin"]
		curr_shirt = save["cloth"]["curr_shirt"]
		curr_pants = save["cloth"]["curr_pants"]
		curr_hair_color = save["cloth"]["curr_hair_color"]
	else:
		save_game()

func _ready() -> void:
	pass

func load_abilities():
	while (save["ability"]["reload_skill"] >= 10) == true:
		save["ability"]["reload_skill"] -= 10
		save["ability"]["reload"] += 1
	
	while (save["ability"]["steps"] >= 2000) == true:
		save["ability"]["steps"] -= 2000
		save["ability"]["speed"] += 1
		save_game()
	
	#make guns shoot faster
	guns = guns_og
	for n in guns:
		n[1] = str(int(n[1]) * (save["ability"]["reload"] * 0.02))
		

func check_abilities() -> String:
	while (save["ability"]["reload_skill"] >= 10) == true:
		save["ability"]["reload_skill"] -= 10
		save["ability"]["reload"] += 1
		return "reloadup"
	while (save["ability"]["steps"] >= 2000) == true:
		save["ability"]["steps"] -= 2000
		save["ability"]["speed"] += 1
		return "speedup"
	return "none"
