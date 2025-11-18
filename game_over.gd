extends Control

@onready var sfx_lol = $sfx_lol
var survival_label: Label
var high_score_label: Label

func _ready() -> void:
	print("🎮 Game Over Scene Loaded")
	
	# ✅ CEK DATA GLOBAL
	print("⏱️ Survival Time:", global.formatted_survival_time)
	print("🏆 High Score:", global.high_score_formatted)
	
	# ✅ BUAT LABEL JIKA TIDAK ADA
	create_labels()
	
	play_game_over_sound()

func create_labels():
	# Cari container/parent yang tepat
	var parent = $Panel  # Coba panel dulu
	if not parent:
		parent = $ColorRect  # Kalau tidak ada, coba ColorRect
	if not parent:
		parent = self  # Kalau masih tidak ada, pakai root
	
	# Buat Survival Time Label
	survival_label = Label.new()
	survival_label.name = "SurvivalTimeLabel"
	survival_label.text = "Waktu Bertahan: " + global.formatted_survival_time
	survival_label.position = Vector2(50, 80)
	survival_label.add_theme_font_size_override("font_size", 28)
	survival_label.modulate = Color.WHITE
	parent.add_child(survival_label)
	print("✅ Created SurvivalTimeLabel")
	
	# Buat High Score Label  
	high_score_label = Label.new()
	high_score_label.name = "HighScoreLabel"
	high_score_label.text = "High Score: " + global.high_score_formatted
	high_score_label.position = Vector2(50, 120)
	high_score_label.add_theme_font_size_override("font_size", 28)
	high_score_label.modulate = Color.GOLD
	parent.add_child(high_score_label)
	print("✅ Created HighScoreLabel")

func play_game_over_sound():
	if sfx_lol and sfx_lol.stream != null:
		sfx_lol.play()

func _on_retry_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
