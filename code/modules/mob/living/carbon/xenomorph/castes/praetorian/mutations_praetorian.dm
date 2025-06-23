//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/adaptive_armor
	name = "Adaptive Armor"
	desc = "When you are hit by a non-friendly projectile, you gain 10/15/20 armor against that particular projectile's armor type and lose 15/22.5/30 in all other types. This lasts only for 10 seconds until it reselects."
	/// After this amount of time since their last move, they will no longer evade projectiles.
	var/movement_leniency = 0.5 SECONDS
	/// For the first structure, the amount to increase a particular type of armor by while the effect is active.
	var/particular_armor_increase_initial = 5
	/// For each structure, the additional amount to increase a particular type of armor by while the effect is active.
	var/particular_armor_increase_per_structure = 5
	/// For the first structure, the amount to increase all other armor by while the effect is active.
	var/other_armor_increase_initial = -7.5
	/// For each structure, the additional amount to increase all other armor by while the effect is active.
	var/other_armor_increase_per_structure = -7.5
	/// The most recent projectle's armor type.
	var/recent_projectile_armor_type
	/// The attached armor that been given, if any.
	var/datum/armor/attached_armor
	/// How long should the armor be given?
	var/timer_length = 10 SECONDS
	/// Timer ID for a proc that revokes the armor given when it times out.
	var/timer_id

/datum/mutation_upgrade/shell/adaptive_armor/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "When you are hit by a non-friendly projectile, you gain [particular_armor_increase_initial + (particular_armor_increase_per_structure * new_amount)] armor against that particular projectile's armor type and lose [(other_armor_increase_initial + (other_armor_increase_per_structure * new_amount)) * -1] in all other types. This lasts only for [timer_length / 10] seconds until it reselects."

/datum/mutation_upgrade/shell/adaptive_armor/on_mutation_enabled()
	RegisterSignal(xenomorph_owner, COMSIG_XENO_PROJECTILE_HIT, PROC_REF(pre_projectile_hit))
	return ..()

/datum/mutation_upgrade/shell/adaptive_armor/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, list(COMSIG_XENO_PROJECTILE_HIT))
	return ..()

/// (Re)sets the attached armor.
/datum/mutation_upgrade/shell/adaptive_armor/proc/set_armor(projectile_armor_type)
	remove_armor()
	if(!get_total_structures())
		return
	var/all_armor_change = other_armor_increase_initial + (other_armor_increase_per_structure * get_total_structures())
	recent_projectile_armor_type = projectile_armor_type
	attached_armor = new()
	attached_armor.modifyAllRatings(all_armor_change)
	attached_armor.modifyRating(arglist(list("[recent_projectile_armor_type]" = particular_armor_increase_initial - all_armor_change)))
	xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.attachArmor(attached_armor)
	// TODO: Add an outline based on armor type to indicate what type of armor is chosen: orange = fire, blue = bullet, yellow = explosion, green = bio, grey = melee

/// Removes the attached armor.
/datum/mutation_upgrade/shell/adaptive_armor/proc/remove_armor()
	if(timer_id)
		deltimer(timer_id)
		timer_id = null
	if(!attached_armor)
		return
	recent_projectile_armor_type = null
	xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.detachArmor(attached_armor)
	attached_armor = null

/// Checks if they can dodge a projectile. If they can, they do so.
/datum/mutation_upgrade/shell/adaptive_armor/proc/pre_projectile_hit(datum/source, atom/movable/projectile/proj, cardinal_move, uncrossing)
	SIGNAL_HANDLER
	if(attached_armor)
		return FALSE
	if(xenomorph_owner.issamexenohive(proj.firer))
		return FALSE
	set_armor(proj.ammo.armor_type)
	timer_id = addtimer(CALLBACK(src, PROC_REF(remove_armor)), timer_length, TIMER_STOPPABLE|TIMER_UNIQUE)

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/circular_acid
	name = "Circular Acid"
	desc = "Acid Spray now creates acid in a circle around you in a radius of 2/3/4 tiles."
	/// For the first structure, the range to increase the circular Acid Spray by.
	var/range_initial = 1
	/// For each structure, the additional range to increase the circular Acid Spray by.
	var/range_per_structure = 1

/datum/mutation_upgrade/spur/circular_acid/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Acid Spray now creates acid in a circle around you in a radius of [range_initial + (range_per_structure * new_amount)] tiles."

/datum/mutation_upgrade/spur/circular_acid/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/spray_acid/cone/cone_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/spray_acid/cone]
	if(cone_ability)
		cone_ability.remove_action(xenomorph_owner)
	var/datum/action/ability/activable/xeno/spray_acid/cone/circle/circle_ability = new()
	circle_ability.give_action(xenomorph_owner)
	circle_ability.range += range_initial
	return ..()

/datum/mutation_upgrade/spur/circular_acid/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/spray_acid/cone/circle/circle_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/spray_acid/cone/circle]
	if(circle_ability)
		circle_ability.remove_action(xenomorph_owner)
	var/datum/action/ability/activable/xeno/spray_acid/cone/cone_ability = new()
	cone_ability.give_action(xenomorph_owner)
	return ..()

/datum/mutation_upgrade/spur/circular_acid/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/spray_acid/cone/circle/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/spray_acid/cone/circle]
	if(!ability)
		return
	ability.range += (new_amount - previous_amount) * range_per_structure

/datum/mutation_upgrade/spur/circular_acid/on_xenomorph_upgrade()
	var/datum/action/ability/activable/xeno/spray_acid/cone/cone_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/spray_acid/cone]
	if(cone_ability)
		cone_ability.remove_action(xenomorph_owner)
	var/datum/action/ability/activable/xeno/spray_acid/cone/circle/circle_ability = new()
	circle_ability.give_action(xenomorph_owner)
	circle_ability.range += range_initial + (range_per_structure * get_total_structures())

//*********************//
//         Veil        //
//*********************//
