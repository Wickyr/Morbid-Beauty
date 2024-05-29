extends CharacterBody3D
enum States{
	patrol,
	chasing,
	hunting,
	waiting
}

var currentState : States
var navAgent : NavigationAgent3D
@export var waypoints : Array
var waypointIndex : int
@export var patrolspeed = 2
@export var chasespeed = 3
@onready var patrol_timer = $PatrolTimer
var player

var PlayerEarShotFar : bool
var PlayerEarShotClose : bool
var PlayerSightFar : bool
var PlayerSightClose : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	navAgent = $NavigationAgent3D
	currentState = States.patrol
	waypoints = get_tree().get_nodes_in_group("EnemyWaypoint")
	navAgent.set_target_position(waypoints[0].global_position)
	player = get_tree().get_nodes_in_group("Player")[0]



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match currentState:
		States.patrol:
			if(navAgent.is_navigation_finished()):
				currentState = States.waiting
				patrol_timer.start()
				return
			MoveTowardPoint(delta, patrolspeed)
			pass
		States.chasing:
			if(navAgent.is_navigation_finished()):
				patrol_timer.start()
				currentState = States.waiting
			navAgent.set_target_position(player.global_position)
			MoveTowardPoint(delta, chasespeed)
			pass
		States.hunting:
			if(navAgent.is_navigation_finished()):
				patrol_timer.start()
				currentState = States.waiting
			MoveTowardPoint(delta, patrolspeed)
			pass
		States.waiting:
			pass

func MoveTowardPoint(delta, speed):
	var targetPos = navAgent.get_next_path_position()
	var direction = global_position.direction_to(targetPos)
	faceDirection(targetPos)
	velocity = direction * speed
	move_and_slide()
	if(PlayerEarShotFar):
		CheckForPlayer()

func CheckForPlayer():
	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create($Head.global_position, get_tree().get_nodes_in_group("Player")[0].global_position, 1, [self]))
	if result.size() > 0:
		if(result["collider"].is_in_group("Player")):
			if(PlayerEarShotClose):
				if(result["collider"].crouched == false):
					currentState = States.chasing
			if(PlayerEarShotFar):
				if(result["collider"].crouched == false):
					currentState = States.hunting
					navAgent.set_target_position(player.global_position)
			if(PlayerSightClose):
				currentState = States.chasing
			if(PlayerSightFar):
				if(result["collider"].crouched == false):
					currentState = States.hunting
					navAgent.set_target_position(player.global_position)

func faceDirection(direction : Vector3):
	look_at(Vector3(direction.x, global_position.y, direction.z), Vector3.UP)

func _on_patrol_timer_timeout():
	currentState = States.patrol
	waypointIndex += 1
	if waypointIndex > waypoints.size() - 1:
		waypointIndex = 0
	navAgent.set_target_position(waypoints[waypointIndex].global_position)


func _on_hearing_far_body_entered(body):
	if body.is_in_group("Player"):
		PlayerEarShotFar = true
		print("Player Far")

func _on_hearing_far_body_exited(body):
	if body.is_in_group("Player"):
		PlayerEarShotFar = false
		print("Player Left Far")

func _on_hearingclose_body_entered(body):
	if body.is_in_group("Player"):
		PlayerEarShotClose = true
		print("Player CLose")

func _on_hearingclose_body_exited(body):
	if body.is_in_group("Player"):
		PlayerEarShotClose = false
		print("Player Left CLose")

func _on_sightfar_body_entered(body):
	if body.is_in_group("Player"):
		PlayerSightFar = true
		print("Player Far Sight")


func _on_sightfar_body_exited(body):
	if body.is_in_group("Player"):
		PlayerSightFar = false
		print("Player Left Far Sight")

func _on_sight_close_body_entered(body):
	if body.is_in_group("Player"):
		PlayerSightClose = true
		print("Player CLose Sight")


func _on_sight_close_body_exited(body):
	if body.is_in_group("Player"):
		PlayerSightClose = false
		print("Player Left CLose Sight")

