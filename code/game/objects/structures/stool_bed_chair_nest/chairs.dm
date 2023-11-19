#define DROPSHIP_CHAIR_UNFOLDED 1
#define DROPSHIP_CHAIR_FOLDED 2
#define DROPSHIP_CHAIR_BROKEN 3

/obj/structure/bed/chair //YES, chairs are a type of bed, which are a type of stool. This works, believe me.	-Pete
	name = "chair"
	desc = "A rectangular metallic frame sitting on four legs with a back panel. Designed to fit the sitting position, more or less comfortably."
	icon_state = "chair"
	buckle_lying = 0
	max_integrity = 20
	var/propelled = 0 //Check for fire-extinguisher-driven chairs

//directional variants mostly used for random spawners
/obj/structure/bed/chair/east
	dir = EAST

/obj/structure/bed/chair/west
	dir = WEST

/obj/structure/bed/chair/north
	dir = NORTH

/obj/structure/bed/chair/alt
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "chair_alt"

/obj/structure/bed/chair/nometal
	dropmetal = FALSE

/obj/structure/bed/chair/proc/handle_rotation(direction) //Making this into a seperate proc so office chairs can call it on Move()
	handle_layer()
	for(var/m in buckled_mobs)
		var/mob/living/buckled_mob = m
		buckled_mob.setDir(direction)

/obj/structure/bed/chair/proc/handle_layer()
	if(LAZYLEN(buckled_mobs) && dir == NORTH)
		layer = FLY_LAYER
	else
		layer = OBJ_LAYER


/obj/structure/bed/chair/post_buckle_mob(mob/buckling_mob)
	. = ..()
	if(isliving(buckling_mob)) //Properly update whether we're lying or not; no more people lying on chairs; ridiculous
		var/mob/living/buckled_target = buckling_mob
		buckled_target.set_lying_angle(0)

	handle_layer()

/obj/structure/bed/chair/post_unbuckle_mob(mob/buckled_mob)
	. = ..()
	handle_layer()

/obj/structure/bed/chair/setDir(newdir)
	. = ..()
	handle_rotation(newdir)


/obj/structure/bed/chair/verb/rotate()
	set name = "Rotate Chair"
	set category = "Object"
	set src in view(0)

	var/mob/living/carbon/user = usr

	if(!istype(user) || !isturf(user.loc) || user.incapacitated())
		return FALSE

	if(world.time <= user.next_move)
		return FALSE
	user.next_move = world.time + 3

	setDir(turn(dir, 90))

//Chair types
/obj/structure/bed/chair/reinforced
	name = "reinforced chair"
	desc = "Some say that the TGMC shouldn't spent this much money on reinforced chairs, but the documents from briefing riots prove otherwise."
	buildstackamount = 2


/obj/structure/bed/chair/reinforced/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(iswrench(I))
		to_chat(user, span_warning("You can only deconstruct this by welding it down!"))

	else if(iswelder(I))
		if(user.do_actions)
			return
		var/obj/item/tool/weldingtool/WT = I

		if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_METAL)
			user.visible_message(span_notice("[user] fumbles around figuring out how to weld down \the [src]."),
			span_notice("You fumble around figuring out how to weld down \the [src]."))
			var/fumbling_time = 5 SECONDS * (SKILL_ENGINEER_METAL - user.skills.getRating(SKILL_ENGINEER))
			if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED, extra_checks = CALLBACK(WT, /obj/item/tool/weldingtool/proc/isOn)))
				return

		if(!WT.remove_fuel(0, user))
			return

		user.visible_message(span_notice("[user] begins welding down \the [src]."),
		span_notice("You begin welding down \the [src]."))
		add_overlay(GLOB.welding_sparks)
		playsound(loc, 'sound/items/welder2.ogg', 25, 1)
		if(!do_after(user, 5 SECONDS, NONE, src, BUSY_ICON_FRIENDLY))
			cut_overlay(GLOB.welding_sparks)
			to_chat(user, span_warning("You need to stand still!"))
			return
		user.visible_message(span_notice("[user] welds down \the [src]."),
		span_notice("You weld down \the [src]."))
		cut_overlay(GLOB.welding_sparks)
		if(buildstacktype && dropmetal)
			new buildstacktype(loc, buildstackamount)
		playsound(loc, 'sound/items/welder2.ogg', 25, 1)
		qdel(src)


/obj/structure/bed/chair/wood
	buildstacktype = /obj/item/stack/sheet/wood
	hit_sound = 'sound/effects/woodhit.ogg'

/obj/structure/bed/chair/wood/normal
	icon_state = "wooden_chair"
	name = "wooden chair"
	desc = "Old is never too old to not be in fashion."

/obj/structure/bed/chair/wood/wings
	icon_state = "wooden_chair_wings"
	name = "wooden chair"
	desc = "Old is never too old to not be in fashion."

/obj/structure/bed/chair/comfy
	name = "comfy chair"
	desc = "It looks comfy."
	icon_state = "comfychair"
	color = rgb(255,255,255)
	hit_sound = 'sound/weapons/bladeslice.ogg'

