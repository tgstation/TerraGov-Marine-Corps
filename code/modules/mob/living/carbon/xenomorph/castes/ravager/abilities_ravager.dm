#define STAGE_ONE_BLOODTHIRST 100
#define STAGE_TWO_BLOODTHIRST 300
#define STAGE_THREE_BLOODTHIRST 400

// ***************************************
// *********** Charge
// ***************************************
/datum/action/ability/activable/xeno/charge
	name = "Eviscerating Charge"
	action_icon_state = "pounce"
	action_icon = 'icons/Xeno/actions/runner.dmi'
	desc = "Charge up to 4 tiles and viciously attack your target."
	cooldown_duration = 20 SECONDS
	ability_cost = 500 //Can't ignore pain/Charge and ravage in the same timeframe, but you can combo one of them.
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_RAVAGER_CHARGE,
	)
	/// The amount of deciseconds that carbons will be paralyze if hit.
	var/paralyze_duration = 2 SECONDS
	/// The maximum range/distance that can be charged.
	var/charge_range = RAV_CHARGEDISTANCE

/datum/action/ability/activable/xeno/charge/use_ability(atom/A)
	if(!A)
		return
	RegisterSignal(xeno_owner, COMSIG_XENO_OBJ_THROW_HIT, PROC_REF(obj_hit))
	RegisterSignal(xeno_owner, COMSIG_MOVABLE_POST_THROW, PROC_REF(charge_complete))
	RegisterSignal(xeno_owner, COMSIG_XENOMORPH_LEAP_BUMP, PROC_REF(mob_hit))

	xeno_owner.visible_message(span_danger("[xeno_owner] charges towards \the [A]!"), \
	span_danger("We charge towards \the [A]!") )
	xeno_owner.emote("roar")
	xeno_owner.xeno_flags |= XENO_LEAPING //This has to come before throw_at, which checks impact. So we don't do end-charge specials when thrown
	var/multiplier = 1
	if(HAS_TRAIT(owner, TRAIT_BLOODTHIRSTER))
		if(xeno_owner.plasma_stored >= STAGE_TWO_BLOODTHIRST)
			multiplier += 0.5
			if(xeno_owner.plasma_stored >= STAGE_THREE_BLOODTHIRST)
				multiplier += 0.5

	xeno_owner.throw_at(A, charge_range*multiplier, RAV_CHARGESPEED*multiplier, xeno_owner)

	add_cooldown()
	succeed_activate()


/datum/action/ability/activable/xeno/charge/on_cooldown_finish()
	to_chat(owner, span_xenodanger("Our exoskeleton quivers as we get ready to use [name] again."))
	playsound(owner, 'sound/effects/alien/new_larva.ogg', 50, 0, 1)
	return ..()

/datum/action/ability/activable/xeno/charge/ai_should_start_consider()
	return TRUE

/datum/action/ability/activable/xeno/charge/ai_should_use(atom/target)
	if(!iscarbon(target))
		return FALSE
	if(!line_of_sight(owner, target, charge_range))
		return FALSE
	if(!can_use_ability(target, override_flags = ABILITY_IGNORE_SELECTED_ABILITY))
		return FALSE
	if(target.get_xeno_hivenumber() == owner.get_xeno_hivenumber())
		return FALSE
	return TRUE

///Deals with hitting objects
/datum/action/ability/activable/xeno/charge/proc/obj_hit(datum/source, obj/target, speed)
	SIGNAL_HANDLER
	if(istype(target, /obj/structure/table))
		var/obj/structure/S = target
		owner.visible_message(span_danger("[owner] plows straight through [S]!"), null, null, 5)
		S.deconstruct(FALSE) //We want to continue moving, so we do not reset throwing.
		return //stay registered

	target.hitby(owner, speed) //This resets throwing.
	charge_complete()

///Deals with hitting mobs. Triggered by bump instead of throw impact as we want to plow past mobs
/datum/action/ability/activable/xeno/charge/proc/mob_hit(datum/source, mob/living/living_target)
	SIGNAL_HANDLER
	. = TRUE
	if(living_target.stat || isxeno(living_target)) //we leap past xenos
		return

	var/multiplier = 1
	if(HAS_TRAIT(xeno_owner, TRAIT_BLOODTHIRSTER))
		if(xeno_owner.plasma_stored >= STAGE_TWO_BLOODTHIRST)
			multiplier++
			if(xeno_owner.plasma_stored >= STAGE_THREE_BLOODTHIRST)
				multiplier++
	living_target.attack_alien_harm(xeno_owner, xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier * 0.25 * multiplier, FALSE, TRUE, FALSE, TRUE, INTENT_HARM) //Location is always random, cannot crit, harm only
	var/target_turf = get_ranged_target_turf(living_target, get_dir(src, living_target), rand(1, 3)) //we blast our victim behind us
	target_turf = get_step_rand(target_turf) //Scatter
	if(iscarbon(living_target) && paralyze_duration)
		var/mob/living/carbon/carbon_victim = living_target
		carbon_victim.Paralyze(paralyze_duration)
	living_target.throw_at(get_turf(target_turf), charge_range, RAV_CHARGESPEED, src)

///Cleans up after charge is finished
/datum/action/ability/activable/xeno/charge/proc/charge_complete()
	SIGNAL_HANDLER
	UnregisterSignal(owner, list(COMSIG_XENO_OBJ_THROW_HIT, COMSIG_MOVABLE_POST_THROW, COMSIG_XENOMORPH_LEAP_BUMP))
	xeno_owner.xeno_flags &= ~XENO_LEAPING

// ***************************************
// *********** Ravage
// ***************************************
/datum/action/ability/activable/xeno/ravage
	name = "Ravage"
	action_icon_state = "ravage"
	action_icon = 'icons/Xeno/actions/ravager.dmi'
	desc = "Attacks and knockbacks enemies in the direction your facing."
	ability_cost = 200
	cooldown_duration = 6 SECONDS
	keybind_flags = ABILITY_KEYBIND_USE_ABILITY | ABILITY_IGNORE_SELECTED_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_RAVAGE,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_RAVAGE_SELECT,
	)
	/// The amount of armor penetration that all slash attacks caused by Ravage to have.
	var/armor_penetration = 0
	/// The amount of deciseconds that the owner must wait to successfully use this ability.
	var/cast_time = 0 SECONDS
	/// Does the ability affect all directions? If not, it will affect the direction the owner is facing.
	var/aoe = FALSE

