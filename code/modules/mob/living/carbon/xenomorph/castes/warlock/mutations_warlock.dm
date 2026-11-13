//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/cautious_mind
	name = "Cautious Mind"
	desc = "Psychic Shield will attempt to detonate if it was automatically canceled while the shield is intact."


/datum/mutation_upgrade/shell/cautious_mind/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/psychic_shield/shield_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_shield]
	if(!shield_ability)
		return
	shield_ability.detonates_on_cancel = TRUE

/datum/mutation_upgrade/shell/cautious_mind/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/psychic_shield/shield_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_shield]
	if(!shield_ability)
		return
	shield_ability.detonates_on_cancel = initial(shield_ability.detonates_on_cancel)

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/draining_blast
	name = "Draining Blast"
	desc = "Psychic Blast now switch to a different type of beam called Psychic Drain; it deals 0.7x stamina damage, briefly knockdowns on direct impact, and knockback on non-direct impact. Psychic Drain's cooldown is 90% of its original cooldown."
	/// The multiplier to add to Psychic Blast's cooldown.
	var/cooldown_multiplier = -0.1


/datum/mutation_upgrade/spur/draining_blast/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/psy_blast/blast_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psy_blast]
	if(!blast_ability)
		return
	blast_ability.selectable_ammo_types += /datum/ammo/energy/xeno/psy_blast/psy_drain
	blast_ability.cooldown_duration += initial(blast_ability.cooldown_duration) * cooldown_multiplier

/datum/mutation_upgrade/spur/draining_blast/on_mutation_disabled()

	var/datum/action/ability/activable/xeno/psy_blast/blast_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psy_blast]
	if(!blast_ability)
		return
	blast_ability.selectable_ammo_types -= /datum/ammo/energy/xeno/psy_blast/psy_drain
	blast_ability.cooldown_duration -= initial(blast_ability.cooldown_duration) * cooldown_multiplier

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/mobile_mind
	name = "Mobile Mind"
	desc = "Psychic Shield no longer forces you to remain still to keep the shield up. However, the shield sizzles out when manually detonating and slows you down by 0.6 while it is active."
	/// The amount to increase Psychic Shield's movement speed modifier by.
	var/movespeed_change = 0.6 // Negative = faster. Positive = slower.

/datum/mutation_upgrade/veil/mobile_mind/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/psychic_shield/shield_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_shield]
	if(!shield_ability)
		return
	shield_ability.do_after_flags |= (IGNORE_USER_LOC_CHANGE|IGNORE_TARGET_LOC_CHANGE)
	shield_ability.can_manually_detonate = FALSE
	shield_ability.movement_speed_modifier += movespeed_change

/datum/mutation_upgrade/veil/mobile_mind/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/psychic_shield/shield_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_shield]
	if(!shield_ability)
		return
	shield_ability.do_after_flags &= ~(IGNORE_USER_LOC_CHANGE|IGNORE_TARGET_LOC_CHANGE)
	shield_ability.can_manually_detonate = initial(shield_ability.can_manually_detonate)
	shield_ability.movement_speed_modifier -= movespeed_change
