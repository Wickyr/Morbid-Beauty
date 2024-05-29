extends Area3D

@onready var cam_1 = $"../../Cams/Cam1"
@onready var cam_2 = $"../../Cams/Cam2"
@onready var collision_shape_3d_2 = $"../Cam1Trigger/CollisionShape3D2"
@onready var collision_shape_3d = $CollisionShape3D


func _on_body_entered(body):
	if "Player" in body.name:
		cam_1.current = true
		cam_2.current = false

