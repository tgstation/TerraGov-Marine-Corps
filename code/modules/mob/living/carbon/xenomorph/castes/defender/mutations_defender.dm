//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/carapace_waxing
	name = "Carapace Waxing"
	desc = "Regenerate Skin additionally reduces various debuffs by 1/2/3 stacks or 2/4/6 seconds."

/datum/mutation_upgrade/shell/carapace_waxing/on_structure_update(datum/source, previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/regenerate_skin/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/regenerate_skin]
	if(!ability)
		return FALSE
	ability.debuff_amount_to_remove += (new_amount - previous_amount)

/datum/mutation_upgrade/shell/brittle_upclose
	name = "Brittle Upclose"
	desc = "You can no longer be staggered by projectiles and gain 5/7.5/10 bullet armor. However, you lose 30/35/40 melee armor."

/datum/mutation_upgrade/shell/brittle_upclose/on_mutation_enabled()
	xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.modifyRating(-25, 2.5)
	ADD_TRAIT(xenomorph_owner, TRAIT_STAGGER_RESISTANT, TRAIT_MUTATION)
	return ..()

/datum/mutation_upgrade/shell/brittle_upclose/on_mutation_disabled()
	xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.modifyRating(25, -2.5)
	REMOVE_TRAIT(xenomorph_owner, TRAIT_STAGGER_RESISTANT, TRAIT_MUTATION)
	return ..()

/datum/mutation_upgrade/shell/brittle_upclose/on_structure_update(datum/source, previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/difference = new_amount - previous_amount
	xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.modifyRating(difference * -5, difference * 2.5)

/datum/mutation_upgrade/shell/carapace_regrowth
	name = "Carapace Regrowth"
	desc = "Regenerate Skin additionally recovers 50/60/70% of your maximum health, but will reduce all of your armor values by 30 for 6 seconds."
	/// The beginning percentage of the health to heal (at zero structures)
	var/beginning_percentage = 0.4
	/// The additional percentage of the health to heal for each structure.
	var/percentage_per_structure = 0.1

/datum/mutation_upgrade/shell/carapace_regrowth/on_mutation_enabled()
	var/datum/action/ability/xeno_action/regenerate_skin/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/regenerate_skin]
	if(!ability)
		return FALSE
	ability.percentage_to_heal += beginning_percentage
	ability.should_apply_temp_debuff = TRUE
	return ..()

/datum/mutation_upgrade/shell/carapace_regrowth/on_mutation_disabled()
	var/datum/action/ability/xeno_action/regenerate_skin/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/regenerate_skin]
	if(!ability)
		return FALSE
	ability.percentage_to_heal -= beginning_percentage
	ability.should_apply_temp_debuff = FALSE
	return ..()

/datum/mutation_upgrade/shell/carapace_regrowth/on_structure_update(datum/source, previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/regenerate_skin/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/regenerate_skin]
	if(!ability)
		return FALSE
	ability.percentage_to_heal += (new_amount - previous_amount) * percentage_per_structure

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/breathtaking_spin
	name = "Breathtaking Spin"
	desc = "Tail Swipe no longer stuns and deals stamina damage instead. It deals an additional 2x/2.75x/2.5x stamina damage."

/datum/mutation_upgrade/shell/breathtaking_spin/on_mutation_enabled()
	var/datum/action/ability/xeno_action/tail_sweep/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/tail_sweep]
	if(!ability)
		return FALSE
	ability.brute_damage_multiplier -= 1
	ability.stamina_damage_multiplier += 2.25
	ability.paralyze_duration -= 0.5 SECONDS
	return ..()

/datum/mutation_upgrade/shell/breathtaking_spin/on_mutation_disabled()
	var/datum/action/ability/xeno_action/tail_sweep/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/tail_sweep]
	if(!ability)
		return FALSE
	ability.brute_damage_multiplier += 1
	ability.stamina_damage_multiplier -= 2.25
	ability.paralyze_duration += 0.5 SECONDS
	return ..()

/datum/mutation_upgrade/spur/breathtaking_spin/on_structure_update(datum/source, previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/tail_sweep/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/tail_sweep]
	if(!ability)
		return FALSE
	ability.stamina_damage_multiplier += (new_amount - previous_amount) * 0.75

/datum/mutation_upgrade/spur/power_spin
	name = "Power Spin"
	desc = "Tail Swipe knockbacks humans one tile further and staggers them for 1/2/3s."

/datum/mutation_upgrade/spur/power_spin/on_mutation_enabled()
	var/datum/action/ability/xeno_action/tail_sweep/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/tail_sweep]
	if(!ability)
		return FALSE
	ability.knockback_distance += 1
	return ..()

