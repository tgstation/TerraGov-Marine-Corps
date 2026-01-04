//copypaste cryo object but structure base

/obj/structure/bed/chair/stasis
	name = "Hypersleep stasis frame"
	desc = "Latest to hypersleep tech that runs on a mini nuclear battery, \
	could be used by ones who fear closed spaces or kinky people, can be dragged unlike regular cryos, \
	items are not removed and the person is still 'interactable' and may wake up later unlike traditional hypersleep pods."
	anchored = FALSE
	buckle_flags = CAN_BUCKLE
	drag_delay = 1 //Pulling something on wheels is easy
	icon = 'ntf_modular/icons/obj/machines/suit_cycler.dmi'
	icon_state = "suit_cycler"
	layer = ABOVE_ALL_MOB_LAYER
	dir = SOUTH
	density = FALSE
	resistance_flags = RESIST_ALL
	light_range = 0.5
	light_power = 0.5
	light_color = LIGHT_COLOR_BLUE
	///Person waiting to be taken by ghosts
	var/mob/living/occupant
	///the radio plugged into this pod
	var/obj/item/radio/radio

/obj/structure/bed/chair/stasis/dark
	icon_state = "dark_cycler"

/obj/structure/bed/chair/stasis/pilot
	icon_state = "pilot_cycler"

/obj/structure/bed/chair/stasis/captain
	icon_state = "cap_cycler"

/obj/structure/bed/chair/stasis/sec
	icon_state = "sec_cycler"

/obj/structure/bed/chair/stasis/med
	icon_state = "med_cycler"

/obj/structure/bed/chair/stasis/explo
	icon_state = "explo_cycler"

/obj/structure/bed/chair/stasis/engi
	icon_state = "engi_cycler"

/obj/structure/bed/chair/stasis/indust
	icon_state = "industrial_cycler"

/obj/structure/bed/chair/stasis/red
	icon_state = "red_cycler"

/obj/structure/bed/chair/stasis/Initialize(mapload)
	. = ..()
	update_icon()
	RegisterSignal(src, COMSIG_MOVABLE_SHUTTLE_CRUSH, PROC_REF(shuttle_crush))

/obj/structure/bed/chair/stasis/update_icon()
	. = ..()
	if(!occupant)
		set_light(0)
	else
		set_light(initial(light_range))


/obj/structure/bed/chair/stasis/update_overlays()
	. = ..()
	if(!occupant)
		return
	. += emissive_appearance(icon, "cap", src, alpha = 100)
	. += mutable_appearance(icon, "cap", alpha = 100)

/obj/structure/bed/chair/stasis/proc/shuttle_crush()
	SIGNAL_HANDLER
	if(occupant)
		var/mob/living/L = occupant
		unbuckle_mob(L, TRUE, FALSE)
		L.gib()

/obj/structure/bed/chair/stasis/Destroy()
	unbuckle_all_mobs()
	return ..()

/obj/structure/bed/chair/stasis/grab_interact(obj/item/grab/grab, mob/user, base_damage = BASE_OBJ_SLAM_DAMAGE, is_sharp = FALSE)
	. = ..()
	if(.)
		return
	if(isxeno(user))
		return
	var/mob/living/carbon/human/grabbed_mob = grab.grabbed_thing
	if(!ishuman(grabbed_mob))
		to_chat(user, span_warning("There is no way [src] will accept [grabbed_mob]!"))
		return

	if(grabbed_mob.client)
		if(tgui_alert(grabbed_mob, "Would you like to enter cryosleep?", null, list("Yes", "No")) == "Yes")
			if(QDELETED(grabbed_mob) || !(grab?.grabbed_thing == grabbed_mob))
				return
		else
			return

	user_buckle_mob(grabbed_mob, user, TRUE, FALSE)
	return TRUE


