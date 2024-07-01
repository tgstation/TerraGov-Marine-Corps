#define CALLING_BURROWED_DURATION 15 SECONDS

// ***************************************
// *********** Call of the Burrowed
// ***************************************
/datum/action/ability/xeno_action/call_of_the_burrowed
	name = "Call of the Burrowed"
	desc = "Attempts to summon all currently burrowed larva."
	action_icon_state = "larva_growth"
	action_icon = 'icons/Xeno/actions/leader.dmi'
	ability_cost = 400
	cooldown_duration = 2 MINUTES
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_CALL_OF_THE_BURROWED,
	)
	use_state_flags = ABILITY_USE_LYING


/datum/action/ability/xeno_action/call_of_the_burrowed/action_activate()
	var/mob/living/carbon/xenomorph/shrike/caller = owner
	if(!isnormalhive(caller.hive))
		to_chat(caller, span_warning("Burrowed larva? What a strange concept... It's not for our hive."))
		return FALSE
	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	var/stored_larva = xeno_job.total_positions - xeno_job.current_positions
	if(!stored_larva)
		to_chat(caller, span_warning("Our hive currently has no burrowed to call forth!"))
		return FALSE

	playsound(caller,'sound/magic/invoke_general.ogg', 75, TRUE)
	new /obj/effect/temp_visual/telekinesis(get_turf(caller))
	caller.visible_message(span_xenowarning("A strange buzzing hum starts to emanate from \the [caller]!"), \
	span_xenodanger("We call forth the larvas to rise from their slumber!"))

	if(stored_larva)
		RegisterSignals(caller.hive, list(COMSIG_HIVE_XENO_MOTHER_PRE_CHECK, COMSIG_HIVE_XENO_MOTHER_CHECK), PROC_REF(is_burrowed_larva_host))
		caller.hive.give_larva_to_next_in_queue()
		notify_ghosts("\The <b>[caller]</b> is calling for the burrowed larvas to wake up!", enter_link = "join_larva=1", enter_text = "Join as Larva", source = caller, action = NOTIFY_JOIN_AS_LARVA)
		addtimer(CALLBACK(src, PROC_REF(calling_larvas_end), caller), CALLING_BURROWED_DURATION)

	succeed_activate()
	add_cooldown()


/datum/action/ability/xeno_action/call_of_the_burrowed/proc/calling_larvas_end(mob/living/carbon/xenomorph/shrike/caller)
	UnregisterSignal(caller.hive, list(COMSIG_HIVE_XENO_MOTHER_PRE_CHECK, COMSIG_HIVE_XENO_MOTHER_CHECK))


/datum/action/ability/xeno_action/call_of_the_burrowed/proc/is_burrowed_larva_host(datum/source, list/mothers, list/silos) //Should only register while a viable candidate.
	SIGNAL_HANDLER
	if(!owner.incapacitated())
		mothers += owner //Adding them to the list.


// ***************************************
// *********** Psychic Fling
// ***************************************
#define PSYCHIC_FLING_RANGE 3 // in tiles

/datum/action/ability/activable/xeno/psychic_fling
	name = "Psychic Fling"
	action_icon_state = "fling"
	action_icon = 'icons/Xeno/actions/shrike.dmi'
	desc = "Sends an enemy or an item flying. A close ranged ability."
	cooldown_duration = 12 SECONDS
	ability_cost = 100
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PSYCHIC_FLING,
	)
	target_flags = ABILITY_MOB_TARGET
	/// The duration of this ability's stun effect.
	var/stun_duration = 2 SECONDS
	/// The duration of this ability's weaken effect.
	var/weaken_duration = 0.2 SECONDS

/datum/action/ability/activable/xeno/psychic_fling/on_cooldown_finish()
	owner.balloon_alert(owner, "[initial(name)] ready")
	return ..()

