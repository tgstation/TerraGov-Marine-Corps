/*
* Contains:
* 		Beds
*		Roller beds
*/

/*
* Beds
*/
/obj/structure/bed
	name = "bed"
	desc = "A mattress seated on a rectangular metallic frame. This is used to support a lying person in a comfortable manner, notably for regular sleep. Ancient technology, but still useful."
	icon_state = "bed"
	icon = 'icons/obj/objects.dmi'
	buckle_flags = CAN_BUCKLE|BUCKLE_PREVENTS_PULL
	buckle_lying = 90
	throwpass = TRUE
	resistance_flags = XENO_DAMAGEABLE
	max_integrity = 40
	resistance_flags = XENO_DAMAGEABLE
	hit_sound = 'sound/effects/metalhit.ogg'
	coverage = 10
	var/dropmetal = TRUE
	var/buildstacktype = /obj/item/stack/sheet/metal
	var/buildstackamount = 1
	var/foldabletype //To fold into an item (e.g. roller bed item)
	var/buckling_y = 0 //pixel y shift to give to the buckled mob.
	var/obj/structure/closet/bodybag/buckled_bodybag
	var/accepts_bodybag = FALSE //Whether you can buckle bodybags to this bed
	var/base_bed_icon //Used by beds that change sprite when something is buckled to them


/obj/structure/bed/nometal
	dropmetal = FALSE

/obj/structure/bed/bunkbed
	name = "bunk bed"
	icon_state = "bunkbed"

/obj/structure/bed/update_icon_state()
	if(!base_bed_icon)
		return
	if(LAZYLEN(buckled_mobs) || buckled_bodybag)
		icon_state = "[base_bed_icon]_up"
	else
		icon_state = "[base_bed_icon]_down"

obj/structure/bed/Destroy()
	if(buckled_bodybag)
		unbuckle_bodybag()
	return ..()


/obj/structure/bed/post_buckle_mob(mob/buckling_mob)
	. = ..()
	buckling_mob.pixel_y = buckling_y
	buckling_mob.old_y = buckling_y
	if(base_bed_icon)
		density = TRUE
	update_icon()

/obj/structure/bed/post_unbuckle_mob(mob/buckled_mob)
	. = ..()
	buckled_mob.pixel_y = initial(buckled_mob.pixel_y)
	buckled_mob.old_y = initial(buckled_mob.pixel_y)
	if(base_bed_icon)
		density = FALSE
	update_icon()

	if(isliving(buckled_mob)) //Properly update whether we're lying or not
		var/mob/living/unbuckled_target = buckled_mob
		if(HAS_TRAIT(unbuckled_target, TRAIT_FLOORED))
			unbuckled_target.set_lying_angle(pick(90, 270))

//Unsafe proc
/obj/structure/bed/proc/buckle_bodybag(obj/structure/closet/bodybag/B, mob/user)
	if(buckled_bodybag || buckled)
		return
	B.visible_message(span_notice("[user] buckles [B] to [src]!"))
	B.roller_buckled = src
	B.glide_modifier_flags |= GLIDE_MOD_BUCKLED
	B.loc = loc
	B.setDir(dir)
	B.layer = layer + 0.1
	buckled_bodybag = B
	density = TRUE
	update_icon()
	if(buckling_y)
		buckled_bodybag.pixel_y = buckling_y
	if(B.pulledby)
		B.pulledby.stop_pulling()
	if(pulledby)
		B.set_glide_size(pulledby.glide_size)


/obj/structure/bed/proc/unbuckle_bodybag(mob/user)
	if(!buckled_bodybag)
		return
	buckled_bodybag.layer = initial(buckled_bodybag.layer)
	buckled_bodybag.pixel_y = initial(buckled_bodybag.pixel_y)
	buckled_bodybag.roller_buckled = null
	buckled_bodybag.glide_modifier_flags &= ~GLIDE_MOD_BUCKLED
	buckled_bodybag.reset_glide_size()
	buckled_bodybag = null
	density = FALSE
	update_icon()


