//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/healing_jab
	name = "Healing Jab"
	desc = "The effects of Jab from Conqueror's Will is replaced. It will instead heal you for 5/10/15% of your maximum health."
	/// For each structure, the multiplier of the owner's maximium health that Jab from Conqueror's Will will heal.
	var/percentage_per_structure = 0.05

/datum/mutation_upgrade/shell/healing_jab/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "The effects of Jab from Conqueror's Will is replaced. It will instead heal you for [PERCENT(get_percentage(new_amount))]% of your maximum health."

/datum/mutation_upgrade/shell/healing_jab/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/conqueror_will/will_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/conqueror_will]
	if(!will_ability)
		return
	will_ability.jab_damage_multiplier = 0

/datum/mutation_upgrade/shell/healing_jab/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/conqueror_will/will_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/conqueror_will]
	if(!will_ability)
		return
	will_ability.jab_damage_multiplier = initial(will_ability.jab_damage_multiplier)

/datum/mutation_upgrade/shell/healing_jab/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/conqueror_will/will_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/conqueror_will]
	if(!will_ability)
		return
	will_ability.jab_heal_percentage += get_percentage(new_amount - previous_amount)

/// Returns the percentage of the owner's maximium health that Jab from Conqueror's Will will heal.
/datum/mutation_upgrade/shell/healing_jab/proc/get_percentage(structure_count)
	return percentage_per_structure * structure_count

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/telefrag
	name = "Telefrag"
	desc = "Domination's radius is reduced by 1, but knocked down for 0.5/0.8/1.1 seconds longer."
	/// For the first structure, the amount to increase Domination's radius by.
	var/radius_initial = -1
	/// For the first structure, the amount of deciseconds to add to Domination's knockdown duration.
	var/duration_initial = 0.2 SECONDS
	/// For each structure, the additional amount of deciseconds to add to Domination's knockdown duration.
	var/duration_per_structure = 0.3 SECONDS

/datum/mutation_upgrade/spur/telefrag/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Domination's radius is reduced by [-radius_initial], but knocked down for [get_duration(new_amount) / 10] seconds longer."

/datum/mutation_upgrade/spur/telefrag/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/conqueror_domination/domination_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/conqueror_domination]
	if(!domination_ability)
		return
	domination_ability.radius += radius_initial
	domination_ability.knockdown_duration += get_duration(0)

/datum/mutation_upgrade/spur/telefrag/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/conqueror_domination/domination_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/conqueror_domination]
	if(!domination_ability)
		return
	domination_ability.radius -= radius_initial
	domination_ability.knockdown_duration -= get_duration(0)

/datum/mutation_upgrade/spur/telefrag/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/conqueror_domination/domination_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/conqueror_domination]
	if(!domination_ability)
		return
	domination_ability.knockdown_duration += get_duration(new_amount - previous_amount, FALSE)

/// Returns the amount of deciseconds to add to Domination's knockdown duration.
/datum/mutation_upgrade/spur/telefrag/proc/get_duration(structure_count, include_initial = TRUE)
	return (include_initial ? duration_initial : 0) + (duration_per_structure * structure_count)

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/dasher
	name = "Dasher"
	desc = "Dash can be activated at will as long it has charges. It can store up to 2/3/4 charges which are given at the rate of 200% of the ability's original cooldown."
	/// For the first structure, the multiplier of Dash's initial cooldown in which a charge will be restored.
	var/cooldown_multiplier_initial = 2
	/// For each structure, the amount of charges to add to Dash.
	var/charges_per_structure = 1

// /datum/action/ability/xeno_action/conqueror_dash
/datum/mutation_upgrade/veil/dasher/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Dash can be activated at will as long it has charges. It can store up to [get_dashes(new_amount)] charges which are given at the rate of [PERCENT(cooldown_multiplier_initial)]% of the ability's original cooldown."

/datum/mutation_upgrade/veil/dasher/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/conqueror_dash/dash_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/conqueror_dash]
	if(!dash_ability)
		return
	dash_ability.cooldown_duration = 0.1 SECONDS

/datum/mutation_upgrade/veil/dasher/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/xeno_action/conqueror_dash/dash_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/conqueror_dash]
	if(!dash_ability)
		return
	dash_ability.cooldown_duration = initial(dash_ability.cooldown_duration)

/datum/mutation_upgrade/veil/dasher/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/conqueror_dash/dash_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/conqueror_dash]
	if(!dash_ability)
		return
	dash_ability.set_maximum_charges(get_dashes(new_amount), initial(dash_ability.cooldown_duration) * (cooldown_multiplier_initial))

/// Returns the amount of additional uses that Dash should get.
/datum/mutation_upgrade/veil/dasher/proc/get_dashes(structure_count)
	return 1 + (charges_per_structure * structure_count)
