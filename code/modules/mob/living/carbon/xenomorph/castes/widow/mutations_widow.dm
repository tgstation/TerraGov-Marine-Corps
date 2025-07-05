//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/hive_toughness
	name = "Hive Toughness"
	desc = "Your wall speedup now also grants 10/15/20 soft armor in all categories."
	/// For the first structure, the amount of armor to give for being near walls.
	var/armor_initial = 5
	/// For each structure, the amount of armor to give for being near walls.
	var/armor_per_structure = 5
	/// Armor attached to the xenomorph owner, if any.
	var/datum/armor/attached_armor

/datum/mutation_upgrade/shell/hive_toughness/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Your wall speedup now also grants [get_armor(new_amount)] soft armor in all categories."

/datum/mutation_upgrade/shell/hive_toughness/on_mutation_enabled()
	RegisterSignal(xenomorph_owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_movement))
	return ..()

/datum/mutation_upgrade/shell/hive_toughness/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, COMSIG_MOVABLE_MOVED)
	if(attached_armor)
		xenomorph_owner.soft_armor.detachArmor(attached_armor)
		attached_armor = null
	return ..()

/datum/mutation_upgrade/shell/hive_toughness/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!. || !attached_armor)
		return
	var/amount = get_armor(new_amount - previous_amount)
	attached_armor = attached_armor.modifyAllRatings(amount)
	xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.modifyAllRatings(amount)

/// Returns the armor that the mutation should be adding for being near walls.
/datum/mutation_upgrade/shell/hive_toughness/proc/get_armor(structure_count, include_initial = TRUE)
	return (include_initial ? armor_initial : 0) + (armor_per_structure * structure_count)

/// Checks if there are any nearby walls. Depending if there are walls or not, grant or revoke armor.
/datum/mutation_upgrade/shell/hive_toughness/proc/on_movement(datum/source, atom/old_loc, movement_dir, forced, list/old_locs)
	SIGNAL_HANDLER
	var/found_double_walls = FALSE
	for(var/direction in list(NORTH, NORTHEAST, EAST, SOUTHEAST))
		if(!isclosedturf(get_step(xenomorph_owner, direction)))
			continue
		if(!isclosedturf(get_step(xenomorph_owner, REVERSE_DIR(direction))))
			continue
		found_double_walls = TRUE
		break
	if(found_double_walls && !attached_armor)
		attached_armor = getArmor()
		attached_armor = attached_armor.modifyAllRatings(get_armor(get_total_structures()))
		xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.attachArmor(attached_armor)
	else if(!found_double_walls && attached_armor)
		xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.detachArmor(attached_armor)
		attached_armor = null

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/web_yank
	name = "Web Yank"
	desc = "Leash Ball's cooldown is set to 80/65/50% of its original cooldown. Interacting with any Leash Ball will stun and pull in leashed humans after a 1s channel."
	/// For the first structure, the multiplier to increase the cooldown by.
	var/cooldown_multiplier_initial = -0.05
	/// For each structure, the multiplier to increase the cooldown by.
	var/cooldown_multiplier_per_structure = -0.15

/datum/mutation_upgrade/spur/web_yank/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Leash Ball's cooldown is set to [PERCENT(1 - get_multiplier(new_amount))] of its original cooldown. Interacting with any Leash Ball will stun and pull in leashed humans after a 1s channel."

/datum/mutation_upgrade/spur/web_yank/on_mutation_enabled()
	var/datum/action/ability/xeno_action/create_spiderling/create_spiderling = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/create_spiderling]
	if(!create_spiderling)
		return FALSE
	create_spiderling.cooldown_duration += initial(create_spiderling.cooldown_duration) * cooldown_multiplier_initial
	ADD_TRAIT(xenomorph_owner, TRAIT_WEB_PULLER, TRAIT_MUTATION)
	return ..()

/datum/mutation_upgrade/spur/web_yank/on_mutation_disabled()
	var/datum/action/ability/xeno_action/create_spiderling/create_spiderling = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/create_spiderling]
	if(!create_spiderling)
		return FALSE
	create_spiderling.cooldown_duration -= initial(create_spiderling.cooldown_duration) * cooldown_multiplier_initial
	REMOVE_TRAIT(xenomorph_owner, TRAIT_WEB_PULLER, TRAIT_MUTATION)
	return ..()

/datum/mutation_upgrade/spur/web_yank/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/create_spiderling/create_spiderling = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/create_spiderling]
	if(!create_spiderling)
		return FALSE
	create_spiderling.cooldown_duration += initial(create_spiderling.cooldown_duration) * get_multiplier(new_amount - previous_amount)

/// Returns the multiplier that the mutation should be adding to the ability's cooldown.
/datum/mutation_upgrade/spur/web_yank/proc/get_multiplier(structure_count)
	return cooldown_multiplier_per_structure * structure_count

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/incubator
	name = "Incubator"
	desc = "Birth Spiderling's cooldown is set to 80/65/50% of its original cooldown."
	/// For the first structure, the multiplier to increase the cooldown by.
	var/cooldown_multiplier_initial = -0.05
	/// For each structure, the multiplier to increase the cooldown by.
	var/cooldown_multiplier_per_structure = -0.15

/datum/mutation_upgrade/veil/incubator/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Birth Spiderling's cooldown is set to [PERCENT(1 - get_multiplier(new_amount))]% of its original cooldown."

/datum/mutation_upgrade/veil/incubator/on_mutation_enabled()
	var/datum/action/ability/xeno_action/create_spiderling/create_spiderling = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/create_spiderling]
	if(!create_spiderling)
		return FALSE
	create_spiderling.cooldown_duration += initial(create_spiderling.cooldown_duration) * cooldown_multiplier_initial
	return ..()

/datum/mutation_upgrade/veil/incubator/on_mutation_disabled()
	var/datum/action/ability/xeno_action/create_spiderling/create_spiderling = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/create_spiderling]
	if(!create_spiderling)
		return FALSE
	create_spiderling.cooldown_duration -= initial(create_spiderling.cooldown_duration) * cooldown_multiplier_initial
	return ..()

/datum/mutation_upgrade/veil/incubator/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/create_spiderling/create_spiderling = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/create_spiderling]
	if(!create_spiderling)
		return FALSE
	create_spiderling.cooldown_duration += initial(create_spiderling.cooldown_duration) * get_multiplier(new_amount - previous_amount, FALSE)

/// Returns the multiplier that the mutation should be adding to the ability's cooldown.
/datum/mutation_upgrade/veil/incubator/proc/get_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? cooldown_multiplier_initial : 0) + (cooldown_multiplier_per_structure * structure_count)

