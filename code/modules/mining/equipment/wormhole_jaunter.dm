/**********************Jaunter**********************/
/obj/item/wormhole_jaunter
	name = "wormhole jaunter"
	desc = ""
	icon = 'icons/obj/mining.dmi'
	icon_state = "Jaunter"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 1
	throw_range = 5
	slot_flags = ITEM_SLOT_BELT

/obj/item/wormhole_jaunter/attack_self(mob/user)
	user.visible_message("<span class='notice'>[user.name] activates the [src.name]!</span>")
	SSblackbox.record_feedback("tally", "jaunter", 1, "User") // user activated
	activate(user, TRUE)

/obj/item/wormhole_jaunter/proc/turf_check(mob/user)
	var/turf/device_turf = get_turf(user)
	if(!device_turf || is_centcom_level(device_turf.z) || is_reserved_level(device_turf.z))
		to_chat(user, "<span class='notice'>You're having difficulties getting the [src.name] to work.</span>")
		return FALSE
	return TRUE

/obj/item/wormhole_jaunter/proc/get_destinations(mob/user)
	var/list/destinations = list()

	for(var/obj/item/beacon/B in GLOB.teleportbeacons)
		var/turf/T = get_turf(B)
		if(is_station_level(T.z))
			destinations += B

	return destinations

/obj/item/wormhole_jaunter/proc/activate(mob/user, adjacent)
	if(!turf_check(user))
		return

	var/list/L = get_destinations(user)
	if(!L.len)
		to_chat(user, "<span class='notice'>The [src.name] found no beacons in the world to anchor a wormhole to.</span>")
		return
	var/chosen_beacon = pick(L)
	var/obj/effect/portal/jaunt_tunnel/J = new (get_turf(src), src, 100, null, FALSE, get_turf(chosen_beacon))
	if(adjacent)
		try_move_adjacent(J)
	playsound(src,'sound/blank.ogg',50,TRUE)
	qdel(src)

/obj/item/wormhole_jaunter/emp_act(power)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return

	var/mob/M = loc
	if(istype(M))
		var/triggered = FALSE
		if(M.get_item_by_slot(SLOT_BELT) == src)
			if(power == 1)
				triggered = TRUE
			else if(power == 2 && prob(50))
				triggered = TRUE

		if(triggered)
			M.visible_message("<span class='warning'>[src] overloads and activates!</span>")
			SSblackbox.record_feedback("tally", "jaunter", 1, "EMP") // EMP accidental activation
			activate(M)

/obj/item/wormhole_jaunter/proc/chasm_react(mob/user)
	if(user.get_item_by_slot(SLOT_BELT) == src)
		to_chat(user, "<span class='notice'>My [name] activates, saving you from the chasm!</span>")
		SSblackbox.record_feedback("tally", "jaunter", 1, "Chasm") // chasm automatic activation
		activate(user, FALSE)
	else
		to_chat(user, "<span class='danger'>[src] is not attached to my belt, preventing it from saving you from the chasm. RIP.</span>")

//jaunter tunnel
/obj/effect/portal/jaunt_tunnel
	name = "jaunt tunnel"
	icon = 'icons/effects/effects.dmi'
	icon_state = "bhole3"
	desc = ""
	mech_sized = TRUE //save my ripley
	innate_accuracy_penalty = 6

/obj/effect/portal/jaunt_tunnel/teleport(atom/movable/M)
	. = ..()
	if(.)
		// KERPLUNK
		playsound(M,'sound/blank.ogg',50,TRUE)
		if(iscarbon(M))
			var/mob/living/carbon/L = M
			L.Paralyze(60)
			if(ishuman(L))
				shake_camera(L, 20, 1)
				addtimer(CALLBACK(L, TYPE_PROC_REF(/mob/living/carbon, vomit)), 20)
