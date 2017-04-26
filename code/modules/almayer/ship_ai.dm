/mob/living/silicon/decoy/ship_ai
	icon = 'icons/Marine/ai.dmi'
	icon_state = "hydra"
	density = 1 //Do not want to see past it.
	bound_height = 96 //putting this in so we can't walk through our machine.
	bound_width = 64
	var/obj/item/device/radio/R

	New()
		..()
		name = MAIN_AI_SYSTEM
		desc = "This is the the artificial intelligence system for the [MAIN_SHIP_NAME]. Like many other military-grade AI systems, this one was manufactured by Weyland-Yutani."
		R = new(src)

	say(message)
		if(stat || !message) r_FAL

		message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

		R.talk_into(src,message, "headset", "states", languages[1])
		r_TRU