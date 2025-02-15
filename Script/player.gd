extends CharacterBody3D


@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@export var walkingspeed = 5.0
@export var sprint = 8.0
@export var crouchspeed = 3.0
@onready var stand = $Stand
@onready var crouch = $Crouch
@onready var check = $Check
var crouched : bool

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
	if Input.is_action_pressed("crouch"):
		SPEED = crouchspeed
		crouch.disabled = false
		stand.disabled = true
		crouch.visible = true
		stand.visible = false
		crouched = true
	elif !check.is_colliding():
		crouched = false
		if Input.is_action_pressed("sprint"):
			SPEED = sprint
		else:
			SPEED = walkingspeed
			crouch.disabled = true
			stand.disabled = false
			crouch.visible = false
			stand.visible = true
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("a", "d", "w", "s")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


