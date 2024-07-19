extends CanvasLayer

@onready var health_bar = $MarginContainer/HealthBar

@onready var drunkess_bar = $MarginContainer2/DrunkessBar


func update_health(value):
    health_bar.value = value

func update_drunkness(value):
    drunkess_bar.value = value
