//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/lone_healer
	name = "Lone Healer"
	desc = "Psychic Cure can now target yourself. Healing yourself is only 50/60/70% as effective and will set the cooldown to 200/175/150% of its original value."
	/// For the first structure, the multiplier of Psychic Cure's initial healing power to add to the ability.
	var/self_heal_multiplier_initial = -0.6
	/// For each structure, the multiplier of Psychic Cure's initial healing power to add to the ability.
	var/self_heal_multiplier_per_structure = 0.1
	/// For the first structure, the multiplier of Psychic Cure's initial cooldown duration to add to the ability.
	var/self_cooldown_multiplier_initial = 1.25
	/// For each structure, the multiplier of Psychic Cure's initial cooldown duration to add to the ability.
	var/self_cooldown_multiplier_per_structure = -0.25

/datum/mutation_upgrade/shell/lone_healer/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Psychic Cure can now target yourself. Healing yourself is only [PERCENT(1 + get_self_heal_multiplier(new_amount))]% as effective and will set the cooldown to [PERCENT(1 + get_self_cooldown_multiplier(new_amount))]% of its original value."

/datum/mutation_upgrade/shell/lone_healer/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/psychic_cure/cure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_cure]
	if(!cure_ability)
		return
	cure_ability.use_state_flags |= ABILITY_TARGET_SELF
	cure_ability.self_heal_multiplier += get_self_heal_multiplier(0)
	cure_ability.self_cooldown_multiplier += get_self_cooldown_multiplier(0)

/datum/mutation_upgrade/shell/lone_healer/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/psychic_cure/cure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_cure]
	if(!cure_ability)
		return
	cure_ability.use_state_flags &= ~(ABILITY_TARGET_SELF)
	cure_ability.self_heal_multiplier -= get_self_heal_multiplier(0)
	cure_ability.self_cooldown_multiplier -= get_self_cooldown_multiplier(0)

/datum/mutation_upgrade/shell/lone_healer/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/psychic_cure/cure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_cure]
	if(!cure_ability)
		return
	cure_ability.self_heal_multiplier += get_self_heal_multiplier(new_amount - previous_amount, FALSE)
	cure_ability.self_cooldown_multiplier += get_self_cooldown_multiplier(new_amount - previous_amount, FALSE)

/// Returns the multiplier of Psychic Cure's initial healing power to add to the ability.
/datum/mutation_upgrade/shell/lone_healer/proc/get_self_heal_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? self_heal_multiplier_initial : 0) + (self_heal_multiplier_per_structure * structure_count)

/// Returns the multiplier of Psychic Cure's initial cooldown duration to add to the ability.
/datum/mutation_upgrade/shell/lone_healer/proc/get_self_cooldown_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? self_cooldown_multiplier_initial : 0) + (self_cooldown_multiplier_per_structure * structure_count)

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/smashing_fling
	name = "Smashing Fling"
	desc = "Psychic Fling deals 100/125/150% damage equal to your melee damage, enables collusions, but no longer immediately stuns. If the target collides with a human, object, or wall: they are briefly paralyzed and dealt damage again."
	/// For the first structure, the multiplier of the owner's melee damage to deal as both immediate and collusion damage.
	var/multiplier_initial = 0.75
	/// For each structure, the multiplier of the owner's melee damage to deal as both immediate and collusion damage.
	var/multiplier_per_structure = 0.25

/datum/mutation_upgrade/spur/smashing_fling/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Psychic Fling deals [PERCENT(get_multiplier(new_amount))]% damage equal to your melee damage, enables collusions, but no longer immediately stuns. If the target collides with a human, object, or wall: they are paralyzed and dealt damage again."

/datum/mutation_upgrade/spur/smashing_fling/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/psychic_fling/fling_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_fling]
	if(!fling_ability)
		return
	fling_ability.stun_duration = 0 SECONDS
	fling_ability.damage_multiplier += get_multiplier(0)
	fling_ability.collusion_paralyze_duration = 0.1 SECONDS // This is honestly flavor.
	fling_ability.collusion_damage_multiplier += get_multiplier(0)

/datum/mutation_upgrade/spur/smashing_fling/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/psychic_fling/fling_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_fling]
	if(!fling_ability)
		return
	fling_ability.stun_duration = initial(fling_ability.stun_duration)
	fling_ability.damage_multiplier -= get_multiplier(0)
	fling_ability.collusion_paralyze_duration = initial(fling_ability.collusion_paralyze_duration)
	fling_ability.collusion_damage_multiplier -= get_multiplier(0)

/datum/mutation_upgrade/spur/smashing_fling/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/psychic_fling/fling_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_fling]
	if(!fling_ability)
		return
	var/amount = get_multiplier(new_amount - previous_amount, FALSE)
	fling_ability.damage_multiplier += amount
	fling_ability.collusion_damage_multiplier += amount

/// Returns the multiplier of the owner's melee damage to deal as both immediate and collusion damage.
/datum/mutation_upgrade/spur/smashing_fling/proc/get_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? multiplier_initial : 0) + (multiplier_per_structure * structure_count)

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/stand_in_recycler
	name = "Stand-In Recycler"
	desc = "You gain the Recycle ability. It costs 80/65/50% of its original cost."
	/// For the first structure, the multiplier of Recycle's initial ability cost to add to the ability.
	var/multiplier_initial = -0.05
	/// For each structure, the multiplier of Recycle's initial ability cost to add to the ability.
	var/multiplier_per_structure = -0.15

/datum/mutation_upgrade/veil/stand_in_recycler/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "You gain the Recycle ability. Recycle's ability cost is [PERCENT(1 + get_multiplier(new_amount))]% of its original value."

/datum/mutation_upgrade/veil/stand_in_recycler/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/recycle/recycle_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/recycle]
	if(!recycle_ability)
		recycle_ability = new()
		recycle_ability.give_action(xenomorph_owner)
		recycle_ability.ability_cost += initial(recycle_ability.ability_cost) * get_multiplier(0)
	return ..()

/datum/mutation_upgrade/veil/stand_in_recycler/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/recycle/recycle_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/recycle]
	if(recycle_ability)
		recycle_ability.remove_action(xenomorph_owner)
		qdel(recycle_ability)
	return ..()

/datum/mutation_upgrade/veil/stand_in_recycler/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/recycle/recycle_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/recycle]
	if(!recycle_ability)
		return
	recycle_ability.ability_cost += initial(recycle_ability.ability_cost) * get_multiplier(new_amount - previous_amount, FALSE)

/// Returns the multiplier of Recycle's initial ability cost to add to the ability.
/datum/mutation_upgrade/veil/stand_in_recycler/proc/get_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? multiplier_initial : 0) + (multiplier_per_structure * structure_count)