//Trying to buckle a mob
/obj/structure/bed/buckle_mob(mob/living/buckling_mob, force = FALSE, check_loc = TRUE, lying_buckle = FALSE, hands_needed = 0, target_hands_needed = 0, silent)
	if(buckled_bodybag)
		return FALSE
	return ..()

/obj/structure/bed/Moved(atom/old_loc, movement_dir, forced, list/old_locs)
	. = ..()
	if(!buckled_bodybag || buckled_bodybag.Move(loc, movement_dir))
		return TRUE
	forceMove(buckled_bodybag.loc)
	return FALSE

/obj/structure/bed/roller/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(mover == buckled_bodybag)
		return TRUE

/obj/structure/bed/MouseDrop_T(atom/dropping, mob/user)
	if(accepts_bodybag && !buckled_bodybag && !LAZYLEN(buckled_mobs) && istype(dropping,/obj/structure/closet/bodybag) && ishuman(user))
		var/obj/structure/closet/bodybag/B = dropping
		if(!B.roller_buckled && !B.anchored)
			buckle_bodybag(B, user)
			return TRUE
	else
		return ..()

/obj/structure/bed/MouseDrop(atom/over_object)
	. = ..()
	if(foldabletype && !LAZYLEN(buckled_mobs) && !buckled_bodybag)
		if(ishuman(over_object))
			var/mob/living/carbon/human/H = over_object
			if(H == usr && !H.incapacitated() && Adjacent(H) && in_range(src, over_object))
				var/obj/item/I = new foldabletype(get_turf(src))
				H.put_in_hands(I)
				if(istype(I,/obj/item/roller/medevac)) //We need to preserve key variables like linked beacons and cooldowns.
					var/obj/item/roller/medevac/M = I
					var/obj/structure/bed/medevac_stretcher/B = src
					if(B.last_teleport)
						M.last_teleport = B.last_teleport
					if(B.linked_beacon)
						M.linked_beacon = B.linked_beacon
						if(B.linked_beacon.linked_bed_deployed == B)
							M.linked_beacon.linked_bed = M
							B.linked_beacon.linked_bed_deployed = null
				H.visible_message(span_warning("[H] grabs [src] from the floor!"),
				span_warning("You grab [src] from the floor!"))
				qdel(src)

/obj/structure/bed/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			if(prob(50))
				if(buildstacktype && dropmetal)
					new buildstacktype (loc, buildstackamount)
				qdel(src)
		if(EXPLODE_LIGHT)
			if(prob(5))
				if(buildstacktype && dropmetal)
					new buildstacktype (loc, buildstackamount)
				qdel(src)

/obj/structure/bed/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	SEND_SIGNAL(X, COMSIG_XENOMORPH_ATTACK_BED)
	return ..()

/obj/structure/bed/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(iswrench(I))
		if(!buildstacktype)
			return

		playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
		if(dropmetal)
			new buildstacktype(loc, buildstackamount)
		qdel(src)

	else if(istype(I, /obj/item/grab) && !LAZYLEN(buckled_mobs) && !buckled_bodybag)
		var/obj/item/grab/G = I
		if(!ismob(G.grabbed_thing))
			return

		var/mob/M = G.grabbed_thing
		to_chat(user, span_notice("You place [M] on [src]."))
		M.forceMove(loc)
		return TRUE


/obj/structure/bed/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(istype(mover) && CHECK_BITFIELD(mover.flags_pass, PASSTABLE))
		return TRUE

/obj/structure/bed/alien
	icon_state = "abed"

/obj/structure/bed/fancy
	name = "fancy bed"
	desc = "For prime comfort."


/*
* Roller beds
*/
/obj/structure/bed/roller
	name = "roller bed"
	desc = "A basic cushioned leather board resting on a small frame. Not very comfortable at all, but allows the patient to rest lying down while moved to another location rapidly."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "roller_down"
	anchored = FALSE
	buckle_flags = CAN_BUCKLE
	drag_delay = 0 //Pulling something on wheels is easy
	buckling_y = 6
	foldabletype = /obj/item/roller
	accepts_bodybag = TRUE
	base_bed_icon = "roller"


