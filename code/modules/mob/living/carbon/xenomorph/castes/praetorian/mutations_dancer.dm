//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/flame_dance
	name = "Flame Dance"
	desc = "If you are on fire, Tail Trip and Tail Hook will extinguishes you and inflict nearby humans with an equal amount of melting fire. Your fire armor is reduced by 15/10/5."
	/// For the first structure, the amount of fire armor that should be given for having this mutation.
	var/armor_initial = -20
	/// For each structure, the amount of fire armor that should be given for having this mutation.
	var/armor_per_structure = 5
	/// Armor attached to the xenomorph owner, if any.
	var/datum/armor/attached_armor

/datum/mutation_upgrade/shell/flame_dance/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "If you are on fire, Tail Trip and Tail Hook will extinguishes you and inflict nearby humans with an equal amount of melting fire. Your fire armor is reduced by [-get_armor(new_amount)]."

/datum/mutation_upgrade/shell/flame_dance/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/tail_trip/trip_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/tail_trip]
	if(!trip_ability)
		return
	var/datum/action/ability/activable/xeno/tail_hook/hook_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/tail_hook]
	if(!hook_ability)
		return
	trip_ability.spreads_fire = TRUE
	hook_ability.spreads_fire = TRUE
	if(!attached_armor)
		attached_armor = getArmor(fire = get_armor(0))
		xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.attachArmor(attached_armor)

/datum/mutation_upgrade/shell/flame_dance/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/tail_trip/trip_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/tail_trip]
	if(!trip_ability)
		return
	var/datum/action/ability/activable/xeno/tail_hook/hook_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/tail_hook]
	if(!hook_ability)
		return
	trip_ability.spreads_fire = initial(trip_ability.spreads_fire)
	hook_ability.spreads_fire = initial(hook_ability.spreads_fire)
	if(attached_armor)
		xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.detachArmor(attached_armor)
		attached_armor = null

/datum/mutation_upgrade/shell/flame_dance/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!attached_armor)
		return
	var/amount = get_armor(new_amount - previous_amount, FALSE)
	attached_armor = attached_armor.modifyRating(fire = amount)
	xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.modifyRating(fire = amount)

/// Returns the amount of fire armor that should be given for having this mutation.
/datum/mutation_upgrade/shell/flame_dance/proc/get_armor(structure_count, include_initial = TRUE)
	return (include_initial ? armor_initial : 0) + (armor_per_structure * structure_count)

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/bob_and_weave
	name = "Bob and Weave"
	desc = "Tail Hook now pushes humans away instead of pulling them in. It deals 2/4/6 additional damage."
	/// For each structure, the amount to increase the damage that Tail Hook deals by.
	var/damage_per_structure = 2

/datum/mutation_upgrade/spur/bob_and_weave/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Tail Hook now pushes humans away instead of pulling them in. It deals [get_damage(new_amount)] additional damage."

/datum/mutation_upgrade/spur/bob_and_weave/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/tail_hook/hook_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/tail_hook]
	if(!hook_ability)
		return
	hook_ability.pull_distance *= -1 // Makes it negative (pushes them away).

/datum/mutation_upgrade/spur/bob_and_weave/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/tail_hook/hook_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/tail_hook]
	if(!hook_ability)
		return
	hook_ability.pull_distance *= -1 // Makes it positive (pushes them in).

/datum/mutation_upgrade/spur/bob_and_weave/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/tail_hook/hook_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/tail_hook]
	if(!hook_ability)
		return
	hook_ability.bonus_damage += get_damage(new_amount - previous_amount)

/// Returns the amount to increase the damage that Tail Hook deals by.
/datum/mutation_upgrade/spur/bob_and_weave/proc/get_damage(structure_count)
	return damage_per_structure * structure_count

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/eb_and_flow
	name = "Eb and Flow"
	desc = "Dodge now lets you walk over structures such as tables and window frames. It now costs 2/1.75/1.5x of its original cost."
	/// For the first structure, the multiplier to add as Dodge's initial ability cost to the ability.
	var/cost_multiplier_initial = 1.25
	/// For each structure, the multiplier to add as Dodge's initial ability cost to the ability.
	var/cost_multiplier_per_structure = -0.25

/datum/mutation_upgrade/veil/eb_and_flow/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Dodge now lets you walk over structures such as tables and window frames. It now costs [1 + get_multiplier(new_amount)]x of its original cost."

/datum/mutation_upgrade/veil/eb_and_flow/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/dodge/dodge_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/dodge]
	if(!dodge_ability)
		return
	if(dodge_ability.particle_holder) // This means it is active.
		dodge_ability.xeno_owner.allow_pass_flags |= PASS_LOW_STRUCTURE
		dodge_ability.xeno_owner.add_pass_flags(PASS_LOW_STRUCTURE, dodge_ability.type)
	dodge_ability.dodge_pass_flags |= PASS_LOW_STRUCTURE
	dodge_ability.ability_cost += initial(dodge_ability.ability_cost) * get_multiplier(0)

/datum/mutation_upgrade/veil/eb_and_flow/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/xeno_action/dodge/dodge_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/dodge]
	if(!dodge_ability)
		return
	if(dodge_ability.particle_holder) // This means it is active.
		dodge_ability.xeno_owner.allow_pass_flags &= ~(PASS_LOW_STRUCTURE)
		dodge_ability.xeno_owner.remove_pass_flags(PASS_LOW_STRUCTURE, dodge_ability.type)
	dodge_ability.dodge_pass_flags &= ~(PASS_LOW_STRUCTURE)
	dodge_ability.ability_cost -= initial(dodge_ability.ability_cost) * get_multiplier(0)

/datum/mutation_upgrade/veil/eb_and_flow/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/dodge/dodge_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/dodge]
	if(!dodge_ability)
		return
	dodge_ability.ability_cost += initial(dodge_ability.ability_cost) * get_multiplier(new_amount - previous_amount, FALSE)

/// Returns the multiplier to add as Dodge's initial ability cost to the ability.
/datum/mutation_upgrade/veil/eb_and_flow/proc/get_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? cost_multiplier_initial : 0) + (cost_multiplier_per_structure * structure_count)
