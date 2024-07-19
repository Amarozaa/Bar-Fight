extends Node2D


#var player_scene = preload("res://scenes/player.tscn")
@export var player_scene: PackedScene
@onready var players: Node2D = $Players

@onready var player_a = $SpawnPoints/PlayerA
@onready var player_b = $SpawnPoints/PlayerB

@onready var item_a = $SpawnPoints/ItemA
@onready var item_b = $SpawnPoints/ItemB
@onready var item_c = $SpawnPoints/ItemC
@onready var item_d = $SpawnPoints/ItemD
@onready var item_e = $SpawnPoints/ItemE







var offset = 0 

var items_offset = 0

var beer_counter = 10



var shader_material: ShaderMaterial
var distorsion_mat: ShaderMaterial
@onready var texture_rect = $CanvasLayer/TextureRect #blur
@onready var texture_dist = $DISTORSION/TextureRect  #distorsion


var objeto_scene = preload("res://beer.tscn")
var wine_text = preload("res://Assets/NewWine.png")

var ArrItem = [1, 1, 1, 1] #A, B, C ,D  



func hay_nodo_en_posicion(node: Node2D) -> bool:
    # Recorremos todos los hijos del nodo padre (en este caso, el nodo al que se adjunta el script)
    return node.get_child_count() > 0 




func _ready() -> void:
    Game.players.sort_custom(func(a,b): return a.id < b.id)
    for player_data in Game.players:
        
        var player = player_scene.instantiate()
        #player.global_position = Vector2(120+offset,30)
        if (offset == 0):
            player.global_position = player_a.global_position
        else:
            player.global_position = player_b.global_position
        
        shader_material = texture_rect.material
        distorsion_mat = texture_dist.material
        if shader_material is ShaderMaterial:
            print("Shader encontrado")
        if distorsion_mat is ShaderMaterial:
            print("Distorsion encontrada ")
        offset = offset + 200
        set_blur(0)
        set_inte(0)
        players.add_child(player)
        player.setup(player_data)
        
        #player.PUNCHED.connect(_on_player_punched)
        #'''
    
    
    
    var rev_pos= Vector2(443,542)
    #inicializamos los objetos
    for posicion_name in [item_a, item_b, item_c, item_d]:
        spawn_beer(posicion_name)
    
    spawn_wine(item_e)
    
    #spawn_beer(item_a)
    #spawn_beers()
            
func spawn_beer(parent: Node2D)  -> void:
        var iniobj = objeto_scene.instantiate()
        #iniobj.position = posicion_name.position
        #beer_counter += 1
        #iniobj.name = "Beer%d" % beer_counter
        #add_child(iniobj)
        if not parent.get_tree():
            return 
        parent.add_child(iniobj, true)
        await iniobj.tree_exited
        if not get_tree():
            return
        await get_tree().create_timer(5.0).timeout
        spawn_beer(parent)

func spawn_wine(parent: Node2D) -> void:
    var iniobj = objeto_scene.instantiate()
    var sprite_node = iniobj.get_node("Sprite2D")
    sprite_node.texture = wine_text
    iniobj.name = "Wine1"  # Asignar el nombre al nodo
    #si es que se quieren spawnear multiples vinos a la vez, hay que hacer un 
    #contador, para que el nombre de cada vino sea unico.

    if not parent.get_tree():
        return 
    parent.add_child(iniobj, true)
    await iniobj.tree_exited
    if not get_tree():
        return
    await get_tree().create_timer(5.0).timeout
    spawn_wine(parent)

        
    
        
func spawn_beers() -> void:
    while true:
        await get_tree().create_timer(5.0).timeout
        if (!hay_nodo_en_posicion(item_a)):
            
            var objeto_instance = objeto_scene.instantiate()
            #objeto_instance.position = item_a.position
            beer_counter += 1
            objeto_instance.name = "Beer%d" % beer_counter
            item_a.add_child(objeto_instance)
            Debug.log('objeto añadido: %s' % objeto_instance.name)
    

func set_blur(value: float):
    if shader_material:
        shader_material.set_shader_parameter("blur",value)
        
func get_blur() -> float:
    if shader_material:
        return shader_material.get_shader_parameter("blur")
    return 0.0
    
func set_inte(value: float):
    if distorsion_mat:
        distorsion_mat.set_shader_parameter("intensity",value)

func get_inte() -> float:
    if distorsion_mat:
        return distorsion_mat.get_shader_parameter("intensity")
    return 0.0
    


    

        
