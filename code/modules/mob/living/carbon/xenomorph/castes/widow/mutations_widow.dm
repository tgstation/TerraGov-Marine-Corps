//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/hive_toughness
	name = "Hive Toughness"
	desc = "Being adjacent to any resin wall grants 15 soft armor in all categories."
	/// The amount of armor that should be given for being near resin walls.
	var/armor = 15
	/// Armor attached to the xenomorph owner, if any.
	var/datum/armor/attached_armor

/datum/mutation_upgrade/shell/hive_toughness/on_mutation_enabled()
	RegisterSignal(xenomorph_owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_movement))
	on_movement() // Don't wanna wait until they move.

/datum/mutation_upgrade/shell/hive_toughness/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, COMSIG_MOVABLE_MOVED)
	if(!attached_armor)
		return
	xenomorph_owner.soft_armor.detachArmor(attached_armor)
	attached_armor = null

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
		return
	if(found_resin_wall && !attached_armor)
		attached_armor = getArmor(armor, armor, armor, armor, armor, armor, armor, armor)
		xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.attachArmor(attached_armor)

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/web_yank
	name = "Web Yank"
	desc = "Leash Ball's cooldown is set to 65% of its original cooldown. Interacting with any Snaring Web will cause you to channel for 1 second which will stun and pull in leashed humans."
	/// The multiplier to increase the Leash Ball's initial ability cooldown to add to it.
	var/multiplier = -0.35

/datum/mutation_upgrade/spur/web_yank/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/leash_ball/leash_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/leash_ball]
	if(!leash_ability)
		return
	leash_ability.cooldown_duration += initial(leash_ability.cooldown_duration) * multiplier
	ADD_TRAIT(xenomorph_owner, TRAIT_WEB_PULLER, MUTATION_TRAIT)

/datum/mutation_upgrade/spur/web_yank/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/leash_ball/leash_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/leash_ball]
	if(!leash_ability)
		return
	leash_ability.cooldown_duration -= initial(leash_ability.cooldown_duration) * multiplier
	REMOVE_TRAIT(xenomorph_owner, TRAIT_WEB_PULLER, MUTATION_TRAIT)

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/incubator
	name = "Incubator"
	desc = "Birth Spiderling's cooldown is set to 65% of its original cooldown."
	/// The multiplier of Birth Spiderling's initial ability cooldown to add to it.
	var/multiplier = -0.35

/datum/mutation_upgrade/veil/incubator/on_mutation_enabled()
	var/datum/action/ability/xeno_action/create_spiderling/spiderling_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/create_spiderling]
	if(!spiderling_ability)
		return
	spiderling_ability.cooldown_duration += initial(spiderling_ability.cooldown_duration) * multiplier

/datum/mutation_upgrade/veil/incubator/on_mutation_disabled()
	var/datum/action/ability/xeno_action/create_spiderling/spiderling_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/create_spiderling]
	if(!spiderling_ability)
		return
	spiderling_ability.cooldown_duration -= initial(spiderling_ability.cooldown_duration) * multiplier