/obj/structure/bed/chair/comfy/brown
	color = rgb(255,113,0)

/obj/structure/bed/chair/comfy/beige
	color = rgb(255,253,195)

/obj/structure/bed/chair/comfy/teal
	color = rgb(0,255,255)

/obj/structure/bed/chair/comfy/black
	color = rgb(167,164,153)

/obj/structure/bed/chair/comfy/lime
	color = rgb(255,251,0)

/obj/structure/bed/chair/sofa
	name = "comfy sofa"
	desc = "It looks comfy."
	icon_state = "sofamiddle"
	resistance_flags = XENO_DAMAGEABLE
/obj/structure/bed/chair/sofa/left
	icon_state = "sofaend_left"

/obj/structure/bed/chair/sofa/right
	icon_state = "sofaend_right"

/obj/structure/bed/chair/sofa/corner
	icon_state = "sofacorner"

/obj/structure/bed/chair/sofa/corsat
	name = "comfy sofa"
	desc = "It looks comfy."
	icon_state = "couch_hori2"

/obj/structure/bed/chair/sofa/corsat/left
	icon_state = "couch_hori1"

/obj/structure/bed/chair/sofa/corsat/right
	icon_state = "couch_hori3"

/obj/structure/bed/chair/sofa/corsat/verticaltop
	icon_state = "couch_vet3"

/obj/structure/bed/chair/sofa/corsat/verticalmiddle
	icon_state = "couch_vet2"

/obj/structure/bed/chair/sofa/corsat/verticalsouth
	icon_state = "couch_vet1"

//cm benches do not have corners


/obj/structure/bed/chair/pew
	name = "chapel pew"
	desc = "An old fashioned wood pew."
	icon_state = "pews"

/obj/structure/bed/chair/office
	name = "Office Chair"
	desc = "A novel idea of a spinning chair with wheels on the bottom, for office work only."
	anchored = FALSE
	buckle_flags = CAN_BUCKLE
	drag_delay = 1 //Pulling something on wheels is easy

//directional chairs for random spawners
/obj/structure/bed/chair/office/light/north
	dir = 1

/obj/structure/bed/chair/office/light/east
	dir = 4

/obj/structure/bed/chair/office/light/west
	dir = 8

/obj/structure/bed/chair/office/dark/north
	dir = 1

/obj/structure/bed/chair/office/dark/east
	dir = 4

/obj/structure/bed/chair/office/dark/west
	dir = 8

/obj/structure/bed/chair/office/Bump(atom/A)
	. = ..()
	if(!LAZYLEN(buckled_mobs))
		return

	if(!propelled)
		return
	var/mob/living/occupant = buckled_mobs[1]
	unbuckle_mob(occupant)

	var/def_zone = ran_zone()
	var/armor_modifier = occupant.modify_by_armor(1, MELEE, 0, def_zone)
	occupant.throw_at(A, 3, propelled)
	occupant.apply_effect(6 SECONDS * armor_modifier, STUN)
	occupant.apply_effect(6 SECONDS * armor_modifier, WEAKEN)
	occupant.apply_effect(6 SECONDS * armor_modifier, STUTTER)
	occupant.apply_damage(10 * armor_modifier, BRUTE, def_zone)
	UPDATEHEALTH(occupant)
	playsound(src.loc, 'sound/weapons/punch1.ogg', 25, 1)
	if(isliving(A))
		var/mob/living/victim = A
		def_zone = ran_zone()
		armor_modifier = victim.modify_by_armor(1, MELEE, 0, def_zone)
		victim.apply_effect(6 SECONDS * armor_modifier, STUN)
		victim.apply_effect(6 SECONDS * armor_modifier, WEAKEN)
		victim.apply_effect(6 SECONDS * armor_modifier, STUTTER)
		victim.apply_damage(10 * armor_modifier, BRUTE, def_zone)
		UPDATEHEALTH(victim)
	occupant.visible_message(span_danger("[occupant] crashed into \the [A]!"))

/obj/structure/bed/chair/office/light
	icon_state = "officechair_white"
	anchored = FALSE

/obj/structure/bed/chair/office/dark
	icon_state = "officechair_dark"
	anchored = FALSE

/obj/structure/bed/chair/dropship/pilot
	icon_state = "pilot_chair"
	anchored = TRUE
	name = "pilot's chair"
	desc = "A specially designed chair for pilots to sit in."

/obj/structure/bed/chair/dropship/pilot/rotate()
	return // no

/obj/structure/bed/chair/dropship/passenger
	name = "passenger seat"
	desc = "Holds you in place during high altitude drops."
	icon_state = "shuttle_chair"
	var/image/chairbar = null
	var/chair_state = DROPSHIP_CHAIR_UNFOLDED
	buildstacktype = 0
	resistance_flags = RESIST_ALL
	var/is_animating = 0

/obj/structure/bed/chair/dropship/passenger/CanAllowThrough(atom/movable/mover, turf/target, height = 0, air_group = 0)
	if(chair_state == DROPSHIP_CHAIR_UNFOLDED && istype(mover, /obj/vehicle/multitile) && !is_animating)
		visible_message(span_danger("[mover] slams into [src] and breaks it!"))
		INVOKE_ASYNC(src, PROC_REF(fold_down), TRUE)
		return FALSE

	return ..()