/datum/mutation_upgrade/spur/power_spin/on_mutation_disabled()
	var/datum/action/ability/xeno_action/tail_sweep/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/tail_sweep]
	if(!ability)
		return FALSE
	ability.knockback_distance -= 1
	return ..()

/datum/mutation_upgrade/spur/power_spin/on_structure_update(datum/source, previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/tail_sweep/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/tail_sweep]
	if(!ability)
		return FALSE
	ability.stagger_duration += (new_amount - previous_amount) SECONDS

/datum/mutation_upgrade/spur/sharpening_claws
	name = "Sharpening Claws"
	desc = "For 10 sunder you have, you gain 3/6/9% additive increase in your slash damage."
	/// How many times has the melee damage modifier been increased?
	var/multiplier_so_far = 0

/datum/mutation_upgrade/spur/sharpening_claws/on_mutation_enabled()
	RegisterSignal(xenomorph_owner, COMSIG_XENOMORPH_SUNDER_CHANGE, PROC_REF(on_sunder_change))
	return ..()

/datum/mutation_upgrade/spur/sharpening_claws/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, COMSIG_XENOMORPH_SUNDER_CHANGE)
	return ..()

/datum/mutation_upgrade/spur/sharpening_claws/on_structure_update(datum/source, previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	xenomorph_owner.xeno_melee_damage_modifier -= multiplier_so_far * previous_amount * 0.03
	multiplier_so_far = 0
	on_sunder_change(null, 0, xenomorph_owner.sunder)

/// Changes melee damage modifier based on the difference between old and current sunder values.
/datum/mutation_upgrade/spur/sharpening_claws/proc/on_sunder_change(datum/source, old_sunder, new_sunder)
	SIGNAL_HANDLER
	var/multiplier_difference = (FLOOR(new_sunder, 10) * 0.1) - multiplier_so_far
	if(multiplier_difference == 0)
		return
	xenomorph_owner.xeno_melee_damage_modifier += multiplier_difference * get_total_structures() * 0.03
	multiplier_so_far += multiplier_difference

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/carapace_sweat
	name = "Carapace Sweat"
	desc = "Regenerate Skin can be used while on fire and grants fire immunity for 2/4/6 seconds. If you were on fire, you will be extinguished and set nearby humans on fire."

/datum/mutation_upgrade/veil/carapace_sweat/on_structure_update(datum/source, previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/regenerate_skin/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/regenerate_skin]
	if(!ability)
		return FALSE
	ability.fire_immunity_length += 2 * (new_amount - previous_amount) SECONDS

/datum/mutation_upgrade/veil/slow_and_steady
	name = "Slow and Steady"
	desc = "While Fortify is active, you can move at 10/20/30% of your movement speed."

/datum/mutation_upgrade/veil/slow_and_steady/on_mutation_enabled()
	var/datum/action/ability/xeno_action/fortify/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/fortify]
	if(!ability)
		return FALSE
	if(xenomorph_owner.fortify)
		REMOVE_TRAIT(xenomorph_owner, TRAIT_IMMOBILE, FORTIFY_TRAIT)
	else
		xenomorph_owner.add_movespeed_modifier(MOVESPEED_ID_MUTATION_SLOW_AND_STEADY, TRUE, 0, NONE, FALSE, movement_modifier)
		xenomorph_owner.client?.move_delay = world.time
	ability.movement_modifier += 12
	return ..()

/datum/mutation_upgrade/veil/slow_and_steady/on_mutation_disabled()
	var/datum/action/ability/xeno_action/fortify/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/fortify]
	if(!ability)
		return FALSE
	if(xenomorph_owner.fortify)
		ADD_TRAIT(xenomorph_owner, TRAIT_IMMOBILE, FORTIFY_TRAIT)
	else
		xenomorph_owner.remove_movespeed_modifier(MOVESPEED_ID_MUTATION_SLOW_AND_STEADY, TRUE)
	ability.movement_modifier -= 12
	return ..()

/datum/mutation_upgrade/veil/slow_and_steady/on_structure_update(datum/source, previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/fortify/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/fortify]
	if(!ability)
		return FALSE
	ability.movement_modifier -= 2 * (new_amount - previous_amount)

/datum/mutation_upgrade/veil/carapace_sharing
	name = "Carapace Sharing"
	desc = "Regenerate Skin additionally removes 8/16/24% sunder of a nearby friendly xenomorph. This prioritizes those with the highest sunder."

/datum/mutation_upgrade/veil/carapace_sharing/on_structure_update(datum/source, previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/regenerate_skin/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/regenerate_skin]
	if(!ability)
		return FALSE
	ability.percentage_to_unsunder_ally += (new_amount - previous_amount) * 0.08
