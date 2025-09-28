//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/cautious_mind
	name = "Cautious Mind"
	desc = "Psychic Shield will attempt to detonate if it was automatically canceled while the shield is intact. The detonation cost is now 125/100/75% of its original cost."
	/// For the first structure,the multiplier of Psychic Shield's initial ability cost to add to the ability cost.
	var/cost_multiplier_initial = 0.5
	/// For each structure, the multiplier of Psychic Shield's initial ability cost to add to the ability cost.
	var/cost_multiplier_per_structure = -0.25

/datum/mutation_upgrade/shell/cautious_mind/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Psychic Shield will attempt to detonate if it was canceled while the shield is intact. The detonation cost is now [PERCENT(1 + get_multiplier(new_amount))]% of its original cost."

/datum/mutation_upgrade/shell/cautious_mind/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/psychic_shield/shield_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_shield]
	if(!shield_ability)
		return
	shield_ability.detonates_on_cancel = TRUE
	shield_ability.detonation_cost += initial(shield_ability.detonation_cost) * get_multiplier(0)

/datum/mutation_upgrade/shell/cautious_mind/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/psychic_shield/shield_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_shield]
	if(!shield_ability)
		return
	shield_ability.detonates_on_cancel = initial(shield_ability.detonates_on_cancel)
	shield_ability.detonation_cost -= initial(shield_ability.detonation_cost) * get_multiplier(0)

/datum/mutation_upgrade/shell/cautious_mind/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/psychic_shield/shield_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_shield]
	if(!shield_ability)
		return
	shield_ability.detonation_cost += initial(shield_ability.detonation_cost) * get_multiplier(new_amount - previous_amount, FALSE)

/// Returns the multiplier of Psychic Shield's initial ability cost to add to the ability cost.
/datum/mutation_upgrade/shell/cautious_mind/proc/get_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? cost_multiplier_initial : 0) + (cost_multiplier_per_structure * structure_count)

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/draining_blast
	name = "Draining Blast"
	desc = "Psychic Blast now switch to a different type of beam called Psychic Drain; it deals 0.7x stamina damage, briefly knockdowns on direct impact, and knockback on non-direct impact. Psychic Drain's cooldown is 95/90/85% of its original cooldown."
	/// For each structure, the multiplier to add to Psychic Blast's cooldown.
	var/multiplier_per_structure = -0.05

/datum/mutation_upgrade/spur/draining_blast/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Psychic Blast now switch to a different type of beam called Psychic Drain; it deals 0.7x stamina damage, briefly knockdowns on direct impact, and knockback on non-direct impact. Psychic Drain's cooldown is [PERCENT(1 + get_multiplier(new_amount))]% of its original cooldown."

/datum/mutation_upgrade/spur/draining_blast/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/psy_blast/blast_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psy_blast]
	if(!blast_ability)
		return
	blast_ability.selectable_ammo_types += /datum/ammo/energy/xeno/psy_blast/psy_drain

/datum/mutation_upgrade/spur/draining_blast/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/psy_blast/blast_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psy_blast]
	if(!blast_ability)
		return
	blast_ability.selectable_ammo_types -= /datum/ammo/energy/xeno/psy_blast/psy_drain

/datum/mutation_upgrade/spur/draining_blast/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/psy_blast/blast_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psy_blast]
	if(!blast_ability)
		return
	blast_ability.cooldown_duration += initial(blast_ability.cooldown_duration) * get_multiplier(new_amount - previous_amount)

/// Returns the multiplier to add to Psychic Blast's cooldown.
/datum/mutation_upgrade/spur/draining_blast/proc/get_multiplier(structure_count)
	return multiplier_per_structure * structure_count

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/mobile_mind
	name = "Mobile Mind"
	desc = "Psychic Shield no longer forces you to remain still to keep the shield up. However, the shield sizzles out when manually detonating and slows you down by 0.8/0.6/0.4 while it is active."
	/// For the first structure, the amount to increase Psychic Shield's movement speed modifier by.
	var/movespeed_initial = 1
	/// For each structure, the amount to increase Psychic Shield's movement speed modifier by.
	var/movespeed_per_structure = -0.2

/datum/mutation_upgrade/veil/mobile_mind/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Psychic Shield no longer forces you to remain still to keep the shield up. However, the shield sizzles out when manually detonating and slows you down by [get_movespeed(new_amount)] while it is active."

/datum/mutation_upgrade/veil/mobile_mind/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/psychic_shield/shield_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_shield]
	if(!shield_ability)
		return
	shield_ability.do_after_flags |= (IGNORE_USER_LOC_CHANGE|IGNORE_TARGET_LOC_CHANGE)
	shield_ability.can_manually_detonate = FALSE
	shield_ability.movement_speed_modifier += get_movespeed(0)

/datum/mutation_upgrade/veil/mobile_mind/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/psychic_shield/shield_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_shield]
	if(!shield_ability)
		return
	shield_ability.do_after_flags &= ~(IGNORE_USER_LOC_CHANGE|IGNORE_TARGET_LOC_CHANGE)
	shield_ability.can_manually_detonate = initial(shield_ability.can_manually_detonate)
	shield_ability.movement_speed_modifier -= get_movespeed(0)

/datum/mutation_upgrade/veil/mobile_mind/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/psychic_shield/shield_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_shield]
	if(!shield_ability)
		return
	shield_ability.movement_speed_modifier += get_movespeed(new_amount - previous_amount, FALSE)

/// Returns the amount to increase Psychic Shield's movement speed modifier by.
/datum/mutation_upgrade/veil/mobile_mind/proc/get_movespeed(structure_count, include_initial = TRUE)
	return (include_initial ? movespeed_initial : 0) + (movespeed_per_structure * structure_count)
