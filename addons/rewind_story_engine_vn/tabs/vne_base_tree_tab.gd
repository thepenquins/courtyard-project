@abstract
class_name VneBaseTreeTab
extends Control


@export var tree: Tree
var _tree_root: TreeItem
var _selected_item: TreeItem

@export var popup_menu: PopupMenu
@export var confirmation_dialog: ConfirmationDialog


func initialize() -> void:
	_initialize_process()


@abstract func _initialize_process() -> void


func _ready() -> void:
	tree.cell_selected.connect(_on_tree_cell_selected)
	tree.item_mouse_selected.connect(_on_tree_item_mouse_selected)
	tree.button_clicked.connect(_on_tree_button_clicked)
	if popup_menu != null:
		popup_menu.index_pressed.connect(_on_popup_menu_index_pressed)
	if confirmation_dialog != null:
		confirmation_dialog.confirmed.connect(_on_confirmation_dialog_confirmed)
		confirmation_dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_SCREEN_WITH_MOUSE_FOCUS
	
	tree.allow_rmb_select = true


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		_pre_update_tree_process()
		update_tree()
		_after_update_tree_process()


@abstract func _pre_update_tree_process() -> void
@abstract func _after_update_tree_process() -> void


func update_tree(root_name: String = "root") -> void:
	tree.clear()
	_tree_root = tree.create_item()
	_tree_root.set_text(0, root_name)
	
	_pre_fill_tree_process()
	fill_tree()

@abstract func _pre_fill_tree_process() -> void


## Заполнить дерево элементами.
@abstract func fill_tree() -> void


func add_item(item_name: String, parent: TreeItem = null) -> TreeItem:
	if parent == null:
		parent = _tree_root
	var item = tree.create_item(parent)
	item.set_text(0, item_name)
	return item


## Обработка выбора элемента дерева.
func _on_tree_cell_selected() -> void:
	_selected_item = tree.get_selected()


## Обработка нажатия кнопки мыши на элементе дерева. 
func _on_tree_item_mouse_selected(mouse_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == MouseButton.MOUSE_BUTTON_RIGHT:
		if popup_menu != null:
			popup_menu.position = get_screen_transform().origin + mouse_position
			popup_menu.popup()


## Обработка нажатия добавленных кнопок на элементе дерева.
func _on_tree_button_clicked(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
	pass


func _on_popup_menu_index_pressed(index: int) -> void:
	pass


func _on_confirmation_dialog_confirmed() -> void:
	pass