/obj/item/roller
	name = "roller bed"
	desc = "A collapsed roller bed that can be carried around."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "folded"
	w_class = WEIGHT_CLASS_SMALL //Fits in a backpack
	drag_delay = 1 //Pulling something on wheels is easy
	var/rollertype = /obj/structure/bed/roller

/obj/item/roller/attack_self(mob/user)
	deploy_roller(user, user.loc)

/obj/item/roller/afterattack(obj/target, mob/user , proximity)
	if(!proximity)
		return
	if(isturf(target))
		var/turf/T = target
		if(!T.density)
			deploy_roller(user, target)

/obj/item/roller/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/roller_holder) && rollertype == /obj/structure/bed/roller)
		var/obj/item/roller_holder/RH = I
		if(RH.held)
			return

		to_chat(user, span_notice("You pick up [src]."))
		forceMove(RH)
		RH.held = src


/obj/item/roller/proc/deploy_roller(mob/user, atom/location)
	var/obj/structure/bed/roller/R = new rollertype(location)
	user.temporarilyRemoveItemFromInventory(src)
	if(istype(R,/obj/structure/bed/medevac_stretcher)) //We need to preserve key variables like linked beacons and cooldowns.
		var/obj/item/roller/medevac/I = src
		var/obj/structure/bed/medevac_stretcher/B = R
		if(I.last_teleport)
			B.last_teleport = I.last_teleport
		if(I.linked_beacon)
			B.linked_beacon = I.linked_beacon
			if(B.linked_beacon.linked_bed == I)
				B.linked_beacon.linked_bed_deployed = B
				B.linked_beacon.linked_bed = null
	qdel(src)

/obj/item/roller_holder
	name = "roller bed rack"
	desc = "A rack for carrying a collapsed roller bed."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "folded"
	var/obj/item/roller/held

/obj/item/roller_holder/Initialize()
	. = ..()
	held = new(src)

/obj/item/roller_holder/attack_self(mob/user as mob)

	if(!held)
		to_chat(user, span_warning("The rack is empty."))
		return

	var/obj/structure/bed/roller/R = new(user.loc)
	to_chat(user, span_notice("You deploy [R]."))
	qdel(held)
	held = null

////////////////////////////////////////////
			//MEDEVAC STRETCHER
//////////////////////////////////////////////

//List of all activated medevac stretchers
GLOBAL_LIST_EMPTY(activated_medevac_stretchers)

/obj/structure/bed/medevac_stretcher
	name = "medevac stretcher"
	desc = "A medevac stretcher with integrated beacon for rapid evacuation of an injured patient via dropship lift and an emergency bluespace teleporter for tele-evacuation to a linked beacon. Accepts patients and body bags."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "stretcher_down"
	buckling_y = 6
	buildstacktype = null
	foldabletype = /obj/item/roller/medevac
	base_bed_icon = "stretcher"
	accepts_bodybag = TRUE
	resistance_flags = NONE
	var/teleport_timer = null
	var/last_teleport = null
	var/obj/item/medevac_beacon/linked_beacon = null
	var/stretcher_activated
	var/obj/item/radio/headset/mainship/doc/radio
	///A busy var to check if the strecher is already used to send someone to the beacon
	var/busy = FALSE

/obj/structure/bed/medevac_stretcher/Initialize(mapload)
	. = ..()
	radio = new(src)

/obj/structure/bed/medevac_stretcher/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(X.status_flags & INCORPOREAL)
		return FALSE
	if(buckled_bodybag)
		unbuckle_bodybag()
	for(var/m in buckled_mobs)
		user_unbuckle_mob(m, X, TRUE)

/obj/structure/bed/medevac_stretcher/Destroy()
	QDEL_NULL(radio)
	if(linked_beacon)
		linked_beacon.linked_bed_deployed = null
		linked_beacon = null
	return ..()