/obj/structure/bed/chair/dropship/passenger/Initialize(mapload)
	. = ..()
	chairbar = image("icons/obj/objects.dmi", "shuttle_bars")
	chairbar.layer = ABOVE_MOB_LAYER


/obj/structure/bed/chair/dropship/passenger/post_buckle_mob(mob/buckling_mob)
	icon_state = "shuttle_chair_buckled"
	overlays += chairbar
	return ..()


/obj/structure/bed/chair/dropship/passenger/post_unbuckle_mob(mob/buckled_mob)
	icon_state = "shuttle_chair"
	overlays -= chairbar
	return ..()


/obj/structure/bed/chair/dropship/passenger/buckle_mob(mob/living/buckling_mob, force = FALSE, check_loc = TRUE, lying_buckle = FALSE, hands_needed = 0, target_hands_needed = 0, silent)
	if(chair_state != DROPSHIP_CHAIR_UNFOLDED)
		return FALSE
	return ..()

/obj/structure/bed/chair/dropship/passenger/proc/fold_down(break_it = FALSE)
	if(chair_state == DROPSHIP_CHAIR_UNFOLDED)
		is_animating = 1
		flick("shuttle_chair_new_folding", src)
		is_animating = 0
		if(LAZYLEN(buckled_mobs))
			unbuckle_mob(buckled_mobs[1])
		if(break_it)
			chair_state = DROPSHIP_CHAIR_BROKEN
		else
			chair_state = DROPSHIP_CHAIR_FOLDED
		sleep(0.5 SECONDS) // animation length
		icon_state = "shuttle_chair_new_folded"

/obj/structure/bed/chair/dropship/passenger/proc/unfold_up()
	if(chair_state == DROPSHIP_CHAIR_BROKEN)
		return
	is_animating = 1
	flick("shuttle_chair_new_unfolding", src)
	is_animating = 0
	chair_state = DROPSHIP_CHAIR_UNFOLDED
	sleep(0.5 SECONDS)
	icon_state = "shuttle_chair"

/obj/structure/bed/chair/dropship/passenger/rotate()
	return // no


/obj/structure/bed/chair/dropship/passenger/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(X.status_flags & INCORPOREAL)
		return FALSE
	if(chair_state != DROPSHIP_CHAIR_BROKEN)
		X.visible_message(span_warning("[X] smashes \the [src], shearing the bolts!"),
		span_warning("We smash \the [src], shearing the bolts!"))
		fold_down(1)

/obj/structure/bed/chair/dropship/passenger/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(iswrench(I))
		switch(chair_state)
			if(DROPSHIP_CHAIR_UNFOLDED)
				user.visible_message(span_warning("[user] begins loosening the bolts on \the [src]."),
				span_warning("You begin loosening the bolts on \the [src]."))
				playsound(loc, 'sound/items/ratchet.ogg', 25, 1)

				if(!do_after(user, 2 SECONDS, NONE, src, BUSY_ICON_BUILD))
					return

				user.visible_message(span_warning("[user] loosens the bolts on \the [src], folding it into the decking."),
				span_warning("You loosen the bolts on \the [src], folding it into the decking."))
				fold_down()

			if(DROPSHIP_CHAIR_FOLDED)
				user.visible_message(span_warning("[user] begins unfolding \the [src]."),
				span_warning("You begin unfolding \the [src]."))
				playsound(loc, 'sound/items/ratchet.ogg', 25, 1)

				if(!do_after(user, 2 SECONDS, NONE, src, BUSY_ICON_BUILD))
					return

				user.visible_message(span_warning("[user] unfolds \the [src] from the floor and tightens the bolts."),
				span_warning("You unfold \the [src] from the floor and tighten the bolts."))
				unfold_up()

			if(DROPSHIP_CHAIR_BROKEN)
				to_chat(user, span_warning("\The [src] appears to be broken and needs welding."))
				return

	else if(iswelder(I) && chair_state == DROPSHIP_CHAIR_BROKEN)
		var/obj/item/tool/weldingtool/C = I
		if(!C.remove_fuel(0, user))
			return

		playsound(loc, 'sound/items/weldingtool_weld.ogg', 25)
		user.visible_message(span_warning("[user] begins repairing \the [src]."),
		span_warning("You begin repairing \the [src]."))
		add_overlay(GLOB.welding_sparks)
		if(!do_after(user, 2 SECONDS, NONE, src, BUSY_ICON_BUILD))
			cut_overlay(GLOB.welding_sparks)
			return

		user.visible_message(span_warning("[user] repairs \the [src]."),
		span_warning("You repair \the [src]."))
		chair_state = DROPSHIP_CHAIR_FOLDED


/obj/structure/bed/chair/ob_chair
	name = "seat"
	desc = "A comfortable seat."
	icon_state = "ob_chair"
	buildstacktype = null
	resistance_flags = UNACIDABLE
	dir = WEST
