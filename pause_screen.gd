extends CanvasLayer



var _player
@onready var player_name = %PlayerName
@onready var panel_container = $PanelContainer


func _ready() -> void:
    hide()

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("pause"):
        if not _player:
            pause.rpc(multiplayer.get_unique_id())
        elif _player.id == multiplayer.get_unique_id():
            unpause.rpc()
        
@rpc("any_peer", "call_local")
func pause(player_id) -> void:
    _player = Game.get_player(player_id)
    get_tree().paused = true
    player_name.text = _player.name
    if(_player.id == multiplayer.get_unique_id()):
        panel_container.self_modulate = Color.GREEN
        print("hola")
    else:
        panel_container.self_modulate = Color.BLUE
        print("chao")
    show()
    
@rpc("any_peer", "call_local")
func unpause() -> void:
    _player = null
    get_tree().paused = false
    hide()
