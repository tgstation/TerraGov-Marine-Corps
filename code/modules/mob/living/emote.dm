/datum/emote/living
	mob_type_allowed_typecache = /mob/living

/datum/emote/living/deathgasp
	key = "deathgasp"
	key_third_person = "deathgasps"
	message = null
	stat_allowed = UNCONSCIOUS
	emote_flags = EMOTE_FORCED_AUDIO

/datum/emote/living/deathgasp/run_emote(mob/user, params, type_override, intentional, prefix)
	message = params
	. = ..()
	message = null
