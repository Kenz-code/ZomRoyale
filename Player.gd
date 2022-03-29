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

var motion = Vector2()

func _physics_process(delta: float) -> void:
	motion.y += GRAVITY
	if motion.y > 0:
		motion += Vector2.UP * (-9.81) * (FALLMULTIPLIER)
	elif motion.y < 0 && Input.is_action_just_released("jump"):
		motion += Vector2.UP * (-9.81) * (JUMPMULTIPLER)
	
	
	$Gun.position.x = $Sprite.position.x + (13 *direction)
	$muzzle.position.x = $Sprite.position.x + (22*direction)
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
	elif Input.is_action_pressed("left"):
		motion.x -= ACCEL
		direction = -1
		$AnimationPlayer.play("run")
	else:
		motion.x = lerp(motion.x,0,0.2)
		$AnimationPlayer.play("idle")
	if Input.is_action_just_pressed("shoot"):
		shoot()
	
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			motion = Vector2.UP * JUMPFORCE
	
	
	motion = move_and_slide(motion,UP)

func ouch(var enemyposx):
	if not invincible:
		var hearts_node = get_parent().get_node("Hearts")
		var hearts = hearts_node.get_children()
		hearts[hearts.size() - 1 - lives].hide()
		lives += 1
		var hurt = load("res://Sounds/Hurt.wav")
		$audio.set_stream(hurt)
		$audio.play()
		set_modulate(Color(1,0.3,0.3,0.3))
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
			get_tree().reload_current_scene()


func _on_return_to_normal_color_timeout() -> void:
	set_modulate(Color(1,1,1,1))


func _on_invincibility_timeout() -> void:
	invincible = false
	set_collision_layer_bit(4, false)
	set_collision_layer_bit(0, true)
	set_collision_mask_bit(0,true)
	set_collision_mask_bit(1,true)

func shoot():
	if can_shoot == true:
		can_shoot = false
		$shot_pause.start()
		var b = Bullet.instance()
		b.speed = b.speed * direction
		b.global_position = $muzzle.global_position
		var shoot = load("res://Sounds/Shoot.wav")
		$audio.set_stream(shoot)
		$audio.play()
		add_child(b)


func _on_shot_pause_timeout() -> void:
	can_shoot = true
