#define X_STAND_OPEN_STATE "open"
#define X_STAND_CLOSED_STATE "close"

/obj/structure/bed/bdsm_bed
	name = "bdsm bed"
	desc = "A latex bed with D-rings on the sides. Looks comfortable."
	icon = 'ntf_modular/icons/obj/structures/bdsm_furniture.dmi'
	icon_state = "bdsm_bed"
	max_integrity = 50

/obj/item/bdsm_bed_kit
	name = "bdsm bed construction kit"
	icon = 'ntf_modular/icons/obj/structures/bdsm_furniture.dmi'
	throwforce = 0
	icon_state = "bdsm_bed_kit"
	w_class = WEIGHT_CLASS_HUGE

/obj/item/bdsm_bed_kit/CtrlShiftClick(mob/user)
	add_fingerprint(user)
	if((item_flags & IN_INVENTORY) || (item_flags & IN_STORAGE))
		return

	to_chat(user, span_notice("You fasten the frame to the floor and begin to inflate the latex pillows..."))
	if(!do_after(user, 8 SECONDS, src))
		to_chat(user, span_warning("You fail to assemble [src]."))
		return

	to_chat(user, span_notice("You assemble [src]."))
	var/obj/structure/bed/bdsm_bed/assembled_bed = new
	assembled_bed.forceMove(loc)
	qdel(src)


/obj/item/bdsm_bed_kit/examine(mob/user)
	. = ..()
	. += span_purple("[src] can be assembled by using Ctrl+Shift+Click while [src] is on the floor.")

/obj/structure/bed/bdsm_bed/post_buckle_mob(mob/living/affected_mob)
	density = TRUE

/obj/structure/bed/bdsm_bed/post_unbuckle_mob(mob/living/affected_mob)
	density = FALSE

/obj/structure/bed/bdsm_bed/CtrlShiftClick(mob/user)
	. = ..()
	add_fingerprint(user)
	to_chat(user, span_notice("You begin unfastening the frame of [src] and deflating the latex pillows..."))
	if(!do_after(user, 8 SECONDS, src))
		to_chat(user, span_warning("You fail to disassemble [src]."))
		return

	to_chat(user, span_notice("You disassemble [src]."))
	new /obj/item/construction_kit/bdsm/bed/(loc)
	qdel(src)

/obj/structure/bed/bdsm_bed/Destroy()
	unbuckle_all_mobs(TRUE)
	return ..()

/obj/structure/bed/bdsm_bed/examine(mob/user)
	. = ..()
	. += span_purple("[src] can be disassembled by using Ctrl+Shift+Click")

/*
*	X-STAND
*/

/obj/structure/bed/chair/x_stand
	name = "x stand"
	desc = "A stand for buckling people in an X shape."
	icon = 'ntf_modular/icons/obj/structures/bdsm_furniture.dmi'
	icon_state = "xstand_open"
	base_icon_state = "xstand"
	max_buckled_mobs = 1
	max_integrity = 75
	///What state is the stand currently in? This is here for sprites.
	var/stand_state = "open"
	///What overlay is the stand using when stand_state is set to closed?
	var/static/mutable_appearance/xstand_overlay = mutable_appearance('ntf_modular/icons/obj/structures/bdsm_furniture.dmi', "xstand_overlay", LYING_MOB_LAYER)
	///What human is currently buckled in?
	var/mob/living/carbon/human/current_mob = null

//to make it have model when we constructing the thingy
/obj/structure/bed/chair/x_stand/Initialize(mapload)
	. = ..()
	update_icon_state()
	update_icon()

/obj/structure/bed/chair/x_stand/Destroy()
	if(current_mob)
		if(current_mob.handcuffed)
			current_mob.handcuffed.dropped(current_mob)

		current_mob.update_abstract_handcuffed()

	unbuckle_all_mobs(TRUE)
	return ..()

/obj/structure/bed/chair/x_stand/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]_[stand_state? "open" : "close"]"

//X-Stand LBM interaction handler
/obj/structure/bed/chair/x_stand/attack_hand(mob/living/user)
	if(LAZYLEN(buckled_mobs))
		user_unbuckle_mob(buckled_mobs[1], user)
		return TRUE

	var/mob/living/affected_mob = locate() in loc
	if(!affected_mob)
		toggle_mode(user)
		return TRUE

	user_buckle_mob(affected_mob, user, check_loc = TRUE)

// Another plug to disable rotation
/obj/structure/bed/chair/x_stand/attack_tk(mob/user)
	return FALSE

// Handler for attempting to unbuckle a mob from a X-Stand
/obj/structure/bed/chair/x_stand/user_unbuckle_mob(mob/living/buckled_mob, mob/living/user)
	// Let's make sure that the X-Stand is in the correct state
	if(stand_state == X_STAND_OPEN_STATE)
		toggle_mode(user)

	if(!buckled_mob)
		return FALSE

	if(buckled_mob != user)
		if(!do_after(user, 5 SECONDS, buckled_mob)) // Timer for unbuckling one mob with another mob
			to_chat(user, span_warning("You fail to unbuckle [buckled_mob] from [src]."))
			return FALSE

		buckled_mob.visible_message(span_notice("[user] unbuckles [buckled_mob] from [src]."),\
			span_notice("[user] unbuckles you from [src]."),\
			span_hear("You hear metal clanking."))

	else
		if(!do_after(user, 10 SECONDS, buckled_mob)) // Timer for unbuckling one mob with another mob
			to_chat(user, span_warning("You fail to unbuckle yourself from [src]."))
			return FALSE

		user.visible_message(span_notice("You unbuckle yourself from [src]."),\
			span_hear("You hear metal clanking."))

	unbuckle_mob(buckled_mob)

	add_fingerprint(user, "unbuckle")
	if(isliving(buckled_mob.pulledby))
		var/mob/living/pulling_mob = buckled_mob.pulledby
		pulling_mob.set_pull_offsets(buckled_mob, buckled_mob.grab_state)

	toggle_mode(user)
	return buckled_mob

