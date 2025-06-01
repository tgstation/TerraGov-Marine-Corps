/datum/emote/living/carbon/human/choke
	key = "choke"
	key_third_person = "chokes"
	message = "chokes!"
	emote_type = EMOTE_AUDIBLE
	stat_allowed = UNCONSCIOUS

/datum/emote/living/carbon/human/choke/get_sound(mob/living/carbon/human/user)
	if(!user.species)
		return
	if(user.species.chokes[user.gender])
		return user.species.chokes[user.gender]
	if(user.species.chokes[NEUTER])
		return user.species.chokes[NEUTER]

/datum/emote/living/carbon/human/sexmoanlight
	key = "sexmoanlight"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/sexmoanhvy
	key = "sexmoanhvy"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/groan
	key = "groan"
	key_third_person = "groans"
	message = "groans."
	emote_type = EMOTE_AUDIBLE