/obj/structure/bed/medevac_stretcher/update_icon()
	..()
	overlays.Cut()
	if(stretcher_activated)
		overlays += image("beacon_active_[density ? "up":"down"]")

	if(LAZYLEN(buckled_mobs) || buckled_bodybag)
		overlays += image("icon_state"="stretcher_box","layer"=LYING_MOB_LAYER + 0.1)


/obj/structure/bed/medevac_stretcher/verb/activate_medevac_displacer()
	set name = "Activate Medevac Displacement Field"
	set desc = "Teleport the occupant of the stretcher to a linked beacon."
	set category = "Object"
	set src in oview(1)

	activate_medevac_teleport(usr)


/obj/structure/bed/medevac_stretcher/attack_hand_alternate(mob/living/user)
	activate_medevac_teleport(user)

/obj/structure/bed/medevac_stretcher/attack_ghost(mob/dead/observer/user)
	. = ..()
	if(!linked_beacon?.loc) //TODO: Redo medevac links
		return
	user.forceMove(get_turf(linked_beacon))

/obj/structure/bed/medevac_stretcher/proc/activate_medevac_teleport(mob/user)
	if(!ishuman(user))
		return

	if(busy)
		return

	if(!linked_beacon)
		playsound(loc,'sound/machines/buzz-two.ogg', 25, FALSE)
		to_chat(user, span_warning("[src]'s bluespace engine isn't linked to any medvac beacon."))
		return

	if(user.faction != linked_beacon.faction)
		playsound(loc,'sound/machines/buzz-two.ogg', 25, FALSE)
		visible_message(span_warning("[src]'s safeties kick in before displacement as it fails to detect correct identification codes."))
		return

	if(world.time < last_teleport )
		playsound(loc,'sound/machines/buzz-two.ogg', 25, FALSE)
		to_chat(user, span_warning("[src]'s bluespace engine is still recharging; it will be ready in [round(last_teleport - world.time) * 0.1] seconds."))
		return

	if(user in buckled_mobs)
		to_chat(user, span_warning("You can't reach the teleportation activation button while buckled to [src]."))
		return

	if(!linked_beacon.planted)
		playsound(loc,'sound/machines/buzz-two.ogg', 25, FALSE)
		to_chat(user, span_warning("[src]'s bluespace engine linked medvac beacon isn't planted and active!"))
		return

	if(!linked_beacon.check_power())
		playsound(loc,'sound/machines/buzz-two.ogg', 25, FALSE)
		to_chat(user, span_warning("[src]'s bluespace engine linked medvac beacon is unpowered."))
		return

	if(is_centcom_level(linked_beacon.z)) // No. No using teleportation to teleport to the adminzone.
		playsound(loc,'sound/machines/buzz-two.ogg', 25, FALSE)
		to_chat(user, span_warning("[src]'s beacon is out of range!"))
		return

	user.visible_message(span_warning("[user] activates [src]'s bluespace engine, causing it to rev to life."),
	span_warning("You activate [src]'s bluespace engine, causing it to rev to life."))
	playsound(loc,'sound/mecha/powerup.ogg', 25, FALSE)
	teleport_timer = addtimer(CALLBACK(src, .proc/medevac_teleport, user), MEDEVAC_TELE_DELAY, TIMER_STOPPABLE|TIMER_UNIQUE) //Activate after 5 second delay.
	RegisterSignal(src, COMSIG_MOVABLE_UNBUCKLE, .proc/on_mob_unbuckle)
	busy = TRUE

/obj/structure/bed/medevac_stretcher/proc/on_mob_unbuckle(datum/source, mob/living/buckled_mob, force = FALSE)
	SIGNAL_HANDLER
	busy = FALSE
	UnregisterSignal(src, COMSIG_MOVABLE_UNBUCKLE)
	deltimer(teleport_timer)
	playsound(loc,'sound/machines/buzz-two.ogg', 25, FALSE)
	visible_message(span_warning("[src]'s safeties kick in, no longer detecting a buckled mob."))


