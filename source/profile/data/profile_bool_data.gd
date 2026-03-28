class_name ProfileBoolData extends ProfileData


var value: bool:
    get:
        return _v
    set(new_value):
        _v = new_value


func _init(data_key: String, data_value: bool = false) -> void:
    super(data_key, data_value)