/particles/xeno_smoke/acid_light
	color = "#9dcf30"


// ***************************************
// *********** Dump acid
// ***************************************

/datum/action/xeno_action/dump_acid
	name = "Dump Acid"
	action_icon_state = "dump_acid"
	desc = "You dump your acid to escape, creating clouds of deadly acid mist behind you, while becoming faster for a short period of time. Unroots you if you are rooted."
	ability_name = "dump acid"
	plasma_cost = 150
	cooldown_timer = 180 SECONDS
	keybind_flags = XACT_KEYBIND_USE_ABILITY|XACT_IGNORE_SELECTED_ABILITY
	use_state_flags = XACT_USE_STAGGERED|XACT_USE_ROOTED
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_DUMP_ACID,
	)
	/// Used for particles. Holds the particles instead of the mob. See particle_holder for documentation.
	var/obj/effect/abstract/particle_holder/particle_holder

/datum/action/xeno_action/dump_acid/action_activate()
	var/mob/living/carbon/xenomorph/boiler/caster = owner
	toggle_particles(TRUE)

	add_cooldown()
	succeed_activate()

	caster.visible_message(span_xenodanger("[caster] emits an acid!"),
	span_xenodanger("You dump your acid, disabling your offensive abilities to escape!"))

	if(HAS_TRAIT_FROM(caster, TRAIT_IMMOBILE, BOILER_ROOTED_TRAIT))
		REMOVE_TRAIT(caster, TRAIT_IMMOBILE, BOILER_ROOTED_TRAIT)
		if(caster.client)
			caster.client.mouse_pointer_icon = initial(caster.client.mouse_pointer_icon)
		caster.anchored = FALSE

	dispense_gas()

	var/datum/action/xeno_action/activable/spray_acid = caster.actions_by_path[/datum/action/xeno_action/activable/spray_acid/line/boiler]
	if(spray_acid)
		spray_acid.add_cooldown()

/datum/action/xeno_action/dump_acid/fail_activate()
	toggle_particles(FALSE)
	return ..()

/datum/action/xeno_action/dump_acid/proc/dispense_gas(time_left = 6)
	if(time_left <= 0)
		toggle_particles(FALSE)
		owner.remove_movespeed_modifier(MOVESPEED_ID_BOILER_DUMP)
		return

	var/mob/living/carbon/xenomorph/boiler/caster = owner
	var/smoke_range = 1
	var/datum/effect_system/smoke_spread/xeno/gas
	gas = new /datum/effect_system/smoke_spread/xeno/acid/light

	owner.add_movespeed_modifier(MOVESPEED_ID_BOILER_DUMP, TRUE, 0, NONE, TRUE, BOILER_DUMP_SPEED)
	if(caster.IsStun() || caster.IsParalyzed())
		to_chat(caster, span_xenohighdanger("We try to emit acid but are disabled!"))
		owner.remove_movespeed_modifier(MOVESPEED_ID_BOILER_DUMP)
		toggle_particles(FALSE)
		return
	var/turf/T = get_turf(caster)
	playsound(T, 'sound/effects/smoke.ogg', 25)
	if(time_left > 1)
		gas.set_up(smoke_range, T)
	else //last emission is larger
		gas.set_up(CEILING(smoke_range*1.3,1), T)

	gas.start()
	T.visible_message(span_danger("Acidic mist emits from the hulking xenomorph!"))

	addtimer(CALLBACK(src, PROC_REF(dispense_gas), time_left - 1), BOILER_GAS_DELAY)

// Toggles particles on or off, depending on the defined var. эта хуйня нужна
/datum/action/xeno_action/dump_acid/proc/toggle_particles(activate)
	if(!activate)
		QDEL_NULL(particle_holder)
		return

	particle_holder = new(owner, /particles/xeno_smoke/acid_light)
	particle_holder.pixel_x = 16
	particle_holder.pixel_y = 16
