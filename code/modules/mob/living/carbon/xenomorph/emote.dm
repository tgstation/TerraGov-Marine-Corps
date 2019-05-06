/datum/emote/living/carbon/Xenomorph
	mob_type_allowed_typecache = /mob/living/carbon/Xenomorph


/datum/emote/living/carbon/Xenomorph/growl
	key = "growl"
	key_third_person = "growls"
	message = "growls!"
	emote_type = EMOTE_AUDIBLE
	sound = 'sound/voice/alien_growl1.ogg'


/datum/emote/living/carbon/Xenomorph/growl/one
	key = "growl1"
	sound = 'sound/voice/alien_growl1.ogg'


/datum/emote/living/carbon/Xenomorph/growl/two
	key = "growl2"
	sound = 'sound/voice/alien_growl2.ogg'


/datum/emote/living/carbon/Xenomorph/growl/three
	key = "growl3"
	sound = 'sound/voice/alien_growl3.ogg'


/datum/emote/living/carbon/Xenomorph/hiss
	key = "hiss"
	key_third_person = "hisses"
	message = "hisses!"
	emote_type = EMOTE_AUDIBLE
	sound = 'sound/voice/alien_hiss1.ogg'


/datum/emote/living/carbon/Xenomorph/hiss/one
	key = "hiss1"
	sound = 'sound/voice/alien_hiss1.ogg'


/datum/emote/living/carbon/Xenomorph/hiss/two
	key = "hiss2"
	sound = 'sound/voice/alien_hiss2.ogg'


/datum/emote/living/carbon/Xenomorph/hiss/three
	key = "hiss3"
	sound = 'sound/voice/alien_hiss3.ogg'


/datum/emote/living/carbon/Xenomorph/needhelp
	key = "heedhelp"
	key_third_person = "needshelp"
	message = "needs help!"
	emote_type = EMOTE_AUDIBLE
	sound = 'sound/voice/alien_help1.ogg'


/datum/emote/living/carbon/Xenomorph/needhelp/one
	key = "needhelp1"
	sound = 'sound/voice/alien_help1.ogg'


/datum/emote/living/carbon/Xenomorph/needhelp/two
	key = "needhelp2"
	sound = 'sound/voice/alien_help2.ogg'


/datum/emote/living/carbon/Xenomorph/roar
	key = "roar"
	key_third_person = "roars"
	message = "roars!"
	emote_type = EMOTE_AUDIBLE
	sound = 'sound/voice/alien_roar1.ogg'


/datum/emote/living/carbon/Xenomorph/roar/one
	key = "roar1"
	sound = 'sound/voice/alien_roar1.ogg'


/datum/emote/living/carbon/Xenomorph/roar/two
	key = "roar2"
	sound = 'sound/voice/alien_roar2.ogg'


/datum/emote/living/carbon/Xenomorph/roar/three
	key = "roar3"
	sound = 'sound/voice/alien_roar3.ogg'


/datum/emote/living/carbon/Xenomorph/roar/four
	key = "roar4"
	sound = 'sound/voice/alien_roar4.ogg'


/datum/emote/living/carbon/Xenomorph/roar/five
	key = "roar5"
	sound = 'sound/voice/alien_roar5.ogg'


/datum/emote/living/carbon/Xenomorph/roar/six
	key = "roar6"
	sound = 'sound/voice/alien_roar6.ogg'


/datum/emote/living/carbon/Xenomorph/tail
	key = "tail"
	key_third_person = "tailsweeps"
	message = "swipes its tail."
	emote_type = EMOTE_AUDIBLE
	sound = 'sound/effects/alien_tail_swipe1.ogg'


/datum/emote/living/carbon/Xenomorph/tail/one
	key = "tail1"
	sound = 'sound/effects/alien_tail_swipe1.ogg'


/datum/emote/living/carbon/Xenomorph/roar/two
	key = "tail2"
	sound = 'sound/effects/alien_tail_swipe2.ogg'


/datum/emote/living/carbon/Xenomorph/roar/three
	key = "tail3"
	sound = 'sound/effects/alien_tail_swipe3.ogg'


/datum/emote/living/carbon/Xenomorph/run_emote(mob/user, params, type_override, intentional = FALSE, prefix)
	if(istype(user, /mob/living/carbon/Xenomorph/Larva))
		playsound(user.loc, "alien_roar_larva", 15)
	else
		return ..()