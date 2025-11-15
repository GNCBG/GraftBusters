extends StaticBody2D

var enemy_inattack_range = false
var enemy_attack_cooldown = true
var health = 1000
var max_health = 1000
var house_alive = true

var original_brightness = 1.0

func _ready():
	$AnimatedSprite2D.play("idle")
	
	# Simpan alpha awal sprite agar tidak ikut berubah
	original_brightness = $AnimatedSprite2D.modulate.a
	
	# Set brightness awal berdasarkan HP penuh
	update_brightness()
	print("🏠 House spawned with health: ", health, "/", max_health)

func _physics_process(delta):
	enemy_attack()
	
	if health <= 0 and house_alive:
		house_alive = false
		health = 0
		print("💀 House has been destroyed! Final HP: ", health, "/", max_health)
		destroy_house()

# === SIGNAL DARI Area2D (misal: attackRange / house_hitbox) ===
func _on_attackRange_body_entered(body):
	if body.has_method("enemy"):
		enemy_inattack_range = true
		print("🎯 Enemy detected near house!")

func _on_attackRange_body_exited(body):
	if body.has_method("enemy"):
		enemy_inattack_range = false
		print("⬅️ Enemy left house area")

# === LOGIKA DISERANG MUSUH ===
func enemy_attack():
	if enemy_inattack_range and enemy_attack_cooldown == true and house_alive:
		var damage_taken = 20
		var previous_health = health
		
		health = max(0, health - damage_taken)
		enemy_attack_cooldown = false
		$attackCooldownTimer.start()
		
		# OUTPUT DETAIL DAMAGE + ALERT SISA HP
		print("⚔️ House attacked!")
		print("   HP Before: ", previous_health)
		print("   Damage Taken: -", damage_taken)
		print("   HP After: ", health)
		
		var hp_percent = float(health) / float(max_health) * 100.0
		print("🚨 ALERT: HP House tersisa ", health, "/", max_health, " (", hp_percent, "% )")
		
		# Update brightness sesuai HP
		update_brightness()
		
		# Efek flash merah sebentar
		$AnimatedSprite2D.modulate = Color.RED
		$demageFlashTimer.start()

# === BRIGHTNESS BERDASARKAN HP ===
func update_brightness():
	# Kalau house sudah mati, brightness di-handle di destroy_house()
	if not house_alive:
		return
	
	var health_percentage = clamp(float(health) / float(max_health), 0.0, 1.0)
	var brightness = health_percentage  # 1.0 = cerah, 0.0 = gelap
	
	# Grayscale sesuai HP (alpha tetap sama)
	$AnimatedSprite2D.modulate = Color(brightness, brightness, brightness, original_brightness)

# === SIGNAL TIMER ATTACK COOLDOWN ===
func _on_attackCooldownTimer_timeout():
	enemy_attack_cooldown = true
	print("🔄 House attack cooldown reset")

# === SIGNAL TIMER FLASH MERAH ===
func _on_demageFlashTimer_timeout():
	if house_alive:
		# Balik ke brightness sesuai HP setelah flash merah
		update_brightness()
		print("🎨 House color returned to HP-based brightness")

# === PROSES HANCUR ===
func destroy_house():
	# Brightness 0 total
	$AnimatedSprite2D.modulate = Color(0, 0, 0, original_brightness)
	
	# Kalau ada animasi kehancuran
	if $AnimatedSprite2D.sprite_frames.has_animation("destroyed"):
		$AnimatedSprite2D.play("destroyed")
		print("🔥 Playing destroyed animation")
	
	# Matikan collision supaya nggak ke-hit lagi
	$CollisionShape2D.set_deferred("disabled", true)
	print("🚫 House collision disabled")
	
	# Hapus house setelah 2 detik
	$destroyTimer.start()
	print("⏰ House will be removed in 2 seconds...")

# === SIGNAL TIMER DESTROY ===
func _on_destroyTimer_timeout():
	print("🗑️ House removed from game!")
	queue_free()

# Dipakai enemy.gd untuk cek has_method("house")
func house():
	pass
