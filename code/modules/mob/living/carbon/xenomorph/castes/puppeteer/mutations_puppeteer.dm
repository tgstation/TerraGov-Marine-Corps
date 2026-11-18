//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/flesh_for_life
	name = "Flesh For Life"
	desc = "If damage taken would put you into critical, lose 1.25x amount of plasma instead."
	/// The amount of plasma to consume for each point of damage.
	var/plasma_per_damage = 1.25

/datum/mutation_upgrade/shell/flesh_for_life/on_mutation_enabled()
	RegisterSignals(xenomorph_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE), PROC_REF(on_damage))

/datum/mutation_upgrade/shell/flesh_for_life/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE))

/// If they receive damage that would put them into critical, subtract damage as long they have plasma.
/datum/mutation_upgrade/shell/flesh_for_life/proc/on_damage(datum/source, amount, list/amount_mod)
	SIGNAL_HANDLER
	if(xenomorph_owner.stat == DEAD)
		return
	var/damage_until_threshold = xenomorph_owner.health - xenomorph_owner.get_crit_threshold()
	if(damage_until_threshold > amount)
		return
	var/damage_reduction = min(amount, xenomorph_owner.plasma_stored / plasma_per_damage)
	xenomorph_owner.use_plasma(ROUND_UP(damage_reduction * plasma_per_damage))
	amount_mod += damage_reduction

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/suffocating_presence
	name = "Suffocating Presence"
	desc = "Dreadful Presence will inflict a temporary effect that deals 6 stamina damage every second instead."
	/// The amount of stamina damage that Dreadful Presence should be doing per second.
	var/damage = 6

/datum/mutation_upgrade/spur/suffocating_presence/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/dreadful_presence/dreadful_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/dreadful_presence]
	if(!dreadful_ability)
		return
	dreadful_ability.stamina_draining += damage

/datum/mutation_upgrade/spur/suffocating_presence/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/dreadful_presence/dreadful_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/dreadful_presence]
	if(!dreadful_ability)
		return
	dreadful_ability.stamina_draining -= damage

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/shifting_costs
	name = "Shifting Costs"
	desc = "Stitch Puppet's cost is 20% of its original cost. Bestow Blessing costs 30% more."
	/// The multiplier to add as Stitch Puppet's initial ability cost to its current cost.
	var/puppet_multiplier = -0.8
	/// The multiplier to add as Bestow Blessings' initial ability cost to its current cost.
	var/blessings_multiplier = 0.3

/datum/mutation_upgrade/veil/shifting_costs/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/puppet/puppet_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/puppet]
	if(!puppet_ability)
		return
	var/datum/action/ability/activable/xeno/puppet_blessings/blessings_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/puppet_blessings]
	if(!blessings_ability)
		return
	puppet_ability.ability_cost += initial(puppet_ability.ability_cost) * puppet_multiplier
	blessings_ability.ability_cost += initial(blessings_ability.ability_cost) * blessings_multiplier

/datum/mutation_upgrade/veil/shifting_costs/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/puppet/puppet_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/puppet]
	if(!puppet_ability)
		return
	var/datum/action/ability/activable/xeno/puppet_blessings/blessings_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/puppet_blessings]
	if(!blessings_ability)
		return
	puppet_ability.ability_cost -= initial(puppet_ability.ability_cost) * puppet_multiplier
	blessings_ability.ability_cost -= initial(blessings_ability.ability_cost) * blessings_multiplier
