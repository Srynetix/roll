extends Control
class_name GTitle

@onready var start_game := %StartGame as Button
@onready var customize := %Customize as Button
@onready var how_to_play := %HowToPlay as Button
@onready var clear_data := %ClearData as Button

func _ready() -> void:
	GameData.play_intro()

	start_game.pressed.connect(func():
		if !GameData._saw_how_to_play:
			SceneTransitioner.fade_to_scene(GameData.HowToPlayScreen)
		else:
			SceneTransitioner.fade_to_scene(GameData.GameScreen)
	)

	customize.pressed.connect(func():
		get_tree().change_scene_to_packed(GameData.CustomizeScreen)
	)

	how_to_play.pressed.connect(func():
		SceneTransitioner.fade_to_scene(GameData.HowToPlayScreen)
	)

	clear_data.pressed.connect(func():
		var popup := SxUiNodes.FullScreenConfirmationDialog.new()
		popup.confirmed.connect(func():
			# TODO: Remove
			get_tree().reload_current_scene()
		)

		popup.canceled.connect(func():
			popup.queue_free()
			start_game.grab_focus()
		)
		add_child(popup)

		popup.show_dialog()
	)

	start_game.grab_focus()
