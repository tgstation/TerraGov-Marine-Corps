
// ***************************************
// *********** Melter's Overrides
// ***************************************
/datum/action/ability/activable/xeno/corrosive_acid/melter
	desc = "Cover an object with acid to slowly melt it. Takes less time than usual."
	ability_cost = 25
	acid_type = /obj/effect/xenomorph/acid/weak
	acid_speed_multiplier = 0.75 // 50% faster

/datum/action/ability/activable/xeno/charge/acid_dash/melter
	ability_cost = 50
	cooldown_duration = 15 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_ACID_DASH_MELTER,
	)
	charge_range = 7
	do_acid_spray_act = FALSE

/datum/action/ability/activable/xeno/charge/acid_dash/melter/mob_hit(datum/source, mob/living/living_target)
	. = ..()
	if(living_target.stat || isxeno(living_target) || !(iscarbon(living_target)))
		return
	var/mob/living/carbon/carbon_victim = living_target
	carbon_victim.apply_damage(20, BURN, null, ACID)


// ***************************************
// *********** Melter's Shroud
// ***************************************
/datum/action/ability/activable/xeno/melter_shroud
	name = "Melter Shroud"
	action_icon_state = "acid_shroud"
	action_icon = 'icons/Xeno/actions/boiler.dmi'
	desc = "Creates see-through acid smoke below yourself."
	ability_cost = 50
	use_state_flags = ABILITY_USE_BUSY|ABILITY_USE_LYING
	keybind_flags = ABILITY_KEYBIND_USE_ABILITY | ABILITY_IGNORE_SELECTED_ABILITY
	cooldown_duration = 32 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_ACID_SHROUD_MELTER,
	)

/datum/action/ability/activable/xeno/melter_shroud/use_ability(atom/A)
	var/datum/effect_system/smoke_spread/emitted_gas = new /datum/effect_system/smoke_spread/xeno/acid(xeno_owner)
	emitted_gas.set_up(2, get_turf(xeno_owner))
	emitted_gas.start()
	succeed_activate()
	add_cooldown()


// ***************************************
// *********** Acidic Missile
// ***************************************
/datum/action/ability/activable/xeno/acidic_missile
	name = "Acidic Missile"
	action_icon_state = "pounce"
	action_icon = 'icons/Xeno/actions/runner.dmi'
	desc = "Slowly build up acid in preparation to launch yourself as an acidic missile. Can launch yourself early if desired. Will slow you down initially, but will ramp up speed at maximum acid of 5x5."
	ability_cost = 100
	cooldown_duration = 60 SECONDS
	use_state_flags = ABILITY_USE_BUSY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_ACIDIC_MISSILE,
	)
	/// The particles effects from activation.
	var/obj/effect/abstract/particle_holder/particle_holder
	/// The acid level of the ability. Affects radius and movement speed.
	var/acid_level = 0

/datum/action/ability/activable/xeno/acidic_missile/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(xeno_owner.plasma_stored < ability_cost)
		return FALSE
	if(xeno_owner.xeno_flags & XENO_LEAPING)
		return

/datum/action/ability/activable/xeno/acidic_missile/use_ability(atom/A)
	if(!acid_level)
		if(length(xeno_owner.do_actions) && LAZYACCESS(xeno_owner.do_actions, xeno_owner))
			return
		particle_holder = new(owner, /particles/melter_steam)
		particle_holder.pixel_y = -8
		particle_holder.pixel_x = 10
		increase_acid_level(FALSE)
		return
	RegisterSignal(xeno_owner, COMSIG_MOVABLE_POST_THROW, PROC_REF(throw_complete))
	RegisterSignal(xeno_owner, COMSIG_LIVING_STATUS_STAGGER, PROC_REF(on_stagger))
	xeno_owner.xeno_flags |= XENO_LEAPING
	xeno_owner.throw_at(A, HUNTER_POUNCE_RANGE, XENO_POUNCE_SPEED, xeno_owner)

/// Completes the ability and triggers the acid explosion.
/datum/action/ability/activable/xeno/acidic_missile/proc/throw_complete(datum/source)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(acid_explosion), TRUE, TRUE, FALSE, TRUE)

/// Completes the ability and triggers the acid explosion at a reduced acid level.
/datum/action/ability/activable/xeno/acidic_missile/proc/on_stagger(datum/source, amount, ignore_canstun)
	SIGNAL_HANDLER
	acid_level = max(0, acid_level - 1)
	INVOKE_ASYNC(src, PROC_REF(acid_explosion), TRUE, TRUE, FALSE, TRUE)

