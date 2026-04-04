@tool class_name VneStructureEditor extends GraphEdit


var episode_nodes: Dictionary[String, GraphNode]


func _ready():
	var graph_node = GraphNode.new()
	add_child(graph_node)
	graph_node.title = "Эпизод #1"
	
	var desc = Label.new()
	graph_node.add_child(desc)
	desc.text = "Это описание эпизода."
	
	var in_slot = Label.new()
	graph_node.add_child(in_slot)
	in_slot.text = "Предыдущий эпизод"
	graph_node.set_slot(1, true, 0, Color.CRIMSON, false, 0, Color.CRIMSON)
	
	var out_slot = Label.new()
	graph_node.add_child(out_slot)
	out_slot.text = "Следующий эпизод"
	out_slot.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	graph_node.set_slot(2, false, 0, Color.CRIMSON, true, 0, Color.CRIMSON)
	
	_add_options()


func _add_options() -> void:
	var graph_node = GraphNode.new()
	add_child(graph_node)
	graph_node.title = "Выбор"
	graph_node.size = Vector2(300, 0)
	
	var in_slot = Label.new()
	graph_node.add_child(in_slot)
	in_slot.text = "Предыдущий эпизод"
	graph_node.set_slot(0, true, 0, Color.CRIMSON, false, 0, Color.CRIMSON)
	
	var add_option = Button.new()
	graph_node.add_child(add_option)
	add_option.text = "Добавить опцию"
	add_option.icon = EditorIcons.get_icon("Add")
	
	_add_option(graph_node)
	_add_option(graph_node)
	_add_option(graph_node)


func _add_option(graph_node: GraphNode) -> void:
	#var panel_container = PanelContainer.new()
	#graph_node.add_child(panel_container)
	#panel_container.add_theme_stylebox_override("panel", VnePluginController.PANEL_STYLE_BOX)
	
	var option = HBoxContainer.new()
	graph_node.add_child(option)
	
	var button = Button.new()
	option.add_child(button)
	button.icon = EditorIcons.get_icon("GuiClose")
	#button.flat = true
	
	var line_edit = LineEdit.new()
	option.add_child(line_edit)
	#line_edit.flat = true
	line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
