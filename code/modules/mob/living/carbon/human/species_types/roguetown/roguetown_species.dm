/datum/species
	var/amtfail = 0

/datum/species/proc/get_accent_list()
	return

/datum/species/proc/handle_speech(datum/source, mob/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]

	if(message)
		if(message[1])
			if(message[1] != "*")
				message = " [message]"
//				var/list/spellcheck_words = strings("spellcheck.json", "spellcheck") Not necessary to fix, but it's just deleting the word. Temporarily commented out, probably permanent.
				var/list/accent_words = strings("accent_universal.json", "universal")
				
/* 				for(var/key in spellcheck_words)
					var/value = accent_words[key]
					if(islist(value))
						value = pick(value)

					message = replacetextEx(message, "[key]", "[value] ") */

				for(var/key in accent_words)
					var/value = accent_words[key]
					if(islist(value))
						value = pick(value)

					message = replacetextEx(message, " [uppertext(key)]", " [uppertext(value)]")
					message = replacetextEx(message, " [capitalize(key)]", " [capitalize(value)]")
					message = replacetextEx(message, " [key]", " [value]")


		var/list/species_accent = get_accent_list()
		if(species_accent)
			if(message[1] != "*")
				message = " [message]"
				for(var/key in species_accent)
					var/value = species_accent[key]
					if(islist(value))
						value = pick(value)

					message = replacetextEx(message, " [uppertext(key)]", " [uppertext(value)]")
					message = replacetextEx(message, " [capitalize(key)]", " [capitalize(value)]")
					message = replacetextEx(message, " [key]", " [value]")

	speech_args[SPEECH_MESSAGE] = trim(message)