/datum/action/ability/activable/xeno/ravage/on_cooldown_finish()
	to_chat(owner, span_xenodanger("We gather enough strength to Ravage again."))
	playsound(owner, 'sound/effects/alien/new_larva.ogg', 50, 0, 1)
	return ..()

#define CONE_PART_MIDDLE (1<<0)
#define CONE_PART_LEFT (1<<1)
#define CONE_PART_RIGHT (1<<2)
#define CONE_PART_DIAG_LEFT (1<<3)
#define CONE_PART_DIAG_RIGHT (1<<4)
#define CONE_PART_MIDDLE_DIAG (1<<5)

/datum/action/ability/activable/xeno/ravage/use_ability(atom/A)
	xeno_owner.face_atom(A)

	if(cast_time && !do_after(xeno_owner, cast_time, NONE, xeno_owner, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, PROC_REF(can_use_action), TRUE, ABILITY_USE_BUSY)))
		return

	xeno_owner.emote("roar")
	xeno_owner.visible_message(span_danger("\The [xeno_owner] thrashes about in a murderous frenzy!"), \
	span_xenowarning("We thrash about in a murderous frenzy!"))

	var/range = 2 // 1 = turf underneath only.
	if(HAS_TRAIT(owner, TRAIT_BLOODTHIRSTER))
		if(xeno_owner.plasma_stored >= STAGE_THREE_BLOODTHIRST)
			range = 3
		else if(xeno_owner.plasma_stored >= STAGE_TWO_BLOODTHIRST)
			range = 4

	var/turf/current_turf = get_turf(xeno_owner)
	var/facing = xeno_owner.dir
	var/list/turf/ravaged_turfs = list()
	if(!aoe)
		activate_particles(facing)
		switch(facing)
			if(NORTH, SOUTH, EAST, WEST)
				add_valid_turfs_from_cone(current_turf, ravaged_turfs, range, facing, CONE_PART_MIDDLE|CONE_PART_LEFT|CONE_PART_RIGHT)
			if(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
				add_valid_turfs_from_cone(current_turf, ravaged_turfs, range, facing, CONE_PART_MIDDLE_DIAG)
				add_valid_turfs_from_cone(current_turf, ravaged_turfs, range + 1, facing, CONE_PART_DIAG_LEFT|CONE_PART_DIAG_RIGHT)
	else
		for(var/direction in GLOB.alldirs)
			if(direction in GLOB.cardinals)
				activate_particles(direction)
				add_valid_turfs_from_cone(current_turf, ravaged_turfs, range, direction, CONE_PART_MIDDLE)
			else
				add_valid_turfs_from_cone(current_turf, ravaged_turfs, range, direction, CONE_PART_MIDDLE_DIAG)
	ravaged_turfs -= current_turf // Don't want to hit the turf underneath us.

	var/list/atom/movable/atoms_to_ravage = list()
	for(var/turf/ravaged_turf AS in ravaged_turfs)
		ravaged_turf.Shake(duration = 0.2 SECONDS) // To visually indicate what turfs are hit. Mainly for Bloodthirster as they could be hitting more than 3 tiles.
		atoms_to_ravage += ravaged_turf.contents

	if(armor_penetration) // Since everything references the caste for armor peneration, this is how to individually give armor peneration without changing everything.
		RegisterSignal(xeno_owner, COMSIG_XENOMORPH_ATTACK_LIVING, PROC_REF(on_attack_living))
	for(var/atom/movable/ravaged_atom AS in atoms_to_ravage)
		if(ishitbox(ravaged_atom) || isvehicle(ravaged_atom))
			ravaged_atom.attack_alien(xeno_owner, xeno_owner.xeno_caste.melee_damage, armor_penetration = xeno_owner.xeno_caste.melee_ap + armor_penetration) // Handles APC/Tank stuff. Has to be before the !ishuman check or else ravage does work properly on vehicles.
			continue
		if(!(ravaged_atom.resistance_flags & XENO_DAMAGEABLE))
			continue
		if(!ishuman(ravaged_atom))
			ravaged_atom.attack_alien(xeno_owner, xeno_owner.xeno_caste.melee_damage, armor_penetration = xeno_owner.xeno_caste.melee_ap + armor_penetration)
			ravaged_atom.knockback(xeno_owner, RAV_RAVAGE_THROW_RANGE, RAV_CHARGESPEED)
			continue
		var/mob/living/carbon/human/ravaged_human = ravaged_atom
		if(ravaged_human.stat == DEAD)
			continue
		ravaged_human.attack_alien_harm(xeno_owner, xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier * 0.25, FALSE, TRUE, FALSE, TRUE) // The reason why we have to add armor peneration as a signal.
		ravaged_human.knockback(xeno_owner, RAV_RAVAGE_THROW_RANGE, RAV_CHARGESPEED)
		shake_camera(ravaged_human, 2, 1)
		ravaged_human.Paralyze(1 SECONDS)
	if(armor_penetration)
		UnregisterSignal(xeno_owner, COMSIG_XENOMORPH_ATTACK_LIVING)

	succeed_activate()
	add_cooldown()

/// Gets all valid turfs to hit with Ravage. Valid turfs are any turfs that have no density.
/datum/action/ability/activable/xeno/ravage/proc/add_valid_turfs_from_cone(turf/current_turf, list/turf/valid_turfs_so_far = list(), distance_left, facing, direction_flag)
	if(distance_left <= 0 || current_turf.density)
		return
	if(!(current_turf in valid_turfs_so_far))
		valid_turfs_so_far += current_turf

	keep_getting_valid_turf_in_cone(current_turf, get_step(current_turf, facing), valid_turfs_so_far, distance_left, facing, direction_flag)
	return valid_turfs_so_far

/// Performs the next step of getting valid turfs.
/datum/action/ability/activable/xeno/ravage/proc/keep_getting_valid_turf_in_cone(turf/current_turf, turf/next_turf, list/turf/valid_turfs_so_far, distance_left, facing, direction_flag)
	if(CHECK_BITFIELD(direction_flag, CONE_PART_MIDDLE))
		add_valid_turfs_from_cone(next_turf, valid_turfs_so_far, distance_left - 1 , facing, CONE_PART_MIDDLE)
	if(CHECK_BITFIELD(direction_flag, CONE_PART_RIGHT))
		add_valid_turfs_from_cone(get_step(next_turf, turn(facing, 90)), valid_turfs_so_far, distance_left - 1, facing, CONE_PART_RIGHT|CONE_PART_MIDDLE)
	if(CHECK_BITFIELD(direction_flag, CONE_PART_LEFT))
		add_valid_turfs_from_cone(get_step(next_turf, turn(facing, -90)), valid_turfs_so_far, distance_left - 1, facing, CONE_PART_LEFT|CONE_PART_MIDDLE)
	if(CHECK_BITFIELD(direction_flag, CONE_PART_DIAG_LEFT))
		add_valid_turfs_from_cone(get_step(current_turf, turn(facing, 45)), valid_turfs_so_far, distance_left - 1, turn(facing, 45), CONE_PART_MIDDLE)
	if(CHECK_BITFIELD(direction_flag, CONE_PART_DIAG_RIGHT))
		add_valid_turfs_from_cone(get_step(current_turf, turn(facing, -45)), valid_turfs_so_far, distance_left - 1, turn(facing, -45), CONE_PART_MIDDLE)
	if(CHECK_BITFIELD(direction_flag, CONE_PART_MIDDLE_DIAG))
		add_valid_turfs_from_cone(next_turf, valid_turfs_so_far, distance_left - 1, facing, CONE_PART_DIAG_LEFT|CONE_PART_DIAG_RIGHT)
		add_valid_turfs_from_cone(next_turf, valid_turfs_so_far, distance_left - 2, facing, (distance_left < 5) ? CONE_PART_MIDDLE : CONE_PART_MIDDLE_DIAG)

#undef CONE_PART_MIDDLE
#undef CONE_PART_LEFT
#undef CONE_PART_RIGHT
#undef CONE_PART_DIAG_LEFT
#undef CONE_PART_DIAG_RIGHT
#undef CONE_PART_MIDDLE_DIAG

/// Adds armor penetration to attacked living beings.
/datum/action/ability/activable/xeno/ravage/proc/on_attack_living(datum/source, mob/living/target, damage, list/damage_mod, list/armor_mod)
	SIGNAL_HANDLER
	armor_mod += armor_penetration

/// Handles the activation and deactivation of particles, as well as their appearance.
/datum/action/ability/activable/xeno/ravage/proc/activate_particles(direction) // This could've been an animate()!
	var/obj/effect/abstract/particle_holder/particle_holder = new(get_turf(xeno_owner), /particles/ravager_slash)
	QDEL_IN(particle_holder, 0.5 SECONDS)
	particle_holder.particles.rotation += dir2angle(direction)
	switch(direction) // There's no shared logic here because sprites are magical.
		if(NORTH) // Gotta define stuff for each angle so it looks good.
			particle_holder.particles.position = list(8, 4)
			particle_holder.particles.velocity = list(0, 20)
		if(EAST)
			particle_holder.particles.position = list(3, -8)
			particle_holder.particles.velocity = list(20, 0)
		if(SOUTH)
			particle_holder.particles.position = list(-9, -3)
			particle_holder.particles.velocity = list(0, -20)
		if(WEST)
			particle_holder.particles.position = list(-4, 9)
			particle_holder.particles.velocity = list(-20, 0)

/datum/action/ability/activable/xeno/ravage/ai_should_start_consider()
	return TRUE

/datum/action/ability/activable/xeno/ravage/ai_should_use(atom/target)
	if(!iscarbon(target))
		return FALSE
	if(get_dist(target, owner) > 1)
		return FALSE
	if(!can_use_ability(target, override_flags = ABILITY_IGNORE_SELECTED_ABILITY))
		return FALSE
	if(target.get_xeno_hivenumber() == owner.get_xeno_hivenumber())
		return FALSE
	return TRUE

/particles/ravager_slash
	icon = 'icons/effects/200x200.dmi'
	icon_state = "ravager_slash"
	width = 600
	height = 600
	count = 1
	spawning = 1
	lifespan = 4
	fade = 4
	scale = 0.6
	grow = -0.02
	rotation = -160
	friction = 0.6

// ***************************************
// *********** Endure
// ***************************************
/datum/action/ability/xeno_action/endure
	name = "Endure"
	action_icon_state = "ignore_pain"
	action_icon = 'icons/Xeno/actions/ravager.dmi'
	desc = "For the next few moments you will not go into crit and become resistant to explosives and immune to stagger and slowdown, but you still die if you take damage exceeding your crit health."
	ability_cost = 200
	cooldown_duration = 60 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_ENDURE,
	)
	use_state_flags = ABILITY_USE_STAGGERED|ABILITY_USE_SOLIDOBJECT // Can use this while staggered.
	/// The amount of deciseconds Endure should last.
	var/endure_duration = RAVAGER_ENDURE_DURATION
	/// While this ability is active, what amount should the owner's `get_crit_threshold` and `get_death_threshold` return?
	var/endure_threshold = RAVAGER_ENDURE_HP_LIMIT
	/// While this ability is active, what amount should be added to the number returned by `get_crit_threshold` and `get_death_threshold`? This is reset to zero when the ability ends.
	var/endure_threshold_bonus = 0
	/// While this ability is active, how much all soft armor should be given?
	var/endure_armor = 0
	/// While this ability is active, should the owner be given stagger immunity?
	var/endure_stagger_immunity = TRUE
	/// The timer for Endure's duration.
	var/endure_timer
	/// The timer for Endure's warning message.
	var/endure_warning_timer
	/// If they do not have enough to pay the ability cost, should they consume health instead?
	var/uses_health_as_necessary
	/// When this ability ends and the owner's health is under the reverted `get_death_threshold`, should they die instead?
	var/death_beyond_threshold = FALSE
	/// The attached armor that been given, if any.
	var/datum/armor/attached_armor

