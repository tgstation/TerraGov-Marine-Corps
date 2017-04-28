/mob/living/silicon/decoy/ship_ai //For the moment, pending better pathing.
	New()
		..()
		name = MAIN_AI_SYSTEM
		desc = "This is the the artificial intelligence system for the [MAIN_SHIP_NAME]. Like many other military-grade AI systems, this one was manufactured by Weyland-Yutani."
		R = new(src)

//Should likely just replace this with an actual AI mob in the future. Might as well.
/mob/living/silicon/decoy
	name = "AI"
	icon = 'icons/Marine/ai.dmi'
	icon_state = "hydra"
	anchored = 1
	canmove = 0
	density = 1 //Do not want to see past it.
	bound_height = 96 //putting this in so we can't walk through our machine.
	bound_width = 64
	var/obj/item/device/radio/headset/mcom/R //The thing it speaks into.

	Life()
		if(stat == DEAD) r_FAL
		if(health <= config.health_threshold_dead && stat != DEAD) death()

	updatehealth()
		if(status_flags & GODMODE)
			health = 100
			stat = CONSCIOUS
		else
			health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()

	death(gibbed)
		set waitfor = 0
		if(stat == DEAD) r_FAL
		icon_state = "hydra-off"
		sleep(20)
		explosion(loc, -1, 0, 8, 12)
		return ..(gibbed)

	say(message) //General communication across the ship.
		if(stat || !message) r_FAL
		message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
		R.talk_into(src, message, "headset", "states", languages[1])
		r_TRU

/*Specific communication to a terminal.
/mob/living/silicon/decoy/proc/transmit(message)
*/