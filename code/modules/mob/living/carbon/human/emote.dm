/datum/emote/living/carbon/human
	mob_type_allowed_typecache = list(/mob/living/carbon/human)


/datum/emote/living/carbon/human/run_emote(mob/living/carbon/human/user, params, type_override, intentional = FALSE, prefix)
	var/paygrade = user.get_paygrade()
	if(paygrade)
		prefix = "<b>[paygrade]</b> "
	return ..()


/datum/emote/living/carbon/human/blink
	key = "blink"
	key_third_person = "blinks"
	message = "blinks."


/datum/emote/living/carbon/human/blink_r
	key = "blink_r"
	message = "blinks rapidly."


/datum/emote/living/carbon/human/bow
	key = "bow"
	key_third_person = "bows"
	message = "bows."
	message_param = "bows to %t."
	flags_emote = EMOTE_RESTRAINT_CHECK


/datum/emote/living/carbon/human/chuckle
	key = "chuckle"
	key_third_person = "chuckles"
	message = "chuckles."
	emote_type = EMOTE_AUDIBLE


/datum/emote/living/carbon/human/clap
	key = "clap"
	key_third_person = "claps"
	message = "claps."
	flags_emote = EMOTE_RESTRAINT_CHECK|EMOTE_VARY|EMOTE_MUZZLE_IGNORE
	emote_type = EMOTE_AUDIBLE
	sound = 'sound/misc/clap.ogg'


/datum/emote/living/carbon/human/collapse
	key = "collapse"
	key_third_person = "collapses"
	message = "collapses!"
	emote_type = EMOTE_AUDIBLE


/datum/emote/living/carbon/human/collapse/run_emote(mob/living/carbon/human/user, params, type_override, intentional = FALSE, prefix)
	. = ..()
	if(!.)
		return
	user.KnockOut(2)


/datum/emote/living/carbon/human/cough
	key = "cough"
	key_third_person = "coughs"
	message = "coughs!"
	emote_type = EMOTE_AUDIBLE


/datum/emote/living/carbon/human/cry
	key = "cry"
	key_third_person = "cries"
	message = "cries."
	emote_type = EMOTE_AUDIBLE


/datum/emote/living/carbon/human/drool
	key = "drool"
	key_third_person = "drools"
	message = "drools."


/datum/emote/living/carbon/human/eyebrow
	key = "eyebrow"
	message = "raises an eyebrow."


/datum/emote/living/carbon/human/faint
	key = "faint"
	key_third_person = "faints"
	message = "faints."


/datum/emote/living/carbon/human/faint/run_emote(mob/living/carbon/human/user, params, type_override, intentional = FALSE, prefix)
	. = ..()
	if(!.)
		return
	user.sleeping += 10


/datum/emote/living/carbon/human/frown
	key = "frown"
	key_third_person = "frowns"
	message = "frowns."


/datum/emote/living/carbon/human/gasp
	key = "gasp"
	key_third_person = "gasps"
	message = "gasps!"
	emote_type = EMOTE_AUDIBLE
	stat_allowed = UNCONSCIOUS


/datum/emote/living/carbon/human/giggle
	key = "giggle"
	key_third_person = "giggles"
	message = "giggles."
	emote_type = EMOTE_AUDIBLE


/datum/emote/living/carbon/human/glare
	key = "glare"
	key_third_person = "glares"
	message = "glares."
	message_param = "glares at %t."
	emote_type = EMOTE_AUDIBLE


/datum/emote/living/carbon/human/yawn
	key = "yawn"
	key_third_person = "yawns"
	message = "yawns."
	emote_type = EMOTE_AUDIBLE


/datum/emote/living/carbon/human/wave
	key = "wave"
	key_third_person = "waves"
	message = "waves."


/datum/emote/living/carbon/human/twitch
	key = "twitch"
	key_third_person = "twitches"
	message = "twitches."


/datum/emote/living/carbon/human/snore
	key = "snore"
	key_third_person = "snores"
	message = "snores."
	emote_type = EMOTE_AUDIBLE
	stat_allowed = UNCONSCIOUS


/datum/emote/living/carbon/human/smile
	key = "smile"
	key_third_person = "smiles"
	message = "smiles."


/datum/emote/living/carbon/human/stare
	key = "stare"
	key_third_person = "stares"
	message = "stares."
	message_param = "stares at %t."


/datum/emote/living/carbon/human/sneeze
	key = "sneeze"
	key_third_person = "sneezes"
	message = "sneezes."
	emote_type = EMOTE_AUDIBLE


/datum/emote/living/carbon/human/shiver
	key = "shiver"
	key_third_person = "shiver"
	message = "shivers."
	emote_type = EMOTE_AUDIBLE


/datum/emote/living/carbon/human/sigh
	key = "sigh"
	key_third_person = "sighs"
	message = "sighs."
	emote_type = EMOTE_AUDIBLE


/datum/emote/living/carbon/human/shrug
	key = "shrug"
	key_third_person = "shrugs"
	message = "shrugs."


/datum/emote/living/carbon/human/shakehead
	key = "shakehead"
	key_third_person = "shakeheads"
	message = "shakes their head."
	emote_type = EMOTE_AUDIBLE


/datum/emote/living/carbon/human/nod
	key = "nod"
	key_third_person = "nods"
	message = "nods."
	message_param = "nods at %t."


