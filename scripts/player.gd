extends CharacterBody2D

@onready var sfx_walk = $sfx_walk
@onready var sfx_swing = $sfx_swing
@onready var sfx_hit_damage = $sfx_hit_damage

var health = 1000
var player_alive = true

var attack_ip = false

const SPEED = 100
var current_dir = "none"
var is_moving = false

func _ready():
	$AnimatedSprite2D.play("front_idle")
	current_dir = "down"  # default arah supaya E bisa langsung dipakai
	print("👤 Player ready. HP:", health)

func _physics_process(delta):
	player_movement(delta)
	attack()
	
	if health <= 0:
		player_alive = false # go back or to menu
		health = 0
		print("💀 Player has been killed")
		queue_free()

func player_movement(delta):
	# Panah + WASD (tanpa perlu bikin action baru di Input Map)
	var right_pressed = Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D)
	var left_pressed  = Input.is_action_pressed("ui_left")  or Input.is_key_pressed(KEY_A)
	var down_pressed  = Input.is_action_pressed("ui_down")  or Input.is_key_pressed(KEY_S)
	var up_pressed    = Input.is_action_pressed("ui_up")    or Input.is_key_pressed(KEY_W)
	var was_moving = is_moving
	is_moving = false
	
	if right_pressed:
		current_dir = "right"
		play_anim(1)
		velocity.x = SPEED
		velocity.y = 0
		is_moving = true
	elif left_pressed:
		current_dir = "left"
		play_anim(1)
		velocity.x = -SPEED
		velocity.y = 0
		is_moving = true
	elif down_pressed:
		current_dir = "down"
		play_anim(1)
		velocity.y = SPEED
		velocity.x = 0
		is_moving = true
	elif up_pressed:
		current_dir = "up"
		play_anim(1)
		velocity.y = -SPEED
		velocity.x = 0
		is_moving = true
	else:
		play_anim(0)
		velocity.x = 0
		velocity.y = 0
		
	if is_moving && !was_moving:
		if !sfx_walk.playing:
			sfx_walk.play()
	elif !is_moving && was_moving:
		sfx_walk.stop()
	
	move_and_slide()

func play_anim(movement):
	var dir = current_dir
	var anim = $AnimatedSprite2D
	
	if dir == "right":
		anim.flip_h = false
		if movement == 1:
			anim.play("side_walk")
		elif movement == 0 and not attack_ip:
			anim.play("side_idle")
			
	elif dir == "left":
		anim.flip_h = true
		if movement == 1:
			anim.play("side_walk")
		elif movement == 0 and not attack_ip:
			anim.play("side_idle")
			
	elif dir == "down":
		anim.flip_h = true
		if movement == 1:
			anim.play("front_walk")
		elif movement == 0 and not attack_ip:
			anim.play("front_idle")
			
	elif dir == "up":
		anim.flip_h = true
		if movement == 1:
			anim.play("back_walk")
		elif movement == 0 and not attack_ip:
			anim.play("back_idle")

func player():
	# dipakai enemy.gd untuk cek has_method("player")
	pass

# =======================
# (Opsional) HITBOX PLAYER
# =======================
func _on_player_hitbox_body_entered(body):
	print("📘 player_hitbox ENTERED by:", body.name)

func _on_player_hitbox_body_exited(body):
	print("📙 player_hitbox EXITED by:", body.name)

# =======================
# PLAYER MENYERANG
# =======================
func attack():
	var dir = current_dir
	
	if Input.is_action_just_pressed("attack"):
		# Kalau belum pernah gerak sama sekali → pakai arah down
		if dir == "none":
			dir = "down"
			current_dir = "down"
		
		print("🗡 Player ATTACK pressed! Direction:", dir)
		global.player_current_attack = true
		attack_ip = true
		
		sfx_swing.play()
		
		if dir == "right":
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("side_attack")
		elif dir == "left":
			$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.play("side_attack")
		elif dir == "down":
			$AnimatedSprite2D.play("front_attack")
		elif dir == "up":
			$AnimatedSprite2D.play("back_attack_1")
		
		print("⚔️ global.player_current_attack = TRUE (attack window OPEN)")
		$deal_attack_timer.start()

func _on_deal_attack_timer_timeout() -> void:
	print("⏳ Attack window CLOSED → global.player_current_attack = FALSE")
	global.player_current_attack = false
	attack_ip = false