/datum/action/ability/xeno_action/endure/on_cooldown_finish()
	to_chat(owner, span_xenodanger("We feel able to imbue ourselves with plasma to Endure once again!"))
	owner.playsound_local(owner, 'sound/effects/alien/new_larva.ogg', 25, 0, 1)
	return ..()

/datum/action/ability/xeno_action/endure/action_activate()
	xeno_owner.emote("roar")
	xeno_owner.visible_message(span_danger("[xeno_owner]'s skin begins to glow!"), \
	span_xenowarning("We feel the plasma coursing through our veins!"))

	xeno_owner.endure = TRUE

	xeno_owner.add_filter("ravager_endure_outline", 4, outline_filter(1, COLOR_PURPLE)) //Set our cool aura; also confirmation we have the buff

	endure_timer = addtimer(CALLBACK(src, PROC_REF(endure_warning)), endure_duration * RAVAGER_ENDURE_DURATION_WARNING, TIMER_UNIQUE|TIMER_STOPPABLE|TIMER_OVERRIDE) //Warn the ravager when the duration is about to expire.
	endure_warning_timer = addtimer(CALLBACK(src, PROC_REF(endure_deactivate)), endure_duration, TIMER_UNIQUE|TIMER_STOPPABLE|TIMER_OVERRIDE)

	xeno_owner.set_stagger(0) //Remove stagger
	xeno_owner.set_slowdown(0) //Remove slowdown
	xeno_owner.soft_armor = xeno_owner.soft_armor.modifyRating(bomb = 20) //Improved explosion resistance
	if(endure_stagger_immunity)
		ADD_TRAIT(xeno_owner, TRAIT_STAGGERIMMUNE, ENDURE_TRAIT) //Can now endure impacts/damages that would make lesser xenos flinch
	ADD_TRAIT(xeno_owner, TRAIT_SLOWDOWNIMMUNE, ENDURE_TRAIT) //Can now endure slowdown

	if(endure_armor)
		attached_armor = new(endure_armor, endure_armor, endure_armor, endure_armor, endure_armor, endure_armor, endure_armor, endure_armor)
		xeno_owner.soft_armor = xeno_owner.soft_armor.attachArmor(attached_armor)

	RegisterSignal(xeno_owner, COMSIG_XENOMORPH_BRUTE_DAMAGE, PROC_REF(damage_taken)) //Warns us if our health is critically low
	RegisterSignal(xeno_owner, COMSIG_XENOMORPH_BURN_DAMAGE, PROC_REF(damage_taken))

	var/plasma_cost = min(ability_cost, xeno_owner.plasma_stored)
	if(uses_health_as_necessary && ability_cost > plasma_cost)
		xeno_owner.adjustBruteLoss(min((xeno_owner.health - xeno_owner.get_death_threshold() - 1), (ability_cost - plasma_cost))) // Non-lethal. Worst case, one health point from death.
	xeno_owner.updatehealth() // To get them back up if they happen to activate the ability while in critical.
	succeed_activate(plasma_cost)
	add_cooldown()

	GLOB.round_statistics.ravager_endures++ //Statistics
	SSblackbox.record_feedback("tally", "round_statistics", 1, "ravager_endures")

