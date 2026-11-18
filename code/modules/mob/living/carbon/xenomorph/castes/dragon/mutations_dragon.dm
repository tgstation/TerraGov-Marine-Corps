//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/regenerative_armor
	name = "Regenerative Armor"
	desc = "Whenever you passively regenerate health, you will also gain 5% of your maximum plasma. This scales with regenerative power."
	/// The percentage (0-1) of the owner's maximum plasma to regenerate per second. Passive regeneration ticks are expected to be 2 seconds.
	var/percentage = 0.025

/datum/mutation_upgrade/shell/regenerative_armor/on_mutation_enabled()
	RegisterSignal(xenomorph_owner, COMSIG_XENOMORPH_HEALTH_REGEN, PROC_REF(on_health_regeneration))

/datum/mutation_upgrade/shell/regenerative_armor/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, list(COMSIG_XENOMORPH_HEALTH_REGEN))

/// Restores a percentage of the owner's plasma based on their maximum plasma and regeneration power.
/datum/mutation_upgrade/shell/regenerative_armor/proc/on_health_regeneration(datum/source, heal_data, seconds_per_tick)
	SIGNAL_HANDLER
	if(xenomorph_owner.regen_power <= 0)
		return
	xenomorph_owner.gain_plasma(xenomorph_owner.xeno_caste.plasma_max * percentage * (seconds_per_tick * XENO_PER_SECOND_LIFE_MOD) * xenomorph_owner.regen_power)

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/breath_of_variety
	name = "Breath of Variety"
	desc = "Dragon Breath can switch between additional fire types to replace it with different effects: shatter or melting acid. Dragon Breath's cooldown is set to 125% of its original cooldown."
	/// The multiplier of Dragon Breath's initial cooldown duration to add to the ability.
	var/multiplier_initial = 0.25

/datum/mutation_upgrade/spur/breath_of_variety/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/backhand/dragon_breath/breath_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/backhand/dragon_breath]
	if(breath_ability)
		breath_ability.cooldown_duration += initial(breath_ability.cooldown_duration) * multiplier_initial
		breath_ability.selectable_fire_images_list[DRAGON_BREATH_SHATTERING] = image('icons/effects/fire.dmi', icon_state = "violet_3")
		breath_ability.selectable_fire_images_list[DRAGON_BREATH_MELTING_ACID] = image('icons/effects/fire.dmi', icon_state = "green_3")

/datum/mutation_upgrade/spur/breath_of_variety/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/backhand/dragon_breath/breath_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/backhand/dragon_breath]
	if(breath_ability)
		breath_ability.cooldown_duration -= initial(breath_ability.cooldown_duration) * multiplier_initial
		breath_ability.selectable_fire_images_list[DRAGON_BREATH_SHATTERING] = null
		breath_ability.selectable_fire_images_list[DRAGON_BREATH_MELTING_ACID] = null

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/benevolence
	name = "Benevolence"
	desc = "You emit all types of pheromones at 2.5 power in a radius of 15."
	/// The power of the pheromones.
	var/power = 2.5
	/// The radius of the pheromones.
	var/radius = 15
	/// The frenzy aura if it exists.
	var/datum/aura_bearer/frenzy_aura
	/// The warding aura if it exists.
	var/datum/aura_bearer/warding_aura
	/// The recovery aura if it exists.
	var/datum/aura_bearer/recovery_aura

/datum/mutation_upgrade/veil/benevolence/on_mutation_enabled()
	frenzy_aura = SSaura.add_emitter(xenomorph_owner, AURA_XENO_FRENZY, radius, power, -1, FACTION_XENO, xenomorph_owner.hivenumber)
	warding_aura = SSaura.add_emitter(xenomorph_owner, AURA_XENO_WARDING, radius, power, -1, FACTION_XENO, xenomorph_owner.hivenumber)
	recovery_aura = SSaura.add_emitter(xenomorph_owner, AURA_XENO_RECOVERY, radius, power, -1, FACTION_XENO, xenomorph_owner.hivenumber)

/datum/mutation_upgrade/veil/benevolence/on_mutation_disabled()
	if(frenzy_aura)
		QDEL_NULL(frenzy_aura)
	if(warding_aura)
		QDEL_NULL(warding_aura)
	if(recovery_aura)
		QDEL_NULL(recovery_aura)
