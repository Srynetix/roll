# Prelude of the library
extends Node

const SxCamera2D := preload("res://addons/sxgd-fx-nodes/nodes/camera-2d.gd")
const SxGPUParticles3D := preload("res://addons/sxgd-fx-nodes/nodes/gpu-particles-3d.gd")

# Overlays
const VignetteOverlay := preload("res://addons/sxgd-fx-nodes/overlays/vignette-overlay.gd")
const GrayscaleOverlay := preload("res://addons/sxgd-fx-nodes/overlays/grayscale-overlay.gd")
const DissolveOverlay := preload("res://addons/sxgd-fx-nodes/overlays/dissolve-overlay.gd")
const ChromaticAberrationOverlay := preload("res://addons/sxgd-fx-nodes/overlays/chromatic-aberration-overlay.gd")
const GaussianBlurOverlay := preload("res://addons/sxgd-fx-nodes/overlays/gaussian-blur-overlay.gd")
const MotionBlurOverlay := preload("res://addons/sxgd-fx-nodes/overlays/motion-blur-overlay.gd")
const ShockwaveOverlay := preload("res://addons/sxgd-fx-nodes/overlays/shockwave-overlay.gd")