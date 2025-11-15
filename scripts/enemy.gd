extends Node2D

@export var speed: float = 15.0               # lari lebih pelan
@export var stopping_distance: float = 40.0   # jarak berhenti dari target (px)
@export var receive_hit_distance: float = 30.0  # jarak maksimum player bisa mengenai enemy

@onready var sfx_death = $sfx_death

# Targetting
var target: Node2D = null
var detected_houses: Array = []          # list house yang terdeteksi di Area2D
var detected_player: Node2D = null

# Status enemy
var health: int = 100
var can_take_damage: bool = true

func _physics_process(delta):
	deal_with_damage()
	update_target()

	if target != null and is_instance_valid(target):
		_move_towards_target(delta)
	else:
		if has_node("AnimatedSprite2D"):
			$AnimatedSprite2D.play("idle_front")


# ==========================================================
# GERAK KE ARAH TARGET TANPA MASUK KE DALAM RUMAH
# ==========================================================
func _move_towards_target(delta: float) -> void:
	var to_target: Vector2 = target.global_position - global_position
	var distance: float = to_target.length()

	# Kalau masih lebih jauh dari stopping_distance → maju
	if distance > stopping_distance:
		var dir = to_target.normalized()
		global_position += dir * speed * delta

		if has_node("AnimatedSprite2D"):
			$AnimatedSprite2D.play("walk_front")
			$AnimatedSprite2D.flip_h = dir.x < 0
	else:
		# Sudah cukup dekat → berhenti di luar rumah
		if has_node("AnimatedSprite2D"):
			$AnimatedSprite2D.play("idle_front")


# ==========================================================
# PRIORITAS TARGET: HOUSE > PLAYER
# ==========================================================
func update_target() -> void:
	# Bersihkan house yang sudah dihapus (queue_free)
	var valid_houses: Array = []
	for h in detected_houses:
		if is_instance_valid(h):
			valid_houses.append(h)
	detected_houses = valid_houses

	# 1) Kalau masih ada house di dalam area → house jadi target
	if detected_houses.size() > 0:
		if target != detected_houses[0]:
			print("🎯 Target ENEMY sekarang: HOUSE")
		target = detected_houses[0]
		return

	# 2) Kalau tidak ada house, tapi ada player → player jadi target
	if detected_player != null and is_instance_valid(detected_player):
		if target != detected_player:
			print("🎯 Target ENEMY sekarang: PLAYER")
		target = detected_player
	else:
		if target != null:
			print("❌ ENEMY kehilangan target")
		target = null


# ==========================================================
# DETECTION AREA (Area2D): house & player
# ==========================================================
func _on_detection_area_body_entered(body):
	print("🔵 detection_area ENTERED by:", body.name)
	if body.has_method("house"):
		if not detected_houses.has(body):
			detected_houses.append(body)
		print("👀 Enemy mendeteksi HOUSE di area! Jumlah house terdeteksi:", detected_houses.size())
	elif body.has_method("player"):
		detected_player = body
		print("👀 Enemy mendeteksi PLAYER di area!")

func _on_detection_area_body_exited(body):
	print("🟠 detection_area EXITED by:", body.name)
	if body.has_method("house"):
		detected_houses.erase(body)
		print("⬅️ HOUSE keluar dari area. Sisa house terdeteksi:", detected_houses.size())
	elif body == detected_player:
		detected_player = null
		print("⬅️ PLAYER keluar dari area")


func enemy():
	pass


# ==========================================================
# PLAYER MENYERANG ENEMY (berdasarkan JARAK)
# ==========================================================
func deal_with_damage():
	# Pastikan ada player dan player sedang attack
	if detected_player != null and is_instance_valid(detected_player) and global.player_current_attack:
		var dist = (detected_player.global_position - global_position).length()
		
		# Debug jarak
		# print("DEBUG jarak player-enemy:", dist)
		
		if dist <= receive_hit_distance and can_take_damage:
			print("💥 ENEMY RECEIVED ATTACK! Jarak:", dist)
			print("   HP before:", health)
			
			health -= 200
			print("   HP after :", health)
			
			can_take_damage = false
			$take_damage_cooldown.start()

			if health <= 0:
				print("💀 ENEMY DIED! queue_free()")
				sfx_death.play()
				queue_free()
				
	else:
		# Bisa aktifkan ini kalau mau lihat kapan kondisi tidak terpenuhi
		# if global.player_current_attack:
		#     print("⚠️ Player menyerang tapi enemy di luar jarak / tidak terdeteksi")
		pass

func _on_take_damage_cooldown_timeout():
	can_take_damage = true
	print("🔄 ENEMY can_take_damage = TRUE lagi")
