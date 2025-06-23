//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/lone_healer
	name = "Lone Healer"
	desc = "Psychic Cure can now target yourself. Self-targetting causes it to heal for 50/60/70% of its original amount and sets its cooldown to 200/175/150% of its original amount."
	/// For the first structure, the multiplier to increase Psychic Cure's healing by  when it is self-targetted.
	var/self_heal_multiplier_increase_initial = -0.6
	/// For each structure, the additional multiplier to increase Psychic Cure's healing by  when it is self-targetted.
	var/self_heal_multiplier_increase_per_structure = 0.1
	/// For the first structure, the percentage amount to increase the ability's cooldown ontop of its initial amount  when it is self-targetted.
	var/self_cooldown_percentage_increase_initial = 1.25
	/// For each structure, the additional percentage amount to increase the ability's cooldown ontop of its initial amount when it is self-targetted.
	var/self_cooldown_percentage_increase_per_structure = -0.25

/datum/mutation_upgrade/shell/lone_healer/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Psychic Cure can now target yourself. Self-targetting causes it to heal for [PERCENT(1 + self_heal_multiplier_increase_initial + (self_heal_multiplier_increase_per_structure * new_amount))]% of its original amount and sets its cooldown to [PERCENT(1 + self_cooldown_percentage_increase_initial + (self_cooldown_percentage_increase_per_structure * new_amount))]% of its original amount."

/datum/mutation_upgrade/shell/lone_healer/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/psychic_cure/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_cure]
	if(!ability)
		return FALSE
	ability.self_bonus_cooldown_duration += self_heal_multiplier_increase_initial
	ability.self_heal_multiplier += self_cooldown_percentage_increase_initial
	ability.use_state_flags |= ABILITY_TARGET_SELF
	return ..()

/datum/mutation_upgrade/shell/lone_healer/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/psychic_cure/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_cure]
	if(!ability)
		return FALSE
	ability.self_bonus_cooldown_duration -= self_heal_multiplier_increase_initial
	ability.self_heal_multiplier -= self_cooldown_percentage_increase_initial
	ability.use_state_flags &= ABILITY_TARGET_SELF
	return ..()

/datum/mutation_upgrade/shell/lone_healer/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/psychic_cure/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_cure]
	if(!ability)
		return
	ability.self_bonus_cooldown_duration += (new_amount - previous_amount) * self_heal_multiplier_increase_per_structure
	ability.self_heal_multiplier += (new_amount - previous_amount) * self_cooldown_percentage_increase_per_structure

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/smashing_fling
	name = "Smashing Fling"
	desc = "Psychic Fling no longer stuns. It immediately deals 1/1.25/1.5x slashing damage to humans on use, can cause collusions, and deals 1/1.25/1.5x slashing damage if they collide with anything."
	/// For the first structure, the multiplier to increase immediate and collusion damage by.
	var/damage_multiplier_increase_initial = 0.75
	/// For each structure, the additional multiplier to increase immediate and collusion damage by.
	var/damage_multiplier_increase_per_structure = 0.25

/datum/mutation_upgrade/spur/smashing_fling/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Psychic Fling no longer stuns. It immediately deals [damage_multiplier_increase_initial + (damage_multiplier_increase_per_structure * new_amount)]x slashing damage to humans on use, can cause collusions, and deals [damage_multiplier_increase_initial + (damage_multiplier_increase_per_structure * new_amount)]x slashing damage if they collide with anything."

/datum/mutation_upgrade/spur/smashing_fling/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/psychic_fling/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_fling]
	if(!ability)
		return FALSE
	ability.immediate_damage_multiplier += damage_multiplier_increase_initial
	ability.collusion_damage_multiplier += damage_multiplier_increase_initial
	return ..()

/datum/mutation_upgrade/spur/smashing_fling/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/psychic_fling/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_fling]
	if(!ability)
		return FALSE
	ability.immediate_damage_multiplier -= damage_multiplier_increase_initial
	ability.collusion_damage_multiplier -= damage_multiplier_increase_initial
	return ..()

/datum/mutation_upgrade/spur/smashing_fling/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/psychic_fling/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_fling]
	if(!ability)
		return
	ability.immediate_damage_multiplier += (new_amount - previous_amount) * damage_multiplier_increase_per_structure
	ability.collusion_damage_multiplier += (new_amount - previous_amount) * damage_multiplier_increase_per_structure

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/stand_in_recycler
	name = "Stand-In Recycler"
	desc = "You gain the Recycle ability. It costs 80/65/50% of its original cost."
	/// For the first structure, the percentage amount to increase the ability's cost.
	var/cost_percentage_increase_initial = -0.05
	/// For each structure, the additional percentage amount to increase the ability's cost.
	var/cost_percentage_per_structure = -0.15

/datum/mutation_upgrade/veil/stand_in_recycler/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "You gain the Recycle ability. It costs [PERCENT(1 + cost_percentage_increase_initial + (cost_percentage_per_structure * new_amount))]% of its original cost."

/datum/mutation_upgrade/veil/stand_in_recycler/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/recycle/ability = new()
	ability.give_action(xenomorph_owner)
	ability.ability_cost += initial(ability.ability_cost) * cost_percentage_increase_initial
	return ..()

/datum/mutation_upgrade/veil/stand_in_recycler/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/recycle/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/recycle]
	if(ability)
		ability.remove_action(xenomorph_owner)
	return ..()

/datum/mutation_upgrade/veil/stand_in_recycler/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/recycle/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/recycle]
	if(!ability)
		return
	ability.ability_cost += initial(ability.cooldown_duration) * (new_amount - previous_amount) * cost_percentage_per_structure
