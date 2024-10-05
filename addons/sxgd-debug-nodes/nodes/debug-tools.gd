extends CanvasLayer
## Global debug tools, take #2 (WIP)

const SxDebugToolsWindow = preload("res://addons/sxgd-debug-nodes/nodes/debug-tools-window.gd")
const PanelType = SxDebugToolsWindow.PanelType

var background: Control
var window: SxDebugToolsWindow

func show_tools() -> void:
	background.visible = true
	window.visible = true

func hide_tools() -> void:
	background.visible = false
	window.visible = false

func show_specific_panel(panel_type: PanelType) -> void:
	window.show_specific_panel(panel_type)

func toggle_tools() -> void:
	if background.visible:
		hide_tools()
	else:
		show_tools()

func _init() -> void:
	background = Control.new()
	background.name = "Background"
	background.set_anchors_preset(Control.LayoutPreset.PRESET_FULL_RECT)
	background.grow_horizontal = Control.GROW_DIRECTION_BOTH
	background.grow_vertical = Control.GROW_DIRECTION_BOTH
	background.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	window = SxDebugToolsWindow.new()
	add_child(window)

func _ready() -> void:
	window._tools = self
	hide_tools()

func _input(event: InputEvent):
	if event is InputEventKey:
		if event.pressed && event.physical_keycode == KEY_QUOTELEFT:
			window.toggle_console()

		elif event.pressed && event.physical_keycode == KEY_F12:
			toggle_tools()

	if event is InputEventMouseButton:
		if event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
			if window._picking:
				# Get item at position
				var nodes_to_scan := get_tree().current_scene.get_children()
				while len(nodes_to_scan) > 0:
					var node := nodes_to_scan.pop_back() as Node
					for child in node.get_children():
						nodes_to_scan.push_back(child)

					if node is Sprite2D:
						var rect = Rect2()
						rect.position = node.global_position - (node.texture.get_size() * node.scale) / 2
						rect.size = node.get_rect().size
						if rect.has_point(event.global_position):
							window.pick_node(node)
							break

					elif node is Control:
						if node.get_rect().has_point(event.global_position):
							window.pick_node(node)
							break
