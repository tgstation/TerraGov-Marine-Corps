//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/adaptive_armor
	name = "Adaptive Armor"
	desc = "When you are hit by a non-friendly projectile, you gain 10/15/20 armor against that particular projectile's armor type and lose 15/22.5/30 in all other types. A colored outline appears around you for 10 seconds during the duration."
	/// For the first structure, the amount of armor that should be given against the projectile's armor type that the owner was hit with.
	var/defended_armor_initial = 5
	/// For each structure, the  amount of armor that should be given against the projectile's armor type that the owner was hit with.
	var/defended_armor_per_structure = 5
	/// For the first structure, the amount of armor that should be given against all armor types that isn't the projectile's armor type that the owner was hit with.
	var/other_armor_initial = -7.5
	/// For each structure, the amount of armor that should be given against all armor types that isn't the projectile's armor type that the owner was hit with.
	var/other_armor_per_structure = -7.5
	/// The attached armor that been given, if any.
	var/datum/armor/attached_armor
	/// How long should the armor be given?
	var/timer_length = 10 SECONDS
	/// Timer ID for a proc that revokes the armor given when it times out.
	var/timer_id

/datum/mutation_upgrade/shell/adaptive_armor/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "When you are hit by a non-friendly projectile, you gain [get_defended_armor(new_amount)] armor against that particular projectile's armor type and lose [-get_other_armor(new_amount)] in all other types. A colored outline appears around you for [timer_length * 0.1] seconds during the duration."

/datum/mutation_upgrade/shell/adaptive_armor/on_mutation_enabled()
	RegisterSignal(xenomorph_owner, COMSIG_XENO_PROJECTILE_HIT, PROC_REF(pre_projectile_hit))
	return ..()

/datum/mutation_upgrade/shell/adaptive_armor/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, list(COMSIG_XENO_PROJECTILE_HIT))
	return ..()

/// Revokes the attached armor and clears the outline that was given.
/datum/mutation_upgrade/shell/adaptive_armor/proc/remove_armor()
	if(timer_id)
		deltimer(timer_id)
		timer_id = null
	if(attached_armor)
		xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.detachArmor(attached_armor)
		attached_armor = null
	xenomorph_owner.remove_filter("mutation_adaptive_armor")

/// When hit by a non-friendly projectile but before any of its effects, give the armor if they don't have it.
/datum/mutation_upgrade/shell/adaptive_armor/proc/pre_projectile_hit(datum/source, atom/movable/projectile/proj, cardinal_move, uncrossing)
	SIGNAL_HANDLER
	if(attached_armor || xenomorph_owner.issamexenohive(proj.firer))
		return
	var/total_structures = get_total_structures()
	var/other_amount = get_other_armor(total_structures)
	attached_armor = getArmor(arglist(list("[proj.ammo.armor_type]" = get_defended_armor(total_structures) - other_amount)))
	attached_armor = attached_armor.modifyAllRatings(other_amount)
	xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.attachArmor(attached_armor)
	var/outline_color = COLOR_BLACK // For if there is an armor type that isn't catched.
	switch(proj.ammo.armor_type)
		if(MELEE)
			outline_color = COLOR_BLUE_GRAY
		if(BULLET)
			outline_color = COLOR_BLUE
		if(LASER)
			outline_color = COLOR_CYAN
		if(ENERGY)
			outline_color = COLOR_DARK_CYAN
		if(BOMB)
			outline_color = COLOR_YELLOW
		if(BIO)
			outline_color = COLOR_GREEN
		if(ACID)
			outline_color = COLOR_VERY_DARK_LIME_GREEN
		if(FIRE)
			outline_color = COLOR_BEIGE
	xenomorph_owner.add_filter("mutation_adaptive_armor", 2, outline_filter(2, outline_color))
	timer_id = addtimer(CALLBACK(src, PROC_REF(remove_armor)), timer_length, TIMER_STOPPABLE|TIMER_UNIQUE)

/// Returns the amount of armor that should be given against the projectile's armor type that the owner was hit with.
/datum/mutation_upgrade/shell/adaptive_armor/proc/get_defended_armor(structure_count, include_initial = TRUE)
	return (include_initial ? defended_armor_initial : 0) + (defended_armor_per_structure * structure_count)

/// Returns the amount of armor that should be given against all armor types that isn't the projectile's armor type that the owner was hit with.
/datum/mutation_upgrade/shell/adaptive_armor/proc/get_other_armor(structure_count, include_initial = TRUE)
	return (include_initial ? other_armor_initial : 0) + (other_armor_per_structure * structure_count)

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/circular_acid
	name = "Circular Acid"
	desc = "Acid Spray now creates acid underneath you and in a circle around you in a radius of 2/3/4 tiles."
	/// For the first structure, the amount to set Spray Acid Circle's range to.
	var/range_initial = 1
	/// For each structure, the amount to set Spray Acid Circle's range to.
	var/range_per_structure = 1

/datum/mutation_upgrade/spur/circular_acid/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Acid Spray now creates acid underneath you and in a circle around you in a radius of [get_range(new_amount)] tiles."

