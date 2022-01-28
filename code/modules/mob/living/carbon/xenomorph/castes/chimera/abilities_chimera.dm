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
	var/turf/T = get_turf(A)

	if(!check_blink_tile(T, TRUE, FALSE))
		return fail_activate()

	X.face_atom(T)
	play_blink_effect(get_turf(X))

	X.forceMove(T)
	play_blink_effect(T)
	playsound(T, 'sound/effects/ghost2.ogg', 50, TRUE)

	switch(X.selected_blink_effect)
		if(/datum/action/xeno_action/proc/teleport_flash)
			if(do_after(owner, 1 SECONDS, TRUE, owner, BUSY_ICON_HOSTILE))
				teleport_flash(X)
		if(/datum/action/xeno_action/proc/teleport_fling)
			if(do_after(owner, 1 SECONDS, TRUE, owner, BUSY_ICON_HOSTILE))
				teleport_fling(X)

	succeed_activate()
	add_cooldown(cooldown_timer)

/datum/action/xeno_action/activable/chimera_blink/proc/check_blink_tile(turf/T, ignore_blocker = FALSE, silent = FALSE)
	if(isclosedturf(T) || isspaceturf(T))
		if(!silent)
			to_chat(owner, span_xenowarning("We can't blink here!"))
		return FALSE

	var/area/target_area = get_area(T) //We are forced to set this; will not work otherwise
	if(is_type_in_typecache(target_area, GLOB.wraith_strictly_forbidden_areas)) //We can't enter these period.
		if(!silent)
			to_chat(owner, span_xenowarning("We can't blink into this area!"))
		return FALSE

	if(IS_OPAQUE_TURF(T))
		if(!silent)
			to_chat(owner, span_xenowarning("We can't blink into this space without vision!"))
		return FALSE

	for(var/atom/blocker AS in T)
		if(!blocker.CanPass(owner, T))
			if(!silent)
				to_chat(owner, span_xenowarning("We can't blink into a solid object!"))
			return FALSE

	if(ignore_blocker) //If we don't care about objects occupying the target square, return TRUE; used for checking pathing through transparents
		return TRUE

	if(turf_block_check(owner, T, FALSE, TRUE, TRUE, TRUE, TRUE)) //Check if there's anything that blocks us; we only care about Canpass here
		if(!silent)
			to_chat(owner, span_xenowarning("We can't blink here!"))
		return FALSE

	return TRUE

/datum/action/xeno_action/proc/play_blink_effect(turf/T)
	playsound(T, 'sound/effects/EMPulse.ogg', 25, TRUE)
	new /obj/effect/temp_visual/blink_portal(T)
	new /obj/effect/temp_visual/wraith_warp(T)

/datum/action/xeno_action/proc/teleport_flash(atom/movable/teleporter)
	name = "Flash"
	var/location = get_turf(teleporter)
	playsound(location, 'sound/effects/bang.ogg', 50, TRUE)
	for(var/mob/living/living_target in viewers(WORLD_VIEW, location))

		if(living_target.stat == DEAD || living_target == teleporter)
			continue

		switch(get_dist(living_target, location))
			if(0 to 1)
				if(living_target.flash_act())
					living_target.Paralyze(1 SECONDS)

			if(2 to 4)
				if(living_target.flash_act())
					living_target.Stun(1 SECONDS)

/datum/action/xeno_action/proc/teleport_fling(atom/movable/teleporter)
	name = "Fling"
	var/location = get_turf(teleporter)
	playsound(location,'sound/effects/bamf.ogg', 75, TRUE)
	for(var/mob/living/living_target in range(2, location))

		if(living_target.stat == DEAD || living_target == teleporter)
			continue

		playsound(living_target,'sound/weapons/alien_claw_block.ogg', 75, 1)
		living_target.apply_effects(1, 1)
		var/throwlocation = living_target.loc
		for(var/x in 1 to 4)
			throwlocation = get_step(throwlocation, get_dir(owner, living_target))
		living_target.throw_at(throwlocation, 4, 1, owner, TRUE)

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
	mechanics_text = "Switch between different effects post-blink"
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
