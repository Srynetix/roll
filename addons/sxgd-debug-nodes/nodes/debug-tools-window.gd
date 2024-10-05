extends Window

const SxDebugConsole := preload("res://addons/sxgd-debug-nodes/nodes/debug-console.gd")
const SxDebugNodeInspector := preload("res://addons/sxgd-debug-nodes/nodes/debug-tools-node-inspector.gd")
const SxDebugTools := preload("res://addons/sxgd-debug-nodes/nodes/debug-tools.gd")
const SxDebugInfo := preload("res://addons/sxgd-debug-nodes/nodes/debug-tools-info-panel.gd")
const SxNodeTracerSystem := preload("res://addons/sxgd-debug-nodes/nodes/node-tracer-system.gd")
const SxCVarsEditor := preload("res://addons/sxgd-debug-nodes/nodes/debug-tools-cvars-editor.gd")
const SxLogPanel := preload("res://addons/sxgd-debug-nodes/nodes/debug-tools-log-panel.gd")

const _THEME := preload("res://addons/sxgd-debug-nodes/nodes/debug-tools-theme.tres")

var tabs: TabContainer
var toggle_console_btn: Button
var console: SxDebugConsole
var dock_button: MenuButton
var pick_button: Button

var node_tree: Tree
var node_inspector: SxDebugNodeInspector
var refresh_node_tree_button: Button

var _tools: SxDebugTools
var _picking := false
var _tree_dict := {}
var _inspected_node: Node

var _node_tree_update_timer: Timer

enum DockType {
	Right = 0,
	Bottom = 1,
	Left = 2,
	FullScreen = 3
}

enum PanelType {
	Info = 0,
	Graph = 1,
	Tracer = 2,
	CVars = 3,
	Logs = 4
}

func _init() -> void:
	name = "SxDebugToolsWindow"
	title = "SxDebugTools"
	size = Vector2i(500, 500)
	min_size = Vector2i(400, 400)
	add_theme_font_size_override("title_font_size", 10)
	theme = _THEME

	# Create UI
	var panel := Panel.new()
	panel.name = "Panel"
	panel.custom_minimum_size = Vector2i(400, 0)
	panel.set_anchors_preset(Control.LayoutPreset.PRESET_FULL_RECT)
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.name = "VBoxContainer"
	vbox.set_anchors_preset(Control.LayoutPreset.PRESET_FULL_RECT)
	vbox.grow_vertical = Control.GROW_DIRECTION_BOTH
	vbox.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.add_child(vbox)

	var hbox := HBoxContainer.new()
	hbox.name = "HBoxContainer"
	vbox.add_child(hbox)

	pick_button = Button.new()
	pick_button.name = "PickButton"
	pick_button.text = "Pick"
	hbox.add_child(pick_button)

	dock_button = MenuButton.new()
	dock_button.name = "DockButton"
	dock_button.text = "Dock"
	dock_button.flat = false
	dock_button.switch_on_hover = true
	var dock_popup = dock_button.get_popup()
	dock_popup.add_item("Right")
	dock_popup.add_item("Bottom", 1)
	dock_popup.add_item("Left", 2)
	dock_popup.add_item("Full screen", 3)
	hbox.add_child(dock_button)

	tabs = TabContainer.new()
	tabs.name = "Tabs"
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tabs.current_tab = 1
	vbox.add_child(tabs)

	########
	# Stats

	var stats_margin := MarginContainer.new()
	stats_margin.name = "Stats"
	stats_margin.visible = false
	stats_margin.add_theme_constant_override("margin_left", 10)
	stats_margin.add_theme_constant_override("margin_right", 10)
	stats_margin.add_theme_constant_override("margin_top", 10)
	stats_margin.add_theme_constant_override("margin_bottom", 10)
	tabs.add_child(stats_margin)

	var debug_info := SxDebugInfo.new()
	debug_info.process_mode = Node.PROCESS_MODE_ALWAYS
	stats_margin.add_child(debug_info)

	#############
	# Scene graph

	var scene_graph_margin := MarginContainer.new()
	scene_graph_margin.name = "Scene Graph"
	scene_graph_margin.add_theme_constant_override("margin_left", 10)
	scene_graph_margin.add_theme_constant_override("margin_right", 10)
	scene_graph_margin.add_theme_constant_override("margin_top", 10)
	scene_graph_margin.add_theme_constant_override("margin_bottom", 10)
	tabs.add_child(scene_graph_margin)

	var scene_graph_hsplit := HSplitContainer.new()
	scene_graph_hsplit.name = "HSplitContainer"
	scene_graph_hsplit.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scene_graph_margin.add_child(scene_graph_hsplit)

	var scene_graph_vbox := VBoxContainer.new()
	scene_graph_vbox.name = "VBoxContainer"
	scene_graph_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scene_graph_hsplit.add_child(scene_graph_vbox)

	var scene_graph_hbox := HBoxContainer.new()
	scene_graph_hbox.name = "HBoxContainer"
	scene_graph_vbox.add_child(scene_graph_hbox)

	var scene_graph_line_edit := LineEdit.new()
	scene_graph_line_edit.name = "LineEdit"
	scene_graph_line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scene_graph_hbox.add_child(scene_graph_line_edit)

	refresh_node_tree_button = Button.new()
	refresh_node_tree_button.name = "RefreshNodeTreeButton"
	refresh_node_tree_button.text = "Refresh"
	scene_graph_hbox.add_child(refresh_node_tree_button)

	node_tree = Tree.new()
	node_tree.name = "NodeTree"
	node_tree.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	node_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scene_graph_vbox.add_child(node_tree)

	var scroll_container := ScrollContainer.new()
	scroll_container.name = "ScrollContainer"
	scroll_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scene_graph_hsplit.add_child(scroll_container)

	node_inspector = SxDebugNodeInspector.new()
	scroll_container.add_child(node_inspector)

	#############
	# Node tracer

	var node_tracer_margin := MarginContainer.new()
	node_tracer_margin.name = "Node Tracer"
	node_tracer_margin.visible = false
	tabs.add_child(node_tracer_margin)

	var node_tracer_system := SxNodeTracerSystem.new()
	node_tracer_margin.add_child(node_tracer_system)

	#######
	# CVars

	var cvars_margin := MarginContainer.new()
	cvars_margin.name = "CVars"
	cvars_margin.visible = false
	cvars_margin.add_theme_constant_override("margin_left", 10)
	cvars_margin.add_theme_constant_override("margin_right", 10)
	cvars_margin.add_theme_constant_override("margin_top", 10)
	cvars_margin.add_theme_constant_override("margin_bottom", 10)
	tabs.add_child(cvars_margin)

	var cvars_editor := SxCVarsEditor.new()
	cvars_margin.add_child(cvars_editor)

	######
	# Logs

	var logs_margin := MarginContainer.new()
	logs_margin.name = "Logs"
	logs_margin.visible = false
	logs_margin.add_theme_constant_override("margin_left", 10)
	logs_margin.add_theme_constant_override("margin_right", 10)
	logs_margin.add_theme_constant_override("margin_top", 10)
	logs_margin.add_theme_constant_override("margin_bottom", 10)
	tabs.add_child(logs_margin)

	var log_panel := SxLogPanel.new()
	logs_margin.add_child(log_panel)

	#########
	# Console

	var console_panel := VBoxContainer.new()
	console_panel.name = "ConsolePanel"
	vbox.add_child(console_panel)

	toggle_console_btn = Button.new()
	toggle_console_btn.name = "ToggleConsole"
	toggle_console_btn.text = "Toggle Console"
	toggle_console_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	console_panel.add_child(toggle_console_btn)

	console = SxDebugConsole.new()
	console.visible = false
	console.custom_minimum_size = Vector2(0, 300)
	console.size_flags_vertical = Control.SIZE_SHRINK_END | Control.SIZE_EXPAND
	console_panel.add_child(console)

