extends Node


# const STEAM_GAME_ID: int = 3411140


func _enter_tree() -> void:
    # OS.set_environment("SteamAppId", str(STEAM_GAME_ID))
    # OS.set_environment("SteamGameId", str(STEAM_GAME_ID))
    # initialize_steam()
    pass


func initialize_steam() -> void:
    var initialize_response: Dictionary = Steam.steamInitEx()
    print("Инициализация Steam: %s " % initialize_response)


func set_achievement(achievement: String) -> void:
    if not Steam.setAchievement(achievement):
        print("Не удалось установить достижение: '%s'." % achievement)
        return
    
    print("Установка достижения: '%s'" % achievement)

    if not Steam.storeStats():
        print("Не удалось сохранить достижение.")
        return

    print("Данные успешно отправлены в Steam.")