extends Node2D

onready var wave = Global.wave
var wave_enemies_times_this_num = 1.5
var enemy_health_mult: float = 1
var negative_zoms: int = 0

var node = load("res://Nodes/Enemy.tscn")
var text = load("res://Nodes/Text.tscn")
var rand_true_false = [true,false]
var rand_left_right = [-1,1]
var portal_locations
var level
var levels = ["res://Levels/Level1.tscn","res://Levels/Level2.tscn"]

enum game_state{
	set_up_wave = 0,
	playing_wave = 1,
	wave_complete = 2,
	nothing = 3
}
onready var current_state = game_state.playing_wave
var level_node

func _ready() -> void:
	Global.load_game()
	$AudioStreamPlayer2D.play()
	$Pick_gun.scale.x = 0
	set_up_wave()


func set_up_wave():
	randomize()
	
	level_node = get_child(2)
	if(level_node.name == "Level1" or level_node.name == "Level2"):
		level_node.queue_free()
	
	var level_path = levels[randi() % 2]
	level = load(level_path).instance()
	add_child(level)
	move_child(level, 2)
	
	level_node = get_child(2)
	
	portal_locations = [level_node.get_node("Enemys").get_node("Portal").position,level_node.get_node("Enemys").get_node("Portal2").position,level_node.get_node("Enemys").get_node("Portal3").position]
	
	for n in get_tree().get_nodes_in_group("zoms"):
		if n.name != "Enemys":
			n.queue_free()
	
	if not Global.marathon:
		wave = Global.save["wave_reached"]
		$Player.reset_hearts()
	
	#add resistance
	add_resistance()
	
	#spawn player
	$Player.global_position = Vector2(-40,-3)
	$Player.direction = 1
	
	#spawn enemies
	for _n in range(wave * wave_enemies_times_this_num - negative_zoms):
		randomize()
		var enemy = node.instance()
		enemy.position = portal_locations[randi() % portal_locations.size()]
		enemy.jump_cliffs = true
		randomize()
		enemy.direction = rand_left_right[randi()%rand_left_right.size()]
		randomize()
		enemy.MAXSPEED = rand_range(55,75)
		enemy.add_to_group("zoms")
		enemy.get_child(0).material.resource_local_to_scene = true
		enemy.health_mult = enemy_health_mult
		
		level_node.get_node("Enemys").add_child(enemy)
		
	#wave text
	var wave_start_text = text.instance()
	wave_start_text.text = "Wave " + str(wave)
	wave_start_text.set_position(Vector2(320,30))
	add_child(wave_start_text)
	
	call_deferred("change_state",game_state.playing_wave)
	
	blink_text(wave_start_text)

func change_state(new_state):
	if(current_state != new_state):
		if(new_state == game_state.wave_complete):
			do_wave_complete_animation()
		elif(new_state == game_state.playing_wave):
			check_for_end_wave()
		elif(new_state == game_state.set_up_wave):
			set_up_wave()
			
		current_state = new_state

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
	wave += 1
	if not Global.marathon:
		Global.save["wave_reached"] = wave
		Global.save_game()
	yield(get_tree().create_timer(3.8),"timeout")
	
	call_deferred("change_state",game_state.set_up_wave)


func _on_Void_body_entered(body: Node) -> void:
	if body.is_in_group("zoms"):
		body.queue_free()
	elif body.is_in_group("player"):
		body.global_position = Vector2(-40,-3)
		body.ouch()

func _physics_process(_delta):
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


func _on_back_button_up() -> void:
	$Pick_gun/back.release_focus()
	$Pick_gun/pauseaudio.stop()
	get_tree().paused = false
	$Pick_gun.scale.x = 0


func _on_main_menu_button_up() -> void:
	SceneManager.change_scene("res://Scenes/Menu.tscn")


func _on_pause_pressed() -> void:
	$Pick_gun/back.grab_focus()
	$Pick_gun/pauseaudio.play()
	get_tree().paused = true
	$Pick_gun.scale.x = 1

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_on_pause_pressed()

func reset_wave_count():
	wave = 1

func add_resistance():
	if wave in range(10,19):
		negative_zoms = 14
		enemy_health_mult = 2
	elif wave in range(20,29):
		negative_zoms = 29
		enemy_health_mult = 3.5
	elif wave in range(30,39):
		negative_zoms = 44
		enemy_health_mult = 5
	elif wave in range(40,49):
		negative_zoms = 59
		enemy_health_mult = 6.5
	elif wave in range(50,59):
		negative_zoms = 74
		enemy_health_mult = 8
	elif wave in range(60,69):
		negative_zoms = 89
		enemy_health_mult = 9.5
	else:
		negative_zoms = 0
		enemy_health_mult = 1
