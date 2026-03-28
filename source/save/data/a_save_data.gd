class_name ASaveData extends RefCounted
## "Абстрактный" класс для данных сохранения.
##
## Классы-наследники обязательно должны будут реализовать метод [method load_data].
## Примеры возможных классов: SaveDataEpisode, SaveDataLocation, SaveDataInventory и другие. 


var type: String = "ASaveData"
var key: String
var _value


func _init(save_data_key: String, save_data_value) -> void:
    key = save_data_key
    _value = save_data_value


func add_data_to_dictionary(dictionary: Dictionary):
    dictionary[key] = {
        "type" : type,
        "value" : _value,
    }


func load_data() -> void:
    pass