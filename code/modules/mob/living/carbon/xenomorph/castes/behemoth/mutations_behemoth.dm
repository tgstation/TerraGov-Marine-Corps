//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/rocky_layers
	name = "Rocky Layers"
	desc = "When your health is 50% or lower, gain 15/20/25 hard armor."
	/// For the first structure, the amount of hard armor that will be granted.
	var/armor_initial = 10
	/// For each structure, the amount of hard armor that will be granted.
	var/armor_per_structure = 5
	/// The percentage of maximum health to reach in order to activate this.
	var/max_health_percentage_threshold = 0.5
	/// The attached hard armor, if any.
	var/datum/armor/attached_armor

/datum/mutation_upgrade/shell/rocky_layers/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "When your health is [PERCENT(max_health_percentage_threshold)]% or lower, gain [get_armor(new_amount)] hard armor."

/datum/mutation_upgrade/shell/rocky_layers/on_mutation_enabled()
	RegisterSignal(xenomorph_owner, COMSIG_LIVING_UPDATE_HEALTH, PROC_REF(on_update_health))
	if(xenomorph_owner.health <= (xenomorph_owner.maxHealth * max_health_percentage_threshold))
		toggle()
	return ..()

/datum/mutation_upgrade/shell/rocky_layers/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, COMSIG_LIVING_UPDATE_HEALTH)
	if(attached_armor)
		toggle()
	return ..()

/datum/mutation_upgrade/shell/rocky_layers/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!attached_armor)
		return
	var/difference = get_armor(previous_amount - new_amount)
	xenomorph_owner.hard_armor = xenomorph_owner.hard_armor.modifyAllRatings(difference)
	attached_armor = attached_armor.modifyAllRatings(difference)

/// Gives or removes the hard armor.
/datum/mutation_upgrade/shell/rocky_layers/proc/toggle()
	if(!attached_armor)
		var/armor_amount = get_armor(get_total_structures())
		attached_armor = getArmor(armor_amount, armor_amount, armor_amount, armor_amount, armor_amount, armor_amount, armor_amount, armor_amount)
		xenomorph_owner.hard_armor = xenomorph_owner.hard_armor.attachArmor(attached_armor)
		return
	xenomorph_owner.hard_armor = xenomorph_owner.hard_armor.detachArmor(attached_armor)
	attached_armor = null

/// If their health is negative, activate it if possible. If it is full, let them activate it next time.
/datum/mutation_upgrade/shell/rocky_layers/proc/on_update_health(datum/source)
	SIGNAL_HANDLER
	var/health = (xenomorph_owner.status_flags & GODMODE) ? xenomorph_owner.maxHealth : (xenomorph_owner.maxHealth - xenomorph_owner.getFireLoss() - xenomorph_owner.getBruteLoss())
	if(health <= xenomorph_owner.get_death_threshold())
		return
	var/meets_threshold = (xenomorph_owner.health <= (xenomorph_owner.maxHealth * max_health_percentage_threshold))
	if((meets_threshold && !attached_armor) || (!meets_threshold && attached_armor))
		toggle()

/// Returns the amount of hard armor that will be granted.
/datum/mutation_upgrade/shell/rocky_layers/proc/get_armor(structure_count)
	return armor_initial + (armor_per_structure * structure_count)

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/refined_palate
	name = "Refined Palate"
	desc = "Your slashes deal an additional 0.5/1/1.5x damage to barricades."
	/// For each structure, the multiplier to add as a second instance of damage to barricades.
	var/multiplier_per_structure = 0.5

/datum/mutation_upgrade/spur/refined_palate/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Your slashes deal an additional [get_multiplier(new_amount)]x damage to barricades."

/datum/mutation_upgrade/spur/refined_palate/on_mutation_enabled()
	RegisterSignal(xenomorph_owner, COMSIG_XENOMORPH_ATTACK_OBJ, PROC_REF(on_attack_obj))
	return ..()

/datum/mutation_upgrade/spur/refined_palate/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, COMSIG_XENOMORPH_ATTACK_OBJ)
	return ..()

/// Deals a variable amount of damage to barricades.
/datum/mutation_upgrade/spur/refined_palate/proc/on_attack_obj(mob/living/carbon/xenomorph/source, obj/target)
	SIGNAL_HANDLER
	if(!(target.resistance_flags & XENO_DAMAGEABLE) || !isbarricade(target))
		return
	target.take_damage(xenomorph_owner.xeno_caste.melee_damage * xenomorph_owner.xeno_melee_damage_modifier * get_multiplier(get_total_structures()), xenomorph_owner.xeno_caste.melee_damage_type, xenomorph_owner.xeno_caste.melee_damage_armor)
	playsound(xenomorph_owner, 'sound/items/eatfood.ogg', 9, 1) // Nom nom nom!

/// Returns the multiplier to add as a second instance of damage to barricades.
/datum/mutation_upgrade/spur/refined_palate/proc/get_multiplier(structure_count)
	return multiplier_per_structure * structure_count

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/avalanche
	name = "Avalanche"
	desc = "Earth Riser can have 1/2/3 more pillars active at a time, but its cooldown duration is doubled."
	/// For each structure, the amount that Earth Riser's maximum pillars should be increased by.
	var/amount_per_structure = 1

/datum/mutation_upgrade/veil/avalanche/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Earth Riser can have [get_amount(new_amount)] more pillars active at a time, but its cooldown duration is doubled."

/datum/mutation_upgrade/veil/avalanche/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/earth_riser/earth_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/earth_riser]
	if(!earth_ability)
		return
	var/datum/action/ability/xeno_action/primal_wrath/wrath_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/primal_wrath]
	if(wrath_ability?.ability_active) // When the wrath turns off, all the changes will be applied to the non-wrath version.
		wrath_ability.earth_riser_cooldown_changed -= initial(earth_ability.cooldown_duration)
		return
	earth_ability.cooldown_duration += initial(earth_ability.cooldown_duration)

/datum/mutation_upgrade/veil/avalanche/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/earth_riser/earth_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/earth_riser]
	if(!earth_ability)
		return
	var/datum/action/ability/xeno_action/primal_wrath/wrath_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/primal_wrath]
	if(wrath_ability?.ability_active) // When the wrath turns off, all the changes will be applied to the non-wrath version.
		wrath_ability.earth_riser_cooldown_changed += initial(earth_ability.cooldown_duration)
		return
	earth_ability.cooldown_duration -= initial(earth_ability.cooldown_duration)

/datum/mutation_upgrade/veil/avalanche/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/earth_riser/earth_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/earth_riser]
	if(!earth_ability)
		return
	var/datum/action/ability/xeno_action/primal_wrath/wrath_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/primal_wrath]
	if(wrath_ability?.ability_active) // When the wrath turns off, all the changes will be applied to the non-wrath version.
		wrath_ability.earth_riser_pillars_changed -= get_amount(new_amount - previous_amount)
		return
	earth_ability.maximum_pillars += get_amount(new_amount - previous_amount)

/// Returns the amount that Earth Riser's maximum pillars should be increased by.
/datum/mutation_upgrade/veil/avalanche/proc/get_amount(structure_count)
	return amount_per_structure * structure_count