/obj/structure/bed/medevac_stretcher/proc/medevac_teleport(mob/user)
	UnregisterSignal(src, COMSIG_MOVABLE_UNBUCKLE)
	busy = FALSE
	if(!linked_beacon || !linked_beacon.check_power() || !linked_beacon.planted) //Beacon has to be planted in a powered area.
		playsound(loc,'sound/machines/buzz-two.ogg', 25, FALSE)
		visible_message(span_warning("[src]'s safeties kick in before displacement as it fails to detect a powered, linked, and planted medvac beacon."))
		return
	var/mob/living/M
	if(LAZYLEN(buckled_mobs))
		M = buckled_mobs[1]
	else if(buckled_bodybag)
		M = locate(/mob/living) in buckled_bodybag.contents
	else
		playsound(loc,'sound/machines/buzz-two.ogg', 25, FALSE)
		visible_message(span_warning("[src]'s bluespace engine aborts displacement, being unable to detect an appropriate evacuee."))
		return
	if(!M) //We need a mob to teleport or no deal
		playsound(loc,'sound/machines/buzz-two.ogg', 25, FALSE)
		visible_message(span_warning("[src]'s bluespace engine aborts displacement, being unable to detect an appropriate evacuee."))
		return

	if(M.faction != linked_beacon.faction)
		playsound(loc,'sound/machines/buzz-two.ogg', 25, FALSE)
		visible_message(span_warning("[src]'s safeties kick in before displacement as it fails to detect correct identification codes."))
		return

	visible_message(span_notice("<b>[M] vanishes in a flash of sparks as [src]'s bluespace engine generates its displacement field.</b>"))
	if(buckled_bodybag)
		var/obj/structure/closet/bodybag/teleported_bodybag = buckled_bodybag
		unbuckle_bodybag()
		teleported_bodybag.forceMove(get_turf(linked_beacon))
	else
		unbuckle_mob(M)
		M.forceMove(get_turf(linked_beacon))

	//Pretty SFX
	var/datum/effect_system/spark_spread/spark_system
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	spark_system.start(src)
	playsound(loc,'sound/effects/phasein.ogg', 50, FALSE)
	var/datum/effect_system/spark_spread/spark_system2
	spark_system2 = new /datum/effect_system/spark_spread()
	spark_system2.set_up(5, 0, linked_beacon)
	spark_system2.attach(linked_beacon)
	spark_system2.start(linked_beacon)
	playsound(linked_beacon.loc,'sound/effects/phasein.ogg', 50, FALSE)

	linked_beacon.medvac_alert(M) //We warn med channel about the mob, not what was teleported.
	last_teleport = world.time + MEDEVAC_COOLDOWN

/obj/structure/bed/medevac_stretcher/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/medevac_beacon))
		var/obj/item/medevac_beacon/B = I
		linked_beacon = B
		B.linked_bed = src
		to_chat(user, span_notice("<b>You link the medvac beacon to the medvac stretcher.</b>"))
		playsound(loc,'sound/machines/ping.ogg', 25, FALSE)

	else if(istype(I, /obj/item/healthanalyzer)) //Allows us to use the analyzer on the occupant without taking him out.
		var/mob/living/occupant
		if(LAZYLEN(buckled_mobs))
			occupant = buckled_mobs[1]
		else if(buckled_bodybag)
			occupant = locate(/mob/living) in buckled_bodybag.contents
		var/obj/item/healthanalyzer/J = I
		J.attack(occupant, user)


/obj/structure/bed/medevac_stretcher/proc/medvac_alert(mob/M)
	playsound(loc, 'sound/machines/ping.ogg', 50, FALSE)
	radio.talk_into(src, "Patient [M] has been tele-vaced to medvac beacon at: [get_area(linked_beacon)]. Coordinates: (X: [linked_beacon.x], Y: [linked_beacon.y])", RADIO_CHANNEL_MEDICAL)

