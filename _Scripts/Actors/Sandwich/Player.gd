#Attribution
#	Tutorial:	GDQuest; 3D Movement in Godot in Only 6 Minutes - https://youtu.be/UpF7wm0186Q; 
#				CC-By 4.0 - GDQuest and contributors - https://www.gdquest.com/
#				Note: The tutorial is outdated as of 4.0 and needed modifications

extends CharacterBody3D

@export var speed := 7.0
@export var jump_strength := 20.0
@export var gravity := 50.0
@export var sandwich_shuffle: AudioStream 
@export var jump: AudioStream
### THE LINE BELOW IS FROM THE TUTORIAL; MAY BE USEFUL TO REPLACE FOR GRAVITY LATER
## Get the gravity from the project settings to be synced with RigidBody nodes.
# var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var _snap_vector := Vector3.DOWN
var camera_offset := Vector3(0, 2.5, 0)

@onready var _spring_arm: SpringArm3D = $SpringArm
@onready var _model: Node3D = $ModelPivot/Model
@onready var animation= $ModelPivot/Model/AnimationPlayer
@onready var sound= $AudioStreamPlayer

func _physics_process(delta):
	var move_direction := Vector3.ZERO
	move_direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	move_direction.z = Input.get_action_strength("back") - Input.get_action_strength("forward")
	move_direction = move_direction.rotated(Vector3.UP, _spring_arm.rotation.y).normalized()
	
	velocity.x = move_direction.x * speed
	velocity.z = move_direction.z * speed
	velocity.y -= gravity * delta
	
	var just_landed := is_on_floor() and _snap_vector == Vector3.ZERO
	var is_jumping := is_on_floor() and Input.is_action_just_pressed("jump")
	if is_jumping:
		velocity.y = jump_strength
		_snap_vector = Vector3.ZERO
		animation.play("Jump")
		if sound.stream != jump:
			sound.stream = jump
		sound.play()
		
	elif just_landed:
		animation.stop()
		_snap_vector = Vector3.DOWN
	
	move_and_slide()
	
	if velocity.length() > 0.2:
		animation.play("Walk")
		var look_direction = Vector2(velocity.z, velocity.x)
		_model.rotation.y = look_direction.angle()
	

func _process(_delta):
	_spring_arm.position = position + camera_offset
	if(Input.is_action_pressed("back") or Input.is_action_pressed("forward") or 
	Input.is_action_pressed("left") or Input.is_action_pressed("right")):
		if (is_on_floor()):
			if sound.stream != sandwich_shuffle:
				sound.stream = sandwich_shuffle
			if sound.playing == false:
				sound.playing = true
	else:
		if (animation.current_animation == "Walk" && is_on_floor()):
			animation.stop()
		if sound.stream == sandwich_shuffle && sound.playing == true:
			sound.playing = false

	if(Input.is_action_just_pressed("escape")):
			get_tree().quit()
	
	if(Input.is_action_just_pressed("reset")):
		get_tree().reload_current_scene()
