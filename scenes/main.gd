extends Node2D


#var player_scene = preload("res://scenes/player.tscn")
@export var player_scene: PackedScene
@onready var players: Node2D = $Players

@onready var player_a = $SpawnPoints/PlayerA
@onready var player_b = $SpawnPoints/PlayerB

var offset = 0 


var shader_material: ShaderMaterial
@onready var texture_rect = $CanvasLayer/TextureRect





func _ready() -> void:
	Game.players.sort_custom(func(a,b): return a.id < b.id)
	for player_data in Game.players:
		var player = player_scene.instantiate()
		player.global_position = Vector2(120+offset,30)
		shader_material = texture_rect.material
		if shader_material is ShaderMaterial:
			print("Shader encontrado")
		offset = offset + 200
		set_blur(0)
		players.add_child(player)
		player.setup(player_data)
		
		player.PUNCHED.connect(_on_player_punched)
		
func set_blur(value: float):
	if shader_material:
		shader_material.set_shader_parameter("blur",value)
		
func get_blur() -> float:
	if shader_material:
		return shader_material.get_shader_parameter("blur")
	return 0.0
	
func _on_player_punched(player_id: int) -> void:
	punch_player.rpc_id(1, player_id)
	
var attacker_dmg	
@rpc("any_peer", "call_local")
func punch_player(player_id: int)-> void:
	for player in players.get_children():
		#if player.get_multiplayer_authority() != player_id:
			#attacker_dmg = player.attack
		if player.get_multiplayer_authority() == player_id:
			for w in players.get_children():
				if w.get_multiplayer_authority() != player_id:
					attacker_dmg = w.attack
			
		
			player.take_damage2.rpc_id(player_id, attacker_dmg)
		
