//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/self_explosion
	name = "Self Explosion"
	desc = "Toss Grenade can target yourself. Targeting yourself will toss the grenade under you and reduce the detonation time by 0.5/0.75/1 seconds. The resulting detonation time can never go under 0.5 seconds."
	/// For the first structure, the amount of deciseconds to increase the detonation time by.
	var/duration_initial = -0.25 SECONDS
	/// For each structure, the amount of deciseconds to increase the detonation time by.
	var/duration_per_structure = -0.25 SECONDS

/datum/mutation_upgrade/shell/self_explosion/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Toss Grenade can target yourself. Targeting yourself will toss the grenade under you and reduce the detonation time by [-get_duration(new_amount) * 0.1] seconds. The resulting detonation time can never go under 0.5 seconds."

/datum/mutation_upgrade/shell/self_explosion/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/toss_grenade/grenade_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/toss_grenade]
	if(!grenade_ability)
		return
	grenade_ability.use_state_flags |= ABILITY_TARGET_SELF
	grenade_ability.bonus_self_detonation_time += get_duration(0)
	return ..()

/datum/mutation_upgrade/shell/self_explosion/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/toss_grenade/grenade_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/toss_grenade]
	if(!grenade_ability)
		return
	grenade_ability.use_state_flags &= ~ABILITY_TARGET_SELF
	grenade_ability.bonus_self_detonation_time -= get_duration(0)
	return ..()

/datum/mutation_upgrade/shell/self_explosion/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/toss_grenade/grenade_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/toss_grenade]
	if(!grenade_ability)
		return
	grenade_ability.bonus_self_detonation_time += get_duration(new_amount - previous_amount, FALSE)

/// Returns the amount of deciseconds that the detonation time will be increased by if Toss Grenade self-targetted.
/datum/mutation_upgrade/shell/self_explosion/proc/get_duration(structure_count, include_initial = TRUE)
	return (include_initial ? duration_initial : 0) + (duration_per_structure * structure_count)

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/blood_grenades
	name = "Blood Grenades"
	desc = "Toss Grenade will deal damage equal to 20/17.5/15% of your maximum health and allow you to throw a non-healing grenade if you had none."
	/// For the first structure, the percentage of maximum health to lose.
	var/percentage_initial = 0.225
	/// For each structure, the additional percentage of maximum health to lose.
	var/percentage_per_structure = -0.025

/datum/mutation_upgrade/spur/blood_grenades/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Toss Grenade will deal damage equal to [PERCENT(get_percentage(new_amount))]% of your maximum health and allow you to throw a non-healing grenade if you had none."

/datum/mutation_upgrade/spur/blood_grenades/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/toss_grenade/grenade_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/toss_grenade]
	if(!grenade_ability)
		return
	grenade_ability.health_loss_percentage_per_grenade += get_percentage(0)
	return ..()

/datum/mutation_upgrade/spur/blood_grenades/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/toss_grenade/grenade_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/toss_grenade]
	if(!grenade_ability)
		return
	grenade_ability.health_loss_percentage_per_grenade -= get_percentage(0)
	return ..()

/datum/mutation_upgrade/spur/blood_grenades/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/toss_grenade/grenade_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/toss_grenade]
	if(!grenade_ability)
		return
	grenade_ability.health_loss_percentage_per_grenade += get_percentage(new_amount - previous_amount, FALSE)

/// Returns the percentage of maximum health that will be dealt in order to gain a grenade charge.
/datum/mutation_upgrade/spur/blood_grenades/proc/get_percentage(structure_count, include_initial = TRUE)
	return (include_initial ? percentage_initial : 0) + (percentage_per_structure * structure_count)

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/repurposed_capacity
	name = "Repurposed Capacity"
	desc = "Toss Grenade stores 1/2/3 less grenades, but recharges a grenade 2/4/6 seconds faster."
	/// For each structure, the amount to increase Toss Grenade's maximum grenade capacity by.
	var/capacity_per_structure = -1
	/// For each structure, the amount of deciseconds to increase Toss Grenade's recharge cooldown by.
	var/recharge_per_structure = -2 SECONDS

/datum/mutation_upgrade/veil/repurposed_capacity/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Toss Grenade stores [-get_capacity(new_amount)] less grenades, but recharges a grenade [-get_recharge(new_amount) * 0.1] seconds faster."

/datum/mutation_upgrade/veil/repurposed_capacity/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/toss_grenade/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/toss_grenade]
	if(!ability)
		return
	ability.max_grenades += get_capacity(new_amount - previous_amount)
	ability.grenade_cooldown += get_recharge(new_amount - previous_amount)
	ability.current_grenades = min(ability.current_grenades, ability.max_grenades)

/// Returns the amount to increase Toss Grenade's maximum grenade capacity by.
/datum/mutation_upgrade/veil/repurposed_capacity/proc/get_capacity(structure_count)
	return capacity_per_structure * structure_count

/// Returns the amount of deciseconds to increase Toss Grenade's recharge cooldown by.
/datum/mutation_upgrade/veil/repurposed_capacity/proc/get_recharge(structure_count)
	return recharge_per_structure * structure_count
