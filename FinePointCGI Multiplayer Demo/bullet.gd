extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var direction : Vector2

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _ready():
	direction = Vector2(1, 0).rotated(rotation)


func _physics_process(delta):
	# Add the gravity.
	
	velocity = SPEED * direction
	
	if not is_on_floor():
		velocity.y += gravity * delta

	

	move_and_slide()
