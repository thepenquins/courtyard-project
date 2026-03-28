class_name ProfileAchievement extends ProfileBoolData


var description: String

var unlocked: bool:
    get:
        return _v


func _init(data_key: String, achievement_description: String) -> void:
    super(data_key, false)
    description = achievement_description