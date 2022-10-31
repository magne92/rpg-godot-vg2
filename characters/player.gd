extends KinematicBody2D

export var ACCELERATION = 500
export var MAX_SPEED = 85
export var FRICTION = 500
export var DASH_SPEED = 1.5


enum {
	MOVE,
	DASH,
	ATTACK,
}

var state = MOVE
var velocity = Vector2.ZERO
var dash_vector = Vector2.DOWN

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $HitBoxPivot/SwordHitBox

func _ready():
	animationTree.active = true
	swordHitbox.knockback_vector = dash_vector

# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
			
		DASH:
			dash_state(delta)
			
		ATTACK:
			attack_state(delta)
			
func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		dash_vector = input_vector
		swordHitbox.knockback_vector = input_vector
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Dash/dash_position", input_vector)
		animationState.travel("Run") # sets run animation state, made in animation tree
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move()
		
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
	if Input.is_action_just_pressed("dash"):
		state = DASH
	
func dash_state(delta):
	velocity = dash_vector * MAX_SPEED * DASH_SPEED
	animationState.travel("Dash")
	move()

func attack_state(delta):
	velocity = Vector2.ZERO
	animationState.travel("Attack")

func move():
	velocity = move_and_slide(velocity)

func dash_animation_finished():
	velocity = velocity * 0.8
	state = MOVE

func attack_animation_finished():
	state = MOVE
