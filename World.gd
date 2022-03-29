extends Node2D

var node = load("res://Enemy.tscn")
var rand_true_false = [true,false]
var rand_left_right = [-1,1]
onready var portal_locations = [$Enemys/Portal.position,$Enemys/Portal2.position,$Enemys/Portal3.position]

func _ready() -> void:
	$AudioStreamPlayer2D.play()
	for n in range(3):
		randomize()
		var enemy = node.instance()
		enemy.position = portal_locations[randi() % portal_locations.size()]
		var detects_cliff = rand_true_false[randi() % 2]
		if detects_cliff:
			enemy.detects_cliffs = true
		else:
			randomize()
			var jumps_cliff = rand_true_false[randi() % 2]
			if jumps_cliff:
				enemy.jump_cliffs = true
			else:
				randomize()
				jumps_cliff = rand_true_false[randi() % 2]
				if jumps_cliff:
					enemy.jump_cliffs = true
		randomize()
		enemy.direction = rand_left_right[randi()%rand_left_right.size()]
		enemy.add_to_group("zoms")
		
		add_child(enemy)


func _on_Void_body_entered(body: Node) -> void:
	get_tree().reload_current_scene()
