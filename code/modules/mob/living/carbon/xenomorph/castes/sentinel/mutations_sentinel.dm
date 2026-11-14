//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/comforting_acid
	name = "Comforting Acid"
	desc = "Toxic Slash will cause humans to passively heal you for 1.5 health per stack of Intoxicated as long you are adjacent to them."
	/// The health to heal per stack.
	var/healing_per_stack = 1.5

/datum/mutation_upgrade/shell/comforting_acid/on_mutation_enabled()
	var/datum/action/ability/xeno_action/toxic_slash/slash_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toxic_slash]
	if(!slash_ability)
		return
	slash_ability.healing_per_stack += healing_per_stack

/datum/mutation_upgrade/shell/comforting_acid/on_mutation_disabled()
	var/datum/action/ability/xeno_action/toxic_slash/slash_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toxic_slash]
	if(!slash_ability)
		return
	slash_ability.healing_per_stack -= healing_per_stack

/datum/mutation_upgrade/shell/healing_sting
	name = "Healing Sting"
	desc = "Drain Sting now heals 175% of its original value. Any leftover healing is converted to overheal health."
	/// The multiplier to add to Drain Sting's healing.
	var/additional_multiplier = 0.75

/datum/mutation_upgrade/shell/healing_sting/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/drain_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!sting_ability)
		return
	sting_ability.heal_multiplier += additional_multiplier

/datum/mutation_upgrade/shell/healing_sting/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/drain_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!sting_ability)
		return
	sting_ability.heal_multiplier -= additional_multiplier

/datum/mutation_upgrade/shell/constant_surge
	name = "Constant Surge"
	desc = "Drain Sting always triggers Drain Surge. Drain Surge only gives 1.25 soft armor for each Intoxicated stack."
	/// For the first structure, the amount of soft armor that Drain Surge gives for each Intoxicated stack.
	var/armor_per_stack = 1.25

/datum/mutation_upgrade/shell/constant_surge/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/drain_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!sting_ability)
		return
	sting_ability.drain_surge_strength -= initial(sting_ability.drain_surge_strength)
	sting_ability.drain_surge_armor_per += armor_per_stack

/datum/mutation_upgrade/shell/constant_surge/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/drain_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!sting_ability)
		return
	sting_ability.drain_surge_strength += initial(sting_ability.drain_surge_strength)
	sting_ability.drain_surge_armor_per -= armor_per_stack

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/acidic_slasher
	name = "Acidic Slasher"
	desc = "Your attack delay will be 0.1s faster and will always apply 2 stacks of Intoxicated against humans, but all melee damage is reduced by 50%."
	/// The amount of deciseconds to change their next move by.
	var/attack_speed_change = -1 // Negative = faster. Positive = slower.
	/// For each structure, the amount of intoxicated to apply.
	var/intoxicated_stack = 2
	/// The amount to decrease the melee damage modifier by.
	var/melee_damage_modifier = 0.5

/datum/mutation_upgrade/spur/acidic_slasher/on_mutation_enabled()
	RegisterSignal(xenomorph_owner, COMSIG_XENOMORPH_POSTATTACK_LIVING, PROC_REF(on_postattack))
	xenomorph_owner.next_move_adjust += attack_speed_change
	xenomorph_owner.xeno_melee_damage_modifier -= melee_damage_modifier

/datum/mutation_upgrade/spur/acidic_slasher/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, COMSIG_XENOMORPH_POSTATTACK_LIVING)
	xenomorph_owner.next_move_adjust -= attack_speed_change
	xenomorph_owner.xeno_melee_damage_modifier += melee_damage_modifier

/// Applies a variable amount of Intoxicated stacks to those that they attack.
/datum/mutation_upgrade/spur/acidic_slasher/proc/on_postattack(mob/living/source, mob/living/target, damage)
	SIGNAL_HANDLER
	var/datum/status_effect/stacking/intoxicated/debuff = target.has_status_effect(STATUS_EFFECT_INTOXICATED)
	if(!debuff)
		target.apply_status_effect(STATUS_EFFECT_INTOXICATED, intoxicated_stack)
		return
	debuff.add_stacks(intoxicated_stack)

/datum/mutation_upgrade/spur/far_sting
	name = "Far Sting"
	desc = "Drain Sting can be used at targets 1 additional tile away. If the target is at maximum range, Drain Sting is 75% effective."
	/// The range to increase by.
	var/range_increase = 1
	/// The effectiveness of Drain Sting at a range that isn't upclose.
	var/ranged_effectiveness = 0.75

/datum/mutation_upgrade/spur/far_sting/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/drain_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!sting_ability)
		return
	sting_ability.targetable_range += range_increase
	sting_ability.ranged_effectiveness += ranged_effectiveness

