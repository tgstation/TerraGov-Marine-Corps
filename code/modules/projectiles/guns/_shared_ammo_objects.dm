// Used for objects created by ammo datums that tend to be more general and can be used in multiple ammo datum files.


/////////////////////////////
//          FIRE           //
/////////////////////////////
// Base type , meant to be overridden
/obj/fire
	name = "fire"
	desc = "Ouch!"
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = 'icons/effects/fire.dmi'
	icon_state = "red_2"
	layer = BELOW_OBJ_LAYER
	light_system = STATIC_LIGHT
	light_on = TRUE
	light_range = 3
	light_power = 3
	/// tracks for how many process ticks the fire will exist.Can be reduced by other sources
	var/burn_ticks = 10
	///The color the flames and associated particles appear
	var/flame_color = "red"
	///Tracks how HOT the fire is. This is basically the heat level of the fire and determines the temperature
	var/burn_level = 20
	/// How many burn ticks we lose per process
	var/burn_decay = 1

/obj/fire/Initialize(mapload, new_burn_ticks = burn_ticks, new_burn_level = burn_level, f_color, fire_stacks = 0, fire_damage = 0)
	. = ..()
	START_PROCESSING(SSobj, src)

	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_cross),
		COMSIG_TURF_JUMP_ENDED_HERE = PROC_REF(on_jump_landing),
		COMSIG_XENOMORPH_ATTACK_TURF = PROC_REF(on_xeno_attack),
	)
	AddElement(/datum/element/connect_loc, connections)
	AddComponent(/datum/component/submerge_modifier, 10)
	set_fire(new_burn_ticks, new_burn_level, f_color, fire_stacks, fire_damage)
	notify_ai_hazard()

/obj/fire/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/fire/update_icon()
	. = ..()
	var/light_intensity = 3
	switch(burn_ticks)
		if(1 to 9)
			light_intensity = 2
		if(10 to 25)
			light_intensity = 4
		if(25 to INFINITY)
			light_intensity = 6
	set_light(light_intensity, light_power, light_color)

/obj/fire/update_icon_state()
	. = ..()
	switch(flame_color)
		if("red")
			light_color = LIGHT_COLOR_FLAME
		if("blue")
			light_color = LIGHT_COLOR_BLUE_FLAME
		if("green")
			light_color = LIGHT_COLOR_ELECTRIC_GREEN
	switch(burn_ticks)
		if(1 to 9)
			icon_state = "[flame_color]_1"
		if(10 to 25)
			icon_state = "[flame_color]_2"
		if(25 to INFINITY)
			icon_state = "[flame_color]_3"

/obj/fire/update_overlays()
	. = ..()
	. += emissive_appearance(icon, icon_state, src)

/obj/fire/can_z_move(direction, turf/start, turf/destination, z_move_flags, mob/living/rider)
	z_move_flags |= ZMOVE_ALLOW_ANCHORED
	return ..()

/obj/fire/onZImpact(turf/impacted_turf, levels, impact_flags = NONE)
	impact_flags |= ZIMPACT_NO_SPIN
	return ..()

/obj/fire/process()
	if(!isturf(loc))
		qdel(src)
		return PROCESS_KILL

	burn_ticks -= burn_decay
	if(burn_ticks <= 0)
		qdel(src)
		return PROCESS_KILL

	affect_atom(loc)
	for(var/thing in loc)
		affect_atom(thing)

	update_appearance(UPDATE_ICON)

/obj/fire/effect_smoke(obj/effect/particle_effect/smoke/affecting_smoke)
	if(!CHECK_BITFIELD(affecting_smoke.smoke_traits, SMOKE_EXTINGUISH))
		return
	burn_ticks -= EXTINGUISH_AMOUNT
	if(burn_ticks <= 0)
		playsound(affecting_smoke, 'sound/effects/smoke_extinguish.ogg', 20)
		qdel(src)
		return
	update_appearance(UPDATE_ICON)

///Sets the fire_base object to the correct colour and fire_base values, and applies the initial effects to anything on the turf
/obj/fire/proc/set_fire(new_burn_ticks, new_burn_level, new_flame_color, fire_stacks = 0, fire_damage = 0)
	if(new_burn_ticks <= 0)
		qdel(src)
		return

	if(new_flame_color)
		flame_color = new_flame_color
	if(new_burn_ticks)
		burn_ticks = new_burn_ticks
	if(new_burn_level)
		burn_level = new_burn_level
	if(!GLOB.flamer_particles[flame_color])
		GLOB.flamer_particles[flame_color] = new /particles/flamer_fire(flame_color)

	particles = GLOB.flamer_particles[flame_color]
	update_appearance(UPDATE_ICON)

	if((fire_stacks + fire_damage) <= 0)
		return

	for(var/thing in get_turf(src))
		affect_atom(thing)

///Effects applied to anything that crosses a burning turf
/obj/fire/proc/on_cross(datum/source, atom/movable/crosser, oldloc, oldlocs)
	SIGNAL_HANDLER
	affect_atom(crosser)

///Effects applied to anything that jumps onto the fire
/obj/fire/proc/on_jump_landing(datum/source, mob/living/jumper)
	SIGNAL_HANDLER
	affect_atom(jumper)

///Xeno attack interaction with this fire
/obj/fire/proc/on_xeno_attack(datum/source, mob/living/carbon/xenomorph/xeno_attacker)
	SIGNAL_HANDLER
	return

