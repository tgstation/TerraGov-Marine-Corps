//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/comforting_acid
	name = "Comforting Acid"
	desc = "Toxic Slash will cause humans to passively heal you for 1/1.5/2 health per stack of Intoxicated as long you are adjacent to them."
	/// For the first structure, the health to heal.
	var/healing_initial = 0.5
	/// For each structure, the additional health to heal.
	var/healing_per_structure = 0.5

/datum/mutation_upgrade/shell/comforting_acid/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Toxic Slash will cause humans to passively heal you for [get_healing(new_amount)] health per stack of Intoxicated as long you are adjacent to them."

/datum/mutation_upgrade/shell/comforting_acid/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/toxic_slash/slash_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toxic_slash]
	if(!slash_ability)
		return
	slash_ability.healing_per_stack += get_healing(0)

/datum/mutation_upgrade/shell/comforting_acid/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/xeno_action/toxic_slash/slash_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toxic_slash]
	if(!slash_ability)
		return
	slash_ability.healing_per_stack -= get_healing(0)

/datum/mutation_upgrade/shell/comforting_acid/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/toxic_slash/slash_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toxic_slash]
	if(!slash_ability)
		return
	slash_ability.healing_per_stack += get_healing(new_amount - previous_amount, FALSE)

/// Returns the amount that Toxic Slash will cause Intoxicated Stacks to heal overtime by.
/datum/mutation_upgrade/shell/comforting_acid/proc/get_healing(structure_count, include_initial = TRUE)
	return (include_initial ? healing_initial : 0) + (healing_per_structure * structure_count)

/datum/mutation_upgrade/shell/healing_sting
	name = "Healing Sting"
	desc = "Drain Sting now heals 150/175/200% of its original value. Any leftover healing is converted to overheal health."
	/// For the first structure, the multiplier to add to Drain Sting's healing.
	var/multiplier_initial = 0.25
	/// For each structure, the additional multiplier to add to Drain Sting's healing.
	var/multiplier_per_structure = 0.25

/datum/mutation_upgrade/shell/healing_sting/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Drain Sting now heals [PERCENT(1 + get_multiplier(new_amount))]% of its original value. Any leftover healing is converted to overheal health."

/datum/mutation_upgrade/shell/healing_sting/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/drain_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!sting_ability)
		return
	sting_ability.heal_multiplier += get_multiplier(0)

/datum/mutation_upgrade/shell/healing_sting/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/drain_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!sting_ability)
		return
	sting_ability.heal_multiplier -= get_multiplier(0)

/datum/mutation_upgrade/shell/healing_sting/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/drain_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!sting_ability)
		return
	sting_ability.heal_multiplier += get_multiplier(new_amount - previous_amount, FALSE)

/// Returns the multiplier to add to Drain Sting's healing.
/datum/mutation_upgrade/shell/healing_sting/proc/get_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? multiplier_initial : 0) + (multiplier_per_structure * structure_count)

/datum/mutation_upgrade/shell/constant_surge
	name = "Constant Surge"
	desc = "Drain Sting always triggers Drain Surge. Drain Surge only gives 1/1.25/1.5 soft armor for each Intoxicated stack."
	/// For the first structure, the amount of soft armor that Drain Surge gives for each Intoxicated stack.
	var/armor_initial = 0.75
	/// For each structure, the additional amount of soft armor that Drain Surge gives for each Intoxicated stack.
	var/armor_per_structure = 0.25

/datum/mutation_upgrade/shell/constant_surge/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Drain Sting always triggers Drain Surge. Drain Surge only gives [get_armor(new_amount)] soft armor for each Intoxicated stack."

/datum/mutation_upgrade/shell/constant_surge/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/drain_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!sting_ability)
		return
	sting_ability.drain_surge_strength -= initial(sting_ability.drain_surge_strength)
	sting_ability.drain_surge_armor_per += get_armor(0)

/datum/mutation_upgrade/shell/constant_surge/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/drain_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!sting_ability)
		return
	sting_ability.drain_surge_strength += initial(sting_ability.drain_surge_strength)
	sting_ability.drain_surge_armor_per -= get_armor(0)

/datum/mutation_upgrade/shell/constant_surge/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/drain_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!sting_ability)
		return
	sting_ability.drain_surge_armor_per += get_armor(new_amount - previous_amount, FALSE)