/datum/mutation_upgrade/spur/far_sting/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/drain_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!sting_ability)
		return
	sting_ability.targetable_range -= range_increase
	sting_ability.ranged_effectiveness -= ranged_effectiveness

/datum/mutation_upgrade/spur/imbued_claws
	name = "Imbued Claws"
	desc = "Drain Surge's armor is converted to a melee damage modifier. The melee damage modifier is further increased by 15%."
	/// The amount to increase the strength of Drain Surge (which is then converted to melee damage modifier).
	var/modifier = 15

/datum/mutation_upgrade/spur/imbued_claws/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/drain_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!sting_ability)
		return
	sting_ability.drain_surge_strength += modifier
	sting_ability.drain_surge_melee = TRUE

/datum/mutation_upgrade/spur/imbued_claws/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/drain_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!sting_ability)
		return
	sting_ability.drain_surge_strength -= modifier
	sting_ability.drain_surge_melee = initial(sting_ability.drain_surge_melee)

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/toxic_compatibility
	name = "Toxic Compatibility"
	desc = "Every 4u of xeno-chemicals in your target will count as one stack of Intoxicated when calculating the the strength of your Drain Sting."
	/// The additional amount of xeno-chemicals to convert to one stack of Intoxicated.
	var/amount = 4

/datum/mutation_upgrade/veil/toxic_compatibility/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/drain_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!sting_ability)
		return
	sting_ability.chemical_potency = (1 / amount) * SENTINEL_DRAIN_MULTIPLIER

/datum/mutation_upgrade/veil/toxic_compatibility/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/drain_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!sting_ability)
		return
	sting_ability.chemical_potency = initial(sting_ability.chemical_potency)

/datum/mutation_upgrade/veil/toxic_blood
	name = "Toxic Blood"
	desc = "Every 60 damage you take, 1 stacks of Intoxicated will be applied to nearby humans."
	/// The damage needed to be taken.
	var/damage_threshold = 60
	/// The amount of damage taken so far before threshold is calculated.
	var/damage_taken_so_far = 0
	/// The amount of intoxicated stacks to apply.
	var/intoxicated_stacks_to_apply = 1

/datum/mutation_upgrade/veil/toxic_blood/on_mutation_enabled()
	RegisterSignals(xenomorph_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE), PROC_REF(on_damage))

/datum/mutation_upgrade/veil/toxic_blood/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE, COMSIG_MOB_STAT_CHANGED))
	damage_taken_so_far = 0

/// Apply intoxicated stacks to nearby alive humans if the damage threshold is reached.
/datum/mutation_upgrade/veil/toxic_blood/proc/on_damage(datum/source, amount, list/amount_mod)
	SIGNAL_HANDLER
	if(amount <= 0 || xenomorph_owner.stat == DEAD) // It is fine to be unconscious!
		return
	damage_taken_so_far += amount
	if(damage_taken_so_far < damage_threshold)
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

/datum/mutation_upgrade/veil/automatic_sting
	name = "Automatic Sting"
	desc = "Drain Sting starts at 5 Intoxication stacks. It is automatically used against slashed humans if there are 12 Intoxication stacks or more."
	/// The amount of Intoxicated stacks worth of potency that Drain Sting starts off at.
	var/additional_potency_stacks = 5
	/// The threshold of Intoxicated stacks in which Drain Sting will attempt to automatically activate on the attacked living.
	var/stacks_threshold = 12

/datum/mutation_upgrade/veil/automatic_sting/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/drain_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!sting_ability)
		return
	RegisterSignal(xenomorph_owner, COMSIG_XENOMORPH_POSTATTACK_LIVING, PROC_REF(on_postattack))
	sting_ability.base_potency += additional_potency_stacks * SENTINEL_DRAIN_MULTIPLIER

/datum/mutation_upgrade/veil/automatic_sting/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/drain_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!sting_ability)
		return
	UnregisterSignal(xenomorph_owner, COMSIG_XENOMORPH_POSTATTACK_LIVING)
	sting_ability.base_potency -= additional_potency_stacks * SENTINEL_DRAIN_MULTIPLIER

/// Automatically uses Drain Sting on the attacked target if applicable.
/datum/mutation_upgrade/veil/automatic_sting/proc/on_postattack(mob/living/source, mob/living/target, damage)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/human_target = target
	var/datum/action/ability/activable/xeno/drain_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!sting_ability || !sting_ability.action_cooldown_finished() || !sting_ability.can_use_ability(human_target, TRUE))
		return
	var/potency = sting_ability.get_potency(human_target)
	var/potency_in_sets = round(potency / SENTINEL_DRAIN_MULTIPLIER)
	if(potency_in_sets < stacks_threshold)
		return
	INVOKE_NEXT_TICK(sting_ability, TYPE_PROC_REF(/datum/action/ability/activable/xeno/drain_sting, use_ability), human_target)
