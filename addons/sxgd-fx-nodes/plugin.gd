@tool
extends EditorPlugin

const Prelude := preload("res://addons/sxgd-fx-nodes/prelude.gd")

func _enable_plugin() -> void:
	add_autoload_singleton("SxFxNodes", "res://addons/sxgd-fx-nodes/prelude.gd")
	add_custom_type("SxFxCamera2D", "Camera2D", Prelude.SxCamera2D, null)
	add_custom_type("SxFxGPUParticles3D", "GPUParticles3D", Prelude.SxGPUParticles3D, null)
	add_custom_type("SxFxVignetteOverlay", "ColorRect", Prelude.VignetteOverlay, null)
	add_custom_type("SxFxGrayscaleOverlay", "ColorRect", Prelude.GrayscaleOverlay, null)
	add_custom_type("SxFxDissolveOverlay", "ColorRect", Prelude.DissolveOverlay, null)
	add_custom_type("SxFxChromaticAberrationOverlay", "ColorRect", Prelude.ChromaticAberrationOverlay, null)
	add_custom_type("SxFxGaussianBlurOverlay", "ColorRect", Prelude.GaussianBlurOverlay, null)
	add_custom_type("SxFxMotionBlurOverlay", "ColorRect", Prelude.MotionBlurOverlay, null)
	add_custom_type("SxFxShockwaveOverlay", "ColorRect", Prelude.ShockwaveOverlay, null)

func _disable_plugin() -> void:
	remove_autoload_singleton("SxFxNodes")
	remove_custom_type("SxFxCamera2D")
	remove_custom_type("SxFxGPUParticles3D")
	remove_custom_type("SxFxVignetteOverlay")
	remove_custom_type("SxFxGrayscaleOverlay")
	remove_custom_type("SxFxDissolveOverlay")
	remove_custom_type("SxFxChromaticAberrationOverlay")
	remove_custom_type("SxFxGaussianBlurOverlay")
	remove_custom_type("SxFxMotionBlurOverlay")
	remove_custom_type("SxFxShockwaveOverlay")
