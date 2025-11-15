extends Control

var pause_toggle = false

func _ready() -> void:
	self.visible = false
	# ✅ SET INI AGAR NODE INI TETAP PROSES INPUT MESKI GAME PAUSED
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	print("⏸️ Pause menu ready - Process mode: ALWAYS")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		print("🎹 ESC key pressed - Pause toggle:", !pause_toggle)
		pause_and_unpause()
		
func pause_and_unpause():
	pause_toggle = !pause_toggle
	get_tree().paused = pause_toggle
	self.visible = pause_toggle
	print("⏸️ Game paused:", get_tree().paused)

func _on_resume_pressed() -> void:
	pause_and_unpause()

func _on_restart_pressed() -> void:
	pause_and_unpause()
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().quit()
