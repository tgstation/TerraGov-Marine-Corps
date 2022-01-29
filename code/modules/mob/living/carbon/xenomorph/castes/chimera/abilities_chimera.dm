// ***************************************
// *********** Blink
// ***************************************
/datum/action/xeno_action/activable/chimera_blink
	name = "Chimera Blink"
	action_icon_state = "blink"
	ability_name = "Chimera Blink"
	mechanics_text = "We teleport ourselves a short distance."
	use_state_flags = XABB_TURF_TARGET
	plasma_cost = 50
	cooldown_timer = 1 SECONDS

/datum/action/xeno_action/activable/chimera_blink/use_ability(atom/A)
	. = ..()
	var/mob/living/carbon/xenomorph/chimera/X = owner
	var/turf/original_turf = get_turf(X)
	var/turf/T = get_turf(A)

	if(!check_blink_tile(T, TRUE, FALSE))
		return fail_activate()

	X.face_atom(T)
	new /obj/effect/temp_visual/chimera_blink(T)
	new /obj/effect/temp_visual/chimera_blink(original_turf)
	playsound(T, 'sound/effects/ghost2.ogg', 50, TRUE)

	if(do_after(owner, 1.5 SECONDS, TRUE, owner, BUSY_ICON_HOSTILE))
		X.forceMove(T)
		playsound(T, 'sound/effects/EMPulse.ogg', 25, TRUE)
		new /obj/effect/temp_visual/wraith_warp(T)
		new /obj/effect/temp_visual/wraith_warp(original_turf)
		switch(X.selected_blink_effect)
			if(/datum/action/xeno_action/proc/teleport_flash)
				teleport_flash(X)
			if(/datum/action/xeno_action/proc/teleport_fling)
				teleport_fling(X)

	succeed_activate()
	add_cooldown(cooldown_timer)

/datum/action/xeno_action/activable/chimera_blink/proc/check_blink_tile(turf/T, ignore_blocker = FALSE, silent = FALSE)
	if(isclosedturf(T) || isspaceturf(T))
		if(!silent)
			to_chat(owner, span_xenowarning("We can't blink here!"))
		return FALSE

	var/area/target_area = get_area(T)
	if(is_type_in_typecache(target_area, GLOB.wraith_strictly_forbidden_areas))
		if(!silent)
			to_chat(owner, span_xenowarning("We can't blink into this area!"))
		return FALSE

	if(IS_OPAQUE_TURF(T))
		if(!silent)
			to_chat(owner, span_xenowarning("We can't blink into this space without vision!"))
		return FALSE

	if(ignore_blocker)
		return TRUE

	if(turf_block_check(owner, T, FALSE, TRUE, TRUE, TRUE, TRUE))
		if(!silent)
			to_chat(owner, span_xenowarning("We can't blink here!"))
		return FALSE

	for(var/atom/blocker AS in T)
		if(!blocker.CanPass(owner, T))
			if(!silent)
				to_chat(owner, span_xenowarning("We can't blink into a solid object!"))
			return FALSE

	return TRUE

/datum/action/xeno_action/proc/teleport_flash(atom/movable/teleporter)
	var/location = get_turf(teleporter)
	playsound(location, 'sound/effects/bang.ogg', 50, TRUE)
	for(var/mob/living/living_target in viewers(WORLD_VIEW, location))

		if(living_target.stat == DEAD || living_target == teleporter)
			continue

		switch(get_dist(living_target, location))
			if(0 to 1)
				if(living_target.flash_act())
					living_target.Paralyze(1 SECONDS)

			if(2 to 3)
				if(living_target.flash_act())
					living_target.Stun(1 SECONDS)

/datum/action/xeno_action/proc/teleport_fling(atom/movable/teleporter)
	var/location = get_turf(teleporter)
	playsound(location,'sound/effects/bamf.ogg', 75, TRUE)
	for(var/mob/living/living_target in range(2, location))

		if(living_target.stat == DEAD || living_target == teleporter)
			continue

		playsound(living_target,'sound/weapons/alien_claw_block.ogg', 75, 1)
		living_target.apply_effects(1, 1)
		var/throwlocation = living_target.loc
		for(var/x in 1 to 3)
			throwlocation = get_step(throwlocation, get_dir(owner, living_target))
		living_target.throw_at(throwlocation, 3, 1, owner, TRUE)

/datum/action/xeno_action/activable/chimera_blink/on_cooldown_finish()
	to_chat(owner, span_xenodanger("We are able to blink again."))
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()

