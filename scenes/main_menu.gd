extends MarginContainer


@onready var main_menu = %MainMenu
@onready var controls_menu = %ControlsMenu
@onready var credits_menu = %CreditsMenu
@onready var start_button = %Start
@onready var controls_button = %Controls
@onready var credits_button = %Credits
@onready var exit_button = %Exit
@onready var controls_back: Button = %ControlsToMenu
@onready var credits_back: Button = %CreditsToMenu

# Called when the node enters the scene tree for the first time.
func _ready():
    
    start_button.pressed.connect(_on_start_pressed)
    controls_button.pressed.connect(_on_controls_pressed)
    credits_button.pressed.connect(_on_credits_pressed)
    exit_button.pressed.connect(_on_exit_pressed)
    
    controls_back.pressed.connect(_on_backtomenu_pressed)
    
    credits_back.pressed.connect(_on_backtomenu_pressed)
    
    show_main_menu()
    start_button.grab_focus()

func _on_start_pressed():
    get_tree().change_scene_to_file("res://scenes/lobby.tscn")

func _on_controls_pressed():
    main_menu.visible = false
    controls_menu.visible = true
    credits_menu.visible = false
    controls_back.grab_focus()

func _on_credits_pressed():
    main_menu.visible = false
    controls_menu.visible = false
    credits_menu.visible = true
    credits_back.grab_focus()

func _on_exit_pressed():
    get_tree().quit()

func _on_backtomenu_pressed():
    main_menu.visible = true
    controls_menu.visible = false
    credits_menu.visible = false
    start_button.grab_focus()

func show_main_menu():
    main_menu.visible = true
    controls_menu.visible = false
    credits_menu.visible = false