/// Returns the amount of soft armor that Drain Surge gives for each Intoxicated stack.
/datum/mutation_upgrade/shell/constant_surge/proc/get_armor(structure_count, include_initial = TRUE)
	return (include_initial ? armor_initial : 0) + (armor_per_structure * structure_count)

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/acidic_slasher
	name = "Acidic Slasher"
	desc = "Your attack delay will be 0.05/0.1/0.15s faster and will always apply 1/2/3 stacks of Intoxicated against humans, but all melee damage is reduced by 50%."
	/// For each structure, the amount of deciseconds to decrease their next move by.
	var/attack_speed_decrease_per_structure = 0.5
	/// For each structure, the amount of intoxicated to apply.
	var/intoxicated_stack_per_structure = 1
	/// The amount to decrease the melee damage modifier by.
	var/melee_damage_modifier = 0.5

/datum/mutation_upgrade/spur/acidic_slasher/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Your attack delay will be [(get_move_adjust(new_amount)) * 0.1]s faster and will always apply [get_intoxicated_stacks(intoxicated_stack_per_structure)] stacks of Intoxicated against humans, but all melee damage is reduced by [melee_damage_modifier * 100]%."

/datum/mutation_upgrade/spur/acidic_slasher/on_mutation_enabled()
	RegisterSignal(xenomorph_owner, COMSIG_XENOMORPH_POSTATTACK_LIVING, PROC_REF(on_postattack))
	xenomorph_owner.xeno_melee_damage_modifier -= melee_damage_modifier
	return ..()

/datum/mutation_upgrade/spur/acidic_slasher/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, COMSIG_XENOMORPH_POSTATTACK_LIVING)
	xenomorph_owner.xeno_melee_damage_modifier += melee_damage_modifier
	return ..()

/datum/mutation_upgrade/spur/acidic_slasher/on_structure_update(previous_amount, new_amount)
	xenomorph_owner.next_move_adjust -= get_move_adjust(new_amount - previous_amount)
	return ..()

/// Applies a variable amount of Intoxicated stacks to those that they attack.
/datum/mutation_upgrade/spur/acidic_slasher/proc/on_postattack(mob/living/source, mob/living/target, damage)
	SIGNAL_HANDLER
	var/datum/status_effect/stacking/intoxicated/debuff = target.has_status_effect(STATUS_EFFECT_INTOXICATED)
	if(!debuff)
		target.apply_status_effect(STATUS_EFFECT_INTOXICATED, get_intoxicated_stacks(get_total_structures()))
		return
	debuff.add_stacks(get_intoxicated_stacks(get_total_structures()))

/// Returns the amount of deciseconds that the owner's next_move_adjust should be (which makes them attack faster).
/datum/mutation_upgrade/spur/acidic_slasher/proc/get_move_adjust(structure_count)
	return attack_speed_decrease_per_structure * structure_count

/// Returns the amount of Intoxicated stacks that each slash on humans should inflict.
/datum/mutation_upgrade/spur/acidic_slasher/proc/get_intoxicated_stacks(structure_count)
	return intoxicated_stack_per_structure * structure_count

/datum/mutation_upgrade/spur/far_sting
	name = "Far Sting"
	desc = "Drain Sting can be used at targets 1 additional tile away. If the target is at maximum range, Drain Sting is 50/75/100% effective."
	/// For the first structure, the range to increase by.
	var/range_initial = 1
	/// For each structure, the effectiveness of Drain Sting at a range that isn't upclose.
	var/effectiveness_initial = 0.25
	/// For each structure, the additional effectiveness of Drain Sting at a range that isn't upclose.
	var/effectiveness_per_structure = 0.25

/datum/mutation_upgrade/spur/far_sting/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Drain Sting can be used at targets [range_initial] additional tile away. If the target is at maximum range, Drain Sting is [PERCENT(get_effectiveness(new_amount))]% effective."

/datum/mutation_upgrade/spur/far_sting/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/drain_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!sting_ability)
		return
	sting_ability.targetable_range += range_initial
	sting_ability.ranged_effectiveness += get_effectiveness(0)

/datum/mutation_upgrade/spur/far_sting/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/drain_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!sting_ability)
		return
	sting_ability.targetable_range -= range_initial
	sting_ability.ranged_effectiveness -= get_effectiveness(0)

/datum/mutation_upgrade/spur/far_sting/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/drain_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!sting_ability)
		return
	sting_ability.ranged_effectiveness += get_effectiveness(new_amount - previous_amount, FALSE)