/datum/action/ability/activable/xeno/psychic_fling/can_use_ability(atom/target, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(QDELETED(target))
		return FALSE
	if(!isitem(target) && !isliving(target) && !isdroid(target))
		if(!silent)
			owner.balloon_alert(owner, "Invalid target")
		return FALSE
	if(!line_of_sight(owner, target, PSYCHIC_FLING_RANGE))
		if(!silent)
			owner.balloon_alert(owner, "Out of range")
		return FALSE
	if(isliving(target))
		var/mob/living/living_target = target
		if(!CHECK_BITFIELD(use_state_flags|override_flags, ABILITY_IGNORE_DEAD_TARGET) && living_target.stat == DEAD)
			return FALSE

/datum/action/ability/activable/xeno/psychic_fling/use_ability(atom/target)
	GLOB.round_statistics.psychic_flings++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "psychic_flings")
	playsound(owner,'sound/effects/magic.ogg', 75, 1)
	playsound(target,'sound/weapons/alien_claw_block.ogg', 75, 1)
	//Held facehuggers get killed for balance reasons
	if(istype(owner.r_hand, /obj/item/clothing/mask/facehugger))
		var/obj/item/clothing/mask/facehugger/held_hugger = owner.r_hand
		if(held_hugger.stat != DEAD)
			held_hugger.kill_hugger()
	if(istype(owner.l_hand, /obj/item/clothing/mask/facehugger))
		var/obj/item/clothing/mask/facehugger/held_hugger = owner.l_hand
		if(held_hugger.stat != DEAD)
			held_hugger.kill_hugger()
	succeed_activate()
	add_cooldown()
	if(ismovableatom(target))
		do_fling(target)

/datum/action/ability/activable/xeno/psychic_fling/proc/do_fling(atom/movable/target)
	target.knockback(owner, (isitem(target)) ? PSYCHIC_FLING_RANGE + 1 : PSYCHIC_FLING_RANGE, 1, spin = TRUE)
	if(isliving(target))
		var/mob/living/living_target = target
		living_target.apply_effects(stun_duration, weaken_duration)
		shake_camera(living_target, 2, 1)


// ***************************************
// *********** Unrelenting Force
// ***************************************
#define UNRELENTING_FORCE_KNOCK_BACK 6 // in tiles

/datum/action/ability/activable/xeno/unrelenting_force
	name = "Unrelenting Force"
	action_icon_state = "screech"
	action_icon = 'icons/Xeno/actions/queen.dmi'
	desc = "Unleashes our raw psychic power, pushing aside anyone who stands in our path."
	cooldown_duration = 50 SECONDS
	ability_cost = 300
	keybind_flags = ABILITY_KEYBIND_USE_ABILITY | ABILITY_IGNORE_SELECTED_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_UNRELENTING_FORCE,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_UNRELENTING_FORCE_SELECT,
	)
	/// The duration of this ability's stun effect.
	var/stun_duration = 2 SECONDS
	/// The duration of this ability's weaken effect.
	var/weaken_duration = 2 SECONDS

/datum/action/ability/activable/xeno/unrelenting_force/on_cooldown_finish()
	owner.balloon_alert(owner, "[initial(name)] ready")
	return ..()