///Applies effects to an atom
/obj/fire/proc/affect_atom(atom/affected)
	return

///Reduces duration of fire
/obj/fire/proc/reduce_fire(amount = 1)
	if(amount <= 0)
		return
	burn_ticks -= amount
	if(burn_ticks > 0)
		update_appearance(UPDATE_ICON)
	else
		qdel(src)

/////////////////////////////
//      FLAMER FIRE        //
/////////////////////////////

/obj/fire/flamer
	icon_state = "red_2"
	burn_ticks = 12

/obj/fire/flamer/affect_atom(atom/affected)
	affected.fire_act(burn_level)

/obj/fire/flamer/process()
	. = ..()
	burn_level -= 2
	if(burn_level <= 0)
		qdel(src)
		return PROCESS_KILL

/obj/fire/flamer/on_xeno_attack(datum/source, mob/living/carbon/xenomorph/xeno_attacker)
	if(xeno_attacker.a_intent != INTENT_HELP)
		return
	if(xeno_attacker.do_actions)
		return
	if(xeno_attacker.incapacitated())
		return

	xeno_attacker.changeNext_move(xeno_attacker.xeno_caste.attack_delay)
	burn_ticks -= 10
	playsound(src, 'sound/weapons/thudswoosh.ogg', 25, 1, 7)

	xeno_attacker.visible_message(span_danger("[xeno_attacker] tries to put out the fire!"), \
		span_warning("We try to put out the fire!"), null, 5)
	if(burn_ticks > 0)
		update_appearance(UPDATE_ICON)
		return
	xeno_attacker.visible_message(span_danger("[xeno_attacker] has successfully extinguished the fire!"), \
		span_notice("We extinguished the fire."), null, 5)
	qdel(src)

///////////////////////////////
//        MELTING FIRE       //
///////////////////////////////

/obj/fire/melting_fire
	name = "melting fire"
	desc = "It feels cold to the touch, yet it burns."
	icon_state = "xeno_fire"
	flame_color = "purple"
	light_on = FALSE
	light_range = 0
	light_power = 0
	burn_ticks = 36
	burn_decay = 9
	/// The creator of this fire. Only really matters for pyrogens.
	var/mob/living/carbon/xenomorph/creator

/obj/fire/melting_fire/update_overlays()
	. = ..()
	. += emissive_appearance(icon, icon_state, src)

/obj/fire/melting_fire/affect_atom(atom/affected)
	if(isvehicle(affected))
		var/obj/vehicle/ghost_rider = affected
		ghost_rider.take_damage(burn_level / 2, BURN, ACID)
		return
	if(!ishuman(affected))
		return
	var/mob/living/carbon/human/human_affected = affected
	if(human_affected.stat == DEAD)
		return
	if(human_affected.status_flags & (INCORPOREAL|GODMODE))
		return
	if(human_affected.pass_flags & PASS_FIRE)
		return
	if(human_affected.soft_armor.getRating(FIRE) >= 100)
		to_chat(human_affected, span_warning("You are untouched by the flames."))
		return
	handle_human(human_affected)

/// Handles everything that should be done to the human whom is affected by the fire.
/obj/fire/melting_fire/proc/handle_human(mob/living/carbon/human/affected_human)
	var/datum/status_effect/stacking/melting_fire/debuff = affected_human.has_status_effect(STATUS_EFFECT_MELTING_FIRE)
	if(debuff)
		debuff.add_stacks(PYROGEN_MELTING_FIRE_EFFECT_STACK, creator)
	else
		affected_human.apply_status_effect(STATUS_EFFECT_MELTING_FIRE, PYROGEN_MELTING_FIRE_EFFECT_STACK, creator)
	affected_human.take_overall_damage(PYROGEN_MELTING_FIRE_DAMAGE, BURN, FIRE, updating_health = TRUE, max_limbs = 2)

///////////////////////////////
//        SHATTERING FIRE    //
///////////////////////////////

/obj/fire/melting_fire/shattering
	name = "shattering fire"
	desc = "Cold to the touch, it rapidly spreads cracks through anything it contacts."
	icon_state = "violet_1"
	flame_color = "violet"

/obj/fire/melting_fire/shattering/handle_human(mob/living/carbon/human/affected_human)
	..()
	affected_human.apply_status_effect(STATUS_EFFECT_SHATTER, 3 SECONDS)

/obj/fire/melting_fire/melting_acid
	name = "melting acid fire"
	desc = "Cold to the touch, it burns in more ways than one."
	icon_state = "green_1"
	flame_color = "green"

/obj/fire/melting_fire/melting_acid/handle_human(mob/living/carbon/human/affected_human)
	// In sum, it is acid-based and can't be put out like fire. Discounting armor, better than melting at very-low (1-2) and very-high (22-30).
	var/datum/status_effect/stacking/melting_acid/debuff = affected_human.has_status_effect(STATUS_EFFECT_MELTING_ACID)
	if(debuff)
		debuff.add_stacks(1)
	else
		affected_human.apply_status_effect(STATUS_EFFECT_MELTING_ACID, 1)
	affected_human.take_overall_damage(PYROGEN_MELTING_FIRE_DAMAGE, BURN, ACID, updating_health = TRUE, max_limbs = 2)