// Handler for attempting to buckle a mob into a X-Stand
/obj/structure/bed/chair/x_stand/user_buckle_mob(mob/living/affected_mob, mob/user, check_loc = TRUE)
	if(stand_state == X_STAND_CLOSED_STATE)
		toggle_mode(user)

	add_fingerprint(user)

	if(affected_mob == user)
		if(!do_after(user, 10 SECONDS, affected_mob)) // Timer to buckle the mob itself
			to_chat(user, span_warning("You fail to buckle yourself to [src]!"))
			return FALSE

		if(buckle_mob(affected_mob, check_loc = check_loc))
			user.visible_message(span_warning("You buckle yourself to [src]!"),\
				span_hear("You hear metal clanking."))

		toggle_mode(user)
		return TRUE

	affected_mob.visible_message(span_warning("[user] starts buckling [affected_mob] to [src]!"),\
		span_userdanger("[user] starts buckling you to [src]!"),\
		span_hear("You hear metal clanking."))

	if(!do_after(user, 5 SECONDS, affected_mob)) // Timer to buckle one mob by another
		to_chat(user, span_warning("You fail to buckle [affected_mob] to [src]!"))
		return FALSE

	if(!buckle_mob(affected_mob, check_loc = check_loc))
		return FALSE

	affected_mob.visible_message(span_warning("[user] buckled [affected_mob] to [src]!"),\
		span_userdanger("[user] buckled you to [src]!"),\
		span_hear("You hear metal clanking."))

	toggle_mode(user)
	return TRUE

// X-Stand state switch processing
/obj/structure/bed/chair/x_stand/proc/toggle_mode(mob/user)
	if(stand_state == X_STAND_CLOSED_STATE)
		stand_state = X_STAND_OPEN_STATE
		cut_overlay(xstand_overlay)
	else
		stand_state = X_STAND_CLOSED_STATE
		add_overlay(xstand_overlay)

	add_fingerprint(user, "buckle")
	update_icon_state()
	update_icon()
	playsound(loc, 'sound/vehicles/magin.ogg', 20, TRUE)

//Place the mob in the desired position after buckling
/obj/structure/bed/chair/x_stand/post_buckle_mob(mob/living/affected_mob)
	affected_mob.layer = BELOW_MOB_LAYER

	if(LAZYLEN(buckled_mobs))
		if(ishuman(buckled_mobs[1]))
			current_mob = buckled_mobs[1]

	if(!current_mob)
		return FALSE

	if(current_mob.handcuffed)
		current_mob.handcuffed.forceMove(loc)
		current_mob.handcuffed.dropped(current_mob)
		current_mob.update_handcuffed()

	var/obj/item/restraints/handcuffs/milker/cuffs = new(current_mob)
	current_mob.equip_to_slot_if_possible(cuffs, SLOT_HANDCUFFED, 1, 0, 1, 1)
	cuffs.parent_chair = WEAKREF(src)
	current_mob.update_abstract_handcuffed()

//Restore the position of the mob after unbuckling.
/obj/structure/bed/chair/x_stand/post_unbuckle_mob(mob/living/affected_mob)
	affected_mob.layer = initial(affected_mob.layer)

	if(!current_mob)
		return FALSE

	if(current_mob.handcuffed)
		current_mob.handcuffed.dropped(current_mob)

	current_mob.handcuffed.dropped(current_mob)
	current_mob.update_abstract_handcuffed()
	current_mob = null

/*
*	X-STAND CONSTRUCTION KIT
*/

/obj/structure/bed/chair/x_stand/CtrlShiftClick(mob/user)
	add_fingerprint(user)
	to_chat(user, span_notice("You begin unfastening the frame of [src]..."))
	if(!do_after(user, 8 SECONDS, src))
		return

	to_chat(user, span_notice("You disassemble [src]."))
	new /obj/item/construction_kit/bdsm/x_stand(loc)
	unbuckle_all_mobs()
	qdel(src)

/obj/structure/bed/chair/x_stand/examine(mob/user)
	. = ..()
	. += span_purple("[src] can be disassembled by using Ctrl+Shift+Click")

#undef X_STAND_CLOSED_STATE
#undef X_STAND_OPEN_STATE

/obj/item/restraints/handcuffs/milker
	name = "chair cuffs"
	desc = "A thick metal cuff for restraining hands."
	breakouttime = 45 SECONDS
	item_flags = ITEM_ABSTRACT | DELONDROP | NOBLUDGEON
	///The chair that the handcuffs are parented to.
	var/datum/weakref/parent_chair

/obj/item/restraints/handcuffs/milker/make_worn_icon(species_type, slot_name, inhands, default_icon, default_layer)
	return

/obj/item/restraints/handcuffs/milker/Destroy()
	unbuckle_parent()
	parent_chair = null
	return ..()

/obj/item/restraints/handcuffs/milker/proc/unbuckle_parent()
	if(!parent_chair)
		return FALSE

	var/obj/structure/chair = parent_chair.resolve()
	if(!chair)
		return FALSE

	chair.unbuckle_all_mobs()
	return TRUE