/datum/action/ability/activable/xeno/unrelenting_force/use_ability(atom/target)
	succeed_activate()
	add_cooldown()
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	addtimer(CALLBACK(xeno_owner, TYPE_PROC_REF(/mob, update_icons)), 1 SECONDS)
	//Held facehuggers get killed for balance reasons
	if(istype(xeno_owner.r_hand, /obj/item/clothing/mask/facehugger))
		var/obj/item/clothing/mask/facehugger/held_hugger = owner.r_hand
		if(held_hugger.stat != DEAD)
			held_hugger.kill_hugger()
	if(istype(xeno_owner.l_hand, /obj/item/clothing/mask/facehugger))
		var/obj/item/clothing/mask/facehugger/held_hugger = owner.l_hand
		if(held_hugger.stat != DEAD)
			held_hugger.kill_hugger()
	xeno_owner.icon_state = "[xeno_owner.xeno_caste.caste_name][(xeno_owner.xeno_flags & XENO_ROUNY) ? " rouny" : ""] Screeching"
	if(target) // Keybind use doesn't have a target
		xeno_owner.face_atom(target)
	var/turf/lower_left
	var/turf/upper_right
	switch(xeno_owner.dir)
		if(NORTH)
			lower_left = locate(owner.x - 1, owner.y + 1, owner.z)
			upper_right = locate(owner.x + 1, owner.y + 3, owner.z)
		if(SOUTH)
			lower_left = locate(owner.x - 1, owner.y - 3, owner.z)
			upper_right = locate(owner.x + 1, owner.y - 1, owner.z)
		if(WEST)
			lower_left = locate(owner.x - 3, owner.y - 1, owner.z)
			upper_right = locate(owner.x - 1, owner.y + 1, owner.z)
		if(EAST)
			lower_left = locate(owner.x + 1, owner.y - 1, owner.z)
			upper_right = locate(owner.x + 3, owner.y + 1, owner.z)
	do_screech(block(lower_left, upper_right))

/datum/action/ability/activable/xeno/unrelenting_force/proc/do_screech(list/turf/affected_turfs)
	var/list/things_to_throw = list()
	for(var/turf/affected_turf in affected_turfs)
		affected_turf.Shake(duration = 0.5 SECONDS)
		for(var/atom/movable/affected_movable AS in affected_turf)
			if(!isliving(affected_movable) && !isitem(affected_movable) && !isdroid(affected_movable))
				affected_movable.Shake(duration = 0.5 SECONDS)
				continue
			if(isliving(affected_movable))
				var/mob/living/affected_living = affected_movable
				if(affected_living.stat == DEAD)
					continue
				affected_living.apply_effects(stun_duration, weaken_duration)
				shake_camera(affected_living, 2, 1)
			things_to_throw += affected_movable
	for(var/atom/movable/affected_movable AS in things_to_throw)
		affected_movable.knockback(affected_movable.loc, UNRELENTING_FORCE_KNOCK_BACK, 1, owner.dir, spin = TRUE)
	playsound(owner,'sound/effects/bamf.ogg', 75, TRUE)
	playsound(owner, SFX_ALIEN_ROAR, 50)


// ***************************************
// *********** Psychic Cure
// ***************************************
#define PSYCHIC_CURE_HEAL_RANGE 3
#define PSYCHIC_CURE_WIND_UP 1 SECONDS
#define PSYCHIC_CURE_SHRIKE_HEAL_MULTIPLIER 10

/datum/action/ability/activable/xeno/psychic_cure
	name = "Psychic Cure"
	action_icon_state = "heal_xeno"
	action_icon = 'icons/Xeno/actions/drone.dmi'
	desc = "Heal and remove debuffs from a target."
	cooldown_duration = 1 MINUTES
	ability_cost = 200
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PSYCHIC_CURE,
	)
	var/heal_range = PSYCHIC_CURE_HEAL_RANGE
	target_flags = ABILITY_MOB_TARGET

/datum/action/ability/activable/xeno/psychic_cure/on_cooldown_finish()
	owner.balloon_alert(owner, "[initial(name)] ready")
	return ..()

