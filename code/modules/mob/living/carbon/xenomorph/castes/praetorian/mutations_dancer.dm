//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/flame_dance
	name = "Flame Dance"
	desc = "If you are on fire, Tail Trip and Tail Hook will extinguishes you and inflict nearby humans with an equal amount of melting fire. Your fire armor is reduced by 15/10/5."
	/// For the first structure, the amount of fire soft armor to grant the owner.
	var/armor_initial = -20
	/// For each structure, the amount of fire soft armor to grant the owner.
	var/armor_per_structure = 5
	/// The status effect handling the armor.
	var/datum/status_effect/xenomorph_soft_armor_modifier/mutation_dancer_flame_dance/armor_status_effect

/datum/mutation_upgrade/shell/flame_dance/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "If you are on fire, Tail Trip and Tail Hook will extinguishes you and inflict nearby humans with an equal amount of melting fire. Your fire armor is reduced by [get_armor(new_amount)]."

/datum/mutation_upgrade/shell/flame_dance/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/tail_trip/tail_trip = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/tail_trip]
	if(!tail_trip)
		return FALSE
	var/datum/action/ability/activable/xeno/tail_hook/tail_hook = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/tail_hook]
	if(!tail_hook)
		return FALSE
	tail_trip.spreads_fire = TRUE
	tail_hook.spreads_fire = TRUE
	armor_status_effect = xenomorph_owner.apply_status_effect(STATUS_EFFECT_MUTATION_DANCER_FLAME_DANCE, armor_initial, FIRE)
	return ..()

/datum/mutation_upgrade/shell/flame_dance/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/tail_trip/tail_trip = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/tail_trip]
	if(!tail_trip)
		return FALSE
	var/datum/action/ability/activable/xeno/tail_hook/tail_hook = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/tail_hook]
	if(!tail_hook)
		return FALSE
	tail_trip.spreads_fire = initial(tail_trip.spreads_fire)
	tail_hook.spreads_fire = initial(tail_hook.spreads_fire)
	if(armor_status_effect)
		xenomorph_owner.remove_status_effect(STATUS_EFFECT_MUTATION_DANCER_FLAME_DANCE)
		armor_status_effect = null
	return ..()

/datum/mutation_upgrade/shell/flame_dance/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!. || !armor_status_effect)
		return
	armor_status_effect.modify_armor(get_armor(new_amount - previous_amount, FALSE), FIRE)

/// Returns the amount of fire armor that the mutation should be giving.
/datum/mutation_upgrade/shell/flame_dance/proc/get_armor(structure_count, include_initial = TRUE)
	if(!structure_count)
		structure_count = get_total_structures()
	return (include_initial ? armor_initial : 0) + (armor_per_structure * structure_count)

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/bob_and_weave
	name = "Bob and Weave"
	desc = "Tail Hook now pushes away humans rather than in pulls them in. It deals 2/4/6 additional damage."
	/// For each structure, the amount of extra damage that Tail Hook deals.
	var/damage_per_structure = 2

/datum/mutation_upgrade/spur/bob_and_weave/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Tail Hook now pushes away humans rather than in pulls them in. It deals [get_damage(new_amount)] additional damage."

/datum/mutation_upgrade/spur/bob_and_weave/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/tail_hook/tail_hook = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/tail_hook]
	if(!tail_hook)
		return FALSE
	tail_hook.push_distance += initial(tail_hook.push_distance) * -2
	return ..()

/datum/mutation_upgrade/spur/bob_and_weave/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/tail_hook/tail_hook = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/tail_hook]
	if(!tail_hook)
		return FALSE
	tail_hook.push_distance -= initial(tail_hook.push_distance) * -2
	return ..()

/datum/mutation_upgrade/spur/bob_and_weave/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/tail_hook/tail_hook = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/tail_hook]
	if(!tail_hook)
		return
	tail_hook.bonus_damage += get_damage(new_amount - previous_amount)

/// Returns the extra damage that the mutation should be giving.
/datum/mutation_upgrade/spur/bob_and_weave/proc/get_damage(structure_count)
	if(!structure_count)
		structure_count = get_total_structures()
	return damage_per_structure * structure_count

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/eb_and_flow
	name = "Eb and Flow"
	desc = "Dodge now lets you walk over structures such as tables and window frames. It now costs 2/1.75/1.5x of its original cost."
	/// For the first structure, the multiplier to increase the cost by.
	var/cost_multiplier_initial = 1.25
	/// For each structure, the multiplier to increase the cost by.
	var/cost_multiplier_per_structure = -0.25

/datum/mutation_upgrade/veil/eb_and_flow/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Dodge now lets you walk over structures such as tables and window frames. It now costs [get_multiplier(new_amount)]x of its original cost."

/datum/mutation_upgrade/veil/eb_and_flow/on_mutation_enabled()
	var/datum/action/ability/xeno_action/dodge/dodge = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/dodge]
	if(!dodge)
		return FALSE
	dodge.ability_cost += initial(dodge.ability_cost) * cost_multiplier_initial
	return ..()

/datum/mutation_upgrade/veil/eb_and_flow/on_mutation_disabled()
	var/datum/action/ability/xeno_action/dodge/dodge = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/dodge]
	if(!dodge)
		return FALSE
	dodge.ability_cost -= initial(dodge.ability_cost) * cost_multiplier_initial
	return ..()

/datum/mutation_upgrade/veil/eb_and_flow/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/dodge/dodge = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/dodge]
	if(!dodge)
		return
	dodge.ability_cost += initial(dodge.ability_cost) * get_multiplier(new_amount - previous_amount, FALSE)

/// Returns the multiplier that the mutation should be adding to the ability's plasma cost.
/datum/mutation_upgrade/veil/eb_and_flow/proc/get_multiplier(structure_count, include_initial = TRUE)
	if(!structure_count)
		structure_count = get_total_structures()
	return (include_initial ? cost_multiplier_initial : 0) + (cost_multiplier_per_structure * structure_count)