///Warns the player when Endure is about to end
/datum/action/ability/xeno_action/endure/proc/endure_warning()
	if(QDELETED(owner))
		return
	to_chat(owner,span_userdanger("We feel the plasma draining from our veins... [initial(name)] will last for only [timeleft(endure_timer) * 0.1] more seconds!"))
	owner.playsound_local(owner, 'sound/voice/hiss4.ogg', 50, 0, 1)

///Turns off the Endure buff
/datum/action/ability/xeno_action/endure/proc/endure_deactivate()
	if(QDELETED(owner))
		return
	UnregisterSignal(xeno_owner, COMSIG_XENOMORPH_BRUTE_DAMAGE)
	UnregisterSignal(xeno_owner, COMSIG_XENOMORPH_BURN_DAMAGE)

	xeno_owner.do_jitter_animation(1000)
	xeno_owner.endure = FALSE
	xeno_owner.clear_fullscreen("endure", 0.7 SECONDS)
	xeno_owner.remove_filter("ravager_endure_outline")

	xeno_owner.soft_armor = xeno_owner.soft_armor.modifyRating(bomb = -20) //Remove resistances  immunities.
	if(endure_stagger_immunity)
		REMOVE_TRAIT(xeno_owner, TRAIT_STAGGERIMMUNE, ENDURE_TRAIT)
	REMOVE_TRAIT(xeno_owner, TRAIT_SLOWDOWNIMMUNE, ENDURE_TRAIT)
	endure_threshold_bonus = 0 // Reset the endure vars to their initial states.
	endure_timer = null
	endure_warning_timer = null

	if(attached_armor)
		xeno_owner.soft_armor = xeno_owner.soft_armor.detachArmor(attached_armor)
		attached_armor = null

	xeno_owner.playsound_local(owner, 'sound/voice/hiss4.ogg', 50, 0, 1)
	if(xeno_owner.health >= xeno_owner.get_crit_threshold())
		return
	if(death_beyond_threshold && xeno_owner.health < xeno_owner.get_death_threshold())
		to_chat(xeno_owner, span_userdanger("The last of the plasma drains from our body... and so does our life..."))
		xeno_owner.updatehealth() // Die.
		return
	var/total_damage = xeno_owner.getFireLoss() + xeno_owner.getBruteLoss()
	var/burn_percentile_damage = xeno_owner.getFireLoss() / total_damage
	var/brute_percentile_damage = xeno_owner.getBruteLoss() / total_damage
	xeno_owner.setBruteLoss((xeno_owner.xeno_caste.max_health - xeno_owner.get_crit_threshold() - 1) * brute_percentile_damage)
	xeno_owner.setFireLoss((xeno_owner.xeno_caste.max_health - xeno_owner.get_crit_threshold() - 1) * burn_percentile_damage)
	to_chat(xeno_owner, span_userdanger("The last of the plasma drains from our body... We can no longer endure beyond our normal limits!"))

