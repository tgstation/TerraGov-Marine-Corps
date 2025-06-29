//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/self_explosion
	name = "Self Explosion"
	desc = "Toss Grenade can target yourself. Targeting yourself will toss the grenade under you and reduce the detonation time by 0.5/0.75/1 seconds. The final detonation time can never go under 0.5 seconds."
	/// For the first structure, the amount of deciseconds to increase the detonation time by.
	var/detonation_initial = -0.25 SECONDS
	/// For each structure, the additional amount of deciseconds to increase the detonation time by.
	var/detonation_per_structure = -0.25 SECONDS

/datum/mutation_upgrade/shell/self_explosion/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Toss Grenade can target yourself. Targeting yourself will toss the grenade under you and reduce the detonation time by [(detonation_initial + (detonation_per_structure * new_amount))/-10] seconds. The final detonation time can never go under 0.5 seconds."

/datum/mutation_upgrade/shell/self_explosion/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/toss_grenade/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/toss_grenade]
	if(!ability)
		return FALSE
	ability.additional_self_detonation_time += detonation_initial
	return ..()

/datum/mutation_upgrade/shell/self_explosion/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/toss_grenade/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/toss_grenade]
	if(!ability)
		return FALSE
	ability.additional_self_detonation_time -= detonation_initial
	return ..()

/datum/mutation_upgrade/shell/self_explosion/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/toss_grenade/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/toss_grenade]
	if(!ability)
		return FALSE
	ability.additional_self_detonation_time += (new_amount - previous_amount) * detonation_per_structure

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/blood_grenades
	name = "Blood Grenades"
	desc = "Toss Grenade will deal damage equal to 20/17.5/15% of your maximum health and allow you to throw a non-healing grenade if you had none."
	/// For the first structure, the percentage of maximum health to heal by.
	var/health_percentage_initial = -0.225
	/// For each structure, the additional percentage of maximum health to heal by.
	var/health_percentage_per_structure = 0.025

/datum/mutation_upgrade/spur/blood_grenades/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Toss Grenade will deal damage equal to [(health_percentage_initial + (health_percentage_per_structure * new_amount)) * -100]% of your maximum health and allow you to throw a non-healing grenade if you had none."

/datum/mutation_upgrade/spur/blood_grenades/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/toss_grenade/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/toss_grenade]
	if(!ability)
		return FALSE
	ability.max_health_per_grenade += health_percentage_initial
	return ..()

/datum/mutation_upgrade/spur/blood_grenades/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/toss_grenade/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/toss_grenade]
	if(!ability)
		return FALSE
	ability.max_health_per_grenade -= health_percentage_initial
	return ..()

/datum/mutation_upgrade/spur/blood_grenades/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/toss_grenade/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/toss_grenade]
	if(!ability)
		return FALSE
	ability.max_health_per_grenade += (new_amount - previous_amount) * health_percentage_per_structure

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/repurposed_capacity
	name = "Repurposed Capacity"
	desc = "Toss Grenade stores 1/2/3 less grenades, but recharges a grenade 2/4/6s faster."
	/// For each structure, the additional amount to increase grenade capacity by.
	var/capacity_per_structure = -1
	/// For each structure, the additional amount to increase the cooldown by.
	var/recharge_per_structure = -2 SECONDS

/datum/mutation_upgrade/veil/repurposed_capacity/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Toss Grenade stores [capacity_per_structure * new_amount * -1] less grenades, but recharges a grenade [recharge_per_structure  * new_amount * -1] seconds faster."

/datum/mutation_upgrade/veil/repurposed_capacity/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/toss_grenade/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/toss_grenade]
	if(!ability)
		return FALSE
	ability.grenade_cooldown += (new_amount - previous_amount) * recharge_per_structure
	ability.max_grenades += (new_amount - previous_amount) * capacity_per_structure
	ability.current_grenades = min(ability.current_grenades, ability.max_grenades)
