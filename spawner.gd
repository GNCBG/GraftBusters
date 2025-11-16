extends Node2D

# Scene musuh yang mau di-spawn
@export var enemy_scene: PackedScene = preload("res://scenes/enemy.tscn")

# Menyimpan enemy yang sedang hidup dari spawner ini
var current_enemy: Node2D = null


func _ready() -> void:
	# Pastikan Timer ada dan autostart
	if has_node("Timer"):
		$Timer.autostart = true
	else:
		push_warning("Spawner tidak punya child bernama 'Timer'!")


func _on_Timer_timeout() -> void:
	# Kalau enemy lama masih hidup, jangan spawn baru
	if is_instance_valid(current_enemy):
		return

	# Instance musuh baru
	var ene: Node2D = enemy_scene.instantiate()

	# Pastikan spawn tepat di posisi global Spawner
	ene.global_position = global_position

	# Simpan referensi supaya tahu kapan musuh mati
	current_enemy = ene

	# Masukkan ke parent langsung (misal: world)
	get_parent().add_child(ene)
