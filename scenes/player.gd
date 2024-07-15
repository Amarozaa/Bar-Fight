class_name Player
extends CharacterBody2D

# Signals
signal picked(object)
signal health_changed(value)
signal PUNCHED(player_id)
signal drunkness_changed(value)
signal attack_changed(value)

# Variables
var speed = 200
var jump_speed = 300
var gravity = 0
var acceleration = 300
var _score = 1
var top = 50

var max_health = 100
var min_drunk = 0
var max_drunk = 100
var increasing_blur = false
var increasing_dist = false
var decreasing_dist = false
var virtual_blur = 0.0

var virtual_dist = 0.000001

var punch_cooldown = false







@export var attack = 10:
    set(value):
        attack = value
        attack_changed.emit(attack)
# Exported Variables with setters
@export var health = 100:
    set(value):
        health = value
        health_changed.emit(health)

@export var drunk = 0:
    set(value):
        drunk = value
        drunkness_changed.emit(drunk)

@export var score = 1:
    set(value):
        _score = value
        Debug.log("Player %s score %d" % [name, _score])
        


@export var bullet_scene: PackedScene

# Onready Variables
@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var gui: CanvasLayer = $GUI
@onready var health_bar = $HealthBar # Barra de vida propia, solo sale si no somos auth
@onready var drunk_bar = $DrunkBar

@onready var animated_sprite_2d = $AnimatedSprite2D

var bandera = true

# Functions
func _ready() -> void:
    #señal conecta con metodo
    punch_cooldown = false
    picked.connect(_on_picked)
    gui.update_health(health)
    gui.update_drunkness(drunk)
    health_changed.connect(gui.update_health)
    health_changed.connect(_on_health_changed)
    
    attack_changed.connect(_on_atack_changed)
    
    drunkness_changed.connect(gui.update_drunkness)
    drunkness_changed.connect(_on_drunk_changed)
    animated_sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))
    gui.hide()

func _physics_process(delta: float) -> void:
    if is_multiplayer_authority():
        if drunk > min_drunk:
            if drunk > 100:
                print('pasaste el maximo, castigado')
                health -= 20
                drunk = 100
            
            #reglas de proporciones:
            # si barra drunk en 20%, distorsion deberia estar en 0.1
            # si esta en 40%, --- en 0.2
            # 100% --- 0.5
            
            
        
            var decremento_drunk = 0.03 #velocidad ala que aumenta e
            drunk -= decremento_drunk
            #gatito se calcula como la distorsion 
            var gatito = 0.005 * drunk
            var main = get_node("/root/Main")
            if not main:
                return
            #ojo que aqui hay un error cuando se muere el personaje al haber tomado una cuestion.
            main.set_inte(gatito)
            
            #proporcion a la cual debemos de disminuir gaitto 
            var proporcion = 0.0005 / decremento_drunk
            var decremento_gatito = proporcion * decremento_drunk
            if bandera:
                print(decremento_gatito)
                bandera = false
            gatito -= decremento_gatito
            #gatito -=  0.0005
            
            if drunk <= 0:
                print('fin')
             
                print(main.get_inte())
                #en caso de que quede negativo lo dejamos en 0 como deberia :3
                main.set_inte(0)
                print(main.get_inte())
                
            
            
            
        
        handle_movement(delta)
        
        if increasing_dist:
            var main = get_node("/root/Main")
            if main:
                print('disminuyendo  int')
                var current_dist = main.get_inte()
                
                print(current_dist)

                
                #increasing_dist = false
                var target_dist = 0.1
                virtual_dist -=  0.01 * delta
                virtual_dist = max(virtual_dist, 0.0) #el max deberia de ser..

                main.set_inte(virtual_dist)

                if virtual_dist <= 0.0:
                    increasing_dist = false
                    print(main.get_inte())
                    print('dejamos de disminuir int')
                    virtual_dist = target_dist

        if increasing_blur:
            var main = get_node("/root/Main")
            if main:
                var current_blur = main.get_blur()
                var target_blur = 1.0  # Valor máximo de blur deseado
                virtual_blur += 0.2 * delta
                virtual_blur = min(virtual_blur, target_blur)
                
                main.set_blur(virtual_blur)
                
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
        disable_shooting.rpc()
    
    if event.is_action_pressed("test"):
        handle_test_action()
    if event.is_action_pressed("drunk_test"):
        drunk += 100
    if event.is_action_pressed("ui_select"):
        var main = get_node("/root/Main")
        if main:
            print("pasamos a main")
            attack += 10
            #main.set_inte(0.1)
            #increasing_blur = true
            #animated_sprite_2d.set_shader_parameter("param_name", 0.0)
            

            
            increasing_dist = true

func update_mouse_position(mouse_position: Vector2) -> void:
    apuntar.rpc(mouse_position)

@rpc("call_local")
func handle_shooting() -> void:
    if punch_cooldown:
        return
    $Punch/CollissionPunch.disabled = false
    animated_sprite.play("punch")
    print("click")
    punch_cooldown = true
    start_punch_cooldown_timer()
    
func start_punch_cooldown_timer() -> void:
    
    await get_tree().create_timer(3.0).timeout
    #podriamos ponerle algo visual cuando esta esperando, para que se note que esta en cooldown
    Debug.log('ya puedes atacar')
    
    punch_cooldown = false

@rpc("call_local")
func disable_shooting() -> void:
    $Punch/CollissionPunch.disabled = true

func handle_test_action() -> void:
    for player in Game.players:
        if player.id != multiplayer.get_unique_id():
            PUNCHED.emit(player.id)
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
    drunk += 20
    
    Debug.log(object)
    var four_first = object.substr(0, 4)
    print('los 4 letras son: ' + four_first)
    
    
    if four_first == "Beer":
        attack += 5
        if attack == 15: #el primer buff
            change_red_buff.rpc()
        
        start_attack_timer()
        
    if four_first == 'Wine':
        health += 10 
        
    Debug.log(attack)

    
@rpc("call_local")
func change_red_buff() -> void:
    var is_buf_red = $AnimatedSprite2D.get_use_parent_material()
    var inverted_buf_red = !is_buf_red
    $AnimatedSprite2D.set_use_parent_material(inverted_buf_red)
    #var n1 =  $AnimatedSprite2D.get_material()
    
    #print(n1)
    #var shh = load(res://scenes/glowred.gdshader)
    #$AnimatedSprite2D.set_material(shh)
    #que revise si tiene un material
    #si no tiene, que se le annnada, y si tiene que se le ponga nulo
    
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

@rpc("call_local")
func walking() -> void:
    animated_sprite.play("walk")
    

func _on_animation_finished(animation_name: String) -> void:
    if animation_name == "punch":
        update_animation()

func _on_health_changed(new_health) -> void:
    health_bar.value = new_health
    if health_bar.value == 0:
        print("waos")
        switch_game_over.rpc()

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
    
func _on_atack_changed(new_attack) -> void:
    #attack = new_attack
    Debug.log(new_attack)
    
func start_attack_timer() -> void:
    await get_tree().create_timer(10.0).timeout
    Debug.log("10 segundos pasados, buffo terminado")
    attack -= 5
    if attack == 10:
        change_red_buff.rpc()
    
    



#authority,call remote, relible
#authority: solo el con autoridad puede llamar.

#any_peer: cualquiera puede llamar.
#call_local: se llama en ambos
#call_remote: se llama solo en la otra.
#authority,call remote, relible
