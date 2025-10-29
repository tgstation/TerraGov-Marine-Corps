#define DROPSHIP_CHAIR_UNBUCKLED ""
#define DROPSHIP_CHAIR_FOLDED 0
#define DROPSHIP_CHAIR_BUCKLED "_buckled"
#define DROPSHIP_CHAIR_BROKEN "_broken"

#define LEADER_CHAIR 0

#define NO_CHAIR_COLOR ""
#define ALPHA_CHAIR "_alpha"
#define BRAVO_CHAIR "_bravo"
#define CHARLIE_CHAIR "_charlie"
#define DELTA_CHAIR "_delta"
#define FC_CHAIR "_fc"

/obj/structure/bed/chair //YES, chairs are a type of bed, which are a type of stool. This works, believe me.	-Pete
	name = "chair"
	desc = "A rectangular metallic frame sitting on four legs with a back panel. Designed to fit the sitting position, more or less comfortably."
	icon_state = "chair"
	buckle_lying = 0
	buckling_y = 0
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
	icon = 'icons/obj/structures/prop/mainship.dmi'
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
	set category = "IC.Object"
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
	if(.)
		return

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
			if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED, extra_checks = CALLBACK(WT, TYPE_PROC_REF(/obj/item/tool/weldingtool, isOn))))
				return

		if(!WT.remove_fuel(0, user))
			return

		user.visible_message(span_notice("[user] begins welding down \the [src]."),
		span_notice("You begin welding down \the [src]."))
		if(!I.use_tool(src, user, 5 SECONDS, 1, 25, null, BUSY_ICON_FRIENDLY))
			return
		user.visible_message(span_notice("[user] welds down \the [src]."),
		span_notice("You weld down \the [src]."))
		if(buildstacktype && dropmetal)
			new buildstacktype(loc, buildstackamount)
		qdel(src)


/obj/structure/bed/chair/wood
	buildstacktype = /obj/item/stack/sheet/wood
	hit_sound = 'sound/effects/natural/woodhit.ogg'

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

/obj/structure/bed/chair/sofa/corsat/white
	icon_state = "bench_hor2"

/obj/structure/bed/chair/sofa/corsat/single
	icon_state = "sofa"

/obj/structure/bed/chair/sofa/corsat/left
	icon_state = "couch_hori1"

/obj/structure/bed/chair/sofa/corsat/left/white
	icon_state = "bench_hor1"

/obj/structure/bed/chair/sofa/corsat/right
	icon_state = "couch_hori3"

/obj/structure/bed/chair/sofa/corsat/right/white
	icon_state = "bench_hor3"

/obj/structure/bed/chair/sofa/corsat/verticaltop
	icon_state = "couch_vet3"

/obj/structure/bed/chair/sofa/corsat/verticaltop/white
	icon_state = "bench_vet3"

/obj/structure/bed/chair/sofa/corsat/verticalmiddle
	icon_state = "couch_vet2"

/obj/structure/bed/chair/sofa/corsat/verticalmiddle/white
	icon_state = "bench_vet2"

/obj/structure/bed/chair/sofa/corsat/verticalsouth
	icon_state = "couch_vet1"

/obj/structure/bed/chair/sofa/corsat/verticalsouth/white
	icon_state = "bench_vet1"

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
	occupant.apply_effect(6 SECONDS * armor_modifier, EFFECT_STUN)
	occupant.apply_effect(6 SECONDS * armor_modifier, EFFECT_PARALYZE)
	occupant.apply_effect(6 SECONDS * armor_modifier, EFFECT_STUTTER)
	occupant.apply_damage(10 * armor_modifier, BRUTE, def_zone)
	UPDATEHEALTH(occupant)
	playsound(src.loc, 'sound/weapons/punch1.ogg', 25, 1)
	if(isliving(A))
		var/mob/living/victim = A
		def_zone = ran_zone()
		armor_modifier = victim.modify_by_armor(1, MELEE, 0, def_zone)
		victim.apply_effect(6 SECONDS * armor_modifier, EFFECT_STUN)
		victim.apply_effect(6 SECONDS * armor_modifier, EFFECT_PARALYZE)
		victim.apply_effect(6 SECONDS * armor_modifier, EFFECT_STUTTER)
		victim.apply_damage(10 * armor_modifier, BRUTE, def_zone)
		UPDATEHEALTH(victim)
	occupant.visible_message(span_danger("[occupant] crashed into \the [A]!"))

/obj/structure/bed/chair/office/light
	icon_state = "officechair_white"
	anchored = FALSE

/obj/structure/bed/chair/office/dark
	icon_state = "officechair_dark"
	anchored = FALSE

