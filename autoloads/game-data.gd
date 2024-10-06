extends SxCoreNodes.GameData

const IntroMusic := preload("res://sounds/intro.ogg")
const GameMusic := preload("res://sounds/music.ogg")

var _player: AudioStreamPlayer
var _current_level: int = 1
var _saw_how_to_play := false

var TitleScreen = null
var HowToPlayScreen = null
var GameScreen = null
var CustomizeScreen = null
var EndGameScreen = null

var current_level: int :
	set(value):
		_current_level = value
	get:
		return _current_level

var saw_how_to_play: bool :
	set(value):
		_saw_how_to_play = value
		store_value("saw_how_to_play", value)
		persist_to_disk()
	get:
		return _saw_how_to_play

func _ready() -> void:
	default_file_path = "user://ld56-data.dat"
	load_from_disk()

	_saw_how_to_play = load_value("saw_how_to_play", false)

	TitleScreen = load("res://screens/title.tscn")
	HowToPlayScreen = load("res://screens/how-to-play.tscn")
	GameScreen = load("res://screens/game.tscn")
	CustomizeScreen = load("res://screens/customize.tscn")
	EndGameScreen = load("res://screens/end-game.tscn")

	_player = AudioStreamPlayer.new()
	_player.bus = "Music"
	add_child(_player)

func play_intro() -> void:
	if _player.stream != IntroMusic || !_player.playing:
		_player.stream = IntroMusic
		start_music_play()

	if _player.volume_db < 0:
		fade_in()

func play_music() -> void:
	if _player.stream != GameMusic || !_player.playing:
		_player.stream = GameMusic
		start_music_play()

	if _player.volume_db < 0:
		fade_in()

func start_music_play():
	_player.play()

func fade_out() -> void:
	var tween := create_tween()
	tween.tween_property(_player, "volume_db", -10.0, 0.5).from(0.0)
	await tween.finished

func fade_in() -> void:
	var tween := create_tween()
	tween.tween_property(_player, "volume_db", 0.0, 0.5).from(-10.0)
	await tween.finished

func set_volume(value: float) -> void:
	var db := linear_to_db(max(value, 0.1))
	_player.volume_db = db
