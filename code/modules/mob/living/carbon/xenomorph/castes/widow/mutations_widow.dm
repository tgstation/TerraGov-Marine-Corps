//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/hive_toughness
	name = "Hive Toughness"
	desc = "Being adjacent to any resin wall grants 10/15/20 soft armor in all categories."
	/// For the first structure, the amount of armor that should be given for being near resin walls.
	var/armor_initial = 5
	/// For each structure, the amount of armor that should be given for being near resin walls.
	var/armor_per_structure = 5
	/// Armor attached to the xenomorph owner, if any.
	var/datum/armor/attached_armor

/datum/mutation_upgrade/shell/hive_toughness/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Being adjacent to any resin wall now also grants [get_armor(new_amount)] soft armor in all categories."

/datum/mutation_upgrade/shell/hive_toughness/on_mutation_enabled()
	RegisterSignal(xenomorph_owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_movement))
	on_movement() // Don't wanna wait until they move.
	return ..()

/datum/mutation_upgrade/shell/hive_toughness/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, COMSIG_MOVABLE_MOVED)
	if(attached_armor)
		xenomorph_owner.soft_armor.detachArmor(attached_armor)
		attached_armor = null
	return ..()

/datum/mutation_upgrade/shell/hive_toughness/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!attached_armor || !previous_amount)
		return
	var/amount = get_armor(new_amount - previous_amount)
	attached_armor = attached_armor.modifyAllRatings(amount)
	xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.modifyAllRatings(amount)

/// Checks if there are any nearby resin wall. Depending if there are walls or not, grant or revoke armor.
/datum/mutation_upgrade/shell/hive_toughness/proc/on_movement(datum/source, atom/old_loc, movement_dir, forced, list/old_locs)
	SIGNAL_HANDLER
	var/found_resin_wall = FALSE
	for(var/direction in GLOB.alldirs)
		if(isresinwall(get_step(xenomorph_owner, direction)))
			found_resin_wall = TRUE
			break
	if(!found_resin_wall && attached_armor)
		xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.detachArmor(attached_armor)
		attached_armor = null
	else if(found_resin_wall && !attached_armor)
		var/amount = get_armor(get_total_structures())
		attached_armor = getArmor(amount, amount, amount, amount, amount, amount, amount, amount)
		xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.attachArmor(attached_armor)

/// Returns the amount of armor that should be given for being near resin walls.
/datum/mutation_upgrade/shell/hive_toughness/proc/get_armor(structure_count, include_initial = TRUE)
	return (include_initial ? armor_initial : 0) + (armor_per_structure * structure_count)

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/web_yank
	name = "Web Yank"
	desc = "Leash Ball's cooldown is set to 80/65/50% of its original cooldown. Interacting with any Snaring Web will cause you to channel for 1 second which will stun and pull in leashed humans."
	/// For the first structure, the multiplier to increase the cooldown by.
	var/multiplier_initial = -0.05
	/// For each structure, the multiplier to increase the cooldown by.
	var/multiplier_per_structure = -0.15

/datum/mutation_upgrade/spur/web_yank/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Leash Ball's cooldown is set to [PERCENT(1 + get_multiplier(new_amount))]% of its original cooldown. Interacting with any Snaring Web will cause you to channel for 1 second which will stun and pull in leashed humans."

/datum/mutation_upgrade/spur/web_yank/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/leash_ball/leash_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/leash_ball]
	if(!leash_ability)
		return
	leash_ability.cooldown_duration += initial(leash_ability.cooldown_duration) * get_multiplier(0)
	ADD_TRAIT(xenomorph_owner, TRAIT_WEB_PULLER, MUTATION_TRAIT)

/datum/mutation_upgrade/spur/web_yank/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/leash_ball/leash_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/leash_ball]
	if(!leash_ability)
		return
	leash_ability.cooldown_duration -= initial(leash_ability.cooldown_duration) * get_multiplier(0)
	REMOVE_TRAIT(xenomorph_owner, TRAIT_WEB_PULLER, MUTATION_TRAIT)

/datum/mutation_upgrade/spur/web_yank/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/leash_ball/leash_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/leash_ball]
	if(!leash_ability)
		return
	leash_ability.cooldown_duration += initial(leash_ability.cooldown_duration) * get_multiplier(new_amount - previous_amount, FALSE)

/// Returns the multiplier of Birth Spiderling's initial ability cooldown to add to it.
/datum/mutation_upgrade/spur/web_yank/proc/get_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? multiplier_initial : 0) + (multiplier_per_structure * structure_count)

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/incubator
	name = "Incubator"
	desc = "Birth Spiderling's cooldown is set to 80/65/50% of its original cooldown."
	/// For the first structure, the multiplier of Birth Spiderling's initial ability cooldown to add to it.
	var/multiplier_initial = -0.05
	/// For each structure, the multiplier of Birth Spiderling's initial ability cooldown to add to it.
	var/multiplier_per_structure = -0.15

/datum/mutation_upgrade/veil/incubator/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Birth Spiderling's cooldown is set to [PERCENT(1 + get_multiplier(new_amount))]% of its original cooldown."

/datum/mutation_upgrade/veil/incubator/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/create_spiderling/spiderling_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/create_spiderling]
	if(!spiderling_ability)
		return
	spiderling_ability.cooldown_duration += initial(spiderling_ability.cooldown_duration) * get_multiplier(0)

/datum/mutation_upgrade/veil/incubator/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/xeno_action/create_spiderling/spiderling_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/create_spiderling]
	if(!spiderling_ability)
		return
	spiderling_ability.cooldown_duration -= initial(spiderling_ability.cooldown_duration) * get_multiplier(0)

/datum/mutation_upgrade/veil/incubator/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/create_spiderling/spiderling_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/create_spiderling]
	if(!spiderling_ability)
		return
	spiderling_ability.cooldown_duration += initial(spiderling_ability.cooldown_duration) * get_multiplier(new_amount - previous_amount, FALSE)

/// Returns the multiplier of Birth Spiderling's initial ability cooldown to add to it.
/datum/mutation_upgrade/veil/incubator/proc/get_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? multiplier_initial : 0) + (multiplier_per_structure * structure_count)