///Warns us when our health is critically low and tells us exactly how much more punishment we can take
/datum/action/ability/xeno_action/endure/proc/damage_taken(mob/living/carbon/xenomorph/xeno_owner, damage_taken)
	SIGNAL_HANDLER
	if(xeno_owner.health < 0)
		to_chat(xeno_owner, "<span class='xenouserdanger' style='color: red;'>We are critically wounded! We can only withstand [-(endure_threshold + endure_threshold_bonus - xeno_owner.health)] more damage before we perish!</span>")
		xeno_owner.overlay_fullscreen("endure", /atom/movable/screen/fullscreen/animated/bloodlust)
	else
		xeno_owner.clear_fullscreen("endure", 0.7 SECONDS)



/datum/action/ability/xeno_action/endure/ai_should_start_consider()
	return TRUE

/datum/action/ability/xeno_action/endure/ai_should_use(target)
	if(!iscarbon(target))
		return FALSE
	if(get_dist(target, owner) > WORLD_VIEW_NUM) // If we can be seen.
		return FALSE
	if(xeno_owner.health > 50)
		return FALSE
	if(!can_use_action(override_flags = ABILITY_IGNORE_SELECTED_ABILITY))
		return FALSE
	return TRUE

// ***************************************
// *********** Rage
// ***************************************
/datum/action/ability/xeno_action/rage
	name = "Rage"
	action_icon_state = "rage"
	action_icon = 'icons/Xeno/actions/ravager.dmi'
	desc = "Use while at 50% health or lower to gain extra slash damage, resistances and speed in proportion to your missing hit points. This bonus is increased and you regain plasma while your HP is negative."
	ability_cost = 0 //We're limited by cooldowns, not plasma
	cooldown_duration = 60 SECONDS
	keybind_flags = ABILITY_KEYBIND_USE_ABILITY | ABILITY_IGNORE_SELECTED_ABILITY
	use_state_flags = ABILITY_USE_SOLIDOBJECT
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_RAGE,
	)
	/// The percentage of the owner's maximum health that the owner's current health must be under to activate the ability.
	var/minimum_health_rage_threshold = RAVAGER_RAGE_MIN_HEALTH_THRESHOLD
	/// The percentage of the owner's maximum health to use to further increase / calculate rage power. Higher means more rage power which then means it is easier to reach super rage.
	var/rage_power_calculation_bonus = 0
	/// Determines the power of Rage's many effects. Power scales inversely with the Ravager's HP. Ignoring calculation bonus, this can ranges from [0.25 at 50% health] and [0.5 at 0% health]. 0.5 and above triggers special effects.
	var/rage_power
	/// Determines the Sunder to impose when Rage ends.
	var/rage_sunder
	/// Determines the Plasma to remove when Rage ends.
	var/rage_plasma
	/// Should the power to extend Endure's duration be granted to normal Rage?
	var/extends_via_normal_rage = FALSE

/datum/action/ability/xeno_action/rage/on_cooldown_finish()
	to_chat(owner, span_xenodanger("We are able to enter our rage once again."))
	owner.playsound_local(owner, 'sound/effects/alien/new_larva.ogg', 25, 0, 1)
	return ..()

/datum/action/ability/xeno_action/rage/can_use_action(silent, override_flags, selecting)
	. = ..()
	if(!.)
		return FALSE

	if(xeno_owner.health > xeno_owner.maxHealth * minimum_health_rage_threshold) //Need to be at 50% of max hp or lower to rage
		if(!silent)
			to_chat(xeno_owner, span_xenodanger("Our health isn't low enough to rage! We must take [xeno_owner.health - (xeno_owner.maxHealth * RAVAGER_RAGE_MIN_HEALTH_THRESHOLD)] more damage!"))
		return FALSE


