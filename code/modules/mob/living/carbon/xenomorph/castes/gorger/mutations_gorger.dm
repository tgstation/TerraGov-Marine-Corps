//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/unmoving_link
	name = "Unmoving Link"
	desc = "While Psychic Link is active, you gain maximum movement resistance and gain 5/15/25 armor."
	/// For the first structure, the amount of all soft armor to increase by.
	var/armor_increase_initial = -5
	/// For each structure, the amount of additional all soft armor to increase by.
	var/armor_increase_per_structure = 10

/datum/mutation_upgrade/shell/unmoving_link/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "While Psychic Link is active, you gain maximum movement resistance and gain [armor_increase_initial + (armor_increase_per_structure * new_amount)] armor."

/datum/mutation_upgrade/shell/unmoving_link/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/psychic_link/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_link]
	if(!ability)
		return FALSE
	ability.armor_amount += armor_increase_initial
	ability.move_resist = MOVE_FORCE_OVERPOWERING
	return ..()

/datum/mutation_upgrade/shell/unmoving_link/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/psychic_link/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_link]
	if(!ability)
		return FALSE
	ability.armor_amount -= armor_increase_initial
	ability.move_resist = initial(ability.move_resist)
	return ..()

/datum/mutation_upgrade/shell/unmoving_link/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/psychic_link/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_link]
	if(!ability)
		return FALSE
	ability.armor_amount += (new_amount - previous_amount) * armor_increase_per_structure
	ability.set_move_resist(ability.move_resist)
	ability.set_armor(ability.armor_amount)

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/necrotic_link
	name = "Necrotic Link"
	desc = "Psychic Link no longer forces you to rest. While it is active, all health restoration are only 30/40/50% effective."
	/// For the first structure, the amount to multiply all healing by.
	var/health_restoration_multiplier_initial = 0.2
	/// For each structure, the additional amount to multiply all healing by.
	var/health_restoration_multiplier_per_structure = 0.1

/datum/mutation_upgrade/spur/necrotic_link/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Psychic Link no longer forces you to rest. While it is active, all health restoration are only [PERCENT(health_restoration_multiplier_initial + (health_restoration_multiplier_per_structure * new_amount))] effective."

/datum/mutation_upgrade/spur/necrotic_link/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/psychic_link/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_link]
	if(!ability)
		return FALSE
	ability.required_to_rest = FALSE
	ability.set_health_restoration_multiplier(ability.health_restoration_multiplier + health_restoration_multiplier_initial)
	return ..()

/datum/mutation_upgrade/spur/necrotic_link/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/psychic_link/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_link]
	if(!ability)
		return FALSE
	ability.required_to_rest = initial(ability.required_to_rest)
	ability.set_health_restoration_multiplier(ability.health_restoration_multiplier - health_restoration_multiplier_initial)
	return ..()

/datum/mutation_upgrade/spur/necrotic_link/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/psychic_link/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_link]
	if(!ability)
		return FALSE
	ability.set_health_restoration_multiplier(ability.health_restoration_multiplier + ((new_amount - previous_amount) * health_restoration_multiplier_per_structure))

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/burst_healing
	name = "Burst Healing"
	desc = "Transfusion now heals an additional 7.5/15/22.5% maximum health of your target, but requires twice as much plasma."
	/// For each structure, the additional percentage to increase Transfusion's healing by.
	var/transfusion_percentage_increase_per_structure = 0.075

/datum/mutation_upgrade/veil/burst_healing/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/transfusion/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/transfusion]
	if(!ability)
		return FALSE
	ability.ability_cost += initial(ability.ability_cost)
	return ..()

/datum/mutation_upgrade/veil/burst_healing/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/transfusion/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/transfusion]
	if(!ability)
		return FALSE
	ability.ability_cost -= initial(ability.ability_cost)
	return ..()

/datum/mutation_upgrade/veil/burst_healing/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/transfusion/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/transfusion]
	if(!ability)
		return FALSE
	ability.percentage_to_heal += (new_amount - previous_amount) * transfusion_percentage_increase_per_structure
