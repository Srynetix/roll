extends Control

const DemoScene := preload("res://tests/test-howtoplay.tscn")

@onready var demo := %Demo as GHowToPlayDemo
@onready var back := %Back as Button
@onready var skip := %Next as Button

func _ready() -> void:
	back.pressed.connect(func():
		SceneTransitioner.fade_to_scene(GameData.TitleScreen)
	)

	skip.grab_focus()
	skip.pressed.connect(func():
		GameData.saw_how_to_play = true
		SceneTransitioner.fade_to_scene(GameData.GameScreen)
	)

	demo.finished.connect(func():
		_demo_end()
	)

func _demo_end() -> void:
	var demo_parent := demo.get_parent() as Control
	demo.queue_free()

	demo = DemoScene.instantiate()
	demo.finished.connect(func():
		_demo_end()
	)
	demo_parent.add_child(demo)