/obj/structure/bed/medevac_stretcher/examine(mob/user)
	. = ..()
	var/list/details = list()
	if(linked_beacon)
		details += "It's linked to a beacon located at: [get_area(linked_beacon)]. Coordinates: (X: [linked_beacon.x], Y: [linked_beacon.y]).</br>"

	if(world.time < last_teleport)
		details += "Its bluespace engine is currently recharging. <b>The interface displays: [round(last_teleport - world.time) * 0.1] seconds until it has recharged.</b></br>"

	if(LAZYLEN(buckled_mobs))
		details += "It contains [buckled_mobs[1]].</br>"
	else if(buckled_bodybag)
		var/mob/living/M = locate(/mob/living) in buckled_bodybag.contents
		details += "It contains [M].</br>"

	. += span_notice("[details.Join(" ")]")


/obj/item/roller/medevac
	name = "medevac stretcher"
	desc = "A collapsed medevac stretcher that can be carried around."
	icon_state = "stretcher_folded"
	var/last_teleport = null
	var/obj/item/medevac_beacon/linked_beacon = null
	rollertype = /obj/structure/bed/medevac_stretcher

/obj/item/roller/medevac/Destroy()
	if(linked_beacon)
		linked_beacon.linked_bed = null
		linked_beacon = null
	return ..()

/obj/item/roller/medevac/attack_self(mob/user)
	deploy_roller(user, user.loc)

/obj/item/roller/medevac/attack_ghost(mob/dead/observer/user)
	. = ..()
	if(!linked_beacon?.loc) //TODO: Redo medevac links
		return
	user.forceMove(get_turf(linked_beacon))

/obj/item/roller/medevac/examine(mob/user)
	. = ..()
	var/list/details = list()
	if(linked_beacon)
		details += "It's linked to a beacon located at: [get_area(linked_beacon)]. Coordinates: (X: [linked_beacon.x], Y: [linked_beacon.y]).</br>"

	if(world.time < last_teleport)
		details += "[span_warning("It's bluespace engine is currently recharging. The interface estimates: [round(last_teleport - world.time) * 0.1] seconds until i has recharged.")]</br>"

	. += span_notice("[details.Join(" ")]")


/obj/item/roller/medevac/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/medevac_beacon))
		var/obj/item/medevac_beacon/B = I
		linked_beacon = B
		B.linked_bed = src
		to_chat(user, span_notice("<b>You link the medvac beacon to the medvac stretcher.</b>"))
		playsound(loc,'sound/machines/ping.ogg', 25, FALSE)

/obj/item/medevac_beacon
	name = "medevac beacon"
	desc = "A specialized teleportation beacon that links with a medvac stretcher; provides the target destination for the stretcher's displacement field. WARNING: Must be in a powered area to function."
	icon_state = "med_beacon0"
	var/planted = FALSE
	var/locked = FALSE
	var/obj/item/roller/medevac/linked_bed = null
	var/obj/structure/bed/medevac_stretcher/linked_bed_deployed = null
	req_one_access = list(ACCESS_MARINE_MEDPREP, ACCESS_MARINE_LEADER, ACCESS_MARINE_MEDBAY)
	var/obj/item/radio/headset/mainship/doc/radio
	///The faction this beacon belongs to
	var/faction

/obj/item/medevac_beacon/Initialize(mapload)
	. = ..()
	radio = new(src)

/obj/item/medevac_beacon/Destroy()
	QDEL_NULL(radio)
	if(linked_bed)
		linked_bed.linked_beacon = null
		linked_bed = null
	else if(linked_bed_deployed)
		linked_bed_deployed.linked_beacon = null
		linked_bed_deployed = null
	return ..()

