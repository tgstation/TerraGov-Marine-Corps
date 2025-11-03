//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/tough_rock
	name = "Tough Rock"
	desc = "After not moving for 1 second, gain 5/7.5/10 soft armor in all categories."
	/// For the first structure, the amount of soft armor to increase by.
	var/armor_increase_initial = 2.5
	/// For each structure, the amount of additional soft armor to increase by.
	var/armor_increase_per_structure = 2.5
	/// The attached armor that been given, if any.
	var/datum/armor/attached_armor
	/// Timer ID for a proc that grant the armor given when it times out.
	var/timer_id
	/// How long will be the timer be?
	var/timer_length = 1 SECONDS

/datum/mutation_upgrade/shell/tough_rock/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "After not moving for [timer_length * 0.1] second, gain [get_armor(new_amount)] soft armor in all categories."

/datum/mutation_upgrade/shell/tough_rock/on_mutation_enabled()
	. = ..()
	RegisterSignal(xenomorph_owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_movement))

/datum/mutation_upgrade/shell/tough_rock/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, list(COMSIG_MOVABLE_MOVED))
	if(attached_armor)
		toggle()
	if(timer_id)
		deltimer(timer_id)
		timer_id = null
	return ..()

/datum/mutation_upgrade/shell/tough_rock/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(attached_armor)
		var/diff = get_armor(new_amount - previous_amount)
		xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.modifyAllRatings(diff)
		attached_armor = attached_armor.modifyAllRatings(diff)
		return
	if(xenomorph_owner.last_move_time < (world.time - timer_length)) // Haven't moved for a while.
		toggle()
		return
	timer_id = addtimer(CALLBACK(src, PROC_REF(toggle), TRUE), timer_length, TIMER_STOPPABLE|TIMER_UNIQUE)

/// Removes armor if they had it while moving. Restarts the timer.
/datum/mutation_upgrade/shell/tough_rock/proc/on_movement(datum/source, atom/old_loc, movement_dir, forced, list/old_locs)
	SIGNAL_HANDLER
	if(attached_armor)
		toggle()
	timer_id = addtimer(CALLBACK(src, PROC_REF(toggle)), timer_length, TIMER_STOPPABLE|TIMER_UNIQUE)

/// Grants or removes armor.
/datum/mutation_upgrade/shell/tough_rock/proc/toggle()
	if(attached_armor)
		xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.detachArmor(attached_armor)
		attached_armor = null
		return
	if(timer_id)
		deltimer(timer_id)
		timer_id = null
	var/total_armor = get_armor(get_total_structures())
	attached_armor = getArmor(total_armor, total_armor, total_armor, total_armor, total_armor, total_armor, total_armor, total_armor)
	xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.attachArmor(attached_armor)

/// Returns the amount of soft armor that should be given.
/datum/mutation_upgrade/shell/tough_rock/proc/get_armor(structure_count)
	return armor_increase_initial + (armor_increase_per_structure * structure_count)

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/earthquake
	name = "Earthquake"
	desc = "Stomp's range is increased by 1 and loses damage 1 tile further. However, it deals 50/60/70% of its original damage and no longer has extra stun duration for stomping ontop of targets."
	/// For the first structure, the multiplier to add as Stomp's damage.
	var/modifier_initial = -0.6
	/// For each structure, the multiplier to add as Stomp's damage.
	var/modifier_per_structure = 0.1
	/// The amount to increase Stomp's range by.
	var/range_initial = 1
	/// The amount of increase Stomp's falloff distance by.
	var/falloff_initial = -1

/datum/mutation_upgrade/spur/earthquake/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Stomp's range is increased by [range_initial] and the distance before damage begins to falloff is increased by [-falloff_initial]. However, Stomp deals [PERCENT(1 + get_multiplier(new_amount))]% of its original damage and no longer has extra stun duration for stomping ontop of targets."

/datum/mutation_upgrade/spur/earthquake/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/stomp/stomp_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/stomp]
	if(!stomp_ability)
		return
	stomp_ability.stomp_damage += initial(stomp_ability.stomp_damage) * get_multiplier(0)
	stomp_ability.stomp_range += range_initial
	stomp_ability.stomp_falloff += falloff_initial
	stomp_ability.distance_bonus_allowed = FALSE

/datum/mutation_upgrade/spur/earthquake/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/stomp/stomp_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/stomp]
	if(!stomp_ability)
		return
	stomp_ability.stomp_damage -= initial(stomp_ability.stomp_damage) * get_multiplier(0)
	stomp_ability.stomp_range -= range_initial
	stomp_ability.stomp_falloff -= falloff_initial
	stomp_ability.distance_bonus_allowed = initial(stomp_ability.distance_bonus_allowed)

/datum/mutation_upgrade/spur/earthquake/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/stomp/stomp_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/stomp]
	if(!stomp_ability)
		return
	stomp_ability.stomp_damage += initial(stomp_ability.stomp_damage) * get_multiplier(new_amount - previous_amount, FALSE)

/// Returns the multiplier to add as Stomp's damage.
/datum/mutation_upgrade/spur/earthquake/proc/get_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? modifier_initial : 0) + (modifier_per_structure * structure_count)

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/friendly_chest
	name = "Friendly Crest"
	desc = "Crest Toss's cooldown is set to 65/50/35% of its original cooldown if it was used on allies."
	/// For the first structure, the multiplier that'll increase Crest Toss's cooldown if it was used on an allied xenomorph.
	var/multiplier_initial = -0.2
	/// For each structure, the multiplier that'll increase Crest Toss's cooldown if it was used on an allied xenomorph.
	var/multiplier_per_structure = -0.15

/datum/mutation_upgrade/veil/friendly_chest/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Crest Toss's cooldown is set to [PERCENT(1 + get_multiplier(new_amount))]% of its original cooldown if it was used on allies."

/datum/mutation_upgrade/veil/friendly_chest/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/cresttoss/toss_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/cresttoss]
	if(!toss_ability)
		return
	toss_ability.ally_cooldown_multiplier += get_multiplier(0)

/datum/mutation_upgrade/veil/friendly_chest/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/cresttoss/toss_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/cresttoss]
	if(!toss_ability)
		return
	toss_ability.ally_cooldown_multiplier -= get_multiplier(0)

/datum/mutation_upgrade/veil/friendly_chest/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/cresttoss/toss_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/cresttoss]
	if(!toss_ability)
		return
	toss_ability.ally_cooldown_multiplier += get_multiplier(new_amount - previous_amount, FALSE)

/// Returns the multiplier that'll increase Crest Toss's cooldown if it was used on an allied xenomorph.
/datum/mutation_upgrade/veil/friendly_chest/proc/get_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? multiplier_initial : 0) + (multiplier_per_structure * structure_count)

