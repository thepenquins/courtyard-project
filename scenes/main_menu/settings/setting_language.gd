extends OptionButton


var locales: PackedStringArray


func _ready():
	locales = _remove_duplicate_locales(TranslationServer.get_loaded_locales())
	locales.append("ru_RU")
	
	for locale in locales:
		add_item(TranslationServer.get_locale_name(locale))
	
	select(locales.find(Settings.locale))
	
	if (locales.size() < 2):
		disabled = true
		return
	
	item_selected.connect(_set_language)


func _set_language(index: int):
	Settings.locale = locales[index]


func _remove_duplicate_locales(all_locales: Array) -> Array:
	var unique: Array = []
	for locale in all_locales:
		if not unique.has(locale):
			unique.append(locale)
	return unique