/datum/mutation_upgrade/spur/circular_acid/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/spray_acid/cone/cone_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/spray_acid/cone]
	if(cone_ability)
		cone_ability.remove_action(xenomorph_owner)
	var/datum/action/ability/activable/xeno/spray_acid/cone/circle/circle_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/spray_acid/cone/circle]
	if(!circle_ability)
		circle_ability = new()
		circle_ability.give_action(xenomorph_owner) // Range will be set during structure update.
	return ..()

/datum/mutation_upgrade/spur/circular_acid/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/spray_acid/cone/circle/circle_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/spray_acid/cone/circle]
	if(circle_ability)
		circle_ability.remove_action(xenomorph_owner)
	var/datum/action/ability/activable/xeno/spray_acid/cone/cone_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/spray_acid/cone]
	if(!cone_ability)
		cone_ability = new()
		cone_ability.give_action(xenomorph_owner)
	return ..()

/datum/mutation_upgrade/spur/circular_acid/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/spray_acid/cone/circle/circle_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/spray_acid/cone/circle]
	if(!circle_ability)
		return
	// Given that this ability is exclusively from mutations, we can just set the range and not have to worry about anything else messing with it.
	circle_ability.range = 1 + get_range(new_amount) // 1 (turf underneath) + range (turfs from center).

/datum/mutation_upgrade/spur/circular_acid/on_xenomorph_upgrade()
	var/datum/action/ability/activable/xeno/spray_acid/cone/cone_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/spray_acid/cone]
	if(cone_ability)
		cone_ability.remove_action(xenomorph_owner)

/// Returns the amount to set Spray Acid Circle's range to.
/datum/mutation_upgrade/spur/circular_acid/proc/get_range(structure_count, include_initial = TRUE)
	return  range_initial + (range_per_structure * structure_count)

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/wide_pheromones
	name = "Wide Pheromones"
	desc = "Your pheromone strength is decreased by 0.5, but its range is increased by 3/6/9 tiles."
	/// For the first structure, the amount to add to the strength of all pheromones emitting abilities.
	var/strength_initial = -0.5
	/// For each structure, the amount to add to the range of all pheromones emitting abilities.
	var/range_per_structure = 3

/datum/mutation_upgrade/veil/wide_pheromones/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Your pheromone strength is decreased by [-strength_initial], but its range is increased by [get_range(new_amount)] tiles."

/datum/mutation_upgrade/veil/wide_pheromones/on_mutation_enabled()
	add_strength_and_range(strength_initial)
	return ..()

/datum/mutation_upgrade/veil/wide_pheromones/on_mutation_disabled()
	add_strength_and_range(-strength_initial)
	return ..()

/datum/mutation_upgrade/veil/wide_pheromones/on_structure_update(previous_amount, new_amount)
	. = ..()
	add_strength_and_range(0, get_range(new_amount - previous_amount))
	if(!xenomorph_owner.current_aura)
		return
	var/pheromone_type = xenomorph_owner.current_aura.aura_types[1]
	QDEL_NULL(xenomorph_owner.current_aura)
	switch(pheromone_type)
		if(AURA_XENO_RECOVERY)
			var/datum/action/ability/xeno_action/pheromones/emit_recovery/recovery_pheromones = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/pheromones/emit_recovery]
			if(recovery_pheromones)
				recovery_pheromones.apply_pheros(AURA_XENO_RECOVERY)
		if(AURA_XENO_WARDING)
			var/datum/action/ability/xeno_action/pheromones/emit_warding/warding_pheromones = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/pheromones/emit_warding]
			if(warding_pheromones)
				warding_pheromones.apply_pheros(AURA_XENO_WARDING)
		if(AURA_XENO_FRENZY)
			var/datum/action/ability/xeno_action/pheromones/emit_frenzy/frenzy_pheromones = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/pheromones/emit_frenzy]
			if(frenzy_pheromones)
				frenzy_pheromones.apply_pheros(AURA_XENO_FRENZY)

/// Adds strength and/or range to all pheromone abilities by a chosen amount.
/datum/mutation_upgrade/veil/wide_pheromones/proc/add_strength_and_range(strength = 0, range = 0)
	var/datum/action/ability/xeno_action/pheromones/emit_recovery/recovery_pheromones = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/pheromones/emit_recovery]
	if(recovery_pheromones)
		recovery_pheromones.bonus_flat_strength += strength
		recovery_pheromones.bonus_flat_range += range
	var/datum/action/ability/xeno_action/pheromones/emit_warding/warding_pheromones = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/pheromones/emit_warding]
	if(warding_pheromones)
		warding_pheromones.bonus_flat_strength += strength
		warding_pheromones.bonus_flat_range += range
	var/datum/action/ability/xeno_action/pheromones/emit_frenzy/frenzy_pheromones = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/pheromones/emit_frenzy]
	if(frenzy_pheromones)
		frenzy_pheromones.bonus_flat_strength += strength
		frenzy_pheromones.bonus_flat_range += range

/// Returns the amount to add to the range of all pheromones emitting abilities.
/datum/mutation_upgrade/veil/wide_pheromones/proc/get_range(structure_count)
	return range_per_structure * structure_count
