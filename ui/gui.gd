extends CanvasLayer

@onready var health_bar = $MarginContainer/HealthBar

func update_health(value):
	health_bar.value = value

	
