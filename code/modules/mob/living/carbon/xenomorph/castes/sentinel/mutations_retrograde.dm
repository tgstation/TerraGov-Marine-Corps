//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/gaseous_blood
	name = "Gaseous Blood"
	desc = "Everytime you take damage, you emit non-opaque light neurotoxin gas ontop of you. This can happen once every 5/3/1s."
	/// The beginning cooldown (at zero structures) in deciseconds.
	var/beginning_cooldown = 7 SECONDS
	/// The decreased cooldown for each structure in deciseconds
	var/cooldown_per_structure = 2 SECONDS
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
	COOLDOWN_START(src, activation_cooldown, max(1, beginning_cooldown - (get_total_structures() * cooldown_per_structure)))

	var/datum/effect_system/smoke_spread/smoke_system = new gas_type()
	smoke_system.set_up(gas_range, get_turf(xenomorph_owner))
	smoke_system.start()

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/toxic_claws
	name = "Toxic Claws"
	desc = "You gain an ability that makes your slashes inject 5/6/7u Neurotoxin for the next 3 slashes. You no longer have the ability Neurotoxin Sting."
	/// The beginning amount of reagents to inject per slash (at zero structures).
	var/beginning_amount = 4
	/// The additional amount of reagents to inject per slash (for each structure).
	var/amount_per_structure = 1

/datum/mutation_upgrade/spur/toxic_claws/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/neurotox_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/neurotox_sting]
	if(sting_ability)
		sting_ability.remove_action(xenomorph_owner)
	var/datum/action/ability/xeno_action/reagent_slash/slash_ability = new()
	slash_ability.give_action(xenomorph_owner)
	slash_ability.reagent_slash_amount = beginning_amount
	xenomorph_owner.selected_reagent = /datum/reagent/toxin/xeno_neurotoxin
	return ..()

/datum/mutation_upgrade/spur/toxic_claws/on_mutation_disabled()
	var/datum/action/ability/xeno_action/reagent_slash/slash_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/neurotox_sting]
	if(slash_ability)
		slash_ability.remove_action(xenomorph_owner)
	var/datum/action/ability/activable/xeno/neurotox_sting/sting_ability = new()
	sting_ability.give_action(xenomorph_owner)
	xenomorph_owner.selected_reagent = initial(xenomorph_owner.selected_reagent)
	return ..()

/datum/mutation_upgrade/spur/toxic_claws/on_structure_update(datum/source, previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/reagent_slash/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/reagent_slash]
	if(!ability)
		return FALSE
	ability.reagent_slash_amount += (new_amount - previous_amount) * amount_per_structure

/datum/mutation_upgrade/spur/toxic_claws/on_xenomorph_upgrade()
	var/datum/action/ability/activable/xeno/neurotox_sting/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/neurotox_sting]
	if(ability)
		ability.remove_action(xenomorph_owner)

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/toxic_spillage
	name = "Toxic Spillage"
	desc = "Neurotoxin Sting injects 25% as much neurotoxin. It creates non-opaque light neurotoxin gas spreading out up to 2/3/4 tiles on use."
	/// The multiplier of the amount of reagents injected with Neurotoxin Sting.
	var/injection_multiplier = 0.25
	/// The beginning cooldown (at zero structures) in deciseconds.
	var/beginning_range = 1
	/// The increased cooldown for each structure in deciseconds
	var/range_per_structure = 1

/datum/mutation_upgrade/veil/toxic_spillage/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/neurotox_sting/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/neurotox_sting]
	if(!ability)
		return FALSE
	ability.sting_amount *= injection_multiplier
	ability.sting_gas = /datum/effect_system/smoke_spread/xeno/neuro/light
	ability.sting_gas_range += beginning_range
	return ..()

/datum/mutation_upgrade/veil/toxic_spillage/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/neurotox_sting/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/neurotox_sting]
	if(!ability)
		return FALSE
	ability.sting_amount /= injection_multiplier
	ability.sting_gas = initial(ability.sting_gas)
	ability.sting_gas_range -= beginning_range
	return ..()

/datum/mutation_upgrade/veil/toxic_spillage/on_structure_update(datum/source, previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/neurotox_sting/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/neurotox_sting]
	if(!ability)
		return FALSE
	ability.sting_gas_range += (new_amount - previous_amount) * range_per_structure
