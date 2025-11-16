extends Node2D

@export var speed: float = 20.0                 # lari musuh
@export var stopping_distance: float = 55.0     # jarak berhenti dari target (px)
@export var receive_hit_distance: float = 30.0  # jarak maksimum player bisa mengenai enemy
@export var attack_cycle_duration: float = 0.6  # berapa lama 1 siklus idle+attack (detik)

# Targetting
var target: Node2D = null
var detected_banks: Array = []          # list bank yang terdeteksi di Area2D
var detected_player: Node2D = null      # hanya untuk cek jarak saat player menyerang

# Status enemy
var health: int = 100
var can_take_damage: bool = true

# State animasi
var last_dir: String = "down"   # "right", "left", "up", "down"
var is_attacking: bool = false
var is_dying: bool = false
var attack_anim_timer: float = 0.0      # untuk campuran idle + attack


func _physics_process(delta: float) -> void:
	# Kalau sudah mati, jangan lakukan apa-apa lagi
	if is_dying:
		return

	deal_with_damage()
	update_target()

	if target != null and is_instance_valid(target):
		_move_towards_target(delta)
	else:
		is_attacking = false
		attack_anim_timer = 0.0
		_play_idle_anim()


# ============================
# GERAK + ATTACK KE ARAH BANK
# ============================
func _move_towards_target(delta: float) -> void:
	if target == null or not is_instance_valid(target):
		_play_idle_anim()
		return

	var to_target: Vector2 = target.global_position - global_position
	var distance: float = to_target.length()

	if distance > stopping_distance:
		# Jalan menuju bank
		var dir := to_target.normalized()
		global_position += dir * speed * delta
		is_attacking = false
		attack_anim_timer = 0.0
		_play_walk_anim(dir)
	else:
		# Sudah cukup dekat → state menyerang
		is_attacking = true
		attack_anim_timer += delta
		if attack_anim_timer > attack_cycle_duration:
			attack_anim_timer = 0.0
		_play_attack_cycle(to_target.normalized())


# ============================
# ANIMASI: JALAN, IDLE, ATTACK
# ============================
func _play_walk_anim(dir: Vector2) -> void:
	if not has_node("AnimatedSprite2D"):
		return
	var anim := $AnimatedSprite2D

	# Tentukan apakah gerak dominan horizontal atau vertical
	if abs(dir.x) > abs(dir.y):
		# Gerak kanan / kiri → walk_right + flip
		if dir.x > 0:
			anim.flip_h = false
			last_dir = "right"
		else:
			anim.flip_h = true
			last_dir = "left"
		anim.play("walk_right")
	else:
		# Gerak atas / bawah
		anim.flip_h = false
		if dir.y > 0:
			last_dir = "down"
			anim.play("walk_front")
		else:
			last_dir = "up"
			anim.play("walk_back")


func _play_idle_anim() -> void:
	if not has_node("AnimatedSprite2D"):
		return
	var anim := $AnimatedSprite2D

	match last_dir:
		"right":
			anim.flip_h = false
			anim.play("idle_right")
		"left":
			anim.flip_h = true
			anim.play("idle_right")   # sama anim, cuma di-flip
		"up":
			anim.flip_h = false
			anim.play("back_idle")
		"down":
			anim.flip_h = false
			anim.play("idle_front")


# Campuran idle + attack sesuai arah:
# bagian awal siklus → idle, sisanya → attack
func _play_attack_cycle(dir: Vector2) -> void:
	if not has_node("AnimatedSprite2D"):
		return
	var anim := $AnimatedSprite2D

	var t := attack_anim_timer / attack_cycle_duration  # 0..1
	var use_idle := t < 0.5   # 50% pertama idle, 50% kedua attack

	# Dominan horizontal?
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			# menghadap kanan
			anim.flip_h = false
			last_dir = "right"
			if use_idle:
				anim.play("idle_right")
			else:
				anim.play("attack_right")
		else:
			# menghadap kiri
			anim.flip_h = true
			last_dir = "left"
			if use_idle:
				anim.play("idle_right")   # idle kanan tapi di-flip → idle kiri
			else:
				if anim.sprite_frames.has_animation("attack_left"):
					anim.play("attack_left")
				else:
					anim.play("attack_right")
	else:
		# Vertikal
		anim.flip_h = false
		if dir.y > 0:
			# target di bawah → hadap bawah
			last_dir = "down"
			if use_idle:
				anim.play("idle_front")
			else:
				anim.play("attack_front")
		else:
			# target di atas → hadap atas
			last_dir = "up"
			if use_idle:
				anim.play("back_idle")
			else:
				if anim.sprite_frames.has_animation("attack_behind"):
					anim.play("attack_behind")
				else:
					anim.play("attack_front")