/obj/structure/bed/chair/stasis/user_buckle_mob(mob/living/buckling_mob, mob/living/user, check_loc, silent)
	buckling_mob.forceMove(loc)
	. = ..()

	if(user && buckling_mob != user)
		if(buckling_mob.stat == DEAD)
			to_chat(user, span_notice("[buckling_mob] is dead!"))
			return FALSE

		user.visible_message(span_notice("[user] starts putting [buckling_mob] into [src]."),
		span_notice("You start putting [buckling_mob] into [src]."))
	else
		buckling_mob.visible_message(span_notice("[buckling_mob] starts climbing into [src]."),
		span_notice("You start climbing into [src]."))

	var/mob/initiator = user ? user : buckling_mob
	if(!do_after(initiator, 20, TRUE, user, BUSY_ICON_GENERIC))
		return FALSE

	if(!QDELETED(occupant))
		to_chat(initiator, span_warning("[src] is occupied."))
		return FALSE

	occupant = buckling_mob
	update_icon()

	balloon_alert_to_viewers("Hisses as it starts the cryosleep process...")
	to_chat(buckling_mob, span_notice("You feel yourself slipping into unconsciousness... You will be stored if you do not unbuckle soon."))
	playsound(loc, 'sound/machines/hiss.ogg', 25, 1)
	addtimer(CALLBACK(src, PROC_REF(activate), buckling_mob), 5 SECONDS, TIMER_STOPPABLE)

/obj/structure/bed/chair/stasis/proc/activate(mob/living/buckling_mob)
	if(QDELETED(occupant) || !(buckling_mob in buckled_mobs))
		return FALSE
	buckling_mob.set_resting(TRUE)
	buckling_mob.ghostize(TRUE, FALSE, TRUE)
	return TRUE

/obj/structure/bed/chair/stasis/verb/send_away()
	set name = "Fullcryo Occupant"
	set desc = "Send the occupant of this cryopod to the deep storage, freeing up the pod, body, items and their job for future use."
	set category = "IC.Object"
	set src in view(1)

	if(usr.incapacitated(TRUE))
		return
	if(occupant.client)
		to_chat(usr, span_warning("You cannot send away an awake person."))
		return
	if(!occupant)
		to_chat(usr, span_warning("There is no occupant in [src]."))
		return
	playsound(loc, 'sound/machines/hiss.ogg', 25, 1)
	occupant.despawn()
	occupant = null
	update_icon()
	for(var/obj/item/W in src)
		W.store_in_cryo()

/obj/structure/bed/chair/stasis/verb/store_items()
	set name = "Store items"
	set desc = "Store occupant's items in cryoframe's internal storage for later-retrieval."
	set category = "IC.Object"
	set src in view(1)

	if(usr.incapacitated(TRUE))
		return
	if(occupant.client)
		to_chat(usr, span_warning("You cannot do that to an awake person."))
		return
	if(!occupant)
		to_chat(usr, span_warning("There is no occupant in [src]."))
		return
	playsound(loc, 'sound/machines/hiss.ogg', 25, 1)
	for(var/obj/item/W in occupant)
		occupant.temporarilyRemoveItemFromInventory(W)
		W.forceMove(src)

/obj/structure/bed/chair/stasis/verb/eject_items()
	set name = "Eject items"
	set desc = "Eject occupant's items from cryoframe's internal storage."
	set category = "IC.Object"
	set src in view(1)

	if(usr.incapacitated(TRUE))
		return
	if(!length(contents))
		to_chat(usr, span_warning("There are no items stored in [src]."))
		return
	for(var/obj/item/W in src)
		W.forceMove(get_turf(usr))

/obj/structure/bed/chair/stasis/unbuckle_mob(mob/living/buckled_mob, force, can_fall)
	. = ..()
	if(QDELETED(occupant))
		return

	//Eject any items that aren't meant to be in the pod.
	var/list/items = contents

	for(var/I in items)
		var/atom/movable/A = I
		A.forceMove(loc)

	occupant = null
	eject_items()
	playsound(loc, 'sound/machines/hiss.ogg', 25, 1)
	update_icon()

/obj/structure/bed/chair/stasis/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage * xeno_attacker.xeno_melee_damage_modifier, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	if(!occupant)
		to_chat(xeno_attacker, span_xenowarning("There is nothing of interest in there."))
		return
	if(xeno_attacker.status_flags & INCORPOREAL || xeno_attacker.do_actions)
		return
	visible_message(span_warning("[xeno_attacker] begins to take from [src]!"), 3)
	playsound(loc, 'sound/effects/metal_creaking.ogg', 25, 1)
	unbuckle_all_mobs()
