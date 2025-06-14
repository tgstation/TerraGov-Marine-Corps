/obj/structure/xeno/recovery_pylon
	name = "recovery pylon"
	desc = "A resin pillar with a purple orb on the top. It pulsates with a faint hum."
	icon = 'icons/Xeno/2x2building.dmi'
	icon_state = "recovery_pylon"
	max_integrity = 100
	bound_width = 32
	bound_height = 32
	bound_x = 0
	pixel_x = -16
	pixel_y = -16
	/// List of buffed xenomorphs.
	var/list/mob/living/carbon/xenomorph/buffed_xenos = list()
	/// Holds the particles.
	var/obj/effect/abstract/particle_holder/particle_holder
	resistance_flags = UNACIDABLE|XENO_DAMAGEABLE

/obj/structure/xeno/recovery_pylon/Initialize(mapload, _hivenumber)
	. = ..()
	GLOB.hive_datums[hivenumber].recovery_pylons += src
	create_effects()
	update_minimap_icon()

/obj/structure/xeno/recovery_pylon/Destroy()
	GLOB.hive_datums[hivenumber].recovery_pylons -= src
	delete_effects()
	return ..()

/obj/structure/xeno/recovery_pylon/on_changed_z_level(turf/old_turf, turf/new_turf, notify_contents = TRUE)
	. = ..()
	delete_effects()
	if(new_turf?.z)
		create_effects()

/obj/structure/xeno/recovery_pylon/update_minimap_icon()
	SSminimaps.remove_marker(src)
	if(hivenumber != XENO_HIVE_CORRUPTED)
		SSminimaps.add_marker(src, MINIMAP_FLAG_XENO, image('icons/UI_icons/map_blips.dmi', null, "recovery", MINIMAP_LABELS_LAYER))
	if(hivenumber == XENO_HIVE_CORRUPTED)
		SSminimaps.add_marker(src, MINIMAP_FLAG_MARINE, image('icons/UI_icons/map_blips.dmi', null, "recovery", MINIMAP_LABELS_LAYER))

/obj/structure/xeno/recovery_pylon/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	if(!(issamexenohive(xeno_attacker)))
		return ..()
	if(xeno_attacker.a_intent != INTENT_HARM || !(xeno_attacker.xeno_caste.caste_flags & CASTE_IS_BUILDER))
		return ..()
	balloon_alert(xeno_attacker, "Removing...")
	if(!do_after(xeno_attacker, 2 SECONDS, IGNORE_HELD_ITEM, src, BUSY_ICON_HOSTILE))
		balloon_alert(xeno_attacker, "Stopped removing.")
		return
	playsound(src, SFX_ALIEN_RESIN_BREAK, 25)
	deconstruct(TRUE, xeno_attacker)

/// Applies a buff to any entering xenormorph that reduces improves regen variables.
/obj/structure/xeno/recovery_pylon/proc/apply_buff(datum/source, atom/movable/entering_movable, atom/old_loc)
	SIGNAL_HANDLER
	if(!isxeno(entering_movable))
		return
	var/mob/living/carbon/xenomorph/entering_xenomorph = entering_movable
	if((entering_xenomorph in buffed_xenos) || !issamexenohive(entering_xenomorph))
		return
	buffed_xenos += entering_xenomorph
	entering_xenomorph.xeno_caste.regen_delay = 1 SECONDS
	entering_xenomorph.regen_power = max(-entering_xenomorph.xeno_caste.regen_delay, entering_xenomorph.regen_power)
	entering_xenomorph.xeno_caste.regen_ramp_amount *= 2

/// Reverses the buffs to leaving xenomorphs if they were given it.
/obj/structure/xeno/recovery_pylon/proc/remove_buff(datum/source, atom/movable/leaving_movable, direction)
	SIGNAL_HANDLER
	if(direction) // No need to change anything if they are staying within range.
		var/turf/leaving_to_turf = get_step(source, direction)
		if(HAS_TRAIT(leaving_to_turf, TRAIT_RECOVERY_PYLON_TURF))
			return
	var/mob/living/carbon/xenomorph/leaving_xenomorph = leaving_movable
	if(!(leaving_xenomorph in buffed_xenos))
		return
	buffed_xenos -= leaving_xenomorph
	leaving_xenomorph.xeno_caste.regen_delay = initial(leaving_xenomorph.xeno_caste.regen_delay)
	leaving_xenomorph.xeno_caste.regen_ramp_amount /= 2

/// Creates what this structure is suppose to do.
/obj/structure/xeno/recovery_pylon/proc/create_effects()
	var/list/turf/affected_turfs = RANGE_TURFS(1, src) // There should be no issue as long these buildings don't overlap.
	for(var/turf/affected_turf AS in affected_turfs)
		RegisterSignal(affected_turf, COMSIG_ATOM_EXITED, PROC_REF(remove_buff))
		RegisterSignal(affected_turf, COMSIG_ATOM_ENTERED, PROC_REF(apply_buff))
		ADD_TRAIT(affected_turf, TRAIT_RECOVERY_PYLON_TURF, XENO_TRAIT)
		for(var/mob/living/carbon/xenomorph/affected_xeno in affected_turf)
			apply_buff(null, affected_xeno)
	particle_holder = new(get_turf(src), /particles/recovery_pylon_aoe)
	particle_holder.particles.position = generator(GEN_SQUARE, 0, 48, LINEAR_RAND)

/// Removes what this structure is suppose to do.
/obj/structure/xeno/recovery_pylon/proc/delete_effects()
	if(particle_holder)
		particle_holder.particles.spawning = 0
		QDEL_IN(particle_holder, 4 SECONDS)
	var/list/turf/affected_turfs = RANGE_TURFS(1, src)
	for(var/turf/affected_turf AS in affected_turfs)
		UnregisterSignal(affected_turf, list(COMSIG_ATOM_EXITED, COMSIG_ATOM_ENTERED))
		REMOVE_TRAIT(affected_turf, TRAIT_RECOVERY_PYLON_TURF, XENO_TRAIT)
		for(var/mob/living/carbon/xenomorph/affected_xeno AS in buffed_xenos)
			remove_buff(null, affected_xeno)

/particles/recovery_pylon_aoe
	icon = 'icons/effects/particles/generic_particles.dmi'
	icon_state = list("cross" = 1, "x" = 1, "rectangle" = 1, "up_arrow" = 1, "down_arrow" = 1, "square" = 1)
	width = 500
	height = 500
	count = 500
	spawning = 20
	gravity = list(0, 0.1)
	color = LIGHT_COLOR_BLUE
	lifespan = 13
	fade = 5
	fadein = 5
	scale = 0.8
	friction = generator(GEN_NUM, 0.1, 0.15)
	spin = generator(GEN_NUM, -20, 20)