/datum/action/ability/activable/xeno/psychic_cure/can_use_ability(atom/target, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(QDELETED(target))
		return FALSE
	if(!check_distance(target, silent))
		return FALSE
	if(!isxeno(target))
		return FALSE
	var/mob/living/carbon/xenomorph/xeno_target = target
	if(!CHECK_BITFIELD(use_state_flags|override_flags, ABILITY_IGNORE_DEAD_TARGET) && xeno_target.stat == DEAD)
		if(!silent)
			owner.balloon_alert(owner, "Dead")
		return FALSE

/datum/action/ability/activable/xeno/psychic_cure/proc/check_distance(atom/target, silent)
	var/distance = get_dist(owner, target)
	if(distance > heal_range)
		if(!silent)
			owner.balloon_alert(owner, "Too far away, get [distance - heal_range] steps closer")
		return FALSE
	else if(!line_of_sight(owner, target))
		if(!silent)
			owner.balloon_alert(owner, "No line of sight")
		return FALSE
	return TRUE

/datum/action/ability/activable/xeno/psychic_cure/use_ability(atom/target)
	if(owner.do_actions || !isxeno(target))
		return FALSE
	var/mob/living/carbon/xenomorph/xeno_target = target
	if(!do_after(owner, PSYCHIC_CURE_WIND_UP, NONE, xeno_target, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL))
		return FALSE
	if(owner.client)
		var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[owner.ckey]
		personal_statistics.heals++
	GLOB.round_statistics.psychic_cures++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "psychic_cures")
	playsound(xeno_target,'sound/effects/magic.ogg', 75, 1)
	new /obj/effect/temp_visual/telekinesis(get_turf(xeno_target))
	xeno_target.heal_wounds(PSYCHIC_CURE_SHRIKE_HEAL_MULTIPLIER)
	xeno_target.adjust_sunder(-PSYCHIC_CURE_SHRIKE_HEAL_MULTIPLIER)
	if(xeno_target.health > 0)
		xeno_target.SetUnconscious(0)
		xeno_target.SetStun(0)
		xeno_target.SetParalyzed(0)
		xeno_target.set_stagger(0)
		xeno_target.set_slowdown(0)
	xeno_target.updatehealth()
	owner.changeNext_move(CLICK_CD_RANGE)
	log_combat(owner, xeno_target, "psychically cured")
	succeed_activate()
	add_cooldown()


// ***************************************
// *********** Construct Acid Well
// ***************************************
/datum/action/ability/xeno_action/place_acidwell
	name = "Place acid well"
	action_icon_state = "place_trap"
	action_icon = 'icons/Xeno/actions/construction.dmi'
	desc = "Place an acid well that can put out fires."
	ability_cost = 400
	cooldown_duration = 2 MINUTES
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PLACE_ACID_WELL,
	)
	use_state_flags = ABILITY_USE_LYING

/datum/action/ability/xeno_action/place_acidwell/can_use_action(silent = FALSE, override_flags)
	. = ..()
	var/turf/T = get_turf(owner)
	if(!T || !T.is_weedable() || T.density)
		if(!silent)
			to_chat(owner, span_warning("We can't do that here."))
		return FALSE

	var/mob/living/carbon/xenomorph/owner_xeno = owner
	if(!owner_xeno.loc_weeds_type)
		if(!silent)
			to_chat(owner, span_warning("We can only shape on weeds. We must find some resin before we start building!"))
		return FALSE

	if(!T.check_alien_construction(owner, silent, /obj/structure/xeno/acidwell))
		return FALSE

	if(!T.check_disallow_alien_fortification(owner, silent))
		return FALSE

/datum/action/ability/xeno_action/place_acidwell/action_activate()
	var/turf/T = get_turf(owner)
	succeed_activate()

	playsound(T, SFX_ALIEN_RESIN_BUILD, 25)
	new /obj/structure/xeno/acidwell(T, owner)

	to_chat(owner, span_xenonotice("We place an acid well; it can be filled with more acid."))
	GLOB.round_statistics.xeno_acid_wells++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "xeno_acid_wells")
	owner.record_traps_created()


