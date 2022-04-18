extends KinematicBody2D

const UP = Vector2(0,-1)
const GRAVITY = 16
const MAXFALLSPEED = 200
const MAXSPEED = 100
const JUMPFORCE =350
const ACCEL = 40
const FALLMULTIPLIER = 2
const JUMPMULTIPLER = 12

var lives = 0
var invincible = false
var can_shoot = true
var motion = Vector2()
var hit_ground = false
var squish_playing = false

export (PackedScene) var Bullet
export (int) var direction = 1

onready var current_gun = Global.current_gun
onready var camera_shake = $Camera2D/screen_shaker
onready var dust_process_mat = $Dust.get_process_material()
onready var cape_process_mat = $Cape.get_process_material()
onready var hearts_node = $HeartsLayer/Hearts
onready var saturate_tween = $SaturateTween
onready var invince_tween = $InvinceTween
onready var animation = $AnimationPlayer
onready var squish_tween = $SquishTween
onready var squish_tween2 = $SquishTween2

signal reset_level

export (float) var speed_ability = 1
export var reload_ability = 1

var save_timer = Timer.new()

func _ready() -> void:
	#set set save_timer
	save_timer.wait_time = 5
	save_timer.connect("timeout",self,"_on_save_timer_timeout")
	add_child(save_timer)
	
	#current gun
	current_gun = Global.current_gun
	$Gun.frame = current_gun[0]

func _physics_process(_delta: float) -> void:
	#gravity
	motion.y += GRAVITY
	
	#multiplier
	if motion.y > 0:
		motion += Vector2.UP * (-9.81) * (FALLMULTIPLIER)
	elif motion.y < 0 && Input.is_action_just_released("jump"):
		motion += Vector2.UP * (-9.81) * (JUMPMULTIPLER)
	
	#direction stuff
	$Gun.position.x = $CompositeSprites.position.x + (13 *direction)
	$muzzle.position.x = $CompositeSprites.position.x + (current_gun[3]*direction)
	$Dust.position.x = $CompositeSprites.position.x + (-4 *direction)
	$Cape.position.x = $CompositeSprites.position.x + (-8 * direction)
	
	if direction == 1:
		if not squish_playing:
			$CompositeSprites.scale.x = 2
		$Gun.flip_h = false
	elif direction == -1:
		if not squish_playing:
			$CompositeSprites.scale.x = -2
		$Gun.flip_h = true
	
	#clamp speed
	motion.x = clamp(motion.x,-MAXSPEED,MAXSPEED)
	
	#handle movement
	if Input.is_action_pressed("right"):
		motion.x += ACCEL * speed_ability
		direction = 1
		animation.play("run")
		$CompositeSprites.play_run()
		walk_particle(-1)
		yield(get_tree().create_timer(0.02),"timeout")
		Global.save["ability"]["steps"] += 1
	elif Input.is_action_pressed("left"):
		motion.x -= ACCEL * speed_ability
		direction = -1
		animation.play("run")
		$CompositeSprites.play_run()
		walk_particle(1)
		yield(get_tree().create_timer(0.02),"timeout")
		Global.save["ability"]["steps"] += 1
	else:
		motion.x = lerp(motion.x,0,0.2)
		animation.play("idle")
		$CompositeSprites.play_idle()
		$Dust.emitting = false
		$Cape.emitting = false
		$footsteps.playing = false
	
	#handle shoot
	if Input.is_action_pressed("shoot"):
		shoot()
	
	#handle jump
	if not is_on_floor():
		hit_ground = false
	
	elif is_on_floor():
		if hit_ground  == false and not $ZomDetectorUnder.is_colliding():
			play_squish_animation()
			hit_ground = true
		if Input.is_action_just_pressed("jump"):
			$JumpPoof.emitting = true
			$audio.set_stream(Global.jump_s)
			$audio.volume_db = -20
			$audio.play()
			$audio.volume_db = -10
			motion = Vector2.UP * JUMPFORCE
	
	#move
	motion = move_and_slide(motion,UP)
	
	#set health position
	hearts_node.global_position = Vector2(0,0)
	
	#save for abilities
	if save_timer.time_left <= 0:
		save_timer.start()

func _on_save_timer_timeout():
	Global.save_game()

func play_squish_animation():
	squish_playing = true
	var cur_pos = Vector2(56,261)
	squish_tween.interpolate_property($CompositeSprites, "scale", Vector2(2*direction,2),Vector2(3*direction,1.3),0.1,Tween.TRANS_CUBIC,Tween.EASE_OUT)
	squish_tween2.interpolate_property($CompositeSprites,"position",cur_pos,Vector2(cur_pos.x, cur_pos.y +6),0.1,Tween.TRANS_CUBIC,Tween.EASE_OUT)
	squish_tween.start()
	squish_tween2.start()
	yield(squish_tween,"tween_completed")
	squish_tween.interpolate_property($CompositeSprites, "scale", Vector2(3*direction,1.3),Vector2(2*direction,2),0.1,Tween.TRANS_CUBIC,Tween.EASE_OUT)
	squish_tween2.interpolate_property($CompositeSprites,"position",Vector2(cur_pos.x, cur_pos.y +6),cur_pos,0.1,Tween.TRANS_CUBIC,Tween.EASE_OUT)
	squish_tween.start()
	squish_tween2.start()
	$CompositeSprites.position = Vector2(56,261)
	squish_playing = false

