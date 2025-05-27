//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/carapace_waxing
	name = "Carapace Waxing"
	desc = "Regenerate Skin additionally reduces various debuffs by 1/2/3 stacks or 2/4/6 seconds."
	/// For each structure, the amount of additional stacks to decrease debuffs by.
	var/reduction_per_structure = 1

/datum/mutation_upgrade/shell/carapace_waxing/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Regenerate Skin additionally reduces various debuffs by [reduction_per_structure * new_amount] stacks or [reduction_per_structure * new_amount * 2] seconds."

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
	desc = "You can no longer be staggered by projectiles. You gain 5/7.5/10 bullet armor, but lose 30/35/40 melee armor."
	/// For the first structure, the amount of bullet armor to increase by.
	var/bullet_armor_increase_initial = 2.5
	/// For each structure, the amount of additional bullet armor to increase by.
	var/bullet_armor_increase_per_structure = 2.5
	/// For the first structure, the amount of melee armor to decrease by.
	var/melee_armor_reduction_initial = 25
	/// For each structure, the amount of additional melee armor to by.
	var/melee_armor_reduction_per_structure = 5

/datum/mutation_upgrade/shell/brittle_upclose/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "You can no longer be staggered by projectiles. You gain [bullet_armor_increase_initial + (bullet_armor_increase_per_structure * new_amount)] bullet armor, but lose [melee_armor_reduction_initial + (melee_armor_reduction_per_structure * new_amount)] melee armor."

/datum/mutation_upgrade/shell/brittle_upclose/on_mutation_enabled()
	xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.modifyRating(melee_armor_reduction_initial, bullet_armor_increase_initial)
	ADD_TRAIT(xenomorph_owner, TRAIT_STAGGER_RESISTANT, TRAIT_MUTATION)
	return ..()

/datum/mutation_upgrade/shell/brittle_upclose/on_mutation_disabled()
	xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.modifyRating(melee_armor_reduction_initial, -bullet_armor_increase_initial)
	REMOVE_TRAIT(xenomorph_owner, TRAIT_STAGGER_RESISTANT, TRAIT_MUTATION)
	return ..()

/datum/mutation_upgrade/shell/brittle_upclose/on_structure_update(datum/source, previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.modifyRating((new_amount - previous_amount) * -melee_armor_reduction_per_structure, (new_amount - previous_amount) * bullet_armor_increase_per_structure)

/datum/mutation_upgrade/shell/carapace_regrowth
	name = "Carapace Regrowth"
	desc = "Regenerate Skin additionally recovers 50/60/70% of your maximum health, but will reduce all of your armor values by 30 for 6 seconds."
	/// For the first structure, the percentage amount of maximum health to heal by.
	var/maximum_health_percentage_initial = 0.4
	/// For each structure, the additional percentage amount of maximum health to heal by.
	var/maximum_health_percentage_per_structure = 0.1
	/// How much should the armor debuff value be?
	var/armor_debuff_amount = 30

/datum/mutation_upgrade/shell/carapace_regrowth/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Regenerate Skin additionally recovers [100 * (maximum_health_percentage_initial + (maximum_health_percentage_per_structure * new_amount))]% of your maximum health, but will reduce all of your armor values by [armor_debuff_amount] for 6 seconds."

/datum/mutation_upgrade/shell/carapace_regrowth/on_mutation_enabled()
	var/datum/action/ability/xeno_action/regenerate_skin/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/regenerate_skin]
	if(!ability)
		return FALSE
	ability.percentage_to_heal += maximum_health_percentage_initial
	ability.temporary_armor_debuff_amount += armor_debuff_amount
	return ..()

/datum/mutation_upgrade/shell/carapace_regrowth/on_mutation_disabled()
	var/datum/action/ability/xeno_action/regenerate_skin/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/regenerate_skin]
	if(!ability)
		return FALSE
	ability.percentage_to_heal -= maximum_health_percentage_initial
	ability.temporary_armor_debuff_amount -= armor_debuff_amount
	return ..()

/datum/mutation_upgrade/shell/carapace_regrowth/on_structure_update(datum/source, previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/regenerate_skin/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/regenerate_skin]
	if(!ability)
		return FALSE
	ability.percentage_to_heal += (new_amount - previous_amount) * maximum_health_percentage_per_structure

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/breathtaking_spin
	name = "Breathtaking Spin"
	desc = "Tail Swipe deals 2/2.25/2.5x more damage, but it is all stamina damage and no longer stuns."
	/// For the first structure, the multiplier to add as stamina damage.
	var/stamina_damage_multiplier_initial = 1.75
	/// For each structure, the additional multiplier to add as stamina damage.
	var/stamina_damage_multiplier_per_structure = 0.25

/datum/mutation_upgrade/spur/breathtaking_spin/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Tail Swipe deals [stamina_damage_multiplier_initial + (stamina_damage_multiplier_per_structure * new_amount)]x more damage, but it is all stamina damage and no longer stuns."

/datum/mutation_upgrade/spur/breathtaking_spin/on_mutation_enabled()
	var/datum/action/ability/xeno_action/tail_sweep/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/tail_sweep]
	if(!ability)
		return FALSE
	ability.brute_damage_multiplier -= initial(ability.brute_damage_multiplier)
	ability.stamina_damage_multiplier += (initial(ability.brute_damage_multiplier) + stamina_damage_multiplier_initial)
	ability.paralyze_duration -= initial(ability.paralyze_duration)
	return ..()

