//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/toxic_blood
	name = "Toxic Blood"
	desc = "Every 100/75/50 damage you take, 1 stacks of Intoxicated will be applied to nearby humans."
	/// The beginning damage threshold (at zero structures).
	var/beginning_threshold = 25
	/// The additional damage threshold for each structure.
	var/threshold_per_structure = 25
	/// The amount of damage taken so far before threshold is calculated.
	var/damage_taken_so_far = 0
	/// The amount of intoxicated stacks to apply.
	var/applied_intoxicated_stacks = 1

/datum/mutation_upgrade/shell/toxic_blood/on_mutation_enabled()
	RegisterSignals(xenomorph_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE), PROC_REF(on_damage))
	return ..()

/datum/mutation_upgrade/shell/toxic_blood/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE, COMSIG_MOB_STAT_CHANGED))
	return ..()

/datum/mutation_upgrade/shell/toxic_blood/on_structure_update(datum/source, previous_amount, new_amount)
	damage_taken_so_far = min(damage_taken_so_far, (new_amount * threshold_per_structure) - 1)
	return ..()

/// Apply intoxicated stacks to nearby alive humans if the damage threshold is reached.
/datum/mutation_upgrade/shell/toxic_blood/proc/on_damage(datum/source, amount, list/amount_mod)
	SIGNAL_HANDLER
	if(amount <= 0 || xenomorph_owner.stat == DEAD) // It is fine to be unconscious!
		return
	damage_taken_so_far += amount
	if(damage_taken_so_far < (beginning_threshold + (threshold_per_structure * get_total_structures())))
		return
	damage_taken_so_far = 0
	for (var/mob/living/carbon/human/nearby_human AS in cheap_get_humans_near(xenomorph_owner, 1))
		if(nearby_human.stat == DEAD)
			continue
		var/datum/status_effect/stacking/intoxicated/debuff = nearby_human.has_status_effect(STATUS_EFFECT_INTOXICATED)
		if(!debuff)
			nearby_human.apply_status_effect(STATUS_EFFECT_INTOXICATED, applied_intoxicated_stacks)
			continue
		debuff.add_stacks(applied_intoxicated_stacks)

/datum/mutation_upgrade/shell/comforting_acid
	name = "Comforting Acid"
	desc = "Toxic Slash will cause humans to passively heal you for 1/1.5/2 health per stack of Intoxicated as long you stay near them."
	/// The beginning health to heal per stack (at zero structures).
	var/beginning_healing = 0.5
	/// The additional health to heal per stack for each structure.
	var/healing_per_structure = 0.5

/datum/mutation_upgrade/shell/comforting_acid/on_mutation_enabled()
	var/datum/action/ability/xeno_action/toxic_slash/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toxic_slash]
	if(!ability)
		return FALSE
	ability.healing_per_stack += beginning_healing
	return ..()

/datum/mutation_upgrade/shell/comforting_acid/on_mutation_disabled()
	var/datum/action/ability/xeno_action/toxic_slash/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toxic_slash]
	if(!ability)
		return FALSE
	ability.healing_per_stack -= beginning_healing
	return ..()

/datum/mutation_upgrade/shell/comforting_acid/on_structure_update(datum/source, previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/toxic_slash/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toxic_slash]
	if(!ability)
		return FALSE
	ability.healing_per_stack += (new_amount - previous_amount) * healing_per_structure

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/acidic_slasher
	name = "Acidic Slasher"
	desc = "Your attack delay will be -0.05/-0.1/-0.15s faster and will always apply 1/2/3 stacks of Intoxicated against humans, but all melee damage is reduced by 50%."

/datum/mutation_upgrade/spur/acidic_slasher/on_mutation_enabled()
	UnregisterSignal(src, COMSIG_XENOMORPH_POSTATTACK_LIVING)
	xenomorph_owner.xeno_melee_damage_modifier += 0.50
	return ..()

/datum/mutation_upgrade/spur/acidic_slasher/on_mutation_disabled()
	UnregisterSignal(src, COMSIG_XENOMORPH_POSTATTACK_LIVING)
	xenomorph_owner.xeno_melee_damage_modifier += 0.50
	return ..()

/datum/mutation_upgrade/spur/acidic_slasher/on_structure_update(datum/source, previous_amount, new_amount)
	xenomorph_owner.next_move_adjust -= (new_amount - previous_amount) * 0.5
	return ..()

/// Applies a variable amount of Intoxicated stacks to those that they attack.
/datum/mutation_upgrade/spur/acidic_slasher/proc/on_postattack(mob/living/source, mob/living/target, damage)
	SIGNAL_HANDLER
	var/datum/status_effect/stacking/intoxicated/debuff = target.has_status_effect(STATUS_EFFECT_INTOXICATED)
	if(!debuff)
		target.apply_status_effect(STATUS_EFFECT_INTOXICATED, get_total_structures())
		return
	debuff.add_stacks(get_total_structures())

/datum/mutation_upgrade/spur/far_sting
	name = "Far Sting"
	desc = "Drain Sting can be used at targets one additional tile away. If the target is at maximum range, Drain Sting is only 50/75/100% effective."
	/// The beginning effectiveness of Drain Sting at a range that isn't upclose (at zero structures).
	var/beginning_effectiveness = 0.25
	/// The additional effectiveness of Drain Sting at a range that isn't upclose (for each structure).
	var/effectiveness_per_structure = 0.25

/datum/mutation_upgrade/spur/far_sting/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/drain_sting/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!ability)
		return FALSE
	ability.targetable_range += 1
	ability.ranged_effectiveness += beginning_effectiveness
	return ..()

/datum/mutation_upgrade/spur/far_sting/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/drain_sting/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!ability)
		return FALSE
	ability.targetable_range -= 1
	ability.ranged_effectiveness -= beginning_effectiveness
	return ..()

/datum/mutation_upgrade/spur/far_sting/on_structure_update(datum/source, previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/drain_sting/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!ability)
		return FALSE
	ability.ranged_effectiveness += (new_amount - previous_amount) * effectiveness_per_structure

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/toxic_compatibility
	name = "Toxic Compatibility"
	desc = "Every 5/4/3u of xeno-chemicals in your target will count as one stack of Intoxicated when calculating the the strength of your Drain Sting."
	/// The beginning amount of xeno-chemicals needed for one Intoxicated stack (at zero structures).
	var/beginning_amount = 6
	/// The subtracted amount for xeno-chemicals needed for one Intoxicated stack (for each structure).
	var/amount_per_structure = 1

/datum/mutation_upgrade/veil/toxic_compatibility/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/drain_sting/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!ability)
		return FALSE
	ability.xenochemicals_unit_per_stack += beginning_amount
	return ..()

/datum/mutation_upgrade/veil/toxic_compatibility/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/drain_sting/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!ability)
		return FALSE
	ability.xenochemicals_unit_per_stack -= beginning_amount
	return ..()

/datum/mutation_upgrade/veil/toxic_compatibility/on_structure_update(datum/source, previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/drain_sting/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!ability)
		return FALSE
	ability.xenochemicals_unit_per_stack -= (new_amount - previous_amount) * amount_per_structure
