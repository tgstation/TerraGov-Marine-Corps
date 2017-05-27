/datum/hud/larva/New(mob/living/carbon/Xenomorph/Larva/owner)
	..()
	var/obj/screen/using

	using = new /obj/screen/mov_intent()
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = (owner.m_intent == "run" ? "running" : "walking")
	static_inventory += using
	move_intent = using

	healths = new /obj/screen/healths/alien()
	infodisplay += healths

	locate_queen = new /obj/screen/queen_locator()
	infodisplay += locate_queen

	blind_icon = new /obj/screen/blind()
	screenoverlays += blind_icon

	flash_icon = new /obj/screen/flash()
	screenoverlays += flash_icon


/mob/living/carbon/Xenomorph/Larva/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/larva(src)