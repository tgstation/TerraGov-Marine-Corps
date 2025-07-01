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
	return "The effects of Jab from Conqueror's Will is replaced. It will instead heal you for [get_heal_percentage(new_amount)]% of your maximum health."

/// Returns the percentage of maximum health that Jab should heal.
/datum/mutation_upgrade/shell/healing_jab/proc/get_heal_percentage(structure_count)
	return heal_percentage_per_structure * structure_count

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/telefrag
	name = "Telefrag"
	desc = "Domination's radius is reduced by 1, but stuns for 0.5/0.8/1.1s longer."
	/// The amount to increase Domination's radius by.
	var/radius_increase = -1
	/// For the first structure, the amount of deciseconds to add to Domination's stun duration.
	var/stun_duration_initial = 0.2 SECONDS
	/// For each structure, the additional amount of deciseconds to add to Domination's stun duration.
	var/stun_duration_per_structure = 0.3 SECONDS

/datum/mutation_upgrade/spur/telefrag/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Domination's radius is reduced by [-radius_increase], but stuns for [get_stun_duration(new_amount)]s longer."

/// Returns the amount of deciseconds that should be added to Domination's stun duration.
/datum/mutation_upgrade/spur/telefrag/proc/get_stun_duration(structure_count, include_initial = TRUE)
	return (include_initial ? stun_duration_initial : 0) + (stun_duration_per_structure * structure_count)

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/dasher
	name = "Dasher"
	desc = "Dash's cooldown is set to 200% of its original cooldown, but can store up to 2/3/4 charges."
	/// The amount to multiply Dash's cooldown by.
	var/cooldown_multiplier = 2
	/// For each structure, the additional range that Nightfall will get.
	var/charges_per_structure = 1

/datum/mutation_upgrade/veil/dasher/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Dash's cooldown is set to [PERCENT(cooldown_multiplier)]% of its original cooldown, but can store up to [1 + get_dashes(new_amount)] charges."

/// Returns the amount of additional uses that Dash should get.
/datum/mutation_upgrade/veil/dasher/proc/get_dashes(structure_count)
	return charges_per_structure * structure_count
