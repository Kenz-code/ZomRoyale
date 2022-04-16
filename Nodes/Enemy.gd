extends KinematicBody2D

const UP = Vector2(0,-1)
const GRAVITY = 16
const MAXFALLSPEED = 200
const JUMPFORCE = [350,300]
const ACCEL = 40
const FALLMULTIPLIER = 2
const JUMPMULTIPLER = 12
export var MAXSPEED = 75
export var direction = 1
export var detects_cliffs = false
export var jump_cliffs = false
export (float) var health = 100
export (float) var health_mult = 1

var motion = Vector2()


func _ready() -> void:
	$floor_checker.position.x = $CollisionShape2D.shape.get_radius() * direction + 1
	$floor_checker.enabled = true
	$Health_Bar._on_max_health_updated(health)
	$Health_Bar.visible = false
	

func _physics_process(_delta: float) -> void:
	randomize()
	motion.y += GRAVITY
	if motion.y >= MAXFALLSPEED:
		motion.y = MAXFALLSPEED
	
	if is_on_wall():
		direction = direction * -1
		$floor_checker.position.x = $CollisionShape2D.shape.get_radius() * direction + 1
	
	elif is_on_wall() or not $floor_checker.is_colliding() and jump_cliffs and is_on_floor():
		motion.y = UP.y * JUMPFORCE[randi() % JUMPFORCE.size()]
	
	motion.x = MAXSPEED * direction
	$AnimatedSprite.scale.x = direction * 2
	
	#offset sprite
	if direction == -1:
		$AnimatedSprite.offset.x = 1
	else:
		$AnimatedSprite.offset.x = 0
	
	$Health_Bar._on_health_updated(health)
	
	move_and_slide(motion, UP)


func _on_sides_check_body_entered(body: Node) -> void:
	if body.has_method("ouch"):
		body.call_deferred("ouch",position.x)

func die(damage: float):
	$Health_Bar.visible = true
	health -= damage
	if health <= 0:
		Global.add_xp += (Global.wave/10) + 1
		Global.save["ability"]["reload_skill"] += 1
		
		$Health_Bar.visible = false
		$AnimatedSprite.visible = false
		
		$Particles2D.emitting = true
		
		$audio.set_stream(Global.die_s)
		$audio.play()
		
		self.set_physics_process(false)
		
		$sides_check/collision.set_deferred("disabled",true)
		$CollisionShape2D.set_deferred("disabled", true)
		
		remove_from_group("zoms")
		yield(get_tree().create_timer(0.8),"timeout")
		get_parent().remove_child(self)
		
	else:
		$Particles2D2.emitting = true
		$AnimatedSprite.material.set_shader_param("whitening",1)
		yield(get_tree().create_timer(0.05),"timeout")
		$AnimatedSprite.material.set_shader_param("whitening",0)


func reset_state():
	self.set_physics_process(true)
	
	$CollisionShape2D.set_deferred("disabled",false)
	$sides_check/collision.set_deferred("disabled",false)
	
	$AnimatedSprite.visible = true
	$Health_Bar.visible = false
	
	health = 100
	health *= health_mult
	$Health_Bar._on_max_health_updated(health)
	
	add_to_group("zoms")
