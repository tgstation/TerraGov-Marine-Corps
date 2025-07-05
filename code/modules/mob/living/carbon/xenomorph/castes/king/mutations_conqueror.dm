//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/healing_jab
	name = "Healing Jab"
	desc = "The effects of Jab from Conqueror's Will is replaced. It will instead heal you for 5/10/15% of your maximum health."
	/// For each structure, the additional percentage amount of max health to heal when using Jab.
	var/heal_percentage_per_structure = 0.05

/datum/mutation_upgrade/shell/healing_jab/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "The effects of Jab from Conqueror's Will is replaced. It will instead heal you for [PERCENT(get_heal_percentage(new_amount))]% of your maximum health."

/datum/mutation_upgrade/shell/healing_jab/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/conqueror_will/conqueror_will = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/conqueror_will]
	if(!conqueror_will)
		return FALSE
	conqueror_will.jab_damage_multiplier -= initial(conqueror_will.jab_damage_multiplier)
	return ..()

/datum/mutation_upgrade/shell/healing_jab/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/conqueror_will/conqueror_will = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/conqueror_will]
	if(!conqueror_will)
		return FALSE
	conqueror_will.jab_damage_multiplier += initial(conqueror_will.jab_damage_multiplier)
	return ..()

/datum/mutation_upgrade/shell/healing_jab/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/conqueror_will/conqueror_will = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/conqueror_will]
	if(!conqueror_will)
		return FALSE
	conqueror_will.jab_heal_percentage += get_heal_percentage(new_amount - previous_amount)

/// Returns the percentage of maximum health that Jab should heal.
/datum/mutation_upgrade/shell/healing_jab/proc/get_heal_percentage(structure_count)
	return heal_percentage_per_structure * structure_count

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/telefrag
	name = "Telefrag"
	desc = "Domination's radius is reduced by 1, but knocked down for 0.5/0.8/1.1s longer."
	/// The amount to increase Domination's radius by.
	var/radius_increase = -1
	/// For the first structure, the amount of deciseconds to add to Domination's stun duration.
	var/knockdown_duration_initial = 0.2 SECONDS
	/// For each structure, the additional amount of deciseconds to add to Domination's stun duration.
	var/knockdown_duration_per_structure = 0.3 SECONDS

/datum/mutation_upgrade/spur/telefrag/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Domination's radius is reduced by [-radius_increase], but knocked down for [get_knockdown_duration(new_amount)]s longer."

/datum/mutation_upgrade/spur/telefrag/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/conqueror_domination/conqueror_domination = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/conqueror_domination]
	if(!conqueror_domination)
		return FALSE
	conqueror_domination.radius += radius_increase
	conqueror_domination.knockdown_duration += get_knockdown_duration(0)
	return ..()

/datum/mutation_upgrade/spur/telefrag/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/conqueror_domination/conqueror_domination = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/conqueror_domination]
	if(!conqueror_domination)
		return FALSE
	conqueror_domination.radius -= radius_increase
	conqueror_domination.knockdown_duration -= get_knockdown_duration(0)
	return ..()

/datum/mutation_upgrade/spur/telefrag/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/conqueror_domination/conqueror_domination = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/conqueror_domination]
	if(!conqueror_domination)
		return FALSE
	conqueror_domination.knockdown_duration += get_knockdown_duration(new_amount - previous_amount, FALSE)

/// Returns the amount of deciseconds that should be added to Domination's knockdown duration.
/datum/mutation_upgrade/spur/telefrag/proc/get_knockdown_duration(structure_count, include_initial = TRUE)
	return (include_initial ? knockdown_duration_initial : 0) + (knockdown_duration_per_structure * structure_count)

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/dasher
	name = "Dasher"
	desc = "Dash can be activated at will as long it has charges. It can store up to 2/3/4 charges which are given at the rate of 200% of the ability's original cooldown."
	/// The amount to multiply Dash's cooldown by.
	var/cooldown_multiplier = 2
	/// For each structure, the additional range that Nightfall will get.
	var/charges_per_structure = 1

// /datum/action/ability/xeno_action/conqueror_dash
/datum/mutation_upgrade/veil/dasher/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Dash can be activated at will as long it has charges. It can store up to [get_dashes(new_amount)] charges which are given at the rate of [PERCENT(cooldown_multiplier)]% of the ability's original cooldown."

/datum/mutation_upgrade/veil/dasher/on_mutation_enabled()
	var/datum/action/ability/xeno_action/conqueror_dash/conqueror_dash = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/conqueror_dash]
	if(!conqueror_dash)
		return FALSE
	conqueror_dash.cooldown_duration -= (initial(conqueror_dash.cooldown_duration) - 0.1 SECONDS)
	return ..()

/datum/mutation_upgrade/veil/dasher/on_mutation_disabled()
	var/datum/action/ability/xeno_action/conqueror_dash/conqueror_dash = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/conqueror_dash]
	if(!conqueror_dash)
		return FALSE
	conqueror_dash.cooldown_duration += (initial(conqueror_dash.cooldown_duration) - 0.1 SECONDS)
	return ..()

/datum/mutation_upgrade/veil/dasher/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/conqueror_dash/conqueror_dash = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/conqueror_dash]
	if(!conqueror_dash)
		return FALSE
	conqueror_dash.set_maximum_charges(get_dashes(new_amount), initial(conqueror_dash.cooldown_duration) * cooldown_multiplier)

/// Returns the amount of additional uses that Dash should get.
/datum/mutation_upgrade/veil/dasher/proc/get_dashes(structure_count, include_initial = TRUE)
	return (include_initial ? 1 : 0) + (charges_per_structure * structure_count)
