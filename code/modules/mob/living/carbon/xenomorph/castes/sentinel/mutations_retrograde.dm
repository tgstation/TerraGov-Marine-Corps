//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/gaseous_blood
	name = "Gaseous Blood"
	desc = "Everytime you take damage, you emit non-opaque light neurotoxin gas with a radius of 2. This can happen once every 8/6/4 seconds."
	/// For the first structure, the cooldown in deciseconds.
	var/cooldown_initial = 10 SECONDS
	/// For each structure, the increased cooldown in deciseconds.
	var/cooldown_per_structure = -2 SECONDS
	/// The type of gas that is emitted.
	var/datum/effect_system/smoke_spread/gas_type = /datum/effect_system/smoke_spread/xeno/neuro/light
	/// The range of the gas emitted.
	var/gas_range = 2
	COOLDOWN_DECLARE(activation_cooldown)

/datum/mutation_upgrade/shell/gaseous_blood/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Everytime you take damage, you emit non-opaque light neurotoxin gas with a radius of [gas_range]. This can happen once every [get_cooldown(new_amount) * 0.1] seconds."

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
	COOLDOWN_START(src, activation_cooldown, get_cooldown(get_total_structures()))

	var/datum/effect_system/smoke_spread/smoke_system = new gas_type()
	smoke_system.set_up(gas_range, get_turf(xenomorph_owner), 2) // 4 seconds of gas.
	smoke_system.start()

/// Returns the cooldown (in deciseconds) for the gas.
/datum/mutation_upgrade/shell/gaseous_blood/proc/get_cooldown(structure_count, include_initial = TRUE)
	return max(1, (include_initial ? cooldown_initial : 0) + (cooldown_per_structure * structure_count))

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/toxic_claws
	name = "Toxic Claws"
	desc = "You gain an ability that makes your slashes inject 6/7/8u Neurotoxin for the next 3 slashes. You no longer have the ability Neurotoxin Sting."
	conflicting_mutation_types = list(
		/datum/mutation_upgrade/veil/toxic_spillage
	)
	/// For the first structure, the amount of reagents to inject per slash.
	var/amount_initial = 5
	/// For each structure, the additional amount of reagents to inject per slash.
	var/amount_per_structure = 1

/datum/mutation_upgrade/spur/toxic_claws/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "You gain an ability that makes your slashes inject [get_amount(new_amount)]u Neurotoxin for the next 3 slashes. You no longer have the ability Neurotoxin Sting."

/datum/mutation_upgrade/spur/toxic_claws/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/neurotox_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/neurotox_sting]
	if(sting_ability)
		sting_ability.remove_action(xenomorph_owner)
	var/datum/action/ability/xeno_action/reagent_slash/slash_ability = new()
	slash_ability.give_action(xenomorph_owner)
	slash_ability.reagent_slash_amount = get_amount(0)
	xenomorph_owner.set_selected_reagent(/datum/reagent/toxin/xeno_neurotoxin)
	return ..()

/datum/mutation_upgrade/spur/toxic_claws/on_mutation_disabled()
	var/datum/action/ability/xeno_action/reagent_slash/slash_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/neurotox_sting]
	if(slash_ability)
		slash_ability.remove_action(xenomorph_owner) // No need to decrease the reagent slash amount since the ability is gone now.
	var/datum/action/ability/activable/xeno/neurotox_sting/sting_ability = new()
	sting_ability.give_action(xenomorph_owner)
	xenomorph_owner.set_selected_reagent(initial(xenomorph_owner.selected_reagent))
	return ..()

/datum/mutation_upgrade/spur/toxic_claws/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/reagent_slash/slash_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/reagent_slash]
	if(!slash_ability)
		return
	slash_ability.reagent_slash_amount += get_amount(new_amount - previous_amount, FALSE)

/datum/mutation_upgrade/spur/toxic_claws/on_xenomorph_upgrade()
	var/datum/action/ability/activable/xeno/neurotox_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/neurotox_sting]
	if(sting_ability)
		sting_ability.remove_action(xenomorph_owner)

/// Returns the amount of reagents that each slash should give.
/datum/mutation_upgrade/spur/toxic_claws/proc/get_amount(structure_count, include_initial = TRUE)
	return (include_initial ? amount_initial : 0) + (amount_per_structure * structure_count)

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/toxic_spillage
	name = "Toxic Spillage"
	desc = "Neurotoxin Sting injects 25% as much neurotoxin. It creates non-opaque light neurotoxin gas spreading out up to 2/3/4 tiles on use."
	conflicting_mutation_types = list(
		/datum/mutation_upgrade/spur/toxic_claws
	)
	/// The multiplier of the amount of reagents injected with Neurotoxin Sting.
	var/injection_multiplier = 0.25
	/// For the first structure, the radius of gas.
	var/range_initial = 1
	/// For each structure, the increased radius of gas.
	var/range_per_structure = 1

/datum/mutation_upgrade/veil/toxic_spillage/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Neurotoxin Sting injects [PERCENT(injection_multiplier)]% as much neurotoxin. It creates non-opaque light neurotoxin gas spreading out up to [get_range(new_amount)] tiles on use."

/datum/mutation_upgrade/veil/toxic_spillage/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/neurotox_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/neurotox_sting]
	if(!sting_ability)
		return
	sting_ability.sting_amount *= injection_multiplier
	sting_ability.sting_gas = /datum/effect_system/smoke_spread/xeno/neuro/light
	sting_ability.sting_gas_range += get_range(0)
	return ..()

/datum/mutation_upgrade/veil/toxic_spillage/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/neurotox_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/neurotox_sting]
	if(!sting_ability)
		return
	sting_ability.sting_amount /= injection_multiplier
	sting_ability.sting_gas = initial(sting_ability.sting_gas)
	sting_ability.sting_gas_range -= get_range(0)
	return ..()

/datum/mutation_upgrade/veil/toxic_spillage/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/neurotox_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/neurotox_sting]
	if(!sting_ability)
		return
	sting_ability.sting_gas_range += get_range(new_amount - previous_amount, FALSE)

/// Returns the range in which gas spreads to.
/datum/mutation_upgrade/veil/toxic_spillage/proc/get_range(structure_count, include_initial = TRUE)
	return (include_initial ? range_initial : 0) + (range_per_structure * structure_count)
