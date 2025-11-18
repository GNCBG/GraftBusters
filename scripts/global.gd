extends Node

var player_current_attack = false
var current_scene = "world"

# ✅ TAMBAHKAN VARIABEL UNTUK SURVIVAL TIME
var last_survival_time: float = 0.0
var formatted_survival_time: String = "00:00"
var high_score_time: float = 0.0
var high_score_formatted: String = "00:00"

# ✅ FUNCTION UNTUK SIMPAN HIGH SCORE
func save_high_score():
	if last_survival_time > high_score_time:
		high_score_time = last_survival_time
		high_score_formatted = formatted_survival_time
		print("🏆 NEW HIGH SCORE: ", high_score_formatted)

# ✅ FUNCTION UNTUK RESET DATA SETIAP GAME BARU
func reset_game_data():
	player_current_attack = false
	last_survival_time = 0.0
	formatted_survival_time = "00:00"
	# Jangan reset high_score_time, biar tetap tersimpan
