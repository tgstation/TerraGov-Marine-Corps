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

/datum/emote/living/carbon/xenomorph/xurrender
    key = "xurrender"
    key_third_person = "xurrenders"
    message = "puts their hands on their head and falls to the ground, they xurrender!"
    emote_type = EMOTE_AUDIBLE
    stat_allowed = UNCONSCIOUS
    sound = 'sound/machines/beepalert.ogg'

/datum/emote/living/carbon/xenomorph/xurrender/run_emote(mob/user, params, type_override, intentional)
    . = ..()
    if(. && isliving(user))
        var/mob/living/L = user
        L.Paralyze(450 SECONDS)

/datum/emote/living/carbon/xenomorph/xurrender/run_emote(mob/user, params, type_override, intentional = TRUE, prefix)
	if(!isxeno(user))
		return
	if(isxenolarva(user))
		return //Because larva replace the emote
	. = ..()
	var/image/surrendering = image('icons/mob/effects/talk.dmi', user, icon_state = "surrendering")
	user.add_emote_overlay(surrendering, 90 SECONDS) // Xenos got para resist, dont change this
// And the sexy version here

/datum/emote/living/carbon/xenomorph/xubmit
    key = "xubmit"
    key_third_person = "xubmits"
    message = "falls to the ground and submits, offering their body for mercy!"
    emote_type = EMOTE_AUDIBLE
    stat_allowed = UNCONSCIOUS
    sound = 'ntf_modular/sound/misc/mat/end.ogg'

/datum/emote/living/carbon/xenomorph/xubmit/run_emote(mob/user, params, type_override, intentional)
    . = ..()
    if(. && isliving(user))
        var/mob/living/L = user
        L.Paralyze(450 SECONDS)

/datum/emote/living/carbon/xenomorph/xubmit/run_emote(mob/user, params, type_override, intentional = TRUE, prefix)
	if(!isxeno(user))
		return
	if(isxenolarva(user))
		return //Because larva replace the emote
	. = ..()
	var/image/submitting = image('icons/mob/effects/talk.dmi', user, icon_state = "submit")
	user.add_emote_overlay(submitting, 90 SECONDS) //Xenos need to be stunned for longer, dont change this


/datum/emote/living/carbon/human/surrender
    key = "surrender"
    key_third_person = "surrenders"
    message = "puts their hands on their head and falls to the ground, they surrender!"
    emote_type = EMOTE_AUDIBLE
    stat_allowed = UNCONSCIOUS
    sound = 'sound/machines/beepalert.ogg'

/datum/emote/living/carbon/human/surrender/run_emote(mob/user, params, type_override, intentional)
    . = ..()
    if(. && isliving(user))
        var/mob/living/L = user
        L.Paralyze(90 SECONDS)

/datum/emote/living/carbon/human/surrender/run_emote(mob/user, params, type_override, intentional = TRUE, prefix)
    if(!ishuman(user))
        return
    . = ..()
    var/image/surrendering = image('icons/mob/effects/talk.dmi', user, icon_state = "surrendering")
    user.add_emote_overlay(surrendering, 90 SECONDS)
// And now for the sexy varient

/datum/emote/living/carbon/human/submit
    key = "submit"
    key_third_person = "submits"
    message = "falls to the ground and submits, offering their body for mercy!"
    emote_type = EMOTE_AUDIBLE
    stat_allowed = UNCONSCIOUS
    sound = 'ntf_modular/sound/misc/mat/end.ogg'

/datum/emote/living/carbon/human/submit/run_emote(mob/user, params, type_override, intentional)
    . = ..()
    if(. && isliving(user))
        var/mob/living/L = user
        L.Paralyze(90 SECONDS)

/datum/emote/living/carbon/human/submit/run_emote(mob/user, params, type_override, intentional = TRUE, prefix)
    if(!ishuman(user))
        return
    . = ..()
    var/image/submitting = image('icons/mob/effects/talk.dmi', user, icon_state = "submit")
    user.add_emote_overlay(submitting, 90 SECONDS)

