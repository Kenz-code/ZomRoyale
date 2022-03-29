extends Node2D

var wave = 1
var wave_enemies_times_this_num = 2

var node = load("res://Enemy.tscn")
var text = load("res://Text.tscn")
var rand_true_false = [true,false]
var rand_left_right = [-1,1]
onready var portal_locations = [$Enemys/Portal.position,$Enemys/Portal2.position,$Enemys/Portal3.position]

enum game_state{
	set_up_wave = 0,
	playing_wave = 1,
	wave_complete = 2,
	nothing = 3
}
onready var current_state = game_state.playing_wave

func _ready() -> void:
	$AudioStreamPlayer2D.play()
	
	set_up_wave()


func set_up_wave():
	$Player.global_position = Vector2(-40,-3)
	$Player.direction = 1
	for n in range(wave * wave_enemies_times_this_num):
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
		randomize()
		enemy.MAXSPEED = rand_range(55,75)
		enemy.add_to_group("zoms")
		
		print(n)
		add_child(enemy)
		
	#wave text
	var wave_start_text = text.instance()
	wave_start_text.text = "Wave " + str(wave)
	wave_start_text.set_position(Vector2(320,30))
	add_child(wave_start_text)
	
	wave += 1
	call_deferred("change_state",game_state.playing_wave)
	
	blink_text(wave_start_text)

func change_state(new_state):
	if(current_state != new_state):
		if(new_state == game_state.wave_complete):
			do_wave_complete_animation()
		if(new_state == game_state.playing_wave):
			check_for_end_wave()
		if(new_state == game_state.set_up_wave):
			set_up_wave()
			
		current_state = new_state
		print(current_state)

func handle_state_processes(this_state):
	if(this_state == game_state.playing_wave):
		check_for_end_wave()

func check_for_end_wave():
	if(get_tree().get_nodes_in_group("zoms").size() == 1):
		change_state(game_state.wave_complete)
		
func do_wave_complete_animation():
	var text_complete = text.instance()
	text_complete.set_position(Vector2(320,30))
	text_complete.text = "Wave Complete   Well done"
	add_child(text_complete)
	blink_text(text_complete)
	yield(get_tree().create_timer(3.8),"timeout")
	call_deferred("change_state",game_state.set_up_wave)


func _on_Void_body_entered(body: Node) -> void:
	if body.is_in_group("zoms"):
		body.queue_free()
	elif body.is_in_group("player"):
		get_tree().reload_current_scene()

func _physics_process(delta):
	handle_state_processes(current_state)

func blink_text(wave_start_text):
	yield(get_tree().create_timer(0.8),"timeout")
	wave_start_text.hide()
	yield(get_tree().create_timer(0.7),"timeout")
	wave_start_text.show()
	yield(get_tree().create_timer(0.8),"timeout")
	wave_start_text.hide()
	yield(get_tree().create_timer(0.7),"timeout")
	wave_start_text.show()
	yield(get_tree().create_timer(0.8),"timeout")
	wave_start_text.queue_free()
