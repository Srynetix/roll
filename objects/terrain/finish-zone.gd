extends Area2D
class_name GFinishZone

@onready var success_sfx := %SuccessSFX as AudioStreamPlayer

func play_success() -> void:
	success_sfx.play()
