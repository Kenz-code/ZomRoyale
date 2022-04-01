extends Node

var save_path = "user://save.dat"

var wave = 1

var guns = {
	#[frame,shot_pause,distance till decay,muzzle,damage]
	"seven seven": [0,0.23,240,22,20],
	"x90": [1,0.09,200,24,10],
	"pow9": [2,0.5,640,25,75],
	"poshlinov": [3,0.05,250,24,8],
	"zom49": [4,0.25,300,22,80],
	"zom-om": [5,0.07,400,25,30]
}
var current_gun = guns["seven seven"]

var marathon = false

var save = {
	"wave_reached": 1,
	"first_time": true,
	"name": "",
}

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
