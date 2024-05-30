extends Node2D


#var player_scene = preload("res://scenes/player.tscn")
@export var player_scene: PackedScene
@onready var players: Node2D = $Players

@onready var player_a = $SpawnPoints/PlayerA
@onready var player_b = $SpawnPoints/PlayerB

var offset = 0 



func _ready() -> void:
	for player_data in Game.players:
		var player = player_scene.instantiate()
		player.global_position = Vector2(120+offset,30)
		offset = offset + 200
		players.add_child(player)
		player.setup(player_data)
		
		player.PUNCHED.connect(_on_player_punched)
		
func _on_player_punched(player_id: int) -> void:
	punch_player.rpc_id(1, player_id)
	
@rpc("any_peer", "call_local")
func punch_player(player_id: int)-> void:
	for player in players.get_children():
		if player.get_multiplayer_authority() == player_id:
			player.take_damage2.rpc_id(player_id, 10)
		
