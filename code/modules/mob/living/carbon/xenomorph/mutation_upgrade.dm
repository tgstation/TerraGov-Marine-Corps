/datum/mutation_upgrade
	/// The name that is displayed in the TGUI.
	var/name
	/// The description that is displayed in the TGUI.
	var/desc
	/// The category slot that this upgrade takes. This prevents the owner from buying additional mutation that have the same category.
	var/category
	/// The structure that needs to exist for a successful purchase.
	var/required_structure
	/// The status effect given upon successful purchase.
	var/datum/status_effect/status_effect
	/// The xenomorph owner of this mutation upgrade.
	var/mob/living/carbon/xenomorph/xenomorph_owner

/datum/mutation_upgrade/New(mob/living/carbon/xenomorph/new_xeno_owner)
	..()
	xenomorph_owner = new_xeno_owner
	xenomorph_owner.apply_status_effect(status_effect)
	switch(required_structure)
		if(MUTATION_STRUCTURE_SHELL)
			RegisterSignal(SSdcs, COMSIG_MUTATION_CHAMBER_SHELL, PROC_REF(on_building_update))
		if(MUTATION_STRUCTURE_SPUR)
			RegisterSignal(SSdcs, COMSIG_MUTATION_CHAMBER_SPUR, PROC_REF(on_building_update))
		if(MUTATION_STRUCTURE_VEIL)
			RegisterSignal(SSdcs, COMSIG_MUTATION_CHAMBER_VEIL, PROC_REF(on_building_update))
	on_building_update(null, 0, get_total_buildings())

/datum/mutation_upgrade/Destroy(force, ...)
	xenomorph_owner.remove_status_effect(status_effect)
	switch(required_structure)
		if(MUTATION_STRUCTURE_SHELL)
			UnregisterSignal(SSdcs, COMSIG_MUTATION_CHAMBER_SHELL)
		if(MUTATION_STRUCTURE_SPUR)
			UnregisterSignal(SSdcs, COMSIG_MUTATION_CHAMBER_SPUR)
		if(MUTATION_STRUCTURE_VEIL)
			UnregisterSignal(SSdcs, COMSIG_MUTATION_CHAMBER_VEIL)
	on_building_update(null, get_total_buildings(), 0)
	return ..()

/// Called whenever the mutation is created/deleted or when the amount of buildings has changed.
/datum/mutation_upgrade/proc/on_building_update(datum/source, previous_amount, new_amount)
	SIGNAL_HANDLER
	if(previous_amount == new_amount)
		return TRUE

/// Gets the total amount of buildings for the mutation.
/datum/mutation_upgrade/proc/get_total_buildings()
	if(!xenomorph_owner || !required_structure)
		return 0
	switch(required_structure)
		if(MUTATION_STRUCTURE_SHELL)
			return length(xenomorph_owner.hive.shell_chambers)
		if(MUTATION_STRUCTURE_SPUR)
			return length(xenomorph_owner.hive.spur_chambers)
		if(MUTATION_STRUCTURE_VEIL)
			return length(xenomorph_owner.hive.veil_chambers)

/**
 * Shell Mutations
 */
/datum/mutation_upgrade/shell
	category = MUTATION_CATEGORY_SHELL
	required_structure = MUTATION_STRUCTURE_SHELL
	status_effect = /datum/status_effect/mutation_shell_upgrade

// Defender
/datum/mutation_upgrade/shell/carapace_waxing
	name = "Carapace Waxing"
	desc = "Regenerate Skin additionally reduces various debuffs by 1/2/3 stacks or 2/4/6 seconds."

/datum/mutation_upgrade/shell/carapace_waxing/on_building_update(datum/source, previous_amount, new_amount)
	if(..())
		return
	var/datum/action/ability/xeno_action/regenerate_skin/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/regenerate_skin]
	if(!ability)
		return
	ability.debuff_amount_to_remove += (new_amount - previous_amount)

/datum/mutation_upgrade/shell/brittle_upclose
	name = "Brittle Upclose"
	desc = "You can no longer be staggered by projectiles and gain 5/7.5/10 bullet armor. However, you lose 30/35/40 melee armor."

/datum/mutation_upgrade/shell/brittle_upclose/on_building_update(datum/source, previous_amount, new_amount)
	if(..())
		return
	if(previous_amount > 0)
		xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.modifyRating(25, -2.5)
		REMOVE_TRAIT(xenomorph_owner, TRAIT_STAGGER_RESISTANT, MUTATION_TRAIT)
	if(new_amount > 0)
		xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.modifyRating(-25, 2.5)
		ADD_TRAIT(xenomorph_owner, TRAIT_STAGGER_RESISTANT, MUTATION_TRAIT)
	var/difference = new_amount - previous_amount
	xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.modifyRating(difference * -5, difference * 2.5)

/datum/mutation_upgrade/shell/carapace_regrowth
	name = "Carapace Regrowth"
	desc = "Regenerate Skin additionally recovers 50/60/70% of your maximum health, but will reduce all of your armor values by 30 for 6 seconds."

/datum/mutation_upgrade/shell/carapace_regrowth/on_building_update(datum/source, previous_amount, new_amount)
	if(..())
		return
	var/datum/action/ability/xeno_action/regenerate_skin/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/regenerate_skin]
	if(!ability)
		return
	if(previous_amount > 0)
		ability.percentage_to_heal -= 0.40
		ability.should_apply_temp_debuff = FALSE
	if(new_amount > 0)
		ability.percentage_to_heal += 0.40
		ability.should_apply_temp_debuff = TRUE
	ability.percentage_to_heal += (new_amount - previous_amount) * 0.10