func ouch(var enemyposx = 0):
	if not invincible:
		#camerashake
		camera_shake._shake(0.1,1)
		
		#hearts
		var hearts = hearts_node.get_children()
		hearts[hearts.size() - 1 - lives].hide()
		lives += 1
		
		#audio
		$audio.set_stream(Global.hurt_s)
		$audio.play()
		
		#color
		$CompositeSprites.set_modulate(Color(1,0.3,0.3,0.3))
		$return_to_normal_color.start()
		saturate_tween.interpolate_property(get_parent().get_node("WorldEnvironment").environment, "adjustment_saturation", 1, 0.5, 0.15, Tween.TRANS_BACK, Tween.EASE_OUT)
		saturate_tween.start()
		saturate_tween.interpolate_property(get_parent().get_node("WorldEnvironment").environment, "adjustment_saturation", 0.5, 1, 0.15, Tween.TRANS_BACK, Tween.EASE_IN)
		saturate_tween.start()
		
		#invincibility
		$invincibility.start()
		invince_tween.interpolate_property(self, "modulate", Color(1,1,1,1),Color(1,1,1,0),1,Tween.TRANS_CUBIC,Tween.EASE_OUT)
		invince_tween.start()
		set_collision_layer_bit(4, true)
		set_collision_layer_bit(0, false)
		set_collision_mask_bit(0,false)
		set_collision_mask_bit(1,false)
		invincible = true
		
		#knockback
		motion.y = UP.y * JUMPFORCE * 0.5
		
		#direction of kb
		if position.x < enemyposx:
			motion.x = -800
		elif position.x > enemyposx:
			motion.x = 800
		
		#release action
		Input.action_release("left")
		Input.action_release("right")
		
		#check for die
		if(lives == 3):
			if Global.marathon:
				get_parent().reset_wave_count()
			get_parent().change_state(get_parent().game_state.set_up_wave)
			reset_hearts()
		

func _on_return_to_normal_color_timeout() -> void:
	$CompositeSprites.set_modulate(Color(1,1,1,1))


func _on_invincibility_timeout() -> void:
	invincible = false
	set_collision_layer_bit(4, false)
	set_collision_layer_bit(0, true)
	set_collision_mask_bit(0,true)
	set_collision_mask_bit(1,true)

func shoot():
	if can_shoot == false:
		return
	else:
		camera_shake._shake(0.1,1)
		can_shoot = false
		$shot_pause.start()
		var b = Bullet.instance()
		b.speed = b.speed * direction
		b.global_position = $muzzle.global_position
		b.decay = current_gun[2]
		b.direction = direction
		b.damage = current_gun[4]
		$audio.set_stream(Global.shoot_s)
		$audio.play()
		add_child(b)
		return


func _on_shot_pause_timeout() -> void:
	can_shoot = true

func walk_particle(_direction):
	$Cape.emitting = true
	if $footsteps.playing == false:
		$footsteps.playing = true
	cape_process_mat.direction = Vector3(_direction,0,0)
	if is_on_floor():
		$Dust.emitting = true
		dust_process_mat.direction = Vector3(_direction,0,0)
		return
	else:
		$Dust.emitting = false
		return

func reset_hearts():
	for n in hearts_node.get_children():
		n.show()
	lives = 0

#stuff to do when wave is cleared or reset and set abilities
func level_reset():
	Global.load_abilities()
	speed_ability = 1 + Global.save["ability"]["speed"] / 10
	reload_ability = Global.save["ability"]["reload"]
	$shot_pause.wait_time = current_gun[1]


func _on_InvinceTween_tween_completed(_object: Object, _key: NodePath) -> void:
	if $invincibility.time_left > 0:
		if (self.modulate == Color(1,1,1,1)):
			invince_tween.interpolate_property(self, "modulate", Color(1,1,1,1),Color(1,1,1,0),0.9,Tween.TRANS_CUBIC,Tween.EASE_OUT)
			invince_tween.start()
		elif (self.modulate == Color(1,1,1,0)):
			invince_tween.interpolate_property(self, "modulate", Color(1,1,1,0),Color(1,1,1,1),0.9,Tween.TRANS_CUBIC,Tween.EASE_OUT)
			invince_tween.start()
	elif $invincibility.time_left <= 0 and self.modulate == Color(1,1,1,0):
		invince_tween.interpolate_property(self, "modulate", Color(1,1,1,0),Color(1,1,1,1),0.9,Tween.TRANS_CUBIC,Tween.EASE_OUT)
		invince_tween.start()
		print("oof")


