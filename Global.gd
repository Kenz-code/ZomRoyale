extends Node

var guns = {
	#[frame,shot_pause,distance till decay,muzzle,damage]
	"seven-seven": [0,0.23,240,22,34],
	"x90": [1,0.09,200,24,8]
}
var current_gun = guns["seven-seven"]

func _ready() -> void:
	pass
