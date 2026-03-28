class_name ProfileData extends RefCounted


var key: String
var _v


func _init(data_key: String, data_value) -> void:
    key = data_key
    _v = data_value