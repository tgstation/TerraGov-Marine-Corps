//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/tough_rock
	name = "Tough Rock"
	desc = "After not moving for 1 second, gain 7.5 soft armor in all categories."
	/// The amount of soft armor to increase by.
	var/armor_increase = 7.5
	/// The attached armor that been given, if any.
	var/datum/armor/attached_armor
	/// Timer ID for a proc that grant the armor given when it times out.
	var/timer_id
	/// How long will be the timer be?
	var/timer_length = 1 SECONDS

/datum/mutation_upgrade/shell/tough_rock/on_mutation_enabled()
	RegisterSignal(xenomorph_owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_movement))
	if(xenomorph_owner.last_move_time < (world.time - timer_length)) // Haven't moved for a while.
		toggle()
		return
	timer_id = addtimer(CALLBACK(src, PROC_REF(toggle)), timer_length, TIMER_OVERRIDE|TIMER_UNIQUE)

/datum/mutation_upgrade/shell/tough_rock/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, list(COMSIG_MOVABLE_MOVED))
	if(attached_armor)
		toggle()
	if(timer_id)
		deltimer(timer_id)
		timer_id = null

/// Removes armor if they had it while moving. Restarts the timer.
/datum/mutation_upgrade/shell/tough_rock/proc/on_movement(datum/source, atom/old_loc, movement_dir, forced, list/old_locs)
	SIGNAL_HANDLER
	if(attached_armor)
		toggle()
	timer_id = addtimer(CALLBACK(src, PROC_REF(toggle)), timer_length, TIMER_OVERRIDE|TIMER_UNIQUE)

/// Grants or removes armor.
/datum/mutation_upgrade/shell/tough_rock/proc/toggle()
	if(attached_armor)
		xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.detachArmor(attached_armor)
		attached_armor = null
		return
	if(timer_id)
		deltimer(timer_id)
		timer_id = null
	attached_armor = getArmor(armor_increase, armor_increase, armor_increase, armor_increase, armor_increase, armor_increase, armor_increase, armor_increase)
	xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.attachArmor(attached_armor)

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/earthquake
	name = "Earthquake"
	desc = "Stomp's range is increased by 1 and loses damage 1 tile further. However, it deals 60% of its original damage and no longer has extra stun duration for stomping ontop of targets."
	/// The multiplier to add as Stomp's damage.
	var/multiplier = -0.4
	/// The amount to increase Stomp's range by.
	var/range_initial = 1
	/// The amount of increase Stomp's falloff distance by.
	var/falloff_initial = -1

/datum/mutation_upgrade/spur/earthquake/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/stomp/stomp_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/stomp]
	if(!stomp_ability)
		return
	stomp_ability.stomp_damage += initial(stomp_ability.stomp_damage) * multiplier
	stomp_ability.stomp_range += range_initial
	stomp_ability.stomp_falloff += falloff_initial
	stomp_ability.distance_bonus_allowed = FALSE

/datum/mutation_upgrade/spur/earthquake/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/stomp/stomp_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/stomp]
	if(!stomp_ability)
		return
	stomp_ability.stomp_damage -= initial(stomp_ability.stomp_damage) * multiplier
	stomp_ability.stomp_range -= range_initial
	stomp_ability.stomp_falloff -= falloff_initial
	stomp_ability.distance_bonus_allowed = initial(stomp_ability.distance_bonus_allowed)

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/friendly_chest
	name = "Friendly Crest"
	desc = "Crest Toss's cooldown is set to 50% of its original cooldown if it was used on allies."
	/// The multiplier that'll increase Crest Toss's cooldown if it was used on an allied xenomorph.
	var/multiplier = -0.5

/datum/mutation_upgrade/veil/friendly_chest/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/cresttoss/toss_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/cresttoss]
	if(!toss_ability)
		return
	toss_ability.ally_cooldown_multiplier += multiplier

/datum/mutation_upgrade/veil/friendly_chest/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/cresttoss/toss_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/cresttoss]
	if(!toss_ability)
		return
	toss_ability.ally_cooldown_multiplier -= multiplier
