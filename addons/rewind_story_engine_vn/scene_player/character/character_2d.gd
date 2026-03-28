@tool class_name VneCharacter2D extends Node2D


@export var uuid: String:
	set(value):
		uuid = value
		_load_character_resource()
@export var animated_sprites: Dictionary[String, AnimatedSprite2D]
@export var talking_animated_sprites: Array[AnimatedSprite2D]

@export_subgroup("Tools")
@export_tool_button("Создать анимации из файлов", "CreateNewSceneFrom") var button = _parse_animations

const ANIMATIONS_DIRECTORY: String = "emotions"
const SPRITES_DIRECTORY: String = "sprites"

var _character_resource: VneCharacterResource

var _emotions_directory: String
var _sprites_directory: String

var _loaded_textures: Dictionary[String, Texture2D]

var visibility: bool = false
var _visibility_tween: Tween


var emotion: String:
	set(value):
		if emotion == value:
			return
		emotion = value
		for animated_sprite: AnimatedSprite2D in animated_sprites.values():
			if animated_sprite.sprite_frames.has_animation(emotion):
				animated_sprite.animation = emotion

var talking: bool:
	set(value):
		if talking == value:
			return
		talking = value
		for animated_sprite in talking_animated_sprites:
			if talking:
				animated_sprite.play()
			else:
				animated_sprite.stop()


func _ready() -> void:
	if Engine.is_editor_hint():
		_setting_directories()
		_check_directories()
	
	#_load_character_resource()


func _setting_directories() -> void:
	_emotions_directory = scene_file_path.get_base_dir().path_join(ANIMATIONS_DIRECTORY)
	_sprites_directory = scene_file_path.get_base_dir().path_join(SPRITES_DIRECTORY)


func _check_directories() -> void:
	var dir_access = DirAccess.open(scene_file_path.get_base_dir())
	
	if not dir_access.dir_exists(_emotions_directory):
		dir_access.make_dir(_emotions_directory)
		
	if not dir_access.dir_exists(_sprites_directory):
		dir_access.make_dir(_sprites_directory)


func _load_character_resource() -> void:
	_character_resource = VNE.visual_novel.get_character_by_uuid(uuid)
	if not _character_resource:
		push_warning("Не удалось получить персонажа по UUID: %s." % uuid)
	else:
		print_rich("Ресурс персонажа [b]%s[/b] успешно загружен." % _character_resource.name)


func _parse_animations() -> void:
	if _character_resource:
		_character_resource.emotions.clear()
	
	for file in get_files_in_directory(_emotions_directory, VneCharacter2DEmotion.FILE_EXTENSION):
		var emotion = VneCharacter2DEmotion.new(_emotions_directory.path_join(file))
		for animation: VneCharacter2DAnimation in emotion.animations:
			_set_animation(emotion.name, animation)
		if _character_resource:
			_character_resource.emotions.append(emotion.name)


func get_files_in_directory(directory: String, extension: String) -> PackedStringArray:
	var files: PackedStringArray
	
	var dir = DirAccess.open(directory)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(extension):
				files.append(file_name)
			file_name = dir.get_next()
	
	return files


func _set_animation(emotion_name: String, animation: VneCharacter2DAnimation) -> void:
	if not animated_sprites.has(animation.animated_sprite_name):
		return
	
	var animated_sprite = animated_sprites[animation.animated_sprite_name]
	if animated_sprite.sprite_frames == null:
		animated_sprite.sprite_frames = SpriteFrames.new()
		animated_sprite.sprite_frames.remove_animation("default")
	
	if animated_sprite.sprite_frames.has_animation(emotion_name):
		animated_sprite.sprite_frames.remove_animation(emotion_name)
	
	animated_sprite.sprite_frames.add_animation(emotion_name)
	animated_sprite.sprite_frames.set_animation_speed(emotion_name, animation.speed)
	for sprite in animation.sprites:
		if not _loaded_textures.has(sprite): # Загружаем текстуру, если её ещё не загружали.
			if not FileAccess.file_exists(_sprites_directory.path_join(sprite)):
				push_warning("Отсутствует спрайт: %s" % _sprites_directory.path_join(sprite))
				continue # Пропускаем шаг, если спрайта не существует.
			var texture = load(_sprites_directory.path_join(sprite))
			if texture is not Texture2D:
				continue # Пропускаем шаг, если это по какой-то причине не текстура.
			_loaded_textures[sprite] = texture
		animated_sprite.sprite_frames.add_frame(emotion_name, _loaded_textures[sprite])


func set_visibility(visible: bool, instant: bool = false) -> void:
	if _visibility_tween and _visibility_tween.is_valid():
		_visibility_tween.kill()

	visibility = visible
	var target_alpha = 1.0 if visible else 0.0

	if instant:
		modulate.a = target_alpha
		return

	if is_equal_approx(modulate.a, target_alpha):
		return

	_visibility_tween = create_tween()
	_visibility_tween.tween_property(self, "modulate:a", target_alpha, 0.5).set_trans(Tween.TRANS_BACK)
