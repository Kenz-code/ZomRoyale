extends Sprite

onready var ani_player = $AnimationPlayer


func _ready() -> void:
	pass

func play_up(ani: String = "levelup"):
	ani_player.play(ani)
	yield(get_tree().create_timer(2),"timeout")
	ani_player.play_backwards(ani)
