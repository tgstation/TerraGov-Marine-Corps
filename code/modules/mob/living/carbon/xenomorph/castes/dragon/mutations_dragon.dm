//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/regenerative_armor
	name = "Regenerative Armor"
	desc = "Whenever you passively regenerate health, you will also gain 2.5/5/7.5% of your maximum plasma. This scales with regenerative power."
	/// For each structure, the percentage (0-1) of the owner's maximum plasma to regenerate.
	var/percentage_per_structure = 0.025

/datum/mutation_upgrade/shell/regenerative_armor/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Whenever you regenerate health, you will also gain [PERCENT(get_percentage(new_amount))]% of your maximum plasma. This scales with regenerative power."

/datum/mutation_upgrade/shell/regenerative_armor/on_mutation_enabled()
	RegisterSignal(xenomorph_owner, COMSIG_XENOMORPH_HEALTH_REGEN, PROC_REF(on_health_regeneration))
	return ..()

/datum/mutation_upgrade/shell/regenerative_armor/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, list(COMSIG_XENOMORPH_HEALTH_REGEN))
	return ..()

/// Restores a percentage of the owner's plasma based on their maximum plasma then scaling with the amount of structure and regeneration power.
/datum/mutation_upgrade/shell/regenerative_armor/proc/on_health_regeneration(datum/source, heal_data, seconds_per_tick)
	SIGNAL_HANDLER
	if(xenomorph_owner.regen_power <= 0)
		return
	xenomorph_owner.gain_plasma(xenomorph_owner.xeno_caste.plasma_max * get_percentage(get_total_structures()) * (seconds_per_tick * XENO_PER_SECOND_LIFE_MOD) * xenomorph_owner.regen_power)

/// Returns the percentage (0-1) of the owner's maximum plasma to regenerate.
/datum/mutation_upgrade/shell/regenerative_armor/proc/get_percentage(structure_count)
	return percentage_per_structure * structure_count

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/breath_of_variety
	name = "Breath of Variety"
	desc = "Dragon Breath can switch between additional fire types to replace it with different effects: shatter or melting acid. Dragon Breath's cooldown is set to 150/125/100% of its original cooldown."
	/// For the first structure, the multiplier of Dragon Breath's initial cooldown duration to add to the ability.
	var/multiplier_initial = 0.75
	/// For each structure, the multiplier of Dragon Breath's initial cooldown duration to add to the ability.
	var/multiplier_per_structure = -0.25

/datum/mutation_upgrade/spur/breath_of_variety/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Dragon Breath can switch between additional fire types to replace it with different effects: shatter or melting acid. Dragon Breath's cooldown is set to 150/125/100% [PERCENT((1 + get_multiplier(new_amount)))] of its original cooldown."

/datum/mutation_upgrade/spur/breath_of_variety/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/backhand/dragon_breath/breath_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/backhand/dragon_breath]
	if(!breath_ability)
		return
	breath_ability.cooldown_duration += initial(breath_ability.cooldown_duration) * get_multiplier(0)
	breath_ability.selectable_fire_images_list[DRAGON_BREATH_SHATTERING] = image('icons/effects/fire.dmi', icon_state = "violet_3")
	breath_ability.selectable_fire_images_list[DRAGON_BREATH_MELTING_ACID] = image('icons/effects/fire.dmi', icon_state = "green_3")

/datum/mutation_upgrade/spur/breath_of_variety/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/backhand/dragon_breath/breath_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/backhand/dragon_breath]
	if(!breath_ability)
		return
	breath_ability.cooldown_duration -= initial(breath_ability.cooldown_duration) * get_multiplier(0)
	breath_ability.selectable_fire_images_list[DRAGON_BREATH_SHATTERING] = null
	breath_ability.selectable_fire_images_list[DRAGON_BREATH_MELTING_ACID] = null

/datum/mutation_upgrade/spur/breath_of_variety/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/backhand/dragon_breath/breath_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/backhand/dragon_breath]
	if(!breath_ability)
		return
	breath_ability.cooldown_duration += initial(breath_ability.cooldown_duration) * get_multiplier(new_amount - previous_amount, FALSE)

/// Returns the multiplier of Dragon Breath's initial cooldown duration to add to the ability.
/datum/mutation_upgrade/spur/breath_of_variety/proc/get_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? multiplier_initial : 0) + (multiplier_per_structure * structure_count)

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/benevolence
	name = "Benevolence"
	desc = "You emit all types of pheromones at 2/2.5/3 power in a radius of 14/15/16."
	/// For the first structure, the amount of power to increase the pheromones by.
	var/power_increase_initial = 1.5
	/// For each structure, the amount of power to increase the pheromones by.
	var/power_increase_per_structure = 0.5
	/// The frenzy aura if it exists.
	var/datum/aura_bearer/frenzy_aura
	/// The warding aura if it exists.
	var/datum/aura_bearer/warding_aura
	/// The recovery aura if it exists.
	var/datum/aura_bearer/recovery_aura

/datum/mutation_upgrade/veil/benevolence/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "You emit all types of pheromones at [get_power(new_amount)] power in a radius of [get_radius(new_amount)]."

/datum/mutation_upgrade/veil/benevolence/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(frenzy_aura)
		QDEL_NULL(frenzy_aura)
	if(warding_aura)
		QDEL_NULL(warding_aura)
	if(recovery_aura)
		QDEL_NULL(recovery_aura)
	if(!new_amount)
		return
	frenzy_aura = SSaura.add_emitter(xenomorph_owner, AURA_XENO_FRENZY, get_radius(new_amount), get_power(new_amount), -1, FACTION_XENO, xenomorph_owner.hivenumber)
	warding_aura = SSaura.add_emitter(xenomorph_owner, AURA_XENO_WARDING, get_radius(new_amount), get_power(new_amount), -1, FACTION_XENO, xenomorph_owner.hivenumber)
	recovery_aura = SSaura.add_emitter(xenomorph_owner, AURA_XENO_RECOVERY, get_radius(new_amount), get_power(new_amount), -1, FACTION_XENO, xenomorph_owner.hivenumber)

/// Returns the power of the aura(s).
/datum/mutation_upgrade/veil/benevolence/proc/get_power(structure_count)
	return power_increase_initial + (power_increase_per_structure * structure_count)

/// Returns the radius of the aura(s).
/datum/mutation_upgrade/veil/benevolence/proc/get_radius(power)
	return (6 + power) * 2