/datum/emote/living/carbon/human/glare
	key = "glare"
	key_third_person = "glares"
	message = "glares."
	message_param = "glares at %t."
	emote_type = EMOTE_AUDIBLE


/datum/emote/living/carbon/human/grin
	key = "grin"
	key_third_person = "grins"
	message = "grins."


/datum/emote/living/carbon/human/grumble
	key = "grumble"
	key_third_person = "grumbles"
	message = "grumbles!"
	emote_type = EMOTE_AUDIBLE


/datum/emote/living/carbon/human/signal
	key = "signal"
	key_third_person = "signals"
	message_param = "raises %t fingers."
	flags_emote = EMOTE_RESTRAINT_CHECK


/datum/emote/living/carbon/human/sign/select_param(mob/user, params)
	params = text2num(params)
	if(!isnum(params))
		return message
	params = CLAMP(params, 1, 10)
	return ..()


/datum/emote/living/carbon/human/mumble
	key = "mumble"
	key_third_person = "mumbles"
	message = "mumbles!"
	emote_type = EMOTE_AUDIBLE


/datum/emote/living/carbon/human/moan
	key = "moan"
	key_third_person = "moans"
	message = "moans!"
	emote_type = EMOTE_AUDIBLE


/datum/emote/living/carbon/human/laugh
	key = "laugh"
	key_third_person = "laughs"
	message = "laughs."
	emote_type = EMOTE_AUDIBLE


/datum/emote/living/carbon/human/laugh/get_sound(mob/living/user)
	if(user.gender == FEMALE)
		return 'sound/voice/human_female_laugh_1.ogg'
	else
		return pick('sound/voice/human_male_laugh_1.ogg', 'sound/voice/human_male_laugh_2.ogg')


/datum/emote/living/carbon/human/hug
	key = "hug"
	key_third_person = "hugs"
	message = "hugs themself."
	message_param = "hugs %t."
	flags_emote = EMOTE_RESTRAINT_CHECK
	emote_type = EMOTE_AUDIBLE


/datum/emote/living/carbon/human/look
	key = "look"
	key_third_person = "looks"
	message = "looks."
	message_param = "looks at %t."


/datum/emote/living/carbon/human/handshake
	key = "handshake"
	message = "shakes their own hands."
	message_param = "shakes hands with %t."
	flags_emote = EMOTE_RESTRAINT_CHECK
	emote_type = EMOTE_AUDIBLE


/datum/emote/living/carbon/human/salute
	key = "salute"
	key_third_person = "salutes"
	message = "salutes."
	message_param = "salutes to %t."
	flags_emote = EMOTE_RESTRAINT_CHECK
	sound = 'sound/misc/salute.ogg'


/datum/emote/living/carbon/human/golfclap
	key = "golfclap"
	key_third_person = "golfclaps"
	message = "claps, clearly unimpressed."
	flags_emote = EMOTE_RESTRAINT_CHECK
	sound = 'sound/misc/golfclap.ogg'


/datum/emote/living/carbon/human/scream
	key = "scream"
	key_third_person = "screams"
	message = "screams!"
	emote_type = EMOTE_AUDIBLE


/datum/emote/living/carbon/human/scream/get_sound(mob/living/carbon/human/user)
	if(!user.species)
		return
	if(user.species.screams[user.gender])
		return user.species.screams[user.gender]
	if(user.species.screams[NEUTER])
		return user.species.screams[NEUTER]


/datum/emote/living/carbon/human/scream/run_emote(mob/user, params, type_override, intentional = FALSE, prefix)
	. = ..()
	if(!.)
		return
	var/image/scream = image('icons/mob/talk.dmi', user, icon_state = "scream")
	user.add_emote_overlay(scream)


/datum/emote/living/carbon/human/medic
	key = "medic"
	message = "calls for a medic!"
	emote_type = EMOTE_AUDIBLE


/datum/emote/living/carbon/human/medic/get_sound(mob/living/carbon/human/user)
	if(user.gender == MALE)
		if(prob(95))
			return 'sound/voice/human_male_medic.ogg'
		else
			return 'sound/voice/human_male_medic2.ogg'
	else
		return 'sound/voice/human_female_medic.ogg'


/datum/emote/living/carbon/human/medic/run_emote(mob/user, params, type_override, intentional = FALSE, prefix)
	. = ..()
	if(!.)
		return
	var/image/medic = image('icons/mob/talk.dmi', user, icon_state = "medic")
	user.add_emote_overlay(medic)


/datum/emote/living/carbon/human/pain
	key = "pain"
	message = "cries out in pain!"
	emote_type = EMOTE_AUDIBLE


/datum/emote/living/carbon/human/pain/get_sound(mob/living/carbon/human/user)
	if(!user.species)
		return
	if(user.species.paincries[user.gender])
		return user.species.paincries[user.gender]
	if(user.species.paincries[NEUTER])
		return user.species.paincries[NEUTER]


/datum/emote/living/carbon/human/pain/run_emote(mob/user, params, type_override, intentional = FALSE, prefix)
	. = ..()
	if(!.)
		return
	var/image/pain = image('icons/mob/talk.dmi', user, icon_state = "pain")
	user.add_emote_overlay(pain)