//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/unmoving_link
	name = "Unmoving Link"
	desc = "While Psychic Link is active, you gain maximum movement resistance and gain 5/15/25 armor."
	/// For the first structure, the amount of soft armor that Psychic Link should grant while it is active.
	var/armor_initial = -5
	/// For each structure, the amount of soft armor that Psychic Link should grant while it is active.
	var/armor_per_structure = 10

/datum/mutation_upgrade/shell/unmoving_link/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "While Psychic Link is active, you gain maximum movement resistance and gain [get_armor(new_amount)] armor."

/datum/mutation_upgrade/shell/unmoving_link/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/psychic_link/link_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_link]
	if(!link_ability)
		return
	link_ability.armor_amount += get_armor(0)
	link_ability.movement_resistance = MOVE_FORCE_OVERPOWERING
	if(!link_ability.psychic_link_status_effect)
		return
	xenomorph_owner.move_resist = link_ability.movement_resistance
	if(!link_ability.attached_armor)
		link_ability.attached_armor = getArmor(link_ability.armor_amount, link_ability.armor_amount, link_ability.armor_amount, link_ability.armor_amount, link_ability.armor_amount, link_ability.armor_amount, link_ability.armor_amount, link_ability.armor_amount)
		xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.attachArmor(link_ability.attached_armor)

/datum/mutation_upgrade/shell/unmoving_link/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/psychic_link/link_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_link]
	if(!link_ability)
		return
	link_ability.armor_amount -= get_armor(0)
	link_ability.movement_resistance = initial(link_ability.movement_resistance)
	if(!link_ability.psychic_link_status_effect)
		return
	xenomorph_owner.move_resist = initial(xenomorph_owner.move_resist)
	if(link_ability.attached_armor)
		xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.detachArmor(link_ability.attached_armor)
		link_ability.attached_armor = null

/datum/mutation_upgrade/shell/unmoving_link/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/psychic_link/link_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_link]
	if(!link_ability)
		return
	var/difference = get_armor(new_amount - previous_amount, FALSE)
	link_ability.armor_amount += difference
	if(!link_ability.psychic_link_status_effect || !link_ability.attached_armor)
		return
	link_ability.attached_armor = link_ability.attached_armor.modifyAllRatings(difference)
	xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.modifyAllRatings(difference)

/// Returns the amount of soft armor that Psychic Link should grant while it is active.
/datum/mutation_upgrade/shell/unmoving_link/proc/get_armor(structure_count, include_initial = TRUE)
	return (include_initial ? armor_initial : 0) + (armor_per_structure * structure_count)

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/necrotic_link
	name = "Necrotic Link"
	desc = "Psychic Link no longer forces you to rest. While it is active, Drain is only 20/30/40% effective on corpses."
	/// For the first structure, the multiplier to add to Drain's corpse healing while Psychic Link is active.
	var/multiplier_initial = -0.9
	/// For each structure, the multiplier to add to Drain's corpse healing while Psychic Link is active.
	var/multiplier_per_structure = 0.1

/datum/mutation_upgrade/spur/necrotic_link/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Psychic Link no longer forces you to rest. While it is active, Drain is only [PERCENT(1 + get_multiplier(new_amount))]% effective on corpses."

/datum/mutation_upgrade/spur/necrotic_link/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/psychic_link/link_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_link]
	if(!link_ability)
		return
	link_ability.set_required_rest(FALSE)
	link_ability.drain_healing_multiplier += get_multiplier(0)

/datum/mutation_upgrade/spur/necrotic_link/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/psychic_link/link_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_link]
	if(!link_ability)
		return
	link_ability.set_required_rest(initial(link_ability.required_rest))
	link_ability.drain_healing_multiplier -= get_multiplier(0)

/datum/mutation_upgrade/spur/necrotic_link/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/psychic_link/link_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_link]
	if(!link_ability)
		return
	link_ability.drain_healing_multiplier += get_multiplier(new_amount - previous_amount, FALSE)

/// Returns the multiplier to add to Drain's corpse healing while Psychic Link is active.
/datum/mutation_upgrade/spur/necrotic_link/proc/get_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? multiplier_initial : 0) + (multiplier_per_structure * structure_count)

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/burst_healing
	name = "Burst Healing"
	desc = "Transfusion heals an additional 8/12/16% maximum health. The plasma cost is set to 150/175/200% of its their original value."
	/// For the first structure, the multiplier to increase Transfusion's plasma cost by.
	var/multiplier_initial = 0.25
	/// For each structure, the multiplier to increase Transfusion's plasma cost by.
	var/multiplier_per_structure = 0.25
	/// For the first structure, the amount to add to Transfusion's maximum health healing percentage. 1 = 100% of maximum health, 0.01 = 1% of maximum health.
	var/amount_initial = 0.04
	/// For each structure, the amount to add to Transfusion's maximum health healing percentage. 1 = 100% of maximum health, 0.01 = 1% of maximum health.
	var/amount_per_structure = 0.04

/datum/mutation_upgrade/veil/burst_healing/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Transfusion heals an additional [PERCENT(get_amount(new_amount))]% maximum health, but requires twice as much plasma."

/datum/mutation_upgrade/veil/burst_healing/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/transfusion/transfusion_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/transfusion]
	if(!transfusion_ability)
		return
	transfusion_ability.ability_cost += initial(transfusion_ability.ability_cost) * get_multiplier(0)
	transfusion_ability.heal_percentage += get_amount(0)

/datum/mutation_upgrade/veil/burst_healing/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/transfusion/transfusion_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/transfusion]
	if(!transfusion_ability)
		return
	transfusion_ability.ability_cost -= initial(transfusion_ability.ability_cost) * get_multiplier(0)
	transfusion_ability.heal_percentage -= get_amount(0)

/datum/mutation_upgrade/veil/burst_healing/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/transfusion/transfusion_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/transfusion]
	if(!transfusion_ability)
		return
	transfusion_ability.ability_cost += initial(transfusion_ability.ability_cost) * get_multiplier(new_amount - previous_amount, FALSE)
	transfusion_ability.heal_percentage += get_amount(new_amount - previous_amount, FALSE)

/// Returns the amount to add to Transfusion's maximum health healing percentage.
/datum/mutation_upgrade/veil/burst_healing/proc/get_amount(structure_count, include_initial = TRUE)
	return (include_initial ? amount_initial : 0) + (amount_per_structure * structure_count)

/// Returns the multiplier to increase Transfusion's plasma cost by.
/datum/mutation_upgrade/veil/burst_healing/proc/get_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? multiplier_initial : 0) + (multiplier_per_structure * structure_count)


