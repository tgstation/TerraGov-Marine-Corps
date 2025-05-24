//*********************//
//        Shell        //
//*********************//

/datum/mutation_upgrade/shell/scout
	name = "Scout"
	desc = "You gain 5/10/15 armor in all categories. You lose this armor if you've been on weeds for longer than 5 seconds."
	/// The additional amount of armor for all categories when entering weeds (for each structure).
	var/armor_per_structure = 5
	/// The attached armor that been given, if any.
	var/datum/armor/attached_armor
	/// Timer ID for a proc that revokes the armor given when it times out.
	var/timer_id
	/// How long should the armor be given?
	var/timer_length = 5 SECONDS

/datum/mutation_upgrade/shell/scout/on_mutation_enabled()
	. = ..()
	RegisterSignal(xenomorph_owner, COMSIG_LIVING_WEEDS_AT_LOC_CREATED, PROC_REF(entered_weeds))
	RegisterSignal(xenomorph_owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_movement))
	if(!xenomorph_owner.loc_weeds_type)
		grant_armor()
		return
	entered_weeds(xenomorph_owner, xenomorph_owner.loc_weeds_type)

/datum/mutation_upgrade/shell/scout/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, list(COMSIG_LIVING_WEEDS_AT_LOC_CREATED, COMSIG_MOVABLE_MOVED))
	revoke_armor()
	return ..()

/// Grants armor and removes the timer.
/datum/mutation_upgrade/shell/scout/proc/grant_armor()
	if(timer_id)
		deltimer(timer_id)
		timer_id = null
	if(attached_armor)
		return
	var/total_armor = get_total_structures() * armor_per_structure
	attached_armor = new(total_armor, total_armor, total_armor, total_armor, total_armor, total_armor, total_armor, total_armor)
	xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.attachArmor(attached_armor)

/// Removes armor and the timer.
/datum/mutation_upgrade/shell/scout/proc/revoke_armor()
	if(timer_id)
		deltimer(timer_id)
		timer_id = null
	if(!attached_armor)
		return
	xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.detachArmor(attached_armor)
	attached_armor = null

/// Grant armor if they entered a location without weeds. Otherwise, set a timer that will revoke armor later.
/datum/mutation_upgrade/shell/scout/proc/on_movement(datum/source, atom/old_loc, movement_dir, forced, list/old_locs)
	SIGNAL_HANDLER
	var/obj/alien/weeds/found_weed = locate(/obj/alien/weeds) in xenomorph_owner.loc
	if(found_weed)
		entered_weeds(xenomorph_owner, found_weed)
		return
	grant_armor()

/datum/mutation_upgrade/shell/scout/proc/entered_weeds(datum/source, obj/alien/weeds/location_weeds)
	SIGNAL_HANDLER
	if(timer_id)
		return
	timer_id = addtimer(CALLBACK(src, PROC_REF(revoke_armor)), timer_length, TIMER_STOPPABLE|TIMER_UNIQUE)

/datum/mutation_upgrade/shell/together_in_claws
	name = "Together In Claws"
	desc = "While connected with Essence Link, you heal for 10/15/20% of your partner's damage when they slash a human."
	/// The beginning percentage to lifesteal (at zero structures)
	var/beginning_percentage = 0.05
	/// The additional percentage to lifesteal for each structure.
	var/percentage_per_structure = 0.05

/datum/mutation_upgrade/shell/together_in_claws/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/essence_link/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/essence_link]
	if(!ability)
		return FALSE
	ability.lifesteal_percentage += beginning_percentage
	if(ability.existing_link)
		ability.existing_link.set_lifesteal(ability.lifesteal_percentage)
	return ..()

/datum/mutation_upgrade/shell/together_in_claws/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/essence_link/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/essence_link]
	if(!ability)
		return FALSE
	ability.lifesteal_percentage -= beginning_percentage
	return ..()

/datum/mutation_upgrade/shell/together_in_claws/on_structure_update(datum/source, previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/essence_link/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/essence_link]
	if(!ability)
		return FALSE
	ability.lifesteal_percentage += (new_amount - previous_amount) * percentage_per_structure
	if(ability.existing_link)
		ability.existing_link.set_lifesteal(ability.lifesteal_percentage)

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/revenge
	name = "Revenge"
	desc = "While connected with Essence Link and it ends due to death, the survivor temporarily gains 75/100/125% additional melee damage for 10 seconds."
	/// The beginning value to increase melee damage multiplier (at zero structures)
	var/beginning_percentage = 0.50
	/// The additional value to increase melee damage multiplier for each structure.
	var/percentage_per_structure = 0.25

/datum/mutation_upgrade/spur/revenge/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/essence_link/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/essence_link]
	if(!ability)
		return FALSE
	ability.revenge_modifier += beginning_percentage
	if(ability.existing_link)
		ability.existing_link.revenge_modifier  += beginning_percentage
	return ..()

/datum/mutation_upgrade/spur/revenge/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/essence_link/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/essence_link]
	if(!ability)
		return FALSE
	ability.revenge_modifier -= beginning_percentage
	if(ability.existing_link)
		ability.existing_link.revenge_modifier += beginning_percentage
	return ..()

/datum/mutation_upgrade/spur/revenge/on_structure_update(datum/source, previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/essence_link/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/essence_link]
	if(!ability)
		return FALSE
	ability.revenge_modifier += (new_amount - previous_amount) * percentage_per_structure
	if(ability.existing_link)
		ability.existing_link.revenge_modifier += (new_amount - previous_amount) * percentage_per_structure

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/saving_grace
	name = "Saving Grace"
	desc = "Salve Heal has no cast time on your Essence Link partner if they qualify for bonus healing. Bonus healing multiplier is increased by an additive of 1/2/3."

/datum/mutation_upgrade/veil/saving_grace/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/psychic_cure/acidic_salve/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_cure/acidic_salve]
	if(!ability)
		return FALSE
	ability.bypass_cast_time_on_threshold = TRUE
	return ..()

/datum/mutation_upgrade/veil/saving_grace/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/psychic_cure/acidic_salve/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_cure/acidic_salve]
	if(!ability)
		return FALSE
	ability.bypass_cast_time_on_threshold = initial(ability.bypass_cast_time_on_threshold)
	return ..()

/datum/mutation_upgrade/veil/saving_grace/on_structure_update(datum/source, previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/psychic_cure/acidic_salve/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_cure/acidic_salve]
	if(!ability)
		return FALSE
	ability.bonus_healing_additive_multiplier += (new_amount - previous_amount)

/datum/mutation_upgrade/veil/vitality_transfer
	name = "Vitality Transfer"
	desc = "While connected with Essence Link, you can manually disconnect to heal your partner for 5/10/15% of their maximum health multiplied by the attunement amount. However, you take true damage equal to the amount healed. This damage can kill you."

/datum/mutation_upgrade/veil/vitality_transfer/on_structure_update(datum/source, previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/essence_link/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/essence_link]
	if(!ability)
		return FALSE
	ability.disconnection_heal_percentage += (new_amount - previous_amount) * 0.05
