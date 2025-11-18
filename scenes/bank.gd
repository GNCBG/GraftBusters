extends StaticBody2D

@onready var sfx_hit = $sfx_hit
@onready var sfx_hancur = $sfx_hancur
@onready var sfx_lol = $sfx_lol

var enemy_inattack_range = false
var enemy_attack_cooldown = true
var health := 1000
var max_health := 1000
var bank_alive := true

# ✅ VARIABEL TIMER BERTAHAN
var survival_time: float = 0.0
var survival_timer_running: bool = true

const ANIM_FULL   = "bank_100"
const ANIM_75     = "bank_75"
const ANIM_50     = "bank_50"
const ANIM_25     = "bank_25"
const ANIM_BROKEN = "bank_0"

func _ready():
	update_bank_sprite()
	
	# ✅ RESET DATA DI GLOBAL SETIAP GAME BARU
	global.reset_game_data()
	start_survival_timer()
	
	print("🏦 Bank spawned with health: ", health, "/", max_health)

func _physics_process(delta):
	enemy_attack()
	
	# ✅ UPDATE TIMER BERTAHAN SETIAP FRAME
	if survival_timer_running and bank_alive:
		survival_time += delta
	
	if health <= 0 and bank_alive:
		bank_alive = false
		health = 0
		survival_timer_running = false  # ✅ STOP TIMER
		print("💀 Bank has been destroyed! Final HP: ", health, "/", max_health)
		print("⏱️ Survival time: ", format_time(survival_time))
		destroy_bank()

# ==== DETEKSI ENEMY MASUK / KELUAR AREA SERANG BANK ====
func _on_attackRange_body_entered(body):
	if body.has_method("enemy"):
		enemy_inattack_range = true
		print("🎯 Enemy detected near BANK!")

func _on_attackRange_body_exited(body):
	if body.has_method("enemy"):
		enemy_inattack_range = false
		print("⬅️ Enemy left BANK area")

# ==== LOGIKA BANK DISERANG MUSUH ====
func enemy_attack():
	if enemy_inattack_range and enemy_attack_cooldown and bank_alive:
		var damage_taken := 20
		var previous_health := health
		
		sfx_hit.play()
		
		health = max(0, health - damage_taken)
		enemy_attack_cooldown = false
		$attackCooldownTimer.start()
		
		print("⚔️ BANK attacked!")
		print("   HP Before: ", previous_health)
		print("   Damage Taken: -", damage_taken)
		print("   HP After: ", health)
		
		var hp_percent := float(health) / float(max_health) * 100.0
		print("🚨 ALERT: HP BANK tersisa ", health, "/", max_health, " (", hp_percent, "% )")
		
		update_bank_sprite()
		
		# Flash merah sebentar
		$AnimatedSprite2D.modulate = Color(1, 0.3, 0.3)
		$demageFlashTimer.start()

# ==== GANTI ANIMASI BERDASARKAN HP BANK ====
func update_bank_sprite():
	var percent := float(health) / float(max_health)
	var anim_name := ANIM_FULL

	if percent >= 1.00:
		anim_name = ANIM_FULL
	elif percent >= 0.75:
		anim_name = ANIM_75
	elif percent >= 0.50:
		anim_name = ANIM_50
	elif percent > 0.0:
		anim_name = ANIM_25
	else:
		anim_name = ANIM_BROKEN

	if $AnimatedSprite2D.sprite_frames.has_animation(anim_name):
		$AnimatedSprite2D.play(anim_name)
	else:
		print("⚠️ WARNING: animation", anim_name, "tidak ditemukan di AnimatedSprite2D")

	print("🏦 Bank sprite updated → animation:", anim_name, " (", int(percent * 100), "% )")

# ==== TIMER-TIMER BANK ====
func _on_attackCooldownTimer_timeout():
	enemy_attack_cooldown = true
	print("🔄 Bank attack cooldown reset")

func _on_demageFlashTimer_timeout():
	if bank_alive:
		$AnimatedSprite2D.modulate = Color(1, 1, 1)

# ✅ FUNCTION START SURVIVAL TIMER
func start_survival_timer():
	survival_time = 0.0
	survival_timer_running = true
	print("⏱️ Survival timer started!")

# ✅ FUNCTION FORMAT WAKTU (detik -> menit:detik)
func format_time(time_in_seconds: float) -> String:
	var minutes = int(time_in_seconds) / 60
	var seconds = int(time_in_seconds) % 60
	return "%02d:%02d" % [minutes, seconds]

func destroy_bank():
	health = 0
	update_bank_sprite()
	sfx_hancur.play()
	
	# ✅ SIMPAN SURVIVAL TIME KE GLOBAL
	global.last_survival_time = survival_time
	global.formatted_survival_time = format_time(survival_time)
	
	# ✅ SIMPAN HIGH SCORE
	global.save_high_score()
	
	get_tree().change_scene_to_file("res://game_over.tscn")
	
	$CollisionShape2D.set_deferred("disabled", true)
	print("🚫 Bank collision disabled")
	
	$destroyTimer.start()
	print("⏰ Bank will be removed in 2 seconds...")

func _on_destroyTimer_timeout():
	print("🗑️ Bank removed from game!")
	queue_free()

# Dipakai enemy.gd untuk cek has_method("bank")
func bank():
	pass
