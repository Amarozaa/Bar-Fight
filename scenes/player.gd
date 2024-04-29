
class_name Player
extends CharacterBody2D

signal picked(object)

var speed = 200
var jump_speed = 300
var gravity = 0
var acceleration = 300

@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
#@onready var input_synchronizer = $InputSynchronizer
@export var bullet_scene: PackedScene

@export var score = 1 :
	set(value):
		score = value
		Debug.log("Player %s score %d" % [name, score])
		
func _ready()-> void:
	picked.connect(_on_picked)
	

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		if not is_on_floor():
			velocity.y += gravity * delta
		var move_input = Input.get_axis("move_left", "move_right")
		velocity.x = move_toward(velocity.x, move_input * speed, acceleration * delta)
		var vertical_input = Input.get_axis("move_up", "move_down")
		velocity.y = move_toward(velocity.y, vertical_input * speed, acceleration * delta)
		send_data.rpc(global_position)
		move_and_slide()
		var mouse_position = get_global_mouse_position()
		look_at(mouse_position)
	
	
	


func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("click")
		if event.is_action_pressed("test"):
			test.rpc(Game.get_current_player().name)
			var bullet = bullet_scene.instantiate()
			# spawner will spawn a bullet on every simulated
			multiplayer_spawner.add_child(bullet, true)
			# triggers syncronizer
			score += 1
			

func setup(player_data: Statics.PlayerData):
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id)
	multiplayer_spawner.set_multiplayer_authority(player_data.id)
	multiplayer_synchronizer.set_multiplayer_authority(player_data.id)
	#input_synchronizer.set_multiplayer_authority(player_data.id)

@rpc("authority", "call_local", "reliable")
func test(name):
	var message = "test " + name
	var sender_id = multiplayer.get_remote_sender_id()
	var sender_player = Game.get_player(sender_id)
	Debug.log(message)
	Debug.log(sender_player.name)

#authority,call remote, relible

#authority: solo el con autoridad puede llamar.
#any_peer: cualquiera puede llamar.

#call_local: se llama en ambos
#call_remote: se llama solo en la otra.



#authority,call remote, relible

@rpc
func send_data(pos: Vector2):
	global_position = pos
#	global_position = lerp(global_position,pos,0)
#	velocity = lerp(velocity,vel,0.75)
func _on_picked(object: String):
		Debug.log(object)



func _on_punch_body_entered(body):
	if body.is_in_group("hit"):
		body.take_damage()
	else:
		pass # Replace with function body.