/obj/structure/bed/chair/dropship
	name = "dropship chair"
	desc = "Holds you in place during high altitude drops."
	icon_state = "shuttle_chair"
	/// Handles the chair buckle bars overlay
	var/image/chairbar = null
	buildstacktype = 0
	/// Handles the current state of the chair (buckled, unbuckled, folded, broke)
	var/chair_state = DROPSHIP_CHAIR_UNBUCKLED

/obj/structure/bed/chair/dropship/update_overlays()
	. = ..()
	if(chair_state == DROPSHIP_CHAIR_BUCKLED)
		. += image('icons/obj/objects.dmi', icon_state = "shuttle_bars", layer = ABOVE_MOB_LAYER)
		return

/obj/structure/bed/chair/dropship/doublewide/post_buckle_mob(mob/buckling_mob)
	chair_state = DROPSHIP_CHAIR_BUCKLED
	update_icon()
	return ..()

/obj/structure/bed/chair/dropship/doublewide/post_unbuckle_mob(mob/buckled_mob)
	chair_state = DROPSHIP_CHAIR_UNBUCKLED
	update_icon()
	return ..()

/obj/structure/bed/chair/dropship/pilot
	icon_state = "pilot_chair"
	name = "pilot's chair"
	desc = "A specially designed chair for pilots to sit in."

/obj/structure/bed/chair/dropship/pilot/rotate()
	return // no

/obj/structure/bed/chair/dropship/passenger
	name = "passenger seat"
	resistance_flags = RESIST_ALL
	var/is_animating = 0

/obj/structure/bed/chair/dropship/passenger/CanAllowThrough(atom/movable/mover, turf/target, height = 0, air_group = 0)
	if(chair_state == DROPSHIP_CHAIR_UNBUCKLED && istype(mover, /obj/vehicle/sealed) && !is_animating)
		visible_message(span_danger("[mover] slams into [src] and breaks it!"))
		INVOKE_ASYNC(src, PROC_REF(fold_down), TRUE)
		return FALSE

	return ..()

/obj/structure/bed/chair/dropship/passenger/buckle_mob(mob/living/buckling_mob, force = FALSE, check_loc = TRUE, lying_buckle = FALSE, hands_needed = 0, target_hands_needed = 0, silent)
	if(chair_state != DROPSHIP_CHAIR_UNBUCKLED)
		return FALSE
	return ..()

/obj/structure/bed/chair/dropship/passenger/proc/fold_down(break_it = FALSE)
	if(chair_state == DROPSHIP_CHAIR_UNBUCKLED)
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
	chair_state = DROPSHIP_CHAIR_UNBUCKLED
	sleep(0.5 SECONDS)
	icon_state = "shuttle_chair"

/obj/structure/bed/chair/dropship/passenger/rotate()
	return // no


/obj/structure/bed/chair/dropship/passenger/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	if(xeno_attacker.status_flags & INCORPOREAL)
		return FALSE
	if(chair_state != DROPSHIP_CHAIR_BROKEN)
		xeno_attacker.visible_message(span_warning("[xeno_attacker] smashes \the [src], shearing the bolts!"),
		span_warning("We smash \the [src], shearing the bolts!"))
		fold_down(1)

/obj/structure/bed/chair/dropship/passenger/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(iswrench(I))
		switch(chair_state)
			if(DROPSHIP_CHAIR_UNBUCKLED)
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

		user.visible_message(span_warning("[user] begins repairing \the [src]."),
		span_warning("You begin repairing \the [src]."))
		if(!I.use_tool(src, user, 2 SECONDS, 1, 25, null, BUSY_ICON_BUILD))
			return

		user.visible_message(span_warning("[user] repairs \the [src]."),
		span_warning("You repair \the [src]."))
		chair_state = DROPSHIP_CHAIR_FOLDED

/obj/structure/bed/chair/dropship/doublewide
	name = "doublewide seat"
	icon_state = "doublewide_chair" //only facing south cause the rest are ugly
	max_integrity = 130
	/// Handles the color of the chair
	var/chair_color = NO_CHAIR_COLOR
	/// If the chair can only be sat in by a leader or not
	var/leader_chair = FALSE

/obj/structure/bed/chair/dropship/doublewide/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(X.status_flags & INCORPOREAL)
		return FALSE
	if(LAZYLEN(buckled_mobs))
		unbuckle_all_mobs(TRUE)
	return ..()

/obj/structure/bed/chair/dropship/doublewide/welder_act(mob/living/user, obj/item/I)
	if(LAZYLEN(buckled_mobs))
		balloon_alert(user, "someone's sitting in it!")
		return
	welder_repair_act(user, I, 130, 1 SECONDS, 0, SKILL_ENGINEER_METAL, 1)
	chair_state = DROPSHIP_CHAIR_UNBUCKLED
	update_icon()
	return

