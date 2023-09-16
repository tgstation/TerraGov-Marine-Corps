GLOBAL_LIST_INIT(ru_key_to_en_key, list("й" = "q", "ц" = "w", "у" = "e", "к" = "r", "е" = "t", "н" = "y", "г" = "u", "ш" = "i", "щ" = "o", "з" = "p", "х" = "\[", "ъ" = "]",
										"ф" = "a", "ы" = "s", "в" = "d", "а" = "f", "п" = "g", "р" = "h", "о" = "j", "л" = "k", "д" = "l", "ж" = ";", "э" = "'",
										"я" = "z", "ч" = "x", "с" = "c", "м" = "v", "и" = "b", "т" = "n", "ь" = "m", "б" = ",", "ю" = "."))

GLOBAL_LIST_INIT(en_key_to_ru_key, list(
	"q" = "й", "w" = "ц", "e" = "у", "r" = "к", "t" = "е", "y" = "н",
	"u" = "г", "i" = "ш", "o" = "щ", "p" = "з",
	"a" = "ф", "s" = "ы", "d" = "в", "f" = "а", "g" = "п", "h" = "р",
	"j" = "о", "k" = "л", "l" = "д", ";" = "ж", "'" = "э", "z" = "я",
	"x" = "ч", "c" = "с", "v" = "м", "b" = "и", "n" = "т", "m" = "ь",
	"," = "б", "." = "ю",
))

/proc/convert_ru_key_to_en_key(var/_key)
	var/new_key = lowertext(_key)
	new_key = GLOB.ru_key_to_en_key[new_key]
	if(!new_key)
		return _key
	return uppertext(new_key)

/proc/convert_ru_string_to_en_string(text)
	. = ""
	for(var/i in 1 to length_char(text))
		. += convert_ru_key_to_en_key(copytext_char(text, i, i+1))

/proc/sanitize_en_key_to_ru_key(char)
	var/new_char = GLOB.en_key_to_ru_key[lowertext(char)]
	return (new_char != null) ? new_char : char

/proc/sanitize_en_string_to_ru_string(text)
	. = ""
	for(var/i in 1 to length_char(text))
		. += sanitize_en_key_to_ru_key(copytext_char(text, i, i+1))
