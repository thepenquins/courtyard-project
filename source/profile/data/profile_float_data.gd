class_name ProfileFloatData extends ProfileData


var value: float:
    get:
        return _v
    set(new_value):
        _v = new_value


func _init(data_key: String, data_value: float = 0) -> void:
    super(data_key, data_value)