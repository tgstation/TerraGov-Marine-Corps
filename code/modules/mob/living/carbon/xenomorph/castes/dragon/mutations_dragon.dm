//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/regenerative_armor
	name = "Regenerative Armor"
	desc = "Whenever you regenerate health, you will also gain 2.5/5/7.5% of your maximum plasma. This scales with regenerative power only."
	/// For each structure, the additional percentage amount of plasma to restore every 2 seconds.
	var/plasma_percentage_per_structure = 0.025

/datum/mutation_upgrade/shell/regenerative_armor/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Whenever you regenerate health, you will also gain [PERCENT(plasma_percentage_per_structure * new_amount)]% of your maximum plasma. This scales with regenerative power only."

/datum/mutation_upgrade/shell/regenerative_armor/on_mutation_enabled()
	RegisterSignal(xenomorph_owner, COMSIG_XENOMORPH_HEALTH_REGEN, PROC_REF(on_health_regeneration))
	return ..()

/datum/mutation_upgrade/shell/regenerative_armor/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, list(COMSIG_XENOMORPH_HEALTH_REGEN))
	return ..()

/// Restores an percentage of the owner's plasma scaling with the amount of structure and regeneration power.
/datum/mutation_upgrade/shell/regenerative_armor/proc/on_health_regeneration(datum/source, heal_data, seconds_per_tick)
	SIGNAL_HANDLER
	if(xenomorph_owner.regen_power <= 0)
		return
	xenomorph_owner.gain_plasma(xenomorph_owner.xeno_caste.plasma_max * (plasma_percentage_per_structure * get_total_structures()) * (seconds_per_tick / 2) * xenomorph_owner.regen_power)

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/breath_of_variety
	name = "Breath of Variety"
	desc = "Dragon Breath can switch between additional fire types to replace it with different effects: shatter or melting acid. Dragon Breath's cooldown is set to 150/125/100% of its original cooldown."
	/// For the first structure, the percentage amount to increase the ability's cooldown.
	var/cooldown_percentage_increase_initial = 0.75
	/// For each structure, the additional percentage amount to increase the ability's cooldown.
	var/cooldown_percentage_per_structure = -0.25

/datum/mutation_upgrade/spur/breath_of_variety/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Dragon Breath can switch between additional fire types to replace it with different effects: shatter or melting acid. Dragon Breath's cooldown is set to 150/125/100% [PERCENT((1 + cooldown_percentage_increase_initial + (cooldown_percentage_per_structure * new_amount)))] of its original cooldown."

/datum/mutation_upgrade/spur/breath_of_variety/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/backhand/dragon_breath/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/backhand/dragon_breath]
	if(!ability)
		return FALSE
	ability.cooldown_duration += initial(ability.cooldown_duration) * cooldown_percentage_increase_initial
	ability.selectable_fire_images_list["Shattering"] = image('icons/effects/fire.dmi', icon_state = "violet_3")
	ability.selectable_fire_images_list["Melting Acid"] = image('icons/effects/fire.dmi', icon_state = "green_3")
	return ..()

/datum/mutation_upgrade/spur/breath_of_variety/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/backhand/dragon_breath/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/backhand/dragon_breath]
	if(!ability)
		return FALSE
	ability.cooldown_duration -= initial(ability.cooldown_duration) * cooldown_percentage_increase_initial
	ability.selectable_fire_images_list["Shattering"] = null
	ability.selectable_fire_images_list["Melting Acid"] = null
	return ..()

/datum/mutation_upgrade/spur/breath_of_variety/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/backhand/dragon_breath/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/backhand/dragon_breath]
	if(!ability)
		return FALSE
	ability.cooldown_duration += initial(ability.cooldown_duration) * (new_amount - previous_amount) * cooldown_percentage_per_structure

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/benevolence
	name = "Benevolence"
	desc = "You emit all types of pheromones at 2/2.5/3 power in a radius of 14/15/16."
	/// For the first structure, the amount of power to increase the pheromones by.
	var/power_increase_initial = 1.5
	/// For each structure, the additional amount of power to increase the pheromones by.
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

/datum/mutation_upgrade/veil/benevolence/on_mutation_disabled()
	QDEL_NULL(frenzy_aura)
	QDEL_NULL(warding_aura)
	QDEL_NULL(recovery_aura)
	return ..()

/datum/mutation_upgrade/veil/benevolence/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
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