# ============================
# PRIORITAS TARGET: BANK SAJA
# ============================
func update_target() -> void:
	# Bersihkan bank yang sudah dihapus
	var valid_banks: Array = []
	for b in detected_banks:
		if is_instance_valid(b):
			valid_banks.append(b)
	detected_banks = valid_banks

	# Kalau ada bank → pilih yang pertama
	if detected_banks.size() > 0:
		if target != detected_banks[0]:
			print("🎯 Target ENEMY sekarang: BANK")
		target = detected_banks[0]
	else:
		if target != null:
			print("❌ ENEMY kehilangan target (tidak ada bank)")
		target = null


# ============================
# DETECTION AREA (Area2D)
# ============================
func _on_detection_area_body_entered(body):
	print("🔵 detection_area ENTERED by:", body.name)
	if body.has_method("bank"):
		if not detected_banks.has(body):
			detected_banks.append(body)
		print("👀 Enemy mendeteksi BANK di area! Jumlah bank terdeteksi:", detected_banks.size())
	elif body.has_method("player"):
		detected_player = body
		print("👀 Enemy mendeteksi PLAYER di area (untuk cek jarak serangan)")

func _on_detection_area_body_exited(body):
	print("🟠 detection_area EXITED by:", body.name)
	if body.has_method("bank"):
		detected_banks.erase(body)
		print("⬅️ BANK keluar dari area. Sisa bank terdeteksi:", detected_banks.size())
	elif body == detected_player:
		detected_player = null
		print("⬅️ PLAYER keluar dari area enemy")


func enemy():
	pass


# ============================
# PLAYER MENYERANG ENEMY (JARAK)
# ============================
func deal_with_damage() -> void:
	# Kalau sudah mati, jangan bisa kena hit lagi
	if is_dying:
		return

	if detected_player != null and is_instance_valid(detected_player) and global.player_current_attack:
		var dist := (detected_player.global_position - global_position).length()
		
		if dist <= receive_hit_distance and can_take_damage:
			print("💥 ENEMY RECEIVED ATTACK! Jarak:", dist)
			print("   HP before:", health)
			
			health -= 200
			print("   HP after :", health)
			
			can_take_damage = false
			$take_damage_cooldown.start()

			if health <= 0:
				_start_death_sequence()


# ----------------------------
# KEMATIAN DENGAN DELAY OTOMATIS
# ----------------------------
func _start_death_sequence() -> void:
	if is_dying:
		return

	is_dying = true
	print("💀 ENEMY DIED! Playing death animation with delay...")

	# Matikan collider
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)

	if not has_node("AnimatedSprite2D"):
		queue_free()
		return

	var anim := $AnimatedSprite2D

	# Kalau animasi death ada → play lalu hitung durasinya
	if anim.sprite_frames.has_animation("death"):
		anim.play("death")

		var frame_count: int = anim.sprite_frames.get_frame_count("death")
		var fps: float = float(anim.sprite_frames.get_animation_speed("death"))
		if fps <= 0:
			fps = 10.0  # fallback biar nggak bagi 0

		var duration: float = frame_count / fps
		print("🕒 Death animation length:", duration, "seconds")

		# Tunggu sampai animasi selesai baru hapus enemy
		await get_tree().create_timer(duration).timeout
		print("🗑️ ENEMY REMOVED (after death animation)")
		queue_free()
	else:
		# Kalau tidak ada animasi death
		queue_free()


func _on_take_damage_cooldown_timeout() -> void:
	can_take_damage = true
	print("🔄 ENEMY can_take_damage = TRUE lagi")
