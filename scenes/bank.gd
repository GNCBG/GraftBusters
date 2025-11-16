extends StaticBody2D

var enemy_inattack_range = false
var enemy_attack_cooldown = true
var health := 1000
var max_health := 1000
var bank_alive := true

const ANIM_FULL   = "bank_100"
const ANIM_75     = "bank_75"
const ANIM_50     = "bank_50"
const ANIM_25     = "bank_25"
const ANIM_BROKEN = "bank_0"

func _ready():
	update_bank_sprite()
	print("🏦 Bank spawned with health: ", health, "/", max_health)

func _physics_process(delta):
	enemy_attack()
	
	if health <= 0 and bank_alive:
		bank_alive = false
		health = 0
		print("💀 Bank has been destroyed! Final HP: ", health, "/", max_health)
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
		
		health = max(0, health - damage_taken)
		enemy_attack_cooldown = false
		$attackCooldownTimer.start()   # PASTIKAN nama Timer = attackCooldownTimer
		
		print("⚔️ BANK attacked!")
		print("   HP Before: ", previous_health)
		print("   Damage Taken: -", damage_taken)
		print("   HP After: ", health)
		
		var hp_percent := float(health) / float(max_health) * 100.0
		print("🚨 ALERT: HP BANK tersisa ", health, "/", max_health, " (", hp_percent, "% )")
		
		update_bank_sprite()
		
		# Flash merah sebentar
		$AnimatedSprite2D.modulate = Color(1, 0.3, 0.3)
		$demageFlashTimer.start()     # PASTIKAN nama Timer = demageFlashTimer

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

func destroy_bank():
	health = 0
	update_bank_sprite()
	
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
