//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/cautious_mind
	name = "Cautious Mind"
	desc = "Psychic Shield will attempt to detonate if it was canceled while the shield is intact. The detonation cost is now 125/100/75% of its original cost."
	/// For the first structure, the multiplier to increase the cost by.
	var/cost_multiplier_initial = 0.5
	/// For each structure, the multiplier to increase the cost by.
	var/cost_multiplier_per_structure = -0.25

/datum/mutation_upgrade/shell/cautious_mind/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Psychic Shield will attempt to detonate if it was canceled while the shield is intact. The detonation cost is now [PERCENT(1 + get_multiplier(new_amount))]% of its original cost."

/datum/mutation_upgrade/shell/cautious_mind/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/psychic_shield/psychic_shield = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_shield]
	if(!psychic_shield)
		return FALSE
	psychic_shield.always_detonate = TRUE
	psychic_shield.detonation_cost += initial(psychic_shield.detonation_cost) * cost_multiplier_initial
	return ..()

/datum/mutation_upgrade/shell/cautious_mind/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/psychic_shield/psychic_shield = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_shield]
	if(!psychic_shield)
		return FALSE
	psychic_shield.always_detonate = initial(psychic_shield.always_detonate)
	psychic_shield.detonation_cost -= initial(psychic_shield.detonation_cost) * cost_multiplier_initial
	return ..()

/datum/mutation_upgrade/shell/cautious_mind/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/psychic_shield/psychic_shield = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_shield]
	if(!psychic_shield)
		return
	psychic_shield.detonation_cost += initial(psychic_shield.detonation_cost) * get_multiplier(new_amount - previous_amount, FALSE)

/// Returns the multiplier that the mutation should be adding to the ability's plasma cost.
/datum/mutation_upgrade/shell/cautious_mind/proc/get_multiplier(structure_count, include_initial = TRUE)
	if(!structure_count)
		structure_count = get_total_structures()
	return (include_initial ? cost_multiplier_initial : 0) + (cost_multiplier_per_structure * structure_count)

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/draining_blast
	name = "Draining Blast"
	desc = "Psychic Blast now switch to a different type of beam called Psychic Drain; it deals 0.7x stamina damage, briefly knockdowns on direct impact, and knockback on non-direct impact. Psychic Drain's cooldown is 95/90/85% of its original cooldown. "
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
	psy_blast.cooldown_duration += initial(psy_blast.cooldown_duration) * get_multiplier(new_amount - previous_amount)

/// Returns the multiplier to add to Psychic Blast's cooldown.
/datum/mutation_upgrade/spur/draining_blast/proc/get_multiplier(structure_count)
	return multiplier_per_structure * structure_count
//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/mobile_mind
	name = "Mobile Mind"
	desc = "Psychic Shield now creates self-sustaining shield which no longer requires you to stand still, but cannot be manually detonated. While it is active, you are 0.8/0.6/0.4 slower."
	/// For the first structure, the amount of movespeed to give.
	var/movespeed_initial = 1
	/// For each structure, the amount of movespeed to give.
	var/movespeed_per_structure = -0.2

/datum/mutation_upgrade/veil/mobile_mind/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Psychic Shield no longer requires you to stand still, but cannot be canceled or detonated manually. While it is active, you are [get_movespeed(new_amount)] slower."

/datum/mutation_upgrade/veil/mobile_mind/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/psychic_shield/psychic_shield = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_shield]
	if(!psychic_shield)
		return FALSE
	psychic_shield.can_manually_detonate = FALSE
	psychic_shield.movespeed_modifier_amount += get_movespeed(0)
	return ..()

/datum/mutation_upgrade/veil/mobile_mind/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/psychic_shield/psychic_shield = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_shield]
	if(!psychic_shield)
		return FALSE
	psychic_shield.can_manually_detonate = FALSE
	psychic_shield.movespeed_modifier_amount -= get_movespeed(0)
	return ..()

/datum/mutation_upgrade/veil/mobile_mind/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/psychic_shield/psychic_shield = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_shield]
	if(!psychic_shield)
		return
	psychic_shield.movespeed_modifier_amount += get_movespeed(new_amount - previous_amount, FALSE)

/// Returns the movespeed that the mutation should be adding to the ability.
/datum/mutation_upgrade/veil/mobile_mind/proc/get_movespeed(structure_count, include_initial = TRUE)
	return (include_initial ? movespeed_initial : 0) + (movespeed_per_structure * structure_count)