// ***************************************
// *********** Psychic Vortex
// ***************************************
#define VORTEX_RANGE 4
#define VORTEX_INITIAL_CHARGE 2 SECONDS
#define VORTEX_POST_INITIAL_CHARGE 0.5 SECONDS
/datum/action/ability/activable/xeno/psychic_vortex
	name = "Pyschic vortex"
	action_icon_state = "vortex"
	action_icon = 'icons/Xeno/actions/shrike.dmi'
	desc = "Channel a sizable vortex of psychic energy, drawing in nearby enemies."
	ability_cost = 600
	cooldown_duration = 2 MINUTES
	keybind_flags = ABILITY_KEYBIND_USE_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PSYCHIC_VORTEX,
	)
	/// Used for particles. Holds the particles instead of the mob. See particle_holder for documentation.
	var/obj/effect/abstract/particle_holder/particle_holder
	///The particle type this ability uses
	var/channel_particle = /particles/warlock_charge

/datum/action/ability/activable/xeno/psychic_vortex/on_cooldown_finish()
	to_chat(owner, span_notice("Our mind is ready to unleash another chaotic vortex of energy."))
	return ..()

/datum/action/ability/activable/xeno/psychic_vortex/use_ability(atom/target)
	succeed_activate()
	add_cooldown()

	particle_holder = new(owner, channel_particle)
	particle_holder.pixel_x = 15
	particle_holder.pixel_y = 0

	if(target) // Keybind use doesn't have a target
		owner.face_atom(target)
	ADD_TRAIT(owner, TRAIT_IMMOBILE, VORTEX_ABILITY_TRAIT)
	if(do_after(owner, VORTEX_INITIAL_CHARGE, IGNORE_HELD_ITEM, owner, BUSY_ICON_DANGER))
		vortex_pull()
	if(do_after(owner, VORTEX_POST_INITIAL_CHARGE, IGNORE_HELD_ITEM, owner, BUSY_ICON_DANGER))
		vortex_push()
	if(do_after(owner, VORTEX_POST_INITIAL_CHARGE, IGNORE_HELD_ITEM, owner, BUSY_ICON_DANGER))
		vortex_pull()
	QDEL_NULL(particle_holder)
	REMOVE_TRAIT(owner, TRAIT_IMMOBILE, VORTEX_ABILITY_TRAIT)
	return


/**
 * Checks for any non-anchored movable atom, throwing them towards the shrike/owner using the ability.
 * While causing shake to anything in range with effects applied to humans affected.
 */
/datum/action/ability/activable/xeno/psychic_vortex/proc/vortex_pull()
	playsound(owner, 'sound/effects/seedling_chargeup.ogg', 60)
	for(var/atom/movable/movable_victim in range(VORTEX_RANGE, owner.loc))
		if(movable_victim.anchored || isxeno(movable_victim) || movable_victim.move_resist > MOVE_FORCE_STRONG)
			continue
		if(ishuman(movable_victim))
			var/mob/living/carbon/human/H = movable_victim
			if(H.stat == DEAD)
				continue
			H.apply_effects(1,1)
			H.adjust_stagger(2 SECONDS)
			shake_camera(H, 2, 1)
		else if(isitem(movable_victim))
			var/turf/targetturf = get_turf(owner)
			targetturf = locate(targetturf.x + rand(1, 4), targetturf.y + rand(1, 4), targetturf.z)
			movable_victim.throw_at(targetturf, 4, 1, owner, FALSE, FALSE)
		movable_victim.throw_at(owner, 4, 1, owner, FALSE, FALSE)

/// Randomly throws movable atoms in the radius of the vortex abilites range, different each use.
/datum/action/ability/activable/xeno/psychic_vortex/proc/vortex_push()
	for(var/atom/movable/movable_victim in range(VORTEX_RANGE, owner.loc))
		if(movable_victim.anchored || isxeno(movable_victim) || movable_victim.move_resist == INFINITY)
			continue
		if(ishuman(movable_victim))
			var/mob/living/carbon/human/human_victim = movable_victim
			if(human_victim.stat == DEAD)
				continue
		var/turf/targetturf = get_turf(owner)
		targetturf = locate(targetturf.x + rand(1, 4), targetturf.y + rand(1, 4), targetturf.z)
		movable_victim.throw_at(targetturf, 4, 1, owner, FALSE, FALSE)