/obj/structure/bed/chair/dropship/doublewide/update_icon_state()
	. = ..()
	var/percentage = (obj_integrity / max_integrity) * 100
	switch(percentage)
		if(-INFINITY to 65)
			chair_state = DROPSHIP_CHAIR_BROKEN
	icon_state = "doublewide_chair[chair_color][chair_state]"

/obj/structure/bed/chair/dropship/doublewide/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(LAZYLEN(buckled_mobs) && chair_state == DROPSHIP_CHAIR_BROKEN)
		unbuckle_mob(buckled_mobs[1])
		balloon_alert_to_viewers("it's too damaged!")

/obj/structure/bed/chair/dropship/doublewide/buckle_mob(mob/living/buckling_mob, force = FALSE, check_loc = TRUE, lying_buckle = FALSE, hands_needed = 0, target_hands_needed = 0, silent)
	if(chair_state == DROPSHIP_CHAIR_BROKEN)
		balloon_alert_to_viewers("it's too damaged!")
		return FALSE
	if(leader_chair && buckling_mob.skills.getRating(SKILL_LEADERSHIP) < SKILL_LEAD_TRAINED)
		balloon_alert(buckling_mob, "you're not a leader!")
		return FALSE
	if(buckling_x)
		src.pixel_x = buckling_x
	return ..()

/obj/structure/bed/chair/dropship/doublewide/post_buckle_mob(mob/buckling_mob)
	doublewide_mob_density(buckling_mob, TRUE)
	return ..()

/obj/structure/bed/chair/dropship/doublewide/post_unbuckle_mob(mob/buckled_mob)
	doublewide_mob_density(buckled_mob, FALSE)
	return ..()

/// Handles checking the changing density for the person buckling or unbuckling and the person next to the buckling/unbuckling person
/obj/structure/bed/chair/dropship/doublewide/proc/doublewide_mob_density(mob/interactionmob, buckling)
	var/obj/structure/bed/chair/dropship/doublewide/other_doublewide = locate(/obj/structure/bed/chair/dropship/doublewide) in interactionmob.loc
	var/mob/living/other_chair_buckled_mob
	if(other_doublewide) //if there is another doublewide
		if(LAZYLEN(other_doublewide.buckled_mobs) && (other_doublewide.buckled_mobs[1] != interactionmob))
			other_chair_buckled_mob = other_doublewide.buckled_mobs[1]
			if(buckling)
				other_chair_buckled_mob.density = TRUE
				interactionmob.density = TRUE
				return
			//if theyre unbuckling with and there is another buckled mob
			other_chair_buckled_mob.density = FALSE
			interactionmob.density = TRUE
			return
		if(buckling) //if theyre buckling with no other chairs
			interactionmob.density = FALSE
			return
	//if there is no other doublewide or theyre unbuckling
	interactionmob.density = TRUE

/obj/structure/bed/chair/dropship/doublewide/left
	pixel_x = -8
	buckling_x = -8

/obj/structure/bed/chair/dropship/doublewide/right
	pixel_x = 9
	buckling_x = 9

/obj/structure/bed/chair/dropship/doublewide/left/alpha
	name = "Alpha Squad Leader's Chair"
	desc = "A chair specially reserved for the Alpha Squad Leader."
	icon_state = "doublewide_chair_alpha"
	chair_color = ALPHA_CHAIR
	leader_chair = TRUE
	max_integrity = 200

/obj/structure/bed/chair/dropship/doublewide/right/bravo
	name = "Bravo Squad Leader's Chair"
	desc = "A chair specially reserved for the Bravo Squad Leader."
	icon_state = "doublewide_chair_bravo"
	chair_color = BRAVO_CHAIR
	leader_chair = TRUE
	max_integrity = 200

/obj/structure/bed/chair/dropship/doublewide/left/charlie
	name = "Charlie Squad Leader's Chair"
	desc = "A chair specially reserved for the Charlie Squad Leader."
	icon_state = "doublewide_chair_charlie"
	chair_color = CHARLIE_CHAIR
	leader_chair = TRUE
	max_integrity = 200

/obj/structure/bed/chair/dropship/doublewide/right/delta
	name = "Delta Squad Leader's Chair"
	desc = "A chair specially reserved for the Delta Squad Leader."
	icon_state = "doublewide_chair_delta"
	chair_color = DELTA_CHAIR
	leader_chair = TRUE
	max_integrity = 200

/obj/structure/bed/chair/dropship/doublewide/fieldcommander
	name = "Field Commander's Chair"
	desc = "A chair specially reserved for the Field Commander."
	icon_state = "doublewide_chair_fc"
	chair_color = FC_CHAIR
	leader_chair = TRUE
	max_integrity = 200

/obj/structure/bed/chair/ob_chair
	name = "seat"
	desc = "A comfortable seat."
	icon_state = "ob_chair"
	buildstacktype = null
	resistance_flags = UNACIDABLE
	dir = WEST