/datum/mutation_upgrade/spur/breathtaking_spin/on_mutation_disabled()
	var/datum/action/ability/xeno_action/tail_sweep/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/tail_sweep]
	if(!ability)
		return FALSE
	ability.brute_damage_multiplier += initial(ability.brute_damage_multiplier)
	ability.stamina_damage_multiplier -= (initial(ability.brute_damage_multiplier) + stamina_damage_multiplier_initial)
	ability.paralyze_duration += initial(ability.paralyze_duration)
	return ..()

/datum/mutation_upgrade/spur/breathtaking_spin/on_structure_update(datum/source, previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/tail_sweep/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/tail_sweep]
	if(!ability)
		return FALSE
	ability.stamina_damage_multiplier += (new_amount - previous_amount) * stamina_damage_multiplier_per_structure

/datum/mutation_upgrade/spur/power_spin
	name = "Power Spin"
	desc = "Tail Swipe's knockback is increased by 1 tile and staggers for 1/2/3 seconds."
	/// For the first structure, the knockback to add.
	var/knockback_initial = 1
	/// For each structure, the amount of deciseconds to add as stagger.
	var/stagger_per_structure = 1 SECONDS

/datum/mutation_upgrade/spur/power_spin/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Tail Swipe's knockback is increased by [knockback_initial] tile and staggers for [(stagger_per_structure * new_amount * 0.1)] seconds."

/datum/mutation_upgrade/spur/power_spin/on_mutation_enabled()
	var/datum/action/ability/xeno_action/tail_sweep/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/tail_sweep]
	if(!ability)
		return FALSE
	ability.knockback_distance += knockback_initial
	return ..()

/datum/mutation_upgrade/spur/power_spin/on_mutation_disabled()
	var/datum/action/ability/xeno_action/tail_sweep/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/tail_sweep]
	if(!ability)
		return FALSE
	ability.knockback_distance -= knockback_initial
	return ..()

/datum/mutation_upgrade/spur/power_spin/on_structure_update(datum/source, previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/tail_sweep/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/tail_sweep]
	if(!ability)
		return FALSE
	ability.stagger_duration += (new_amount - previous_amount) * stagger_per_structure

/datum/mutation_upgrade/spur/sharpening_claws
	name = "Sharpening Claws"
	desc = "For each 10 sunder / missing armor, your melee damage multiplier is increased by 3/6/9%."
	/// The amount of sunder used to determine the final multiplier.
	var/sunder_repeating_threshold = 10
	/// For each structure, the additional amount to increase melee damage modifier by.
	var/damage_per_structure = 0.03
	/// The amount that the melee damage modifier has been increased by so far.
	var/modifier_so_far = 0

/datum/mutation_upgrade/spur/sharpening_claws/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "For each [sunder_repeating_threshold] sunder / missing armor, your melee damage multiplier is increased by [damage_per_structure * 100]%."

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
	xenomorph_owner.xeno_melee_damage_modifier -= modifier_so_far
	modifier_so_far = 0
	on_sunder_change(null, 0, xenomorph_owner.sunder)

/// Changes melee damage modifier based on the difference between old and current sunder values.
/datum/mutation_upgrade/spur/sharpening_claws/proc/on_sunder_change(datum/source, old_sunder, new_sunder)
	SIGNAL_HANDLER
	var/new_modifier = round(new_sunder / sunder_repeating_threshold) * get_total_structures() * damage_per_structure
	if(new_modifier == modifier_so_far)
		return
	xenomorph_owner.xeno_melee_damage_modifier += (new_modifier - modifier_so_far)
	modifier_so_far = new_modifier

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/carapace_sweat
	name = "Carapace Sweat"
	desc = "Regenerate Skin can be used while on fire and grants fire immunity for 2/4/6 seconds. If you were on fire, you will be extinguished and set nearby humans on fire."
	/// For each structure, the additional deciseconds of fire immunity to give.
	var/fire_immunity_per_structure = 2 SECONDS

/datum/mutation_upgrade/veil/carapace_sweat/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Regenerate Skin can be used while on fire and grants fire immunity for [fire_immunity_per_structure * new_amount * 0.1] seconds. If you were on fire, you will be extinguished and set nearby humans on fire."

/datum/mutation_upgrade/veil/carapace_sweat/on_structure_update(datum/source, previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/regenerate_skin/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/regenerate_skin]
	if(!ability)
		return FALSE
	ability.fire_immunity_length += (new_amount - previous_amount) * fire_immunity_per_structure

/datum/mutation_upgrade/veil/slow_and_steady
	name = "Slow and Steady"
	desc = "While Fortify is active, you can move at 10/20/30% of your movement speed."

/datum/mutation_upgrade/veil/slow_and_steady/on_mutation_enabled()
	var/datum/action/ability/xeno_action/fortify/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/fortify]
	if(!ability)
		return FALSE
	ability.movement_modifier += 12
	if(xenomorph_owner.fortify)
		REMOVE_TRAIT(xenomorph_owner, TRAIT_IMMOBILE, FORTIFY_TRAIT)
	else
		xenomorph_owner.add_movespeed_modifier(MOVESPEED_ID_MUTATION_SLOW_AND_STEADY, TRUE, 0, NONE, FALSE, ability.movement_modifier)
		xenomorph_owner.client?.move_delay = world.time
	return ..()

/datum/mutation_upgrade/veil/slow_and_steady/on_mutation_disabled()
	var/datum/action/ability/xeno_action/fortify/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/fortify]
	if(!ability)
		return FALSE
	ability.movement_modifier -= 12
	if(xenomorph_owner.fortify)
		ADD_TRAIT(xenomorph_owner, TRAIT_IMMOBILE, FORTIFY_TRAIT)
	else
		xenomorph_owner.remove_movespeed_modifier(MOVESPEED_ID_MUTATION_SLOW_AND_STEADY, TRUE)
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
