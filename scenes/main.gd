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
		player.global_position = Vector2(62+offset,30)
		offset = offset + 30 
		players.add_child(player)
		player.setup(player_data)
		
