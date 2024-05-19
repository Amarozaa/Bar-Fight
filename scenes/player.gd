class_name Player
extends CharacterBody2D

signal picked(object)

var speed = 200
var jump_speed = 300
var gravity = 0
var acceleration = 300
var _score = 1

@export var bullet_scene: PackedScene
@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer

@export var score = 1:
	set(value):
		_score = value
		Debug.log("Player %s score %d" % [name, _score])

func _ready() -> void:
	picked.connect(_on_picked)

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		handle_movement(delta)

func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		handle_input(event)

func handle_movement(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	var move_input = Input.get_axis("move_left", "move_right")
	velocity.x = move_toward(velocity.x, move_input * speed, acceleration * delta)
	var vertical_input = Input.get_axis("move_up", "move_down")
	velocity.y = move_toward(velocity.y, vertical_input * speed, acceleration * delta)
	send_data.rpc(global_position)
	move_and_slide()

func handle_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		update_mouse_position(event.position)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		handle_shooting()
	if event.is_action_pressed("test"):
		handle_test_action()

func update_mouse_position(mouse_position: Vector2) -> void:
	apuntar.rpc(mouse_position)

func handle_shooting() -> void:
	print("click")

func handle_test_action() -> void:
	test.rpc(Game.get_current_player().name)
	var bullet = bullet_scene.instantiate()
	multiplayer_spawner.add_child(bullet, true)
	score += 1

func setup(player_data: Statics.PlayerData):
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id)
	multiplayer_spawner.set_multiplayer_authority(player_data.id)
	multiplayer_synchronizer.set_multiplayer_authority(player_data.id)

@rpc("authority", "call_local", "reliable")
func test(name):
	var message = "test " + name
	var sender_id = multiplayer.get_remote_sender_id()
	var sender_player = Game.get_player(sender_id)
	Debug.log(message)
	Debug.log(sender_player.name)

@rpc
func send_data(pos: Vector2):
	global_position = pos

@rpc("call_local")
func apuntar(mouse_position: Vector2) -> void:
	look_at(mouse_position)

func _on_picked(object: String):
	Debug.log(object)

func _on_punch_body_entered(body):
	if body.is_in_group("hit"):
		body.take_damage()
