class_name Player
extends CharacterBody2D

signal picked(object)
signal health_changed(value)
signal PUNCHED(player_id)
signal drunkness_changed(value)


var speed = 200
var jump_speed = 300
var gravity = 0
var acceleration = 300
var _score = 1

var top=50



@export var health = 100:
	set(value):
		health = value
		health_changed.emit(health)
var max_health = 100

@export var drunk = 0:
	set(value):
		drunk = value
		drunkness_changed.emit(drunk)
var max_drunk = 100

var min_drunk = 0

var increasing_blur = false
var virtual_blur = 0.0


@export var bullet_scene: PackedScene
@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var gui: CanvasLayer = $GUI
@onready var health_bar = $HealthBar #Barra de vida propia, solo sale si no somos auth
@onready var drunk_bar = $DrunkBar

@export var score = 1:
	set(value):
		_score = value
		Debug.log("Player %s score %d" % [name, _score])

func _ready() -> void:
	picked.connect(_on_picked)
	gui.update_health(health)
	gui.update_drunkness(drunk)
	#body_entered.connect(_on_punch_body_entered
	health_changed.connect(gui.update_health)
	health_changed.connect(_on_health_changed)
	
	drunkness_changed.connect(gui.update_drunkness)
	drunkness_changed.connect(_on_drunk_changed)
	#player.punched.connect(_on_player_punched)
	animated_sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))
	gui.hide()

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		if drunk > min_drunk:
			drunk -=0.1
		#var main = get_node("/root/Main")
		
		handle_movement(delta)
		
		if increasing_blur:
			#print("miau:3")
			var main = get_node("/root/Main")
			if main:
				var current_blur = main.get_blur()
				var target_blur = 1.0  # Valor máximo de blur deseado
				virtual_blur += 0.2 * delta
				virtual_blur = min(virtual_blur, target_blur)
				
				main.set_blur(virtual_blur)
				
				# Detener el aumento del blur cuando se alcanza el valor máximo
				if virtual_blur >= target_blur:
					increasing_blur = false
					virtual_blur = 0.0  # Restablecer el valor de virtual_blur
	
	update_animation()

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
		handle_shooting.rpc()
	else:
		disable_shotting.rpc()
	
	if event.is_action_pressed("test"):
		handle_test_action()
	if event.is_action_pressed("drunk_test"):
		drunk +=10
	if event.is_action_pressed("ui_select"):
		var main = get_node("/root/Main")
		if main:
			print("pasamos a main")
			increasing_blur = true
			#for i in range(250):
			#	virtual_blur = virtual_blur + 0.01
			#	main.set_blur(virtual_blur)  # Cambia el valor de blur a 4.0
	

func update_mouse_position(mouse_position: Vector2) -> void:
	apuntar.rpc(mouse_position)
	
	
@rpc("call_local")
func handle_shooting() -> void:
	$Punch/CollissionPunch.disabled = false
	animated_sprite.play("punch")
	print("click")
@rpc("call_local")
func disable_shotting()->void:
	$Punch/CollissionPunch.disabled = true


func handle_test_action() -> void:
	#health -=10
	for player in Game.players:
		if player.id != multiplayer.get_unique_id():
			PUNCHED.emit(player.id)
	#test.rpc(Game.get_current_player().name)
	#var bullet = bullet_scene.instantiate()
	#multiplayer_spawner.add_child(bullet, true)
	score += 1
	



func setup(player_data: Statics.PlayerData):
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id)
	multiplayer_spawner.set_multiplayer_authority(player_data.id)
	multiplayer_synchronizer.set_multiplayer_authority(player_data.id)
	
	if multiplayer.get_unique_id() == player_data.id:
		gui.show()
	health_bar.visible = multiplayer.get_unique_id() != player_data.id
	drunk_bar.visible = multiplayer.get_unique_id() != player_data.id

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
	drunk +=10
	Debug.log(object)

#señal
func _on_punch_body_entered(body): 
	if body.is_in_group("HIT") and is_multiplayer_authority():
		Debug.log("SEÑAL")
		body.take_damage()
		handle_test_action()

func update_animation() -> void:
	if animated_sprite.animation == "punch" and animated_sprite.is_playing():
		return 
	if velocity.x != 0 or velocity.y != 0:
		animated_sprite.play("walk")
	else:
		animated_sprite.play("idle")

func _on_animation_finished(animation_name: String) -> void:
	if animation_name == "punch":
		update_animation()  

func _on_health_changed(new_health) -> void:
	health_bar.value = new_health
	if (health_bar.value == 0):
		print("waos")
	
		switch_game_over.rpc()
		#falta aqui detectar quien gano,y darle un feedback en la cuestion.


func take_damage():
	Debug.log("DAÑO_TOMADO")
	

@rpc("call_local")
func switch_game_over() -> void:
	var pscene = load("res://GAME_OVER.tscn")
	get_tree().change_scene_to_packed(pscene)


@rpc("any_peer", "call_local")
func take_damage2(damage) -> void:
	health -= damage
	
func _on_drunk_changed(new_drunk) -> void:
	drunk_bar.value = new_drunk
	
	
	
	


	
#authority,call remote, relible
#authority: solo el con autoridad puede llamar.

#any_peer: cualquiera puede llamar.
#call_local: se llama en ambos
#call_remote: se llama solo en la otra.
#authority,call remote, relible

		

