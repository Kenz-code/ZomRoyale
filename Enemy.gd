extends KinematicBody2D

const UP = Vector2(0,-1)
const GRAVITY = 16
const MAXFALLSPEED = 200
const MAXSPEED = 75
const JUMPFORCE = [350,300]
const ACCEL = 40
const FALLMULTIPLIER = 2
const JUMPMULTIPLER = 12
export var direction = 1
export var detects_cliffs = false
export var jump_cliffs = false

var motion = Vector2()


func _ready() -> void:
	$floor_checker.position.x = $CollisionShape2D.shape.get_radius() * direction + 1
	if jump_cliffs or detects_cliffs:
		$floor_checker.enabled = true

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
	
	move_and_slide(motion, UP)


func _on_sides_check_body_entered(body: Node) -> void:
	if body.has_method("ouch"):
		body.ouch(position.x)
