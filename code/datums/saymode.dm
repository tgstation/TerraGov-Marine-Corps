/datum/saymode
	var/key
	var/mode

//Return FALSE if you have handled the message. Otherwise, return TRUE and saycode will continue doing saycode things.
//user = whoever said the message
//message = the message
//language = the language.
/datum/saymode/proc/handle_message(mob/living/user, message, datum/language/language)
	return TRUE


/datum/saymode/xeno
	key = "a"
	mode = MODE_ALIEN


/datum/saymode/xeno/handle_message(mob/living/user, message, datum/language/language)
	if(isxeno(user))
		var/mob/living/carbon/Xenomorph/X = user
		if(X.hivemind_talk(message))
			return FALSE
	return TRUE