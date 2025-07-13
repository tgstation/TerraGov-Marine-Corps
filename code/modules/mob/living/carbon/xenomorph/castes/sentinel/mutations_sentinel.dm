//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/toxic_blood
	name = "Toxic Blood"
	desc = "Every 100/75/50 damage you take, 1 stacks of Intoxicated will be applied to nearby humans."
	/// For the first structure, the damage needed to be taken.
	var/damage_initial = 125
	/// For each structure, the damage needed to be taken.
	var/damage_per_structure = -25
	/// The amount of damage taken so far before threshold is calculated.
	var/damage_taken_so_far = 0
	/// The amount of intoxicated stacks to apply.
	var/intoxicated_stacks_to_apply = 1

/datum/mutation_upgrade/shell/toxic_blood/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Every [damage_initial + (damage_per_structure * new_amount)] damage you take, [intoxicated_stacks_to_apply] stacks of Intoxicated will be applied to nearby humans."

/datum/mutation_upgrade/shell/toxic_blood/on_mutation_enabled()
	RegisterSignals(xenomorph_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE), PROC_REF(on_damage))
	return ..()

/datum/mutation_upgrade/shell/toxic_blood/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE, COMSIG_MOB_STAT_CHANGED))
	return ..()

/datum/mutation_upgrade/shell/toxic_blood/on_structure_update(previous_amount, new_amount)
	damage_taken_so_far = min(damage_taken_so_far, damage_initial + (damage_per_structure * new_amount) - 1)
	return ..()

/// Apply intoxicated stacks to nearby alive humans if the damage threshold is reached.
/datum/mutation_upgrade/shell/toxic_blood/proc/on_damage(datum/source, amount, list/amount_mod)
	SIGNAL_HANDLER
	if(amount <= 0 || xenomorph_owner.stat == DEAD) // It is fine to be unconscious!
		return
	damage_taken_so_far += amount
	if(damage_taken_so_far < (damage_initial + (damage_per_structure * get_total_structures())))
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

/datum/mutation_upgrade/shell/comforting_acid
	name = "Comforting Acid"
	desc = "Toxic Slash will cause humans to passively heal you for 1/1.5/2 health per stack of Intoxicated as long you stay near them."
	/// For the first structure, the health to heal.
	var/healing_initial = 0.5
	/// For each structure, the additional health to heal.
	var/healing_per_structure = 0.5

/datum/mutation_upgrade/shell/comforting_acid/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Toxic Slash will cause humans to passively heal you for [healing_initial + (healing_per_structure * new_amount)] health per stack of Intoxicated as long you stay near them."

/datum/mutation_upgrade/shell/comforting_acid/on_mutation_enabled()
	var/datum/action/ability/xeno_action/toxic_slash/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toxic_slash]
	if(!ability)
		return
	ability.healing_per_stack += healing_initial
	return ..()

/datum/mutation_upgrade/shell/comforting_acid/on_mutation_disabled()
	var/datum/action/ability/xeno_action/toxic_slash/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toxic_slash]
	if(!ability)
		return
	ability.healing_per_stack -= healing_initial
	return ..()

/datum/mutation_upgrade/shell/comforting_acid/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/toxic_slash/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toxic_slash]
	if(!ability)
		return
	ability.healing_per_stack += (new_amount - previous_amount) * healing_per_structure

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
	return "Your attack delay will be [(attack_speed_decrease_per_structure * new_amount) * 0.1]s faster and will always apply [(intoxicated_stack_per_structure * new_amount)] stacks of Intoxicated against humans, but all melee damage is reduced by [melee_damage_modifier * 100]%."

/datum/mutation_upgrade/spur/acidic_slasher/on_mutation_enabled()
	UnregisterSignal(src, COMSIG_XENOMORPH_POSTATTACK_LIVING)
	xenomorph_owner.xeno_melee_damage_modifier -= melee_damage_modifier
	return ..()

/datum/mutation_upgrade/spur/acidic_slasher/on_mutation_disabled()
	UnregisterSignal(src, COMSIG_XENOMORPH_POSTATTACK_LIVING)
	xenomorph_owner.xeno_melee_damage_modifier += melee_damage_modifier
	return ..()

/datum/mutation_upgrade/spur/acidic_slasher/on_structure_update(previous_amount, new_amount)
	xenomorph_owner.next_move_adjust -= (new_amount - previous_amount) * attack_speed_decrease_per_structure
	return ..()

/// Applies a variable amount of Intoxicated stacks to those that they attack.
/datum/mutation_upgrade/spur/acidic_slasher/proc/on_postattack(mob/living/source, mob/living/target, damage)
	SIGNAL_HANDLER
	var/datum/status_effect/stacking/intoxicated/debuff = target.has_status_effect(STATUS_EFFECT_INTOXICATED)
	if(!debuff)
		target.apply_status_effect(STATUS_EFFECT_INTOXICATED, intoxicated_stack_per_structure)
		return
	debuff.add_stacks(intoxicated_stack_per_structure)

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
	return "Drain Sting can be used at targets [range_initial] additional tile away. If the target is at maximum range, Drain Sting is [effectiveness_initial + (effectiveness_per_structure * new_amount)]% effective."

/datum/mutation_upgrade/spur/far_sting/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/drain_sting/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!ability)
		return
	ability.targetable_range += range_initial
	ability.ranged_effectiveness += effectiveness_initial
	return ..()

/datum/mutation_upgrade/spur/far_sting/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/drain_sting/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!ability)
		return
	ability.targetable_range -= range_initial
	ability.ranged_effectiveness -= effectiveness_initial
	return ..()

/datum/mutation_upgrade/spur/far_sting/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/drain_sting/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!ability)
		return
	ability.ranged_effectiveness += (new_amount - previous_amount) * effectiveness_per_structure

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/toxic_compatibility
	name = "Toxic Compatibility"
	desc = "Every 5/4/3u of xeno-chemicals in your target will count as one stack of Intoxicated when calculating the the strength of your Drain Sting."
	/// For each structure, the amount of xeno-chemicals to convert to one stack of Intoxicated.
	var/amount_initial = 6
	/// For each structure, the additional amount of xeno-chemicals to convert to one stack of Intoxicated.
	var/amount_per_structure = -1

/datum/mutation_upgrade/veil/toxic_compatibility/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Every [amount_initial + (amount_per_structure * new_amount)]u of xeno-chemicals in your target will count as one stack of Intoxicated when calculating the the strength of your Drain Sting."

/datum/mutation_upgrade/veil/toxic_compatibility/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/drain_sting/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!ability)
		return
	ability.xenochemicals_unit_per_stack += amount_initial
	return ..()

/datum/mutation_upgrade/veil/toxic_compatibility/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/drain_sting/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!ability)
		return
	ability.xenochemicals_unit_per_stack -= amount_initial
	return ..()

/datum/mutation_upgrade/veil/toxic_compatibility/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/drain_sting/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!ability)
		return
	ability.xenochemicals_unit_per_stack += (new_amount - previous_amount) * amount_per_structure
