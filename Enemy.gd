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

var motion = Vector2()


func _ready() -> void:
	$floor_checker.position.x = $CollisionShape2D.shape.get_radius() * direction + 1
	if jump_cliffs or detects_cliffs:
		$floor_checker.enabled = true
	$Health_Bar._on_max_health_updated(health)
	$Health_Bar.visible = false

func _physics_process(delta: float) -> void:
	randomize()
	motion.y += GRAVITY
	if motion.y >= MAXFALLSPEED:
		motion.y = MAXFALLSPEED
	
	if is_on_wall() or not $floor_checker.is_colliding() and detects_cliffs and is_on_floor():
		direction = direction * -1
		$floor_checker.position.x = $CollisionShape2D.shape.get_radius() * direction + 1
	
	elif is_on_wall() or not $floor_checker.is_colliding() and jump_cliffs and is_on_floor():
		motion.y = UP.y * JUMPFORCE[randi() % JUMPFORCE.size()]
	
	motion.x = MAXSPEED * direction
	$AnimatedSprite.scale.x = direction * 2
	
	$Health_Bar._on_health_updated(health)
	
	move_and_slide(motion, UP)


func _on_sides_check_body_entered(body: Node) -> void:
	if body.has_method("ouch"):
		body.ouch(position.x)

func die(damage: int):
	$Health_Bar.visible = true
	health -= damage
	if health <= 0:
		$Health_Bar.visible = false
		$Particles2D.emitting = true
		$AnimatedSprite.visible = false
		var die = load("res://Sounds/ZomDie.wav")
		$audio.set_stream(die)
		$audio.play()
		self.set_physics_process(false)
		$sides_check.queue_free()
		$CollisionShape2D.queue_free()
		yield(get_tree().create_timer(0.8),"timeout")
		self.queue_free()