/datum/action/ability/xeno_action/rage/action_activate()
	rage_power = min(0.5, (1 - ((xeno_owner.health - (xeno_owner.maxHealth * rage_power_calculation_bonus)) / xeno_owner.maxHealth)) * RAVAGER_RAGE_POWER_MULTIPLIER) // Calculate the power of our rage; scales with difference between current and max HP.
	var/rage_power_radius = CEILING(rage_power * 7, 1) //Define radius of the SFX

	xeno_owner.visible_message(span_danger("\The [xeno_owner] becomes frenzied, bellowing with a shuddering roar!"), \
	span_userdanger("We bellow as our fury overtakes us! RIP AND TEAR!"))
	xeno_owner.do_jitter_animation(1000)


	//Roar SFX; volume scales with rage
	playsound(xeno_owner.loc, 'sound/voice/alien/roar2.ogg', clamp(100 * rage_power, 25, 80), 0)

	var/bonus_duration
	if(rage_power >= RAVAGER_RAGE_SUPER_RAGE_THRESHOLD) //If we're super pissed it's time to get crazy
		var/datum/action/ability/xeno_action/charge = xeno_owner.actions_by_path[/datum/action/ability/activable/xeno/charge]
		var/datum/action/ability/xeno_action/ravage = xeno_owner.actions_by_path[/datum/action/ability/activable/xeno/ravage]
		var/datum/action/ability/xeno_action/endure/endure_ability = xeno_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
		if(endure_ability && !endure_ability.endure_threshold_bonus)
			endure_ability.endure_threshold_bonus = RAVAGER_ENDURE_HP_LIMIT * rage_power
		if(charge)
			charge.clear_cooldown() //Reset charge cooldown
		if(ravage)
			ravage.clear_cooldown() //Reset ravage cooldown
		RegisterSignal(xeno_owner, COMSIG_XENOMORPH_ATTACK_LIVING, PROC_REF(drain_slash))
	else if(extends_via_normal_rage)
		RegisterSignal(xeno_owner, COMSIG_XENOMORPH_ATTACK_LIVING, PROC_REF(drain_slash))

	for(var/turf/affected_tiles AS in RANGE_TURFS(rage_power_radius / 2, xeno_owner.loc))
		affected_tiles.Shake(duration = 1 SECONDS) //SFX

	for(var/mob/living/affected_mob in cheap_get_humans_near(xeno_owner, rage_power_radius) + cheap_get_xenos_near(xeno_owner, rage_power_radius)) //Roar that applies cool SFX
		if(affected_mob.stat || affected_mob == xeno_owner) //We don't care about the dead/unconsious
			continue

		shake_camera(affected_mob, 1 SECONDS, 1)
		affected_mob.Shake(duration = 1 SECONDS) //SFX

		if(rage_power >= RAVAGER_RAGE_SUPER_RAGE_THRESHOLD && affected_mob.hud_used) //If we're super pissed it's time to get crazy
			var/atom/movable/plane_master_controller/game_plane_master_controller = affected_mob.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
			game_plane_master_controller.add_filter("rage_outcry", 2, radial_blur_filter(0.07))
			for(var/dm_filter/filt AS in game_plane_master_controller.get_filters("rage_outcry"))
				animate(filt, size = 0.12, time = 5, loop = -1)
			addtimer(CALLBACK(game_plane_master_controller, TYPE_PROC_REF(/datum, remove_filter), "rage_outcry"), 1 SECONDS)

	var/multiplier = 1
	if(HAS_TRAIT(owner, TRAIT_BLOODTHIRSTER))
		if(xeno_owner.plasma_stored >= STAGE_TWO_BLOODTHIRST)
			multiplier++
			if(xeno_owner.plasma_stored >= STAGE_THREE_BLOODTHIRST)
				multiplier++

	xeno_owner.add_filter("ravager_rage_outline", 5, outline_filter(1.5, COLOR_RED)) //Set our cool aura; also confirmation we have the buff

	rage_plasma = min(xeno_owner.xeno_caste.plasma_max - xeno_owner.plasma_stored, xeno_owner.xeno_caste.plasma_max * rage_power) //Calculate the plasma to restore (and take away later)
	xeno_owner.plasma_stored += rage_plasma //Regain a % of our maximum plasma scaling with rage

	rage_sunder = min(xeno_owner.sunder, rage_power * 100) //Set our temporary Sunder recovery
	xeno_owner.adjust_sunder(-1 * rage_sunder) //Restores up to 50 Sunder temporarily.

	xeno_owner.xeno_melee_damage_modifier += rage_power  //Set rage melee damage bonus

	xeno_owner.add_movespeed_modifier(MOVESPEED_ID_RAVAGER_RAGE, TRUE, 0, NONE, TRUE, xeno_owner.xeno_caste.speed * (0.5 * multiplier * rage_power)) //Set rage speed bonus

	//Too angry to be stunned/slowed/staggered/knocked down
	ADD_TRAIT(xeno_owner, TRAIT_STUNIMMUNE, RAGE_TRAIT)
	ADD_TRAIT(xeno_owner, TRAIT_SLOWDOWNIMMUNE, RAGE_TRAIT)
	ADD_TRAIT(xeno_owner, TRAIT_STAGGERIMMUNE, RAGE_TRAIT)

	addtimer(CALLBACK(src, PROC_REF(rage_warning), bonus_duration), (RAVAGER_RAGE_DURATION + bonus_duration) * RAVAGER_RAGE_WARNING) //Warn the ravager when rage is about to expire.
	addtimer(CALLBACK(src, PROC_REF(rage_deactivate)), (RAVAGER_RAGE_DURATION + bonus_duration))

	succeed_activate()
	add_cooldown()

	GLOB.round_statistics.ravager_rages++ //Statistics
	SSblackbox.record_feedback("tally", "round_statistics", 1, "ravager_rages")

///Warns the user when his rage is about to end.
/datum/action/ability/xeno_action/rage/proc/rage_warning(bonus_duration = 0)
	if(QDELETED(owner))
		return
	to_chat(owner,span_userdanger("Our rage begins to subside... [initial(name)] will only last for only [(RAVAGER_RAGE_DURATION + bonus_duration) * (1-RAVAGER_RAGE_WARNING) * 0.1] more seconds!"))
	owner.playsound_local(owner, 'sound/voice/hiss4.ogg', 50, 0, 1)

///Warns the user when his rage is about to end.
/datum/action/ability/xeno_action/rage/proc/drain_slash(datum/source, mob/living/target, damage, list/damage_mod, list/armor_mod)
	SIGNAL_HANDLER
	if(rage_power >= RAVAGER_RAGE_SUPER_RAGE_THRESHOLD)
		var/mob/living/xeno_owner = owner
		var/brute_damage = xeno_owner.getBruteLoss()
		var/burn_damage = xeno_owner.getFireLoss()
		if(!brute_damage && !burn_damage) //If we have no healable damage, don't bother proceeding
			return
		var/health_recovery = rage_power * damage //Amount of health we leech per slash
		var/health_modifier
		if(brute_damage) //First heal Brute damage, then heal Burn damage with remainder
			health_modifier = min(brute_damage, health_recovery)*-1 //Get the lower of our Brute Loss or the health we're leeching
			xeno_owner.adjustBruteLoss(health_modifier)
			health_recovery += health_modifier //Decrement the amount healed from our total healing pool
		if(burn_damage)
			health_modifier = min(burn_damage, health_recovery)*-1
			xeno_owner.adjustFireLoss(health_modifier)

	if(extends_via_normal_rage || rage_power >= RAVAGER_RAGE_SUPER_RAGE_THRESHOLD) //If we're super pissed it's time to get crazy
		var/datum/action/ability/xeno_action/endure/endure_ability = xeno_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
		if(endure_ability.endure_timer) //Check if Endure is active
			var/new_duration = min(endure_ability.endure_duration, (timeleft(endure_ability.endure_timer) + RAVAGER_RAGE_ENDURE_INCREASE_PER_SLASH)) //Increment Endure duration by 2 seconds per slash
			deltimer(endure_ability.endure_timer) //Reset timers
			deltimer(endure_ability.endure_warning_timer)
			endure_ability.endure_timer = addtimer(CALLBACK(endure_ability, TYPE_PROC_REF(/datum/action/ability/xeno_action/endure, endure_deactivate)), new_duration, TIMER_UNIQUE|TIMER_STOPPABLE|TIMER_OVERRIDE) //Reset Endure timers if active
			if(new_duration > 3 SECONDS) //Check timing
				endure_ability.endure_warning_timer = addtimer(CALLBACK(endure_ability, TYPE_PROC_REF(/datum/action/ability/xeno_action/endure, endure_warning)), new_duration - 3 SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE|TIMER_OVERRIDE) //Reset Endure timers if active

