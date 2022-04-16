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
var created_zoms = []

enum game_state{
	set_up_wave = 0,
	playing_wave = 1,
	wave_complete = 2,
	nothing = 3
}
onready var current_state = game_state.playing_wave
var level_node

signal level_up

var ani_up

var fps_on = false

func _ready() -> void:
	get_tree().paused = true
	Global.load_game()
	
	#create zoms
	create_zoms()
	
	$AudioStreamPlayer2D.play()
	$Pick_gun.scale.x = 0
	set_up_wave()
	if Global.save["settings"]["fps"] == "On":
		$Fps.show()
		$Memory.show()
		fps_on = true
	else:
		$Fps.hide()
		$Memory.hide()
		fps_on = false
	get_tree().paused = false


func set_up_wave():
	#remvoe zoms so they don't get freed!
	for n in get_tree().get_nodes_in_group("zoms"):
		if n.name != "Enemys":
			n.remove_from_group("zoms")
			get_child(2).get_node("Enemys").remove_child(n)
	
	#free level so we can create new one
	if has_node("Level1"):
		get_node("Level1").free()
	elif has_node("Level2"):
		get_node("Level2").free()
	
	#get level
	var level_path = levels[randi() % 2]
	level = load(level_path).instance()
	#add level
	add_child(level)
	move_child(level, 2)
	#get a reference to the level
	level_node = get_child(2)
	#set portal locations
	portal_locations = [level_node.get_node("Enemys").get_node("Portal").position,level_node.get_node("Enemys").get_node("Portal2").position,level_node.get_node("Enemys").get_node("Portal3").position]
	
	#if is grind, reset hearts
	if not Global.marathon:
		wave = Global.save["wave_reached"]
		$Player.reset_hearts()
	Global.wave = wave
	
	#add resistance
	add_resistance()
	
	#spawn player
	$Player.global_position = Vector2(-40,-3)
	$Player.direction = 1
	#reset level player
	$Player.emit_signal("reset_level")
	
	#spawn enemies
	for n in range(wave * wave_enemies_times_this_num - negative_zoms):
		randomize()
		created_zoms[n].position = portal_locations[randi() % portal_locations.size()]
		created_zoms[n].health_mult = enemy_health_mult
		created_zoms[n].reset_state()
		
		level_node.get_node("Enemys").add_child(created_zoms[n])
		
	#wave text
	var wave_start_text = text.instance()
	wave_start_text.text = "Wave " + str(wave)
	wave_start_text.set_position(Vector2(320,30))
	add_child(wave_start_text)
	
	#change to playing
	call_deferred("change_state",game_state.playing_wave)
	
	#wave number at top
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
	ani_up = Global.check_abilities()
	if ani_up != "none":
		$LevelUp.play_up(ani_up)
	if(get_tree().get_nodes_in_group("zoms").size() == 1):
		change_state(game_state.wave_complete)
	$Fps.text = "Fps  " + str(Performance.get_monitor(Performance.TIME_FPS))
	$Memory.text = "Memory  " + str(int(Performance.get_monitor(Performance.MEMORY_STATIC)/1024/1024))

func do_wave_complete_animation():
	var text_complete = text.instance()
	text_complete.set_position(Vector2(320,30))
	text_complete.text = "Wave Complete"
	add_child(text_complete)
	blink_text(text_complete)
	wave += 1
	if not Global.marathon:
		Global.save["wave_reached"] = wave
		Global.save_game()
	Global.save["xp"] += Global.add_xp
	if Global.save["xp"] >= (Global.save["level"]*Global.save["level"]):
			Global.save["xp"] = 0
			Global.add_xp = 0
			Global.save["level"] += 1
			emit_signal("level_up")
	yield(get_tree().create_timer(3.8),"timeout")
	
	call_deferred("change_state",game_state.set_up_wave)


func _on_Void_body_entered(body: Node) -> void:
	if body.is_in_group("zoms"):
		body.remove_from_group("zoms")
		get_child(2).get_node("Enemys").remove_child(body)
	elif body.is_in_group("player"):
		body.global_position = Vector2(-40,-3)
		body.call_deferred("ouch")

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
	if wave in range(10,10000):
		enemy_health_mult = ((wave/10) * 1.5) + 1
		negative_zoms = ((wave/10)*15) - 1
	elif wave in range(0,10):
		negative_zoms = 0
		enemy_health_mult = 1

func create_zoms():
	#spawn enemies
	for _n in range(15):
		randomize()
		var enemy = node.instance()
		enemy.jump_cliffs = true
		randomize()
		enemy.direction = rand_left_right[randi()%rand_left_right.size()]
		randomize()
		enemy.MAXSPEED = rand_range(55,75)
		enemy.get_child(0).material.resource_local_to_scene = true
		created_zoms.push_back(enemy)

func _on_World_level_up() -> void:
	$LevelUp.show()
	$LevelUp.play_up("levelup")
