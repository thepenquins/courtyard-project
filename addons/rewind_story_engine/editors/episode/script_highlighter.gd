@tool
class_name  RSEScriptHighlighter 
extends CodeHighlighter


var color_character: Color = Color("#FF9999")
var color_comment: Color = Color("#777777")
var color_text: Color = Color("#88CCFF") 
var color_uuid: Color = Color("#666666") 


func _get_line_syntax_highlighting(line: int) -> Dictionary:
    var highlights = {}

    var text = get_text_edit().get_line(line)

    # Проверяем начало строки
    if text.begins_with("—"):
        highlights[0] = {"color": color_text, "length": text.length()}
    elif text.begins_with("#"):
        highlights[0] = {"color": color_comment, "length": text.length()}
    elif text.begins_with("[UUID:"):
        highlights[0] = {"color": color_uuid, "length": text.length()}
    elif text.strip_edges() != "":
        var character = RSE.get_character_by_name(text)
        var color = color_character
        if character != null:
            color = character.color
        highlights[0] = {"color": color, "length": text.length()}
    
    return highlights
