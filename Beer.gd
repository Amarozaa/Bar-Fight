extends Area2D

@onready var label = $Label
@onready var glup= $glupi


var is_pickeable = false
var player: Player
var _PLAYER

# Called when the node enters the scene tree for the first time.
#func _ready():
    #pass # Replace with function body.
func _ready() -> void:
        body_entered.connect(_on_body_entered)
        body_exited.connect(_on_body_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
    #pass
    
func _input(event: InputEvent) -> void:
    if event.is_action_pressed("pickup") and is_pickeable:
        if player.is_multiplayer_authority():
            player.picked.emit(name) 
            picked.rpc()
    
        #var sender_id = multiplayer.get_remote_sender_id()
        #var sender_player = Game.get_player(sender_id)
    
        #Debug.log(sender_player.name)
        
func _on_body_entered(body: Node2D):
    player = body 
    label.show()
    is_pickeable = true
    
func _on_body_exited(body: Node2D):
    player = null
    label.hide()
    is_pickeable = false
    
@rpc("any_peer","call_local") #call_local se llama en ambos
func picked():
    queue_free()
    



