//general stuff
/proc/sanitize_integer(number, min = 0, max = 1, default = 0)
	if(isnum(number))
		number = round(number)
		if(min <= number && number <= max)
			return number
	return default

/proc/sanitize_float(number, min=0, max=1, accuracy=1, default=0)
	if(isnum(number))
		number = round(number, accuracy)
		if(min <= number && number <= max)
			return number
	return default

/proc/sanitize_text(text, default = "")
	if(istext(text))
		return text
	return default

/**
 * Makes sure value is a list
 * Args:
 * value - The list we're ensuring is actually a list
 * default - The set default that will be given as fallback.
 * required_amount - The required length of value for it to be valid, otherwise will continue to check for a fallback default.
 */
/proc/sanitize_islist(list/value, default, required_amount)
	if(length(value) && (!required_amount || (length(value) == required_amount)))
		return value
	if(default)
		return default

/// Sanitize the custom emote list
/proc/sanitize_is_full_emote_list(value)
	if(length(value) == CUSTOM_EMOTE_SLOTS)
		return value
	if(!value)
		value = list()
	for(var/i in (length(value)+1) to CUSTOM_EMOTE_SLOTS)
		var/datum/custom_emote/emote = new
		emote.id = i
		value += emote
	return value

/proc/sanitize_inlist(value, list/L, default)
	if(value in L)
		return value
	if(default)
		return default
	if(length(L))
		return L[1]

///a wrapper with snowflake handling for tts
/proc/sanitize_inlist_tts(value, gender)
	var/list/to_check
	if(SStts.tts_enabled)
		to_check = SStts.available_speakers
	else if(fexists("data/cached_tts_voices.json"))
		var/list/text_data = rustg_file_read("data/cached_tts_voices.json")
		to_check = json_decode(text_data)
	if(!length(to_check))
		to_check = list("Female 01")
	return sanitize_inlist(value, to_check, pick(to_check))

/proc/sanitize_inlist_assoc(value, list/L, default)
	for(var/i in L)
		if(L[i] == value)
			return value
	if(default)
		return default


//more specialised stuff
/proc/sanitize_gender(gender, neuter = FALSE, plural = FALSE, default = MALE)
	switch(gender)
		if(MALE, FEMALE)
			return gender
		if(NEUTER)
			if(neuter)
				return gender
			else
				return default
		if(PLURAL)
			if(plural)
				return gender
			else
				return default
	return default


/proc/sanitize_ethnicity(ethnicity, default = "Western")
	if(ethnicity in GLOB.ethnicities_list)
		return ethnicity

	return default


/proc/sanitize_hexcolor(color, desired_format = 3, include_crunch = FALSE, default = "#000000")
	var/crunch = include_crunch ? "#" : ""
	if(!istext(color))
		return default

	var/start = 1 + (text2ascii(color, 1) == 35)
	var/len = length(color)
	var/char = ""
	// RRGGBB -> RGB but awful
	var/convert_to_shorthand = desired_format == 3 && length_char(color) > 3

	. = ""
	var/i = start
	while(i <= len)
		char = color[i]
		switch(text2ascii(char))
			if(48 to 57)		//numbers 0 to 9
				. += char
			if(97 to 102)		//letters a to f
				. += char
			if(65 to 70)		//letters A to F
				. += lowertext(char)
			else
				break
		i += length(char)
		if(convert_to_shorthand && i <= len) //skip next one
			i += length(color[i])

	if(length_char(.) != desired_format)
		if(default)
			return default
		return crunch + repeat_string(desired_format, "0")

	return crunch + .