///Called when we want to end the Rage effect
/datum/action/ability/xeno_action/rage/proc/rage_deactivate()
	if(QDELETED(owner))
		return
	xeno_owner.do_jitter_animation(1000)
	xeno_owner.remove_filter("ravager_rage_outline")
	xeno_owner.visible_message(span_warning("[xeno_owner] seems to calm down."), \
	span_userdanger("Our rage subsides and its power leaves our body, leaving us exhausted."))

	xeno_owner.xeno_melee_damage_modifier = initial(xeno_owner.xeno_melee_damage_modifier) //Reset rage melee damage bonus
	xeno_owner.remove_movespeed_modifier(MOVESPEED_ID_RAVAGER_RAGE) //Reset speed
	xeno_owner.adjust_sunder(rage_sunder) //Remove the temporary Sunder restoration
	xeno_owner.use_plasma(rage_plasma) //Remove the temporary Plasma

	REMOVE_TRAIT(xeno_owner, TRAIT_STUNIMMUNE, RAGE_TRAIT)
	REMOVE_TRAIT(xeno_owner, TRAIT_SLOWDOWNIMMUNE, RAGE_TRAIT)
	REMOVE_TRAIT(xeno_owner, TRAIT_STAGGERIMMUNE, RAGE_TRAIT)
	UnregisterSignal(xeno_owner, COMSIG_XENOMORPH_ATTACK_LIVING)


	rage_sunder = 0
	rage_power = 0
	rage_plasma = 0
	xeno_owner.playsound_local(xeno_owner, 'sound/voice/hiss5.ogg', 50) //Audio cue


// ***************************************
// *********** Vampirism
// ***************************************

/particles/xeno_slash/vampirism
	color = "#ff0000"
	grow = list(-0.2 ,0.5)
	fade = 10
	gravity = list(0, -5)
	velocity = list(1000, 1000)
	friction = 50
	lifespan = 10
	position = generator(GEN_SPHERE, 10, 30, NORMAL_RAND)
	scale = generator(GEN_VECTOR, list(1, 1), list(0.9, 0.9), NORMAL_RAND)

/datum/action/ability/xeno_action/vampirism
	name = "Toggle vampirism"
	action_icon_state = "neuroclaws_off"
	action_icon = 'icons/Xeno/actions/sentinel.dmi'
	desc = "Toggle on to enable boosting on "
	ability_cost = 0 //We're limited by nothing, rip and tear
	cooldown_duration = 1 SECONDS
	keybind_flags = ABILITY_KEYBIND_USE_ABILITY | ABILITY_IGNORE_SELECTED_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_VAMPIRISM,
	)
	/// how long we have to wait before healing again
	var/heal_delay = 2 SECONDS
	/// Used for particles. Holds the particles instead of the mob. See particle_holder for documentation.
	var/obj/effect/abstract/particle_holder/particle_holder
	/// Ref to our particle deletion timer
	var/timer_ref

/datum/action/ability/xeno_action/vampirism/clean_action()
	QDEL_NULL(particle_holder)
	timer_ref = null
	return ..()

/datum/action/ability/xeno_action/vampirism/update_button_icon()
	action_icon_state = xeno_owner.vampirism ? "neuroclaws_on" : "neuroclaws_off"
	return ..()

/datum/action/ability/xeno_action/vampirism/give_action(mob/living/L)
	. = ..()
	xeno_owner.vampirism = TRUE
	RegisterSignal(L, COMSIG_XENOMORPH_ATTACK_LIVING, PROC_REF(on_slash))

/datum/action/ability/xeno_action/vampirism/remove_action(mob/living/L)
	xeno_owner.vampirism = FALSE
	UnregisterSignal(L, COMSIG_XENOMORPH_ATTACK_LIVING)
	return ..()

/datum/action/ability/xeno_action/vampirism/action_activate()
	. = ..()
	xeno_owner.vampirism = !xeno_owner.vampirism
	if(xeno_owner.vampirism)
		RegisterSignal(xeno_owner, COMSIG_XENOMORPH_ATTACK_LIVING, PROC_REF(on_slash))
	else
		UnregisterSignal(xeno_owner, COMSIG_XENOMORPH_ATTACK_LIVING)
	to_chat(xeno_owner, span_xenonotice("You will now[xeno_owner.vampirism ? "" : " no longer"] heal from attacking"))
	update_button_icon()

///Adds the slashed mob to tracked damage mobs
/datum/action/ability/xeno_action/vampirism/proc/on_slash(datum/source, mob/living/target, damage, list/damage_mod, list/armor_mod)
	SIGNAL_HANDLER
	if(target.stat == DEAD)
		return
	if(!ishuman(target)) // no farming on animals/dead
		return
	if(timeleft(timer_ref) > 0)
		return
	xeno_owner.adjustBruteLoss(-xeno_owner.bruteloss * 0.125)
	xeno_owner.adjustFireLoss(-xeno_owner.fireloss * 0.125)
	particle_holder = new(xeno_owner, /particles/xeno_slash/vampirism)
	particle_holder.pixel_y = 18
	particle_holder.pixel_x = 18
	timer_ref = QDEL_NULL_IN(src, particle_holder, heal_delay)

#define BLOODTHIRST_DECAY_PER_TICK 30
#define LOWEST_BLOODTHIRST_HP_ALLOWED 100
#define MAX_DAMAGE_PER_DISINTEGRATING 25

/datum/action/ability/xeno_action/bloodthirst
	name = "bloodthirst"
	desc = "Passive ability for generating bloodthirst"
	hidden = TRUE
	///tick time of last time we attacked a human
	var/last_fight_time
	///time when we last hit 0 bloodthirst/plasma
	var/hit_zero_time
	/// delay until decaying starts
	var/decay_delay = 30 SECONDS
	///once bloodthirst hits 0 how long
	var/damage_delay = 30 SECONDS
	///used to track if effects played for disintegration start
	var/disintegrating = FALSE

