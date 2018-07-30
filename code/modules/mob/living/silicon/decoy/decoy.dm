/mob/living/silicon/decoy/ship_ai //For the moment, pending better pathing.
	New()
		..()
		name = MAIN_AI_SYSTEM
		desc = "This is the artificial intelligence system for the [MAIN_SHIP_NAME]. Like many other military-grade AI systems, this one was manufactured by Weyland-Yutani."
		ai_headset = new(src)

//Should likely just replace this with an actual AI mob in the future. Might as well.
/mob/living/silicon/decoy
	name = "AI"
	icon = 'icons/Marine/ai.dmi'
	icon_state = "hydra"
	anchored = 1
	canmove = 0
	density = 1 //Do not want to see past it.
	bound_height = 64 //putting this in so we can't walk through our machine.
	bound_width = 96
	var/obj/item/device/radio/headset/almayer/mcom/ai/ai_headset //The thing it speaks into.
	var/sound/ai_sound //The lines that it plays when speaking.

/mob/living/silicon/decoy/Life()
	if(stat == DEAD) r_FAL
	if(health <= config.health_threshold_dead && stat != DEAD) death()

/mob/living/silicon/decoy/updatehealth()
	if(status_flags & GODMODE)
		health = 100
		stat = CONSCIOUS
	else
		health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()

/mob/living/silicon/decoy/death(gibbed, deathmessage = "sparks up and falls silent...")
	set waitfor = 0
	if(stat == DEAD) r_FAL
	icon_state = "hydra-off"
	sleep(20)
	explosion(loc, -1, 0, 8, 12)
	return ..()

/mob/living/silicon/decoy/say(message, new_sound) //General communication across the ship.
	if(stat || !message) r_FAL

	ai_sound = new_sound ? new_sound : 'sound/misc/interference.ogg' //Remember the sound we need to play.

	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	var/message_mode = parse_message_mode(message) //I really prefer my rewrite of all this.

	switch(message_mode)
		if("headset") message = copytext(message, 2)
		if("broadcast") message_mode = "headset"
		else message = copytext(message, 3)

	ai_headset.talk_into(src, message, message_mode, "states", languages[1])
	r_TRU

/mob/living/silicon/decoy/parse_message_mode(message)
	. = "broadcast"

	if(length(message) >= 1 && copytext(message,1,2) == ";")
		return "headset"

	if(length(message) >= 2)
		var/channel_prefix = copytext(message, 1 ,3)
		channel_prefix = department_radio_keys[channel_prefix]
		if(channel_prefix) return channel_prefix


/*Specific communication to a terminal.
/mob/living/silicon/decoy/proc/transmit(message)
*/