extends Control

@onready var main_buttons: VBoxContainer = $MainButtons

@onready var sfx_intro = $sfx_intro

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sfx_intro.play()
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass	

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/world.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()