/obj/item/medevac_beacon/examine(mob/user)
	. = ..()
	var/list/details = list()
	if(!check_power())
		details += "<b>It's currently unpowered.</b></br>"
	else
		details += "<b>It's currently powered.</b></br>"
	var/turf/bed_location
	var/teleport_time
	if(linked_bed_deployed)
		bed_location = get_turf(linked_bed_deployed)
		teleport_time = linked_bed_deployed.last_teleport
	else if(linked_bed)
		bed_location = get_turf(linked_bed)
		teleport_time = linked_bed.last_teleport
	if(bed_location)
		details += "It's linked to a medvac bed located at: [get_area(bed_location)]. Coordinates: (X: [bed_location.x], Y: [bed_location.y]).</br>"
		if(world.time < teleport_time)
			details += "The linked bed's bluespace engine is currently recharging. <b>The interface displays: [round(teleport_time - world.time) * 0.1] seconds until it has recharged.</b></br>"
	else
		details += "It's not currently linked to a medvac bed.</br>"

	. += span_notice("[details.Join(" ")]")

/obj/item/medevac_beacon/proc/medvac_alert(mob/M)
	playsound(loc, 'sound/machines/ping.ogg', 50, FALSE)
	radio.talk_into(src, "Patient [M] has been tele-vaced to medvac beacon at: [get_area(src)]. Coordinates: (X: [x], Y: [y])", RADIO_CHANNEL_MEDICAL)

/obj/item/medevac_beacon/attack_self(mob/user)
	if(locked)
		to_chat(user, span_warning("[src]'s interface is locked! Only a Squad Leader, Corpsman, or Medical Officer can unlock it now."))
		return
	user.drop_held_item()
	flags_item |= NO_VACUUM
	anchored = TRUE
	planted = TRUE
	to_chat(user, span_warning("You plant and activate [src]."))
	icon_state = "med_beacon1"
	playsound(loc,'sound/machines/ping.ogg', 25, FALSE)
	faction = user.faction

/obj/item/medevac_beacon/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(locked)
		to_chat(user, span_warning("[src]'s interface is locked! Only a Squad Leader, Corpsman, or Medical Officer can unlock it now."))
		return
	if(planted)
		flags_item &= ~NO_VACUUM
		anchored = FALSE
		planted = FALSE
		to_chat(user, span_warning("You retrieve and deactivate [src]."))
		icon_state = "med_beacon0"
		playsound(loc,'sound/machines/click.ogg', 25, FALSE)

/obj/item/medevac_beacon/attack_ghost(mob/dead/observer/user)
	. = ..()
	if(linked_bed_deployed && istype(linked_bed_deployed, /obj/structure/bed/medevac_stretcher)) //TODO: Redo medevac links
		user.forceMove(get_turf(linked_bed_deployed))
		return
	if(linked_bed && istype(linked_bed_deployed, /obj/item/roller/medevac))
		user.forceMove(get_turf(linked_bed))

/obj/item/medevac_beacon/attackby(obj/item/I, mob/user, params) //Corpsmen can lock their beacons.
	. = ..()

	if(istype(I, /obj/item/card/id))
		if(!allowed(user))
			to_chat(user, span_warning("Access denied."))
			playsound(loc,'sound/machines/buzz-two.ogg', 25, FALSE)
			return
		locked = !locked
		user.visible_message(span_notice("[user] [locked ? "locks" : "unlocks"] [src]'s interface."),
		span_notice("You [locked ? "lock" : "unlock"] [src]'s interface."))
	else if(istype(I, /obj/item/roller/medevac))
		if(locked)
			to_chat(user, span_warning("Access denied."))
			playsound(loc,'sound/machines/buzz-two.ogg', 25, FALSE)
			return

		var/obj/item/roller/medevac/R = I
		linked_bed = R
		R.linked_beacon = src
		to_chat(user, span_notice("<b>You link the medvac beacon to the medvac stretcher.</b>"))
		playsound(loc,'sound/machines/ping.ogg', 25, FALSE)


/obj/item/medevac_beacon/proc/check_power()
	var/area/A = loc?.loc
	if(!A || !isarea(A))
		return FALSE
	return(A.powered(1))