/// Returns the amount that Drain Sting's ranged effectiveness should be.
/datum/mutation_upgrade/spur/far_sting/proc/get_effectiveness(structure_count, include_initial = TRUE)
	return (include_initial ? effectiveness_initial : 0) + (effectiveness_per_structure * structure_count)

/datum/mutation_upgrade/spur/imbued_claws
	name = "Imbued Claws"
	desc = "Drain Surge's armor is converted to a melee damage modifier. The melee damage modifier is further increased by 0/15/30%."
	/// For the first structure, the amount to increase the strength of Drain Surge (which is then converted to melee damage modifier).
	var/modifier_initial = -15
	/// For each structure, the additional amount to increase the strength of Drain Surge.
	var/modifier_per_structure = 15

/datum/mutation_upgrade/spur/imbued_claws/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Drain Surge's armor is converted to a melee damage modifier. The melee damage modifier is further increased by [get_modifier(new_amount)]%."

/datum/mutation_upgrade/spur/imbued_claws/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/drain_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!sting_ability)
		return
	sting_ability.drain_surge_strength += get_modifier(0)
	sting_ability.drain_surge_melee = TRUE

/datum/mutation_upgrade/spur/imbued_claws/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/drain_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!sting_ability)
		return
	sting_ability.drain_surge_strength -= get_modifier(0)
	sting_ability.drain_surge_melee = initial(sting_ability.drain_surge_melee)

/datum/mutation_upgrade/spur/imbued_claws/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/drain_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!sting_ability)
		return
	sting_ability.drain_surge_strength += get_modifier(new_amount - previous_amount, FALSE)

/// Returns the amount to increase the strength of Drain Surge.
/datum/mutation_upgrade/spur/imbued_claws/proc/get_modifier(structure_count, include_initial = TRUE)
	return (include_initial ? modifier_initial : 0) + (modifier_per_structure * structure_count)

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/toxic_compatibility
	name = "Toxic Compatibility"
	desc = "Every 5/4/3u of xeno-chemicals in your target will count as one stack of Intoxicated when calculating the the strength of your Drain Sting."
	/// For each structure, the additional amount of xeno-chemicals to convert to one stack of Intoxicated.
	var/amount_per_structure = -1

/datum/mutation_upgrade/veil/toxic_compatibility/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Every [get_amount(new_amount)]u of xeno-chemicals in your target will count as one stack of Intoxicated when calculating the the strength of your Drain Sting."

/datum/mutation_upgrade/veil/toxic_compatibility/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/drain_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!sting_ability)
		return
	sting_ability.chemical_potency = initial(sting_ability.chemical_potency)

/datum/mutation_upgrade/veil/toxic_compatibility/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/drain_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!sting_ability)
		return
	if(new_amount)
		sting_ability.chemical_potency = (1 / get_amount(new_amount)) * SENTINEL_DRAIN_MULTIPLIER

/// Returns the amount that Drain Sting will calculate and divide by for xeno-chemicals.
/datum/mutation_upgrade/veil/toxic_compatibility/proc/get_amount(structure_count)
	return 6 + (amount_per_structure * structure_count)

/datum/mutation_upgrade/veil/toxic_blood
	name = "Toxic Blood"
	desc = "Every 80/60/40 damage you take, 1 stacks of Intoxicated will be applied to nearby humans."
	/// For the first structure, the damage needed to be taken.
	var/damage_initial = 100
	/// For each structure, the damage needed to be taken.
	var/damage_per_structure = -20
	/// The amount of damage taken so far before threshold is calculated.
	var/damage_taken_so_far = 0
	/// The amount of intoxicated stacks to apply.
	var/intoxicated_stacks_to_apply = 1

/datum/mutation_upgrade/veil/toxic_blood/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Every [get_damage_threshold(new_amount)] damage you take, [intoxicated_stacks_to_apply] stacks of Intoxicated will be applied to nearby humans."

/datum/mutation_upgrade/veil/toxic_blood/on_mutation_enabled()
	RegisterSignals(xenomorph_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE), PROC_REF(on_damage))
	return ..()

/datum/mutation_upgrade/veil/toxic_blood/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE, COMSIG_MOB_STAT_CHANGED))
	return ..()

