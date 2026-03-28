class_name RSEEmotions
extends RefCounted


enum Emotion {
	NEUTRAL,    # Нейтрально
	JOY,        # Радость/восторг
	ANGER,      # Гнев/ярость/раздражение
	SURPRISE,   # Удивление/любопытство
	FEAR,       # Страх/паника
	SADNESS,    # Грусть/меланхолия
	CONFUSION,  # Растерянность/сомнение
	CALM        # Спокойствие/равнодушие
}

const EMOTION_NAMES = {
	Emotion.NEUTRAL: "нейтрально",
	Emotion.JOY: "радость",
	Emotion.ANGER: "гнев",
	Emotion.SURPRISE: "удивление",
	Emotion.FEAR: "страх",
	Emotion.SADNESS: "грусть",
	Emotion.CONFUSION: "растерянность",
	Emotion.CALM: "спокойствие"
}


static func parse(text: String) -> Emotion:
	text = text.strip_edges()
	if text.is_empty():
		return Emotion.NEUTRAL
	
	var last_char := text[-1] if text.length() > 0 else ""
	var has_ellipsis := "..." in text
	var is_all_caps := text == text.to_upper()
	var is_short := text.split(" ", false).size() <= 2
	var has_repeats := _has_repeated_punct(text)

	# Упрощённые правила
	if "?!" in text or "!?" in text:
		return Emotion.CONFUSION
	elif last_char == "?":
		return Emotion.FEAR if has_repeats else Emotion.SURPRISE
	elif last_char == "!":
		if is_all_caps or has_repeats:
			return Emotion.ANGER
		return Emotion.JOY
	elif has_ellipsis:
		return Emotion.SADNESS
	elif last_char == ".":
		return Emotion.CALM
	elif is_all_caps:
		return Emotion.ANGER
	elif has_repeats:
		return Emotion.FEAR
	else:
		return Emotion.NEUTRAL


static func _has_repeated_punct(text: String) -> bool:
	return ("!!" in text) or ("??" in text) or ("..." in text)
