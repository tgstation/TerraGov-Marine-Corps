//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/flesh_for_life
	name = "Flesh For Life"
	desc = "If damage taken would put you into critical, lose 1.5/1.25/1x amount of plasma instead."
	/// For the first structure, the amount of plasma consumed for each point of damage.
	var/damage_to_plasma_initial = 1.75
	/// For each structure, the additional amount of plasma consumed for each point of damage.
	var/damage_to_plasma_per_structure = -0.25

/datum/mutation_upgrade/shell/flesh_for_life/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "If damage taken would put you into critical, lose [damage_to_plasma_initial + (damage_to_plasma_per_structure * new_amount)]x amount of plasma instead."

/datum/mutation_upgrade/shell/flesh_for_life/on_mutation_enabled()
	RegisterSignals(xenomorph_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE), PROC_REF(on_damage))
	return ..()

/datum/mutation_upgrade/shell/flesh_for_life/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE))
	return ..()

/// If they are awake and receive damage that would put them into critical, subtract damage as long they have plasma.
/datum/mutation_upgrade/shell/flesh_for_life/proc/on_damage(datum/source, amount, list/amount_mod)
	SIGNAL_HANDLER
	if(!xenomorph_owner.stat)
		return
	var/damage_until_threshold = xenomorph_owner.health - xenomorph_owner.health_threshold_crit
	if(damage_until_threshold > amount)
		return
	var/plasma_multiplier = damage_to_plasma_initial + (damage_to_plasma_per_structure * get_total_structures())
	var/damage_reduction = min(amount, xenomorph_owner.plasma_stored / plasma_multiplier)
	xenomorph_owner.use_plasma(ROUND_UP(damage_reduction * plasma_multiplier))
	amount_mod += damage_reduction

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/suffocating_presence
	name = "Suffocating Presence"
	desc = "Dreadful Presence will inflict a temporary effect that deals 4/6/8 stamina damage every second instead."
	/// For the first structure, the amount of stamina damage to deal per second.
	var/stamina_damage_initial = 2
	/// For each structure, the additional amount of stamina damage to deal per second.
	var/stamina_damage_per_structure = 2

/datum/mutation_upgrade/spur/suffocating_presence/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Dreadful Presence will inflict a temporary effect that deals [stamina_damage_initial + (stamina_damage_per_structure * new_amount)] stamina damage every tick instead."

/datum/mutation_upgrade/spur/suffocating_presence/on_mutation_enabled()
	var/datum/action/ability/xeno_action/dreadful_presence/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/dreadful_presence]
	if(!ability)
		return FALSE
	ability.stamina_dps += stamina_damage_initial
	return ..()

/datum/mutation_upgrade/spur/suffocating_presence/on_mutation_disabled()
	var/datum/action/ability/xeno_action/dreadful_presence/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/dreadful_presence]
	if(!ability)
		return FALSE
	ability.stamina_dps -= stamina_damage_initial
	return ..()

/datum/mutation_upgrade/spur/suffocating_presence/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/dreadful_presence/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/dreadful_presence]
	if(!ability)
		return FALSE
	ability.stamina_dps += (new_amount - previous_amount) * stamina_damage_per_structure

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/shifting_costs
	name = "Shifting Costs"
	desc = "Stitch Puppet costs 80% less. Bestow Blessing costs 40/30/20% more."
	/// Adds Snitch Puppet's plasma cost by this multiplier of the initial value.
	var/snitch_puppet_add_multiplier = -0.8
	/// For the first structure, adds this multiplier of the initial cost of Bestow Blessing to it.
	var/bestow_blessing_add_multiplier_initial = 0.5
	/// For each structure, adds this additional multiplier of the initial cost of Bestow Blessing to it.
	var/bestow_blessing_add_multiplier_per_structure = -0.1

/datum/mutation_upgrade/veil/shifting_costs/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Stitch Puppet costs [abs(snitch_puppet_add_multiplier) * 100]% less. Bestow Blessing costs [(bestow_blessing_add_multiplier_initial + (bestow_blessing_add_multiplier_per_structure * new_amount)) * 100]% more."

/datum/mutation_upgrade/veil/shifting_costs/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/puppet/puppet_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/puppet]
	if(!puppet_ability)
		return FALSE
	var/datum/action/ability/activable/xeno/puppet_blessings/blessings_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/puppet_blessings]
	if(!blessings_ability)
		return FALSE
	puppet_ability.ability_cost += initial(puppet_ability.ability_cost) * snitch_puppet_add_multiplier
	blessings_ability.ability_cost += initial(blessings_ability.ability_cost) * bestow_blessing_add_multiplier_initial
	return ..()

/datum/mutation_upgrade/veil/shifting_costs/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/puppet/puppet_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/puppet]
	if(!puppet_ability)
		return FALSE
	var/datum/action/ability/activable/xeno/puppet_blessings/blessings_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/puppet_blessings]
	if(!blessings_ability)
		return FALSE
	puppet_ability.ability_cost -= initial(puppet_ability.ability_cost) * snitch_puppet_add_multiplier
	blessings_ability.ability_cost -= initial(blessings_ability.ability_cost) * bestow_blessing_add_multiplier_initial
	return ..()

/datum/mutation_upgrade/veil/shifting_costs/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/puppet_blessings/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/puppet_blessings]
	if(!ability)
		return FALSE
	ability.ability_cost += initial(ability.ability_cost) * (new_amount - previous_amount) * bestow_blessing_add_multiplier_per_structure
