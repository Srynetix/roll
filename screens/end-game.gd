extends Control

const BallScene := preload("res://objects/ball/ball.tscn")

func _ready() -> void:
	GameData.play_music()
	await GameData.fade_in()
	GameData._player.seek(51.0)

	var timer := Timer.new()
	timer.wait_time = 0.25
	timer.autostart = true
	timer.timeout.connect(func():
		var vp_size := get_viewport_rect().size
		var ball := BallScene.instantiate()
		var rand_x := randi_range(50, vp_size.x - 50)
		ball.position = Vector2(rand_x, -20)
		ball.can_jump_with_music = true
		ball.modulate = SxCore.ColorExt.rand()
		add_child(ball)

		ball._save()
	)
	add_child(timer)

	await get_tree().create_timer(20.0).timeout
	await GameData.fade_out()

	SceneTransitioner.fade_to_scene(GameData.TitleScreen)