/datum/action/ability/xeno_action/bloodthirst/give_action(mob/living/L)
	. = ..()
	RegisterSignal(L, COMSIG_XENOMORPH_ATTACK_LIVING, PROC_REF(on_attack))
	RegisterSignal(L, COMSIG_XENOMORPH_TAKING_DAMAGE, PROC_REF(on_take_damage))
	ADD_TRAIT(L, TRAIT_BLOODTHIRSTER, TRAIT_GENERIC)
	START_PROCESSING(SSprocessing, src)
	last_fight_time = world.time

/datum/action/ability/xeno_action/bloodthirst/remove_action(mob/living/L)
	. = ..()
	REMOVE_TRAIT(L, TRAIT_BLOODTHIRSTER, TRAIT_GENERIC)
	UnregisterSignal(L, list(COMSIG_XENOMORPH_ATTACK_LIVING, COMSIG_XENOMORPH_TAKING_DAMAGE))
	STOP_PROCESSING(SSprocessing, src)

/// sig handler to track attacks for bloodthirst
/datum/action/ability/xeno_action/bloodthirst/proc/on_attack(datum/source, mob/living/attacked, damage)
	SIGNAL_HANDLER
	if(!ishuman(attacked) || attacked.stat == DEAD)
		return
	last_fight_time = world.time

///sig handler to track last attacked for bloodthirst
/datum/action/ability/xeno_action/bloodthirst/proc/on_take_damage(datum/source, damage, mob/living/attacker)
	SIGNAL_HANDLER
	last_fight_time = world.time

/datum/action/ability/xeno_action/bloodthirst/process()
	var/mob/living/carbon/xenomorph/xeno = owner
	if(!last_fight_time) // you may live until first attack happens
		return
	if(last_fight_time + decay_delay > world.time)
		return
	if(xeno.use_plasma(BLOODTHIRST_DECAY_PER_TICK))
		disintegrating = FALSE
		return
	if(!disintegrating)
		hit_zero_time = world.time
		owner.balloon_alert(owner, "disintegrating...")
		xeno.playsound_local(xeno, 'sound/voice/hiss5.ogg', 50)
		disintegrating = TRUE
		return
	if((hit_zero_time + damage_delay) < world.time)
		//take  damage per tick down to a minimum allowed hp
		var/damage_taken = min(MAX_DAMAGE_PER_DISINTEGRATING, (xeno.health - xeno.health_threshold_crit - LOWEST_BLOODTHIRST_HP_ALLOWED))
		xeno.take_overall_damage(damage_taken)


#define DEATHMARK_DAMAGE_OR_DIE 400
#define DEATHMARK_DURATION 40 SECONDS
#define DEATHMARK_MESSAGE_COOLDOWN 2 SECONDS

/datum/action/ability/xeno_action/deathmark
	name = "deathmark"
	desc = "Mark yourself for death, filling your bloodthirst, but failing to deal enough damage to living creatures while it is active instantly kills you."
	action_icon = 'icons/Xeno/actions/ravager.dmi'
	action_icon_state = "deathmark"
	cooldown_duration = DEATHMARK_DURATION*3
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_DEATHMARK,
	)
	COOLDOWN_DECLARE(message_cooldown)
	//tracker for damage dealt during deathmark
	var/damage_dealt = 0

/datum/action/ability/xeno_action/deathmark/action_activate()
	var/mob/living/carbon/xenomorph/xeno = owner
	addtimer(CALLBACK(src, PROC_REF(on_deathmark_expire)), DEATHMARK_DURATION)

	xeno.overlays_standing[SUIT_LAYER] = image('icons/Xeno/64x64_Xeno_overlays.dmi', icon_state = "deathmark")
	xeno.apply_temp_overlay(SUIT_LAYER, DEATHMARK_DURATION)

	RegisterSignal(owner, COMSIG_XENOMORPH_ATTACK_LIVING, PROC_REF(on_attack))
	damage_dealt = 0
	xeno.use_plasma(-xeno.xeno_caste.plasma_max) // fill it to the max so they can kill better
	xeno.add_movespeed_modifier(MOVESPEED_ID_RAVAGER_DEATHMARK, TRUE, 0, NONE, TRUE, -0.75) //Extra speed so they can get to where to kill better
	xeno.emote("roar")
	add_cooldown()

/// on attack for deathmark, tracks the amount of dmg dealt
/datum/action/ability/xeno_action/deathmark/proc/on_attack(datum/source, mob/living/attacked, damage)
	if(!ishuman(attacked) || attacked.stat == DEAD)
		return
	damage_dealt += damage
	if(COOLDOWN_FINISHED(src, message_cooldown))
		var/percent_dealt = round((damage_dealt/DEATHMARK_DAMAGE_OR_DIE)*100)
		owner.balloon_alert(owner, "[percent_dealt]%")
		COOLDOWN_START(src, message_cooldown, DEATHMARK_MESSAGE_COOLDOWN)

/// on expire after the timer, execute the owner if they gambled bad
/datum/action/ability/xeno_action/deathmark/proc/on_deathmark_expire()
	var/mob/living/carbon/xenomorph/xeno = owner
	UnregisterSignal(owner, COMSIG_XENOMORPH_ATTACK_LIVING)
	xeno.remove_movespeed_modifier(MOVESPEED_ID_RAVAGER_DEATHMARK)
	if(damage_dealt < DEATHMARK_DAMAGE_OR_DIE)
		to_chat(owner, span_userdanger("THE QUEEN MOTHER IS DISPLEASED WITH YOUR PERFORMANCE ([damage_dealt]/[DEATHMARK_DAMAGE_OR_DIE]). DEATH COMES TO TAKE ITS DUE."))
		xeno.take_overall_damage(999)
		var/turf/balloonloc = get_turf(xeno)
		balloonloc.balloon_alert_to_viewers("JUDGEMENT")
		return
	xeno.playsound_local(xeno, 'sound/voice/hiss5.ogg', 50)
	to_chat(owner, span_userdanger("THE QUEEN MOTHER IS PLEASED WITH YOUR PERFORMANCE ([damage_dealt]/[DEATHMARK_DAMAGE_OR_DIE])."))
	owner.balloon_alert(owner, "deathmark expired")
