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
		var/mob/living/carbon/xenomorph/X = user
		if(X.hivemind_talk(message))
			return FALSE
	return TRUE


/datum/saymode/binary //everything that uses .b (silicons, drones, blobbernauts/spores, swarmers)
	key = MODE_KEY_BINARY
	mode = MODE_BINARY


/datum/saymode/binary/handle_message(mob/living/user, message, datum/language/language)
	if(user.binarycheck())
		user.robot_talk(message)
		return FALSE
	return FALSE


/datum/saymode/holopad
	key = "h"
	mode = MODE_HOLOPAD


/datum/saymode/holopad/handle_message(mob/living/user, message, datum/language/language)
	if(isAI(user))
		var/mob/living/silicon/ai/AI = user
		AI.holopad_talk(message, language)
		return FALSE
	return TRUE