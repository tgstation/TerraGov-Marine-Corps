//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/carapace_waxing
	name = "Carapace Waxing"
	desc = "Regenerate Skin additionally reduces various debuffs by 2 stacks or 4 seconds."
	/// The amount (in stacks / 2x seconds) that Regenerate Skin will reduce negative status effects by.
	var/debuff_reduction = 2

/datum/mutation_upgrade/shell/carapace_waxing/on_mutation_enabled()
	var/datum/action/ability/xeno_action/regenerate_skin/regenerate_skin = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/regenerate_skin]
	if(!regenerate_skin)
		return
	regenerate_skin.debuff_removal_amount += debuff_reduction

/datum/mutation_upgrade/shell/carapace_waxing/on_mutation_disabled()
	var/datum/action/ability/xeno_action/regenerate_skin/regenerate_skin = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/regenerate_skin]
	if(!regenerate_skin)
		return
	regenerate_skin.debuff_removal_amount -= debuff_reduction

/datum/mutation_upgrade/shell/brittle_upclose
	name = "Brittle Upclose"
	desc = "You can no longer be staggered by projectiles and gain 7.5 bullet armor, but lose 35 melee armor. Projectiles from pointblank range negate this bonus bullet armor."
	/// The amount of bullet armor to increase by.
	var/bullet_armor_increase = 7.5
	/// The amount of melee armor to increase by.
	var/melee_armor_increase = -35

/datum/mutation_upgrade/shell/brittle_upclose/on_mutation_enabled()
	xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.modifyRating(melee_armor_increase, bullet_armor_increase)
	RegisterSignal(xenomorph_owner, COMSIG_XENO_PROJECTILE_HIT, PROC_REF(pre_projectile_hit))
	ADD_TRAIT(xenomorph_owner, TRAIT_STAGGER_RESISTANT, MUTATION_TRAIT)

/datum/mutation_upgrade/shell/brittle_upclose/on_mutation_disabled()
	xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.modifyRating(melee_armor_increase, bullet_armor_increase)
	UnregisterSignal(xenomorph_owner, list(COMSIG_XENO_PROJECTILE_HIT))
	REMOVE_TRAIT(xenomorph_owner, TRAIT_STAGGER_RESISTANT, MUTATION_TRAIT)

/// When hit by a non-friendly projectile at pointblank range, have the projectile deal additional damage.
/datum/mutation_upgrade/shell/brittle_upclose/proc/pre_projectile_hit(datum/source, atom/movable/projectile/proj, cardinal_move, uncrossing)
	SIGNAL_HANDLER
	if(xenomorph_owner.issamexenohive(proj.firer))
		return
	if(proj.distance_travelled >= 2)
		return
	proj.damage *= (1 + (bullet_armor_increase / 100)) // Effectively negates the bonus bullet armor.

/datum/mutation_upgrade/shell/carapace_regrowth
	name = "Carapace Regrowth"
	desc = "Regenerate Skin additionally recovers 60% of your maximum health, but will reduce all of your armor values by 30 for 6 seconds."
	/// The amount to increase Regenerate Skin's healing multiplier by.
	var/heal_multiplier = 0.6
	/// How much should the armor debuff value be?
	var/armor_debuff_amount = 30

/datum/mutation_upgrade/shell/carapace_regrowth/on_mutation_enabled()
	var/datum/action/ability/xeno_action/regenerate_skin/regenerate_skin = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/regenerate_skin]
	if(!regenerate_skin)
		return
	regenerate_skin.heal_multiplier += heal_multiplier
	regenerate_skin.armor_debuff_amount += armor_debuff_amount

/datum/mutation_upgrade/shell/carapace_regrowth/on_mutation_disabled()
	var/datum/action/ability/xeno_action/regenerate_skin/regenerate_skin = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/regenerate_skin]
	if(!regenerate_skin)
		return
	regenerate_skin.heal_multiplier -= heal_multiplier
	regenerate_skin.armor_debuff_amount -= armor_debuff_amount

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/breathtaking_spin
	name = "Breathtaking Spin"
	desc = "Tail Swipe deals stamina damage instead. It no longer paralyzes, but deals 1.75x more damage."
	/// The amount to increase Tail Swipe's damage multiplier by.
	var/damage_multiplier = 1.75

/datum/mutation_upgrade/spur/breathtaking_spin/on_mutation_enabled()
	var/datum/action/ability/xeno_action/tail_sweep/tail_sweep = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/tail_sweep]
	if(!tail_sweep)
		return
	tail_sweep.damage_multiplier += damage_multiplier
	tail_sweep.damage_type = STAMINA
	tail_sweep.paralyze_duration -= initial(tail_sweep.paralyze_duration)

/datum/mutation_upgrade/spur/breathtaking_spin/on_mutation_disabled()
	var/datum/action/ability/xeno_action/tail_sweep/tail_sweep = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/tail_sweep]
	if(!tail_sweep)
		return
	tail_sweep.damage_multiplier -= damage_multiplier
	tail_sweep.damage_type = initial(tail_sweep.damage_type)
	tail_sweep.paralyze_duration += initial(tail_sweep.paralyze_duration)

/datum/mutation_upgrade/spur/power_spin
	name = "Power Spin"
	desc = "Tail Swipe's knockback is increased by 1 tile and staggers for 2 seconds."
	/// The amount to increase Tail Swipe's knockback by.
	var/knockback_amount = 1
	/// The amount of deciseconds to increase Tail Swipe's stagger duration by.
	var/stagger_duration = 2 SECONDS

/datum/mutation_upgrade/spur/power_spin/on_mutation_enabled()
	var/datum/action/ability/xeno_action/tail_sweep/tail_sweep = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/tail_sweep]
	if(!tail_sweep)
		return
	tail_sweep.knockback_distance += knockback_amount
	tail_sweep.stagger_duration += stagger_duration

/datum/mutation_upgrade/spur/power_spin/on_mutation_disabled()
	var/datum/action/ability/xeno_action/tail_sweep/tail_sweep = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/tail_sweep]
	if(!tail_sweep)
		return
	tail_sweep.knockback_distance -= knockback_amount
	tail_sweep.stagger_duration -= stagger_duration

/datum/mutation_upgrade/spur/sharpening_claws
	name = "Sharpening Claws"
	desc = "For each 10 sunder / missing armor, your melee damage multiplier is increased by 6%."
	/// The amount of sunder used to determine the final multiplier.
	var/sunder_repeating_threshold = 10
	/// The amount to increase the melee damage modifier by for each time the sunder threshold is passed.
	var/modifier = 0.06
	/// The amount that the melee damage modifier has been increased by so far.
	var/modifier_so_far = 0

/datum/mutation_upgrade/spur/sharpening_claws/on_mutation_enabled()
	RegisterSignal(xenomorph_owner, COMSIG_XENOMORPH_SUNDER_CHANGE, PROC_REF(on_sunder_change))
	on_sunder_change(null, 0, xenomorph_owner.sunder)

/datum/mutation_upgrade/spur/sharpening_claws/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, COMSIG_XENOMORPH_SUNDER_CHANGE)
	on_sunder_change(null, xenomorph_owner.sunder, 0)

/// Changes melee damage modifier based on the difference between old and current sunder values.
/datum/mutation_upgrade/spur/sharpening_claws/proc/on_sunder_change(datum/source, old_sunder, new_sunder)
	SIGNAL_HANDLER
	var/new_modifier = round(new_sunder / sunder_repeating_threshold) * modifier
	if(new_modifier == modifier_so_far)
		return
	xenomorph_owner.xeno_melee_damage_modifier += (new_modifier - modifier_so_far)
	modifier_so_far = new_modifier

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/carapace_sweat
	name = "Carapace Sweat"
	desc = "Regenerate Skin can be used while on fire and will apply Resin Jelly to you for 4 seconds. If you were on fire, you will be extinguished and set nearby humans on fire."
	/// The amount of deciseconds that the Resin Jelly status effect will have.
	var/duration = 4 SECONDS


/datum/mutation_upgrade/veil/carapace_sweat/on_mutation_enabled()
	var/datum/action/ability/xeno_action/regenerate_skin/regenerate_skin = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/regenerate_skin]
	if(!regenerate_skin)
		return
	regenerate_skin.resin_jelly_duration += duration

/datum/mutation_upgrade/veil/carapace_sweat/on_mutation_disabled()
	var/datum/action/ability/xeno_action/regenerate_skin/regenerate_skin = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/regenerate_skin]
	if(!regenerate_skin)
		return
	regenerate_skin.resin_jelly_duration -= duration

/datum/mutation_upgrade/veil/slow_and_steady
	name = "Slow and Steady"
	desc = "You are no longer immobilized during Fortify. However, your move delay is increased by 1 second while it is active."
	/// The amount of deciseconds of delay to add to movement while Fortify is active.
	var/movement_delay = 1 SECONDS

/datum/mutation_upgrade/veil/slow_and_steady/on_mutation_enabled()
	var/datum/action/ability/xeno_action/fortify/fortify = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/fortify]
	if(!fortify)
		return
	fortify.should_immobilize = FALSE
	fortify.set_movement_delay(fortify.movement_delay + movement_delay)

/datum/mutation_upgrade/veil/slow_and_steady/on_mutation_disabled()
	var/datum/action/ability/xeno_action/fortify/fortify = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/fortify]
	if(!fortify)
		return
	fortify.should_immobilize = initial(fortify.should_immobilize)
	fortify.set_movement_delay(fortify.movement_delay - movement_delay)

/datum/mutation_upgrade/veil/carapace_sharing
	name = "Carapace Sharing"
	desc = "Regenerate Skin additionally removes 16% sunder of a nearby friendly xenomorph. This prioritizes those with the highest sunder."
	/// The amount to increase Regenerate Skin's ally sunder healing multiplier by.
	var/ally_unsunder_multiplier = 0.16

/datum/mutation_upgrade/veil/carapace_sharing/on_mutation_enabled()
	var/datum/action/ability/xeno_action/regenerate_skin/regenerate_skin = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/regenerate_skin]
	if(!regenerate_skin)
		return
	regenerate_skin.ally_unsunder_multiplier += ally_unsunder_multiplier


/datum/mutation_upgrade/veil/carapace_sharing/on_mutation_disabled()
	var/datum/action/ability/xeno_action/regenerate_skin/regenerate_skin = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/regenerate_skin]
	if(!regenerate_skin)
		return
	regenerate_skin.ally_unsunder_multiplier -= ally_unsunder_multiplier
