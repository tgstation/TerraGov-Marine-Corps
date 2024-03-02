
/obj/structure/xeno/resin_jelly_pod
	name = "Resin jelly pod"
	desc = "A large resin pod. Inside is a thick, viscous fluid that looks like it doesnt burn easily."
	icon = 'icons/Xeno/resinpod.dmi'
	icon_state = "resinpod"
	density = FALSE
	opacity = FALSE
	anchored = TRUE
	max_integrity = 250
	layer = RESIN_STRUCTURE_LAYER
	pixel_x = -16
	pixel_y = -16
	xeno_structure_flags = IGNORE_WEED_REMOVAL

	hit_sound = "alien_resin_move"
	destroy_sound = "alien_resin_move"
	///How many actual jellies the pod has stored
	var/chargesleft = 0
	///Max amount of jellies the pod can hold
	var/maxcharges = 10
	///Every 5 times this number seconds we will create a jelly
	var/recharge_rate = 10
	///Countdown to the next time we generate a jelly
	var/nextjelly = 0

/obj/structure/xeno/resin_jelly_pod/Initialize(mapload, _hivenumber)
	. = ..()
	add_overlay(image(icon, "resinpod_inside", layer + 0.01, dir))
	START_PROCESSING(SSslowprocess, src)

/obj/structure/xeno/resin_jelly_pod/Destroy()
	STOP_PROCESSING(SSslowprocess, src)
	return ..()

/obj/structure/xeno/resin_jelly_pod/examine(mob/user, distance, infix, suffix)
	. = ..()
	if(isxeno(user))
		. += "It has [chargesleft] jelly globules remaining[datum_flags & DF_ISPROCESSING ? ", and will create a new jelly in [(recharge_rate-nextjelly)*5] seconds": " and seems latent"]."

/obj/structure/xeno/resin_jelly_pod/process()
	if(nextjelly <= recharge_rate)
		nextjelly++
		return
	nextjelly = 0
	chargesleft++
	if(chargesleft >= maxcharges)
		return PROCESS_KILL

/obj/structure/xeno/resin_jelly_pod/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = X.xeno_caste.melee_ap, isrightclick = FALSE)
	if(X.status_flags & INCORPOREAL)
		return FALSE

	if((X.a_intent == INTENT_HARM && isxenohivelord(X)) || X.hivenumber != hivenumber)
		balloon_alert(X, "Destroying...")
		if(do_after(X, HIVELORD_TUNNEL_DISMANTLE_TIME, IGNORE_HELD_ITEM, src, BUSY_ICON_BUILD))
			deconstruct(FALSE)
		return

	if(!chargesleft)
		balloon_alert(X, "No jelly remaining")
		to_chat(X, span_xenonotice("We reach into \the [src], but only find dregs of resin. We should wait some more.") )
		return
	balloon_alert(X, "Retrieved jelly")
	new /obj/item/resin_jelly(loc)
	chargesleft--
	if(!(datum_flags & DF_ISPROCESSING) && (chargesleft < maxcharges))
		START_PROCESSING(SSslowprocess, src)
