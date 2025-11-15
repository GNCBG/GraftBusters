extends StaticBody2D

var enemy_inattack_range = false
var enemy_attack_cooldown = true
var health = 1000
var max_health = 1000
var bank_alive = true

var original_brightness = 1.0

func _ready():
	$AnimatedSprite2D.play("idle")
	original_brightness = $AnimatedSprite2D.modulate.a
	update_brightness()
	print("🏦 Bank spawned with health: ", health, "/", max_health)

func _physics_process(delta):
	enemy_attack()
	
	if health <= 0 and bank_alive:
		bank_alive = false
		health = 0
		print("💀 Bank has been destroyed! Final HP: ", health, "/", max_health)
		destroy_bank()

func _on_attackRange_body_entered(body):
	if body.has_method("enemy"):
		enemy_inattack_range = true
		print("🎯 Enemy detected near bank!")

func _on_attackRange_body_exited(body):
	if body.has_method("enemy"):
		enemy_inattack_range = false
		print("⬅️ Enemy left bank area")

func enemy_attack():
	if enemy_inattack_range and enemy_attack_cooldown == true and bank_alive:
		var damage_taken = 20
		var previous_health = health
		
		health = max(0, health - damage_taken)
		enemy_attack_cooldown = false
		$attackCooldownTimer.start()
		
		print("⚔️ Bank attacked!")
		print("   HP Before: ", previous_health)
		print("   Damage Taken: -", damage_taken)
		print("   HP After: ", health)
		
		var hp_percent = float(health) / float(max_health) * 100.0
		print("🚨 ALERT: HP Bank tersisa ", health, "/", max_health, " (", hp_percent, "% )")
		
		update_brightness()
		
		$AnimatedSprite2D.modulate = Color.RED
		$demageFlashTimer.start()

func update_brightness():
	if not bank_alive:
		return
	
	var health_percentage = clamp(float(health) / float(max_health), 0.0, 1.0)
	var brightness = health_percentage
	$AnimatedSprite2D.modulate = Color(brightness, brightness, brightness, original_brightness)

func _on_attackCooldownTimer_timeout():
	enemy_attack_cooldown = true
	print("🔄 Bank attack cooldown reset")

func _on_demageFlashTimer_timeout():
	if bank_alive:
		update_brightness()
		print("🎨 Bank color returned to HP-based brightness")

func destroy_bank():
	$AnimatedSprite2D.modulate = Color(0, 0, 0, original_brightness)
	
	if $AnimatedSprite2D.sprite_frames.has_animation("destroyed"):
		$AnimatedSprite2D.play("destroyed")
		print("🔥 Playing bank destroyed animation")
	
	$CollisionShape2D.set_deferred("disabled", true)
	print("🚫 Bank collision disabled")
	
	$destroyTimer.start()
	print("⏰ Bank will be removed in 2 seconds...")

func _on_destroyTimer_timeout():
	print("🗑️ Bank removed from game!")
	queue_free()

# Supaya enemy lama yang pakai has_method("house") juga tetap bisa mendeteksi
func house():
	pass

# Kalau nanti mau cek khusus bank di enemy.gd, bisa pakai:
func bank():
	pass