/// Increases acid level and handles its associated effects.
/datum/action/ability/activable/xeno/acidic_missile/proc/increase_acid_level(require_acid_level = TRUE)
	switch(acid_level)
		if(0)
			xeno_owner.add_atom_colour("#bcff70", FIXED_COLOR_PRIORITY)
			xeno_owner.do_jitter_animation(100)
			xeno_owner.add_movespeed_modifier(MOVESPEED_ID_ACIDIC_MISSILE, TRUE, 0, NONE, TRUE, 1.5)
		if(1)
			xeno_owner.do_jitter_animation(500)
			xeno_owner.add_movespeed_modifier(MOVESPEED_ID_ACIDIC_MISSILE, TRUE, 0, NONE, TRUE, 1)
		if(2)
			xeno_owner.do_jitter_animation(1000)
			xeno_owner.add_movespeed_modifier(MOVESPEED_ID_ACIDIC_MISSILE, TRUE, 0, NONE, TRUE, 0.5)
		if(3)
			xeno_owner.do_jitter_animation(4000)
			xeno_owner.remove_movespeed_modifier(MOVESPEED_ID_ACIDIC_MISSILE)
			xeno_owner.emote("roar2")
			if(do_after(owner, 2.5 SECONDS, IGNORE_HELD_ITEM|IGNORE_LOC_CHANGE, xeno_owner, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, PROC_REF(do_after_checks))))
				acid_level--
			if(!(xeno_owner.xeno_flags & XENO_LEAPING))
				acid_explosion()
			return
	if(do_after(xeno_owner, 1.6 SECONDS, IGNORE_HELD_ITEM|IGNORE_LOC_CHANGE, xeno_owner, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, PROC_REF(do_after_checks), require_acid_level)))
		acid_level++
		increase_acid_level()
		return
	if(xeno_owner.xeno_flags & XENO_LEAPING)
		return
	acid_level = max(0, acid_level - 1)
	acid_explosion()

/// Additional checks for do_after. They must have acid level, enough plasma, and must not be leaping.
/datum/action/ability/activable/xeno/acidic_missile/proc/do_after_checks(require_acid_level = TRUE)
	if(require_acid_level && !acid_level)
		return FALSE
	if(xeno_owner.plasma_stored < ability_cost)
		return FALSE
	if(xeno_owner.xeno_flags & XENO_LEAPING)
		return FALSE
	return TRUE

/// Resets everything related to the ability and ends/completes the ability.
/datum/action/ability/activable/xeno/acidic_missile/proc/end_ability()
	QDEL_NULL(particle_holder)
	UnregisterSignal(xeno_owner, list(COMSIG_MOVABLE_POST_THROW, COMSIG_LIVING_STATUS_STAGGER))
	xeno_owner.remove_movespeed_modifier(MOVESPEED_ID_ACIDIC_MISSILE)
	xeno_owner.remove_atom_colour(FIXED_COLOR_PRIORITY, "#bcff70")
	if(xeno_owner.xeno_flags & XENO_LEAPING)
		xeno_owner.xeno_flags &= ~XENO_LEAPING
	acid_level = 0
	add_cooldown()
	succeed_activate()

/// Explodes with a radius based on acid level.
/datum/action/ability/activable/xeno/acidic_missile/proc/acid_explosion(end_ability_afterward = TRUE, requires_plasma = TRUE, disallow_leaping = TRUE, do_emote = FALSE)
	if(!acid_level || (requires_plasma && xeno_owner.plasma_stored < ability_cost) || (disallow_leaping && (xeno_owner.xeno_flags & XENO_LEAPING)))
		if(end_ability_afterward)
			end_ability()
		return
	for(var/turf/acid_tile AS in RANGE_TURFS(acid_level - 1, xeno_owner.loc))
		if(!line_of_sight(xeno_owner.loc, acid_tile))
			continue
		new /obj/effect/temp_visual/acid_splatter(acid_tile)
		if(!locate(/obj/effect/xenomorph/spray) in acid_tile.contents)
			new /obj/effect/xenomorph/spray(acid_tile, 3 SECONDS, 16)
			for (var/atom/movable/atom_in_acid AS in acid_tile)
				atom_in_acid.acid_spray_act(xeno_owner)
	if(do_emote)
		xeno_owner.emote("roar4")
	if(end_ability_afterward)
		end_ability()

/particles/melter_steam
	icon = 'icons/effects/particles/smoke.dmi'
	icon_state = list("steam_1" = 1, "steam_2" = 1, "steam_3" = 2)
	width = 100
	height = 300
	count = 50
	spawning = 3
	lifespan = 1.5 SECONDS
	fade = 3 SECONDS
	velocity = list(0, 0.3, 0)
	position = list(5, 16, 0)
	drift = generator(GEN_SPHERE, 0, 1, NORMAL_RAND)
	friction = 0.1
	gravity = list(0, 0.95)
	grow = 0.1
