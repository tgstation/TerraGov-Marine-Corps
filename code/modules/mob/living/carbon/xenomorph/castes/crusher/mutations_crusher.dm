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
	return "After not moving for 1 second, gain [armor_increase_initial + (armor_increase_per_structure * new_amount)] soft armor in all categories."

/datum/mutation_upgrade/shell/tough_rock/on_mutation_enabled()
	. = ..()
	RegisterSignal(xenomorph_owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_movement))
	create_timer()

/datum/mutation_upgrade/shell/tough_rock/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, list(COMSIG_MOVABLE_MOVED))
	revoke_armor()
	remove_timer()
	return ..()

/datum/mutation_upgrade/shell/tough_rock/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!. || !attached_armor)
		return
	revoke_armor()
	grant_armor()

/// Removes armor if they had it while moving. Sets or restarts the timer accordingly.
/datum/mutation_upgrade/shell/tough_rock/proc/on_movement(datum/source, atom/old_loc, movement_dir, forced, list/old_locs)
	SIGNAL_HANDLER
	revoke_armor()
	create_timer()

/datum/mutation_upgrade/shell/tough_rock/proc/remove_timer()
	if(!timer_id)
		return
	deltimer(timer_id)
	timer_id = null

/datum/mutation_upgrade/shell/tough_rock/proc/create_timer()
	timer_id = addtimer(CALLBACK(src, PROC_REF(grant_armor)), timer_length, TIMER_STOPPABLE|TIMER_UNIQUE)

/// Grants armor and removes the timer.
/datum/mutation_upgrade/shell/tough_rock/proc/grant_armor()
	remove_timer()
	if(attached_armor)
		return
	var/total_armor = armor_increase_initial + (get_total_structures() * armor_increase_per_structure)
	attached_armor = new(total_armor, total_armor, total_armor, total_armor, total_armor, total_armor, total_armor, total_armor)
	xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.attachArmor(attached_armor)

/// Removes armor and the timer.
/datum/mutation_upgrade/shell/tough_rock/proc/revoke_armor()
	remove_timer()
	if(!attached_armor)
		return
	xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.detachArmor(attached_armor)
	attached_armor = null

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/shell/earthquake
	name = "Earthquake"
	desc = "Stomping ontop of a human no longer deals additional effects or damage. Stomp's range is increased by 1. Stomp's distance falloff begins 1 tile later, but deals 50/60/70% of its original damage."
	/// For the first structure, the amount of soft armor to increase by.
	var/damage_percentage_increase_initial = -0.50
	/// For each structure, the amount of additional soft armor to increase by.
	var/damage_percentage_per_structure = 0.1
	/// The amount of range to increase Stomp by.
	var/range_initial = 1
	/// The amount of falloff range to increase Stomp by.
	var/falloff_initial = 1

/datum/mutation_upgrade/shell/earthquake/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Stomping ontop of a human no longer deals additional effects or damage. Stomp's range is increased by [range_initial]. Stomp's distance falloff begins [falloff_initial] tile later, but deals [(1 + damage_percentage_increase_initial + (damage_percentage_per_structure * new_amount)) * 100]% of its original damage."

/datum/mutation_upgrade/shell/earthquake/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/stomp/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/stomp]
	if(!ability)
		return FALSE
	ability.range += range_initial
	ability.falloff_range += falloff_initial
	ability.has_facestomp_effects = FALSE
	ability.damage += initial(ability.damage) * damage_percentage_increase_initial
	return ..()

/datum/mutation_upgrade/shell/earthquake/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/stomp/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/stomp]
	if(!ability)
		return FALSE
	ability.range -= range_initial
	ability.falloff_range -= falloff_initial
	ability.has_facestomp_effects = initial(ability.has_facestomp_effects)
	ability.damage -= initial(ability.damage) * damage_percentage_increase_initial
	return ..()

/datum/mutation_upgrade/shell/earthquake/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/stomp/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/stomp]
	if(!ability)
		return FALSE
	ability.damage += (new_amount - previous_amount) * damage_percentage_increase_initial

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/shell/friendly_chest
	name = "Friendly Crest"
	desc = "Crest Toss's cooldown is set to 65/50/35% of its original cooldown if it was used on allies."
	/// For the first structure, the percentage amount to increase the ability's cooldown if it was used on an ability.
	var/cooldown_percentage_increase_initial = -0.2
	/// For each structure, the additional percentage amount to increase the ability's cooldown if it was used on an ability.
	var/cooldown_percentage_per_structure = -0.15

/datum/mutation_upgrade/shell/friendly_chest/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Crest Toss's cooldown is set to [PERCENT(1 + cooldown_percentage_increase_initial + (cooldown_percentage_per_structure * new_amount))] of its original cooldown if it was used on allies."

/datum/mutation_upgrade/shell/friendly_chest/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/cresttoss/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/cresttoss]
	if(!ability)
		return FALSE
	ability.friendly_cooldown_reduction += initial(ability.cooldown_duration) * cooldown_percentage_increase_initial
	return ..()

/datum/mutation_upgrade/shell/friendly_chest/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/cresttoss/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/cresttoss]
	if(!ability)
		return FALSE
	ability.friendly_cooldown_reduction -= initial(ability.cooldown_duration) * cooldown_percentage_increase_initial
	return ..()

/datum/mutation_upgrade/shell/friendly_chest/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/cresttoss/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/cresttoss]
	if(!ability)
		return FALSE
	ability.friendly_cooldown_reduction += initial(ability.cooldown_duration) * (new_amount - previous_amount) * cooldown_percentage_per_structure