// ***************************************
// *********** Select blink effect
// ***************************************
/datum/action/xeno_action/select_blink_effect
	name = "Select Blink Effect"
	action_icon_state = "32"
	mechanics_text = "Switch between different post-blink effects."
	use_state_flags = XACT_USE_BUSY|XACT_USE_LYING

/datum/action/xeno_action/select_blink_effect/give_action(mob/living/L)
	. = ..()
	var/mob/living/carbon/xenomorph/X = owner
	X.selected_blink_effect = GLOB.chimera_post_blink_effects[1]

/datum/action/xeno_action/select_blink_effect/action_activate()
	var/mob/living/carbon/xenomorph/X = owner
	var/i = GLOB.chimera_post_blink_effects.Find(X.selected_blink_effect)
	if(length(GLOB.chimera_post_blink_effects) == i)
		X.selected_blink_effect = GLOB.chimera_post_blink_effects[1]
	else
		X.selected_blink_effect = GLOB.chimera_post_blink_effects[i+1]

	var/atom/A = X.selected_blink_effect
	to_chat(X, span_notice("We will now use <b>[A.name]</b>."))
	return succeed_activate()

// ***************************************
// *********** Wormhole
// ***************************************
/datum/action/xeno_action/activable/create_wormhole
	name = "Create Wormhole"
	action_icon_state = "warp_shadow"
	mechanics_text = "Create an instable wormhole, which teleports can randomly teleport a mob."
	use_state_flags = XABB_TURF_TARGET
	plasma_cost = 50
	cooldown_timer = 1 SECONDS

/datum/action/xeno_action/activable/create_wormhole/use_ability(atom/A)
	. = ..()
	var/turf/T = get_turf(A)

	new /obj/effect/xenomorph/chimera_wormhole(T)

	succeed_activate()
	add_cooldown(cooldown_timer)

/datum/action/xeno_action/activable/create_wormhole/on_cooldown_finish()
	to_chat(owner, span_xenodanger("We are ready to create another wormhole."))
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()

// ***************************************
// *********** Forcewall
// ***************************************
/datum/action/xeno_action/create_forcewall
	name = "Create Forcewall"
	action_icon_state = "16"
	mechanics_text = "Create a forcewall that only aliens can walk through."
	use_state_flags = XABB_TURF_TARGET
	plasma_cost = 50
	cooldown_timer = 1 SECONDS

/datum/action/xeno_action/create_forcewall/action_activate()
	var/turf/T = get_turf(owner)
	new /obj/effect/xenomorph/force_wall(T)
	var/turf/otherT = get_step(T, turn(owner.dir, 90))
	if(otherT)
		new /obj/effect/xenomorph/force_wall(otherT)
	otherT = get_step(T, turn(owner.dir, -90))
	if(otherT)
		new /obj/effect/xenomorph/force_wall(otherT)

	succeed_activate()
	add_cooldown(cooldown_timer)

/datum/action/xeno_action/create_forcewall/on_cooldown_finish()
	to_chat(owner, span_xenodanger("We are ready to create another forcewall."))
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()

// ***************************************
// *********** Bodyswap
// ***************************************
/datum/action/xeno_action/activable/body_swap
	name = "body swap"
	action_icon_state = "hyperposition"
	mechanics_text = "Swap places with another alien."
	use_state_flags = XABB_MOB_TARGET
	plasma_cost = 50
	cooldown_timer = 1 SECONDS

/datum/action/xeno_action/activable/body_swap/use_ability(atom/A)
	. = ..()
	if(!isxeno(A))
		return fail_activate()

	var/mob/living/carbon/xenomorph/target = A
	var/mob/living/carbon/xenomorph/chimera/X = owner
	var/turf/target_turf = get_turf(A)
	var/turf/origin_turf = get_turf(X)

	new /obj/effect/temp_visual/blink_portal(origin_turf)
	new /obj/effect/temp_visual/blink_portal(target_turf)
	new /obj/effect/particle_effect/sparks(origin_turf)
	new /obj/effect/particle_effect/sparks(target_turf)
	playsound(target_turf, 'sound/effects/EMPulse.ogg', 25, TRUE)

	X.face_atom(target_turf)
	target.forceMove(origin_turf)
	X.forceMove(target_turf)

	succeed_activate()
	add_cooldown(cooldown_timer)

/datum/action/xeno_action/activable/body_swap/on_cooldown_finish()
	to_chat(owner, span_xenodanger("We gather enough strength to perform body swap again."))
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()