/datum/mutation_upgrade/veil/toxic_blood/on_structure_update(previous_amount, new_amount)
	damage_taken_so_far = min(damage_taken_so_far, get_damage_threshold(new_amount) - 1)
	return ..()

/// Apply intoxicated stacks to nearby alive humans if the damage threshold is reached.
/datum/mutation_upgrade/veil/toxic_blood/proc/on_damage(datum/source, amount, list/amount_mod)
	SIGNAL_HANDLER
	if(amount <= 0 || xenomorph_owner.stat == DEAD) // It is fine to be unconscious!
		return
	damage_taken_so_far += amount
	if(damage_taken_so_far < get_damage_threshold(get_total_structures()))
		return
	damage_taken_so_far = 0
	for (var/mob/living/carbon/human/nearby_human AS in cheap_get_humans_near(xenomorph_owner, 1))
		if(nearby_human.stat == DEAD)
			continue
		var/datum/status_effect/stacking/intoxicated/debuff = nearby_human.has_status_effect(STATUS_EFFECT_INTOXICATED)
		if(!debuff)
			nearby_human.apply_status_effect(STATUS_EFFECT_INTOXICATED, intoxicated_stacks_to_apply)
			continue
		debuff.add_stacks(intoxicated_stacks_to_apply)

/// Returns the amount that the total taken damage must meet in order to trigger the effects.
/datum/mutation_upgrade/veil/toxic_blood/proc/get_damage_threshold(structure_count, include_initial = TRUE)
	return (include_initial ? damage_initial : 0) + (damage_per_structure * structure_count)

/datum/mutation_upgrade/veil/automatic_sting
	name = "Automatic Sting"
	desc = "Drain Sting starts at 3/5/7 Intoxication stacks. It is automatically used against slashed humans if there are 12 Intoxication stacks or more."
	/// For the first structure, the amount of Intoxicated stacks worth of potency that Drain Sting starts off at.
	var/stacks_initial = 1
	/// For each structure, the additional amount of Intoxicated stacks worth of potency that Drain Sting starts off at.
	var/stacks_per_structure = 2
	/// The threshold of Intoxicated stacks in which Drain Sting will attempt to automatically activate on the attacked living.
	var/threshold_initial = 12

/datum/mutation_upgrade/veil/automatic_sting/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Drain Sting starts at [get_stacks(new_amount)] Intoxication stacks. It is automatically used against slashed humans if there are [threshold_initial] Intoxication stacks or more."

/datum/mutation_upgrade/veil/automatic_sting/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/drain_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!sting_ability)
		return
	RegisterSignal(xenomorph_owner, COMSIG_XENOMORPH_POSTATTACK_LIVING, PROC_REF(on_postattack))
	sting_ability.base_potency += get_stacks(0) * SENTINEL_DRAIN_MULTIPLIER

/datum/mutation_upgrade/veil/automatic_sting/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/drain_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!sting_ability)
		return
	UnregisterSignal(xenomorph_owner, COMSIG_XENOMORPH_POSTATTACK_LIVING)
	sting_ability.base_potency -= get_stacks(0) * SENTINEL_DRAIN_MULTIPLIER

/datum/mutation_upgrade/veil/automatic_sting/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/drain_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!sting_ability)
		return
	sting_ability.base_potency += get_stacks(new_amount - previous_amount, FALSE) * SENTINEL_DRAIN_MULTIPLIER

/// Automatically uses Drain Sting on the attacked target if applicable.
/datum/mutation_upgrade/veil/automatic_sting/proc/on_postattack(mob/living/source, mob/living/target, damage)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/human_target = target
	var/datum/action/ability/activable/xeno/drain_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!sting_ability || !sting_ability.action_cooldown_finished() || !sting_ability.can_use_ability(human_target, TRUE))
		return
	var/potency = sting_ability.get_potency(human_target)
	var/potency_in_sets = round(potency / SENTINEL_DRAIN_MULTIPLIER)
	if(potency_in_sets < threshold_initial)
		return
	INVOKE_NEXT_TICK(sting_ability, TYPE_PROC_REF(/datum/action/ability/activable/xeno/drain_sting, use_ability), human_target)

/// Returns the amount of Intoxicated stacks worth of potency that Drain Sting starts off at.
/datum/mutation_upgrade/veil/automatic_sting/proc/get_stacks(structure_count, include_initial = TRUE)
	return (include_initial ? stacks_initial : 0) + (stacks_per_structure * structure_count)
