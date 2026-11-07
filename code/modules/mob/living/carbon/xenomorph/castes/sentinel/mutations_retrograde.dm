//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/gaseous_blood
	name = "Gaseous Blood"
	desc = "Everytime you take damage, you emit non-opaque light neurotoxin gas with a radius of 2. This can happen once every 6 seconds."
	/// The cooldown in deciseconds.
	var/cooldown_duration = 6 SECONDS
	/// The type of gas that is emitted.
	var/datum/effect_system/smoke_spread/gas_type = /datum/effect_system/smoke_spread/xeno/neuro/light
	/// The range of the gas emitted.
	var/gas_range = 2
	COOLDOWN_DECLARE(activation_cooldown)

/datum/mutation_upgrade/shell/gaseous_blood/on_mutation_enabled()
	RegisterSignals(xenomorph_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE), PROC_REF(on_damage))
	return ..()

/datum/mutation_upgrade/shell/gaseous_blood/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE))
	return ..()

/// Emits gas when damage is taken if it is ready to activate.
/datum/mutation_upgrade/shell/gaseous_blood/proc/on_damage(datum/source, amount, list/amount_mod)
	SIGNAL_HANDLER
	if(amount <= 0 || xenomorph_owner.stat == DEAD) // It is fine to be unconscious!
		return
	if(!COOLDOWN_FINISHED(src, activation_cooldown))
		return
	COOLDOWN_START(src, activation_cooldown, cooldown_duration)

	var/datum/effect_system/smoke_spread/smoke_system = new gas_type()
	smoke_system.set_up(gas_range, get_turf(xenomorph_owner), 2) // 4 seconds of gas.
	smoke_system.start()

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/toxic_claws
	name = "Toxic Claws"
	desc = "You gain an ability that makes your slashes inject 7u Neurotoxin for the next 3 slashes. You no longer have the ability Neurotoxin Sting."
	conflicting_mutation_types = list(
		/datum/mutation_upgrade/veil/toxic_spillage
	)
	/// The amount of reagents to inject per slash.
	var/amount = 7
	/// The ability to be given back if the mutation is disabled.
	var/datum/action/ability/activable/xeno/neurotox_sting/removed_ability

/datum/mutation_upgrade/spur/toxic_claws/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/neurotox_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/neurotox_sting]
	if(sting_ability)
		removed_ability = sting_ability
		removed_ability.remove_action(xenomorph_owner)
	var/datum/action/ability/xeno_action/reagent_slash/slash_ability = new()
	slash_ability.give_action(xenomorph_owner)
	slash_ability.reagent_slash_amount = amount
	xenomorph_owner.set_selected_reagent(/datum/reagent/toxin/xeno_neurotoxin)

/datum/mutation_upgrade/spur/toxic_claws/on_mutation_disabled()
	if(removed_ability)
		removed_ability.give_action(xenomorph_owner)
		removed_ability = null
	var/datum/action/ability/xeno_action/reagent_slash/slash_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/neurotox_sting]
	if(slash_ability)
		xenomorph_owner.remove_ability(slash_ability)
	xenomorph_owner.set_selected_reagent(initial(xenomorph_owner.selected_reagent))


/datum/mutation_upgrade/spur/toxic_claws/on_xenomorph_upgrade()
	var/datum/action/ability/activable/xeno/neurotox_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/neurotox_sting]
	if(!sting_ability)
		return
	xenomorph_owner.remove_ability(sting_ability) // Upgrading gives abilities we have removed, thus we need to delete them.

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/toxic_spillage
	name = "Toxic Spillage"
	desc = "Neurotoxin Sting injects 25% as much neurotoxin. It creates non-opaque light neurotoxin gas spreading out up to 3 tiles on use."
	conflicting_mutation_types = list(
		/datum/mutation_upgrade/spur/toxic_claws
	)
	/// The multiplier of the amount of reagents injected with Neurotoxin Sting.
	var/injection_multiplier = 0.25
	/// The radius of gas.
	var/range = 3


/datum/mutation_upgrade/veil/toxic_spillage/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/neurotox_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/neurotox_sting]
	if(!sting_ability)
		return
	sting_ability.sting_amount *= injection_multiplier
	sting_ability.sting_gas = /datum/effect_system/smoke_spread/xeno/neuro/light
	sting_ability.sting_gas_range += range

/datum/mutation_upgrade/veil/toxic_spillage/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/neurotox_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/neurotox_sting]
	if(!sting_ability)
		return
	sting_ability.sting_amount /= injection_multiplier
	sting_ability.sting_gas = initial(sting_ability.sting_gas)
	sting_ability.sting_gas_range -= range