func _ready() -> void:
	toggle_console_btn.pressed.connect(func():
		console.visible = !console.visible
	)

	dock_button.get_popup().id_pressed.connect(func(item_id):
		_dock_tools(item_id as DockType)
	)

	close_requested.connect(func():
		_tools.hide_tools()
	)

	pick_button.pressed.connect(func():
		_picking = !_picking

		if _picking:
			Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
		else:
			Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	)

	node_tree.item_selected.connect(func():
		var selected := node_tree.get_selected()
		var node := selected.get_metadata(0)
		if is_instance_valid(node):
			_set_node_to_inspect(selected.get_metadata(0))
	)

	_dock_tools(DockType.Right)
	_update_node_tree()

	refresh_node_tree_button.pressed.connect(func():
		_update_node_tree()
	)

func show_specific_panel(panel_type: PanelType) -> void:
	tabs.current_tab = int(panel_type)

func pick_node(node: Node):
	_picking = false
	_set_node_to_inspect(node)

func toggle_console():
	if !visible:
		_tools.show_tools()
		console.visible = true
	else:
		console.visible = !console.visible

	if console.visible:
		console.focus_input()

func _set_node_to_inspect(node: Node):
	if is_instance_valid(node):
		node_inspector.inspected_node = node

func _dock_tools(dock_type: DockType) -> void:
	var vp_size = get_tree().root.get_viewport().get_visible_rect().size
	var window_size = get_size_with_decorations()
	var min_width := 400
	var min_height := 400
	var border_size := 8
	var title_bar_size := 32

	if dock_type == DockType.Right:
		size.x = min_width - border_size
		size.y = vp_size.y - title_bar_size - border_size
		position.x = vp_size.x - size.x - border_size
		position.y = title_bar_size
	elif dock_type == DockType.Left:
		size.x = min_width - border_size
		size.y = vp_size.y - title_bar_size - border_size
		position.x = border_size
		position.y = title_bar_size
	elif dock_type == DockType.Bottom:
		size.x = vp_size.x - border_size * 2
		size.y = min_height
		position.x = border_size
		position.y = vp_size.y - size.y - border_size
	elif dock_type == DockType.FullScreen:
		size.x = vp_size.x
		size.y = vp_size.y
		position.x = 0
		position.y = 0

func _update_node_tree() -> void:
	node_tree.clear()

	var current_scene := get_tree().current_scene
	var root = node_tree.create_item()
	_create_node_tree_at_root(root, current_scene)

func _create_node_tree_at_root(tree_root: TreeItem, root: Node) -> void:
	tree_root.set_text(0, root.name)
	tree_root.set_metadata(0, root)

	for child in root.get_children():
		var tree_node := tree_root.create_child()
		_create_node_tree_at_root(tree_node, child)

func _input(event: InputEvent):
	if event is InputEventKey:
		if event.pressed && event.physical_keycode == KEY_QUOTELEFT:
			toggle_console()

		elif event.pressed && event.physical_keycode == KEY_F12:
			_tools.toggle_tools()
