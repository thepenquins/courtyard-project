class_name ProfileStringData extends ProfileData


var value: String:
    get:
        return _v
    set(new_value):
        _v = new_value


func _init(data_key: String, data_value: String = "") -> void:
    super(data_key, data_value)