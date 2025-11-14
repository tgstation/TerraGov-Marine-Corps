//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/flesh_for_life
	name = "Flesh For Life"
	desc = "If damage taken would put you into critical, lose 1.5/1.25/1x amount of plasma instead."
	/// For the first structure, the amount of plasma to consume for each point of damage.
	var/plasma_per_damage_initial = 1.75
	/// For each structure, the amount of plasma to consume for each point of damage.
	var/plasma_per_damage_per_structure = -0.25

/datum/mutation_upgrade/shell/flesh_for_life/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "If damage taken would put you into critical, lose [get_plasma_per_damage(new_amount)]x amount of plasma instead."

/datum/mutation_upgrade/shell/flesh_for_life/on_mutation_enabled()
	RegisterSignals(xenomorph_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE), PROC_REF(on_damage))
	return ..()

/datum/mutation_upgrade/shell/flesh_for_life/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE))
	return ..()

/// If they receive damage that would put them into critical, subtract damage as long they have plasma.
/datum/mutation_upgrade/shell/flesh_for_life/proc/on_damage(datum/source, amount, list/amount_mod)
	SIGNAL_HANDLER
	if(xenomorph_owner.stat == DEAD)
		return
	var/damage_until_threshold = xenomorph_owner.health - xenomorph_owner.get_crit_threshold()
	if(damage_until_threshold > amount)
		return
	var/plasma_per_damage = get_plasma_per_damage(get_total_structures())
	var/damage_reduction = min(amount, xenomorph_owner.plasma_stored / plasma_per_damage)
	xenomorph_owner.use_plasma(ROUND_UP(damage_reduction * plasma_per_damage))
	amount_mod += damage_reduction

/// Returns the amount of plasma to consume for each point of damage.
/datum/mutation_upgrade/shell/flesh_for_life/proc/get_plasma_per_damage(structure_count)
	return plasma_per_damage_initial + (plasma_per_damage_per_structure * structure_count)

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/suffocating_presence
	name = "Suffocating Presence"
	desc = "Dreadful Presence will inflict a temporary effect that deals 4/6/8 stamina damage every second instead."
	/// For the first structure, the amount of stamina damage that Dreadful Presence should be doing per second.
	var/damage_initial = 2
	/// For each structure, the amount of stamina damage that Dreadful Presence should be doing per second.
	var/damage_per_structure = 2

/datum/mutation_upgrade/spur/suffocating_presence/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Dreadful Presence will inflict a temporary effect that deals [get_damage(new_amount)] stamina damage every second instead."

/datum/mutation_upgrade/spur/suffocating_presence/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/dreadful_presence/dreadful_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/dreadful_presence]
	if(!dreadful_ability)
		return
	dreadful_ability.stamina_draining += get_damage(0)

/datum/mutation_upgrade/spur/suffocating_presence/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/xeno_action/dreadful_presence/dreadful_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/dreadful_presence]
	if(!dreadful_ability)
		return
	dreadful_ability.stamina_draining -= get_damage(0)

/datum/mutation_upgrade/spur/suffocating_presence/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/dreadful_presence/dreadful_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/dreadful_presence]
	if(!dreadful_ability)
		return
	dreadful_ability.stamina_draining += get_damage(new_amount - previous_amount, FALSE)

/// Returns the amount of stamina damage that Dreadful Presence should be doing per second.
/datum/mutation_upgrade/spur/suffocating_presence/proc/get_damage(structure_count, include_initial = TRUE)
	return (include_initial ? damage_initial : 0) + (damage_per_structure * structure_count)

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/shifting_costs
	name = "Shifting Costs"
	desc = "Stitch Puppet's cost is 20% of its original cost. Bestow Blessing costs 40/30/20% more."
	/// For the first structure, the multiplier to add as Stitch Puppet's initial ability cost to its current cost.
	var/puppet_multiplier_initial = -0.8
	/// For the first structure, the multiplier to add as Bestow Blessings' initial ability cost to its current cost.
	var/blessings_multiplier_initial = 0.5
	/// For each structure, the multiplier to add as Bestow Blessings' initial ability cost to its current cost.
	var/blessings_multiplier_per_structure = -0.1

/datum/mutation_upgrade/veil/shifting_costs/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Stitch Puppet's cost is [PERCENT(1 + puppet_multiplier_initial)]% of its original cost. Bestow Blessings' cost is [PERCENT(1 + get_blessings_multiplier(new_amount))]% of its original cost."

/datum/mutation_upgrade/veil/shifting_costs/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/puppet/puppet_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/puppet]
	if(!puppet_ability)
		return
	var/datum/action/ability/activable/xeno/puppet_blessings/blessings_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/puppet_blessings]
	if(!blessings_ability)
		return
	puppet_ability.ability_cost += initial(puppet_ability.ability_cost) * puppet_multiplier_initial
	blessings_ability.ability_cost += initial(blessings_ability.ability_cost) * get_blessings_multiplier(0)

/datum/mutation_upgrade/veil/shifting_costs/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/puppet/puppet_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/puppet]
	if(!puppet_ability)
		return
	var/datum/action/ability/activable/xeno/puppet_blessings/blessings_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/puppet_blessings]
	if(!blessings_ability)
		return
	puppet_ability.ability_cost -= initial(puppet_ability.ability_cost) * puppet_multiplier_initial
	blessings_ability.ability_cost -= initial(blessings_ability.ability_cost) * get_blessings_multiplier(0)

/datum/mutation_upgrade/veil/shifting_costs/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/puppet_blessings/blessings_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/puppet_blessings]
	if(!blessings_ability)
		return
	blessings_ability.ability_cost += initial(blessings_ability.ability_cost) * get_blessings_multiplier(new_amount - previous_amount, FALSE)

/// Returns the multiplier to add as Bestow Blessings' initial ability cost to its current cost.
/datum/mutation_upgrade/veil/shifting_costs/proc/get_blessings_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? blessings_multiplier_initial : 0) + (blessings_multiplier_initial * structure_count)