/**
 * Spur
 */
/datum/mutation_upgrade/spur
	category = MUTATION_CATEGORY_SPUR
	required_structure = MUTATION_STRUCTURE_SPUR
	status_effect = /datum/status_effect/mutation_spur_upgrade

// Defender
/datum/mutation_upgrade/spur/breathtaking_spin
	name = "Breathtaking Spin"
	desc = "Tail Swipe no longer stuns and deals only stamina damage. It deals an additional 3x/3.75x/4.5x stamina damage."

/datum/mutation_upgrade/spur/breathtaking_spin/on_building_update(datum/source, previous_amount, new_amount)
	if(..())
		return
	var/datum/action/ability/xeno_action/tail_sweep/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/tail_sweep]
	if(!ability)
		return
	if(previous_amount > 0)
		ability.stamina_multiplier -= 2.25
	if(new_amount > 0)
		ability.stamina_multiplier += 2.25
	ability.stamina_multiplier += (new_amount - previous_amount) * 0.75

/datum/mutation_upgrade/spur/power_spin
	name = "Power Spin"
	desc = "Forward Charge empowers your next Tail Swipe. Depending on the amount of built structures, it will: knockback further, deal 1.5x additional stamina damage, and stun for twice as long."

/datum/mutation_upgrade/spur/power_spin/on_building_update(datum/source, previous_amount, new_amount)
	if(..())
		return
	var/datum/action/ability/xeno_action/tail_sweep/sweep_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/tail_sweep]
	if(!sweep_ability)
		return
	var/datum/action/ability/activable/xeno/charge/forward_charge/charge_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/charge/forward_charge]
	if(!charge_ability)
		return
	sweep_ability.empowered_strength = min(new_amount, sweep_ability.empowered_strength)
	charge_ability.empowering_strength = new_amount

/datum/mutation_upgrade/spur/sharpening_claws
	name = "Sharpening Claws"
	desc = "For 10 sunder you have, you gain 3/6/9% additive increase in your slash damage."
	/// How many times has the melee damage modifier been increased?
	var/multiplier = 0

/datum/mutation_upgrade/spur/sharpening_claws/on_building_update(datum/source, previous_amount, new_amount)
	if(..())
		return
	if(previous_amount > 0)
		UnregisterSignal(xenomorph_owner, COMSIG_XENOMORPH_SUNDER_CHANGE)
	if(new_amount > 0)
		RegisterSignal(xenomorph_owner, COMSIG_XENOMORPH_SUNDER_CHANGE, PROC_REF(on_sunder_change))
	xenomorph_owner.xeno_melee_damage_modifier -= multiplier * previous_amount * 0.03
	multiplier = 0
	on_sunder_change(null, 0, xenomorph_owner.sunder)

/// Changes melee damage modifier based on the difference between old and current sunder values.
/datum/mutation_upgrade/spur/sharpening_claws/proc/on_sunder_change(datum/source, old_sunder, new_sunder)
	SIGNAL_HANDLER
	var/multiplier_difference = (FLOOR(new_sunder, 10) * 0.1) - multiplier
	if(multiplier_difference == 0)
		return
	xenomorph_owner.xeno_melee_damage_modifier += multiplier_difference * get_total_buildings() * 0.03
	multiplier += multiplier_difference

/**
 * Veil
 */
/datum/mutation_upgrade/veil
	category = MUTATION_CATEGORY_VEIL
	required_structure = MUTATION_STRUCTURE_VEIL
	status_effect = /datum/status_effect/mutation_veil_upgrade

// Defender
/datum/mutation_upgrade/veil/carapace_sweat
	name = "Carapace Sweat"
	desc = "Regenerate Skin can be used while on fire and grants fire immunity for 2/4/6 seconds. If you were on fire, you will be extinguished and set nearby humans on fire."

/datum/mutation_upgrade/veil/carapace_sweat/on_building_update(datum/source, previous_amount, new_amount)
	if(..())
		return

	var/datum/action/ability/xeno_action/regenerate_skin/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/regenerate_skin]
	if(!ability)
		return
	ability.fire_immunity_length += 2 * (new_amount - previous_amount) SECONDS

/datum/mutation_upgrade/veil/slow_and_steady
	name = "Slow and Steady"
	desc = "While Fortify is active, you can move at 10/20/30% of your movement speed."

/datum/mutation_upgrade/veil/slow_and_steady/on_building_update(datum/source, previous_amount, new_amount)
	if(..())
		return
	var/datum/action/ability/xeno_action/fortify/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/fortify]
	if(!ability)
		return
	if(previous_amount > 0)
		ability.movement_modifier -= 12
	if(new_amount > 0)
		ability.movement_modifier += 12 // Eyeballing the movement speed and hope that it is close enough in function.
	ability.movement_modifier -= 2 * (new_amount - previous_amount)

/datum/mutation_upgrade/veil/carapace_sharing
	name = "Carapace Sharing"
	desc = "Regenerate Skin additionally removes 8/16/24% sunder of a nearby friendly xenomorph. This prioritizes those with the highest sunder."

/datum/mutation_upgrade/veil/carapace_sharing/on_building_update(datum/source, previous_amount, new_amount)
	if(..())
		return
	var/datum/action/ability/xeno_action/regenerate_skin/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/regenerate_skin]
	if(!ability)
		return
	ability.percentage_to_unsunder_ally += (new_amount - previous_amount) * 0.08
