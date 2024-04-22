/datum/emote/silicon
	mob_type_allowed_typecache = list(/mob/living/silicon)
	emote_type = EMOTE_AUDIBLE

/datum/emote/silicon/boop
	key = "boop"
	key_third_person = "boops"
	message = "boops."

/datum/emote/silicon/buzz
	key = "buzz"
	key_third_person = "buzzes"
	message = "buzzes."
	message_param = "buzzes at %t."
	sound = 'sound/blank.ogg'

/datum/emote/silicon/buzz2
	key = "buzz2"
	message = "buzzes twice."
	sound = 'sound/blank.ogg'

/datum/emote/silicon/chime
	key = "chime"
	key_third_person = "chimes"
	message = "chimes."
	sound = 'sound/blank.ogg'

/datum/emote/silicon/honk
	key = "honk"
	key_third_person = "honks"
	message = "honks."
	vary = TRUE
	sound = 'sound/blank.ogg'

/datum/emote/silicon/ping
	key = "ping"
	key_third_person = "pings"
	message = "pings."
	message_param = "pings at %t."
	sound = 'sound/blank.ogg'

/datum/emote/silicon/sad
	key = "sad"
	message = "plays a sad trombone..."
	sound = 'sound/blank.ogg'

/datum/emote/silicon/warn
	key = "warn"
	message = "blares an alarm!"
	sound = 'sound/blank.ogg'

/mob/living/silicon/robot/verb/powerwarn()
	set category = "Robot Commands"
	set name = "Power Warning"

	if(stat == CONSCIOUS)
		if(!cell || !cell.charge)
			visible_message("<span class='notice'>The power warning light on <span class='name'>[src]</span> flashes urgently.</span>", \
							"You announce you are operating in low power mode.")
			playsound(loc, 'sound/blank.ogg', 50, FALSE)
		else
			to_chat(src, "<span class='warning'>I can only use this emote when you're out of charge.</span>")
