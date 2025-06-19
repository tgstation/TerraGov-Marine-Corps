//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/rocky_layers
	name = "Rocky Layers"
	desc = "When your health is 50% or lower, gain 15/20/25 hard armor."
	/// For the first structure, the amount of hard armor to grant.
	var/hard_armor_initial = 10
	/// For each structure, the additional amount of hard armor to grant.
	var/hard_armor_per_structure = 5
	/// The percentage of maximum health to reach in order to activate this.
	var/max_health_percentage_threshold = 0.50
	/// The attached hard armor, if any.
	var/datum/armor/attached_armor

/datum/mutation_upgrade/shell/rocky_layers/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "When your health is [max_health_percentage_threshold * 100]% or lower, gain [hard_armor_initial + (hard_armor_per_structure * new_amount)] hard armor."

/datum/mutation_upgrade/shell/rocky_layers/on_mutation_enabled()
	RegisterSignals(xenomorph_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE), PROC_REF(on_damage))
	if(xenomorph_owner.health <= (xenomorph_owner.maxHealth * (max_health_percentage_threshold)))
		toggle()
	return ..()

/datum/mutation_upgrade/shell/rocky_layers/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE))
	if(attached_armor)
		toggle()
	return ..()

/datum/mutation_upgrade/shell/rocky_layers/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!. || !attached_armor)
		return
	toggle() // Remove the armor (old).
	toggle() // Add the armor (new).

/// Increases or decreases the critical threshold amount for the owner.
/datum/mutation_upgrade/shell/rocky_layers/proc/toggle()
	if(!attached_armor)
		attached_armor = new()
		attached_armor.modifyAllRatings(hard_armor_initial + (hard_armor_per_structure * get_total_structures()))
		xenomorph_owner.hard_armor.attachArmor(attached_armor)
		return
	xenomorph_owner.hard_armor.detachArmor(attached_armor)
	attached_armor = null

/// Checks on the next tick if anything needs to be done with their new health since it is possible the health is inaccurate (because there can be other modifiers).
/datum/mutation_upgrade/shell/rocky_layers/proc/on_damage(datum/source, amount, list/amount_mod)
	SIGNAL_HANDLER
	INVOKE_NEXT_TICK(src, PROC_REF(check_current_health))

/// If their health is negative, activate it if possible. If it is full, let them activate it next time.
/datum/mutation_upgrade/shell/rocky_layers/proc/check_current_health()
	if(xenomorph_owner.health > (xenomorph_owner.maxHealth * max_health_percentage_threshold))
		if(attached_armor)
			toggle()
		return
	toggle()

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/refined_palate
	name = "Refined Palate"
	desc = "Your slashes deal 0.5/1/1.5x more damage to barricades."
	/// For each structure, the added multiplier of damage applied to barricades.
	var/damage_multiplier_per_structure = 0.5

/datum/mutation_upgrade/spur/refined_palate/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Your slashes deal [damage_multiplier_per_structure * new_amount]x more damage to barricades."

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
	target.take_damage(xenomorph_owner.xeno_caste.melee_damage * xenomorph_owner.xeno_melee_damage_modifier * (damage_multiplier_per_structure * get_total_structures()), xenomorph_owner.xeno_caste.melee_damage_type, xenomorph_owner.xeno_caste.melee_damage_armor)
	playsound(xenomorph_owner, 'sound/items/eatfood.ogg', 9, 1) // Nom nom nom!

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/avalanche
	name = "Avalanche"
	desc = "Earth Riser can have 1/2/3 more pillars active at a time, but its cooldown duration is doubled."
	/// For each structure, the additional amount of pillars that can be active at a time.
	var/pillars_per_structure = 1

/datum/mutation_upgrade/veil/avalanche/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/earth_riser/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/earth_riser]
	if(!ability)
		return FALSE
	ability.cooldown_duration += initial(ability.cooldown_duration)
	return ..()

/datum/mutation_upgrade/veil/avalanche/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/earth_riser/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/earth_riser]
	if(!ability)
		return FALSE
	ability.cooldown_duration -= initial(ability.cooldown_duration)
	return ..()

/datum/mutation_upgrade/veil/avalanche/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/earth_riser/earth_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/earth_riser]
	if(!earth_ability)
		return FALSE
	earth_ability.maximum_pillars_default += (new_amount - previous_amount) * pillars_per_structure
	var/datum/action/ability/xeno_action/primal_wrath/wrath_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/primal_wrath]
	if(wrath_ability && !wrath_ability.toggled)
		earth_ability.change_maximum_pillars(earth_ability.maximum_pillars_default)
