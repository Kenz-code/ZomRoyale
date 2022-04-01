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
export (int) var direction = 1
var invincible = false
var can_shoot = true

export (PackedScene) var Bullet
onready var current_gun = Global.current_gun
onready var camera_shake = $Camera2D/screen_shaker

onready var process_mat = $Dust.get_process_material()

var motion = Vector2()

func _ready() -> void:
	$Gun.frame = current_gun[0]
	$shot_pause.wait_time = current_gun[1]

func _physics_process(delta: float) -> void:
	
	current_gun = Global.current_gun
	$shot_pause.wait_time = current_gun[1]
	$Gun.frame = current_gun[0]
	motion.y += GRAVITY
	if motion.y > 0:
		motion += Vector2.UP * (-9.81) * (FALLMULTIPLIER)
	elif motion.y < 0 && Input.is_action_just_released("jump"):
		motion += Vector2.UP * (-9.81) * (JUMPMULTIPLER)
	
	
	$Gun.position.x = $Sprite.position.x + (13 *direction)
	$muzzle.position.x = $Sprite.position.x + (current_gun[3]*direction)
	$Dust.position.x = $Sprite.position.x + (-4 *direction)
	$Cape.position.x = $Sprite.position.x + (-8 * direction)
	if direction == 1:
		$Sprite.scale.x = 2
		$Gun.flip_h = false
	if direction == -1:
		$Sprite.scale.x = -2
		$Gun.flip_h = true
	
	motion.x = clamp(motion.x,-MAXSPEED,MAXSPEED)
	
	if Input.is_action_pressed("right"):
		motion.x += ACCEL
		direction = 1
		$AnimationPlayer.play("run")
		walk_particle(-1)
	elif Input.is_action_pressed("left"):
		motion.x -= ACCEL
		direction = -1
		$AnimationPlayer.play("run")
		walk_particle(1)
	else:
		motion.x = lerp(motion.x,0,0.2)
		$AnimationPlayer.play("idle")
		$Dust.emitting = false
		$Cape.emitting = false
		$footsteps.playing = false
	if Input.is_action_pressed("shoot"):
		shoot()
	
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			var shoot = load("res://Sounds/Jump.wav")
			$audio.set_stream(shoot)
			$audio.volume_db = -20
			$audio.play()
			$audio.volume_db = -10
			motion = Vector2.UP * JUMPFORCE
	
	
	motion = move_and_slide(motion,UP)
	$Hearts.global_position = Vector2(0,0)

func ouch(var enemyposx = 0):
	if not invincible:
		camera_shake._shake(0.1,1)
		var hearts_node = $Hearts
		var hearts = hearts_node.get_children()
		hearts[hearts.size() - 1 - lives].hide()
		lives += 1
		var hurt = load("res://Sounds/Hurt.wav")
		$audio.set_stream(hurt)
		$audio.play()
		$Sprite.set_modulate(Color(1,0.3,0.3,0.3))
		$return_to_normal_color.start()
		$invincibility.start()
		set_collision_layer_bit(4, true)
		set_collision_layer_bit(0, false)
		set_collision_mask_bit(0,false)
		set_collision_mask_bit(1,false)
		invincible = true
		motion.y = UP.y * JUMPFORCE * 0.5
		
		if position.x < enemyposx:
			motion.x = -800
		elif position.x > enemyposx:
			motion.x = 800
		
		Input.action_release("left")
		Input.action_release("right")
		
		if(lives == 3):
			if Global.marathon:
				get_parent().reset_wave_count()
			get_parent().change_state(get_parent().game_state.set_up_wave)
			reset_hearts()
			


func _on_return_to_normal_color_timeout() -> void:
	$Sprite.set_modulate(Color(1,1,1,1))


func _on_invincibility_timeout() -> void:
	invincible = false
	set_collision_layer_bit(4, false)
	set_collision_layer_bit(0, true)
	set_collision_mask_bit(0,true)
	set_collision_mask_bit(1,true)

func shoot():
	if can_shoot == true:
		camera_shake._shake(0.1,1)
		can_shoot = false
		$shot_pause.start()
		var b = Bullet.instance()
		b.speed = b.speed * direction
		b.global_position = $muzzle.global_position
		b.decay = current_gun[2]
		b.direction = direction
		b.damage = current_gun[4]
		var shoot = load("res://Sounds/Shoot.wav")
		$audio.set_stream(shoot)
		$audio.play()
		add_child(b)


func _on_shot_pause_timeout() -> void:
	can_shoot = true

func walk_particle(direction):
	$Cape.emitting = true
	if $footsteps.playing == false:
		$footsteps.playing = true
	var cape_process_mat = $Cape.get_process_material()
	cape_process_mat.direction = Vector3(direction,0,0)
	if is_on_floor():
		$Dust.emitting = true
		process_mat.direction = Vector3(direction,0,0)
	else:
		$Dust.emitting = false

func reset_hearts():
	for n in $Hearts.get_children():
		n.show()
	lives = 0
