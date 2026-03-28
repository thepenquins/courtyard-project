class_name ProfileIntData extends ProfileData


var value: int:
    get:
        return _v
    set(new_value):
        _v = new_value


func _init(data_key: String, data_value: int = 0) -> void:
    super(data_key, data_value)