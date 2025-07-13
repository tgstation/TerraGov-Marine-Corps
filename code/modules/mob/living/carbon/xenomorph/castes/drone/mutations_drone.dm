//*********************//
//        Shell        //
//*********************//

/datum/mutation_upgrade/shell/scout
	name = "Scout"
	desc = "You gain 5/10/15 armor in all categories. You lose this armor if you've been on weeds for longer than 5 seconds."
	/// For each structure, the additional amount of armor for all categories when entering weeds.
	var/armor_per_structure = 5
	/// The attached armor that been given, if any.
	var/datum/armor/attached_armor
	/// Timer ID for a proc that revokes the armor given when it times out.
	var/timer_id
	/// How long should the armor be given?
	var/timer_length = 5 SECONDS

/datum/mutation_upgrade/shell/scout/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "You gain [armor_per_structure * new_amount] armor in all categories. You lose this armor if you've been on weeds for longer than [timer_length/10] seconds."

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
	/// For the first structure, the percentage to lifesteal.
	var/lifesteal_percentage_initial = 0.05
	/// For each structure, the additional percentage to lifesteal.
	var/lifesteal_percentage_per_structure = 0.05

/datum/mutation_upgrade/shell/together_in_claws/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "While connected with Essence Link, you heal for [(lifesteal_percentage_initial + (lifesteal_percentage_per_structure * new_amount)) * 100]% of your partner's damage when they slash a human."

/datum/mutation_upgrade/shell/together_in_claws/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/essence_link/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/essence_link]
	if(!ability)
		return
	ability.lifesteal_percentage += lifesteal_percentage_initial
	if(ability.existing_link)
		ability.existing_link.set_lifesteal(ability.lifesteal_percentage)
	return ..()

/datum/mutation_upgrade/shell/together_in_claws/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/essence_link/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/essence_link]
	if(!ability)
		return
	ability.lifesteal_percentage -= lifesteal_percentage_initial
	return ..()

/datum/mutation_upgrade/shell/together_in_claws/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/essence_link/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/essence_link]
	if(!ability)
		return
	ability.lifesteal_percentage += (new_amount - previous_amount) * lifesteal_percentage_per_structure
	if(ability.existing_link)
		ability.existing_link.set_lifesteal(ability.lifesteal_percentage)

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/revenge
	name = "Revenge"
	desc = "While connected with Essence Link and it ends due to death, the survivor temporarily gains 75/100/125% additional melee damage for 10 seconds."
	/// For the first structure, the melee damage multiplier to increase by.
	var/percentage_initial = 0.50
	/// For each structure, the additional melee damage multiplier to increase by.
	var/percentage_per_structure = 0.25

/datum/mutation_upgrade/spur/revenge/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "While connected with Essence Link and it ends due to death, the survivor temporarily gains [(percentage_initial + (percentage_per_structure * new_amount)) * 100]% additional melee damage for 10 seconds."

/datum/mutation_upgrade/spur/revenge/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/essence_link/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/essence_link]
	if(!ability)
		return
	ability.revenge_modifier += percentage_initial
	if(ability.existing_link)
		ability.existing_link.revenge_modifier  += percentage_initial
	return ..()

/datum/mutation_upgrade/spur/revenge/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/essence_link/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/essence_link]
	if(!ability)
		return
	ability.revenge_modifier -= percentage_initial
	if(ability.existing_link)
		ability.existing_link.revenge_modifier += percentage_initial
	return ..()

/datum/mutation_upgrade/spur/revenge/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/essence_link/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/essence_link]
	if(!ability)
		return
	ability.revenge_modifier += (new_amount - previous_amount) * percentage_per_structure
	if(ability.existing_link)
		ability.existing_link.revenge_modifier += (new_amount - previous_amount) * percentage_per_structure

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/saving_grace
	name = "Saving Grace"
	desc = "Salve Heal has no cast time on your Essence Link partner if they qualify for bonus healing. Bonus healing multiplier is increased by an additive of 1/2/3."
	/// For each structure, the multiplier as an additive to increase the bonus healing by.
	var/additive_multiplier_per_structure = 1

/datum/mutation_upgrade/veil/saving_grace/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Salve Heal has no cast time on your Essence Link partner if they qualify for bonus healing. Bonus healing multiplier is increased by an additive of [additive_multiplier_per_structure * new_amount]."

/datum/mutation_upgrade/veil/saving_grace/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/psychic_cure/acidic_salve/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_cure/acidic_salve]
	if(!ability)
		return
	ability.bypass_cast_time_on_threshold = TRUE
	return ..()

/datum/mutation_upgrade/veil/saving_grace/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/psychic_cure/acidic_salve/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_cure/acidic_salve]
	if(!ability)
		return
	ability.bypass_cast_time_on_threshold = initial(ability.bypass_cast_time_on_threshold)
	return ..()

/datum/mutation_upgrade/veil/saving_grace/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/psychic_cure/acidic_salve/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_cure/acidic_salve]
	if(!ability)
		return
	ability.bonus_healing_additive_multiplier += (new_amount - previous_amount) * additive_multiplier_per_structure

/datum/mutation_upgrade/veil/vitality_transfer
	name = "Vitality Transfer"
	desc = "While connected with Essence Link, you can manually disconnect to heal your partner for 5/10/15% of their maximum health multiplied by the attunement amount. However, you take true damage equal to the amount healed. This damage can kill you."
	/// For each structure, the additional percentage of maximum health to heal by.
	var/max_health_percentage_per_structure = 0.05

/datum/mutation_upgrade/veil/vitality_transfer/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "While connected with Essence Link, you can manually disconnect to heal your partner for [max_health_percentage_per_structure * new_amount * 100]% of their maximum health multiplied by the attunement amount. However, you take true damage equal to the amount healed. This damage can kill you."

/datum/mutation_upgrade/veil/vitality_transfer/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/essence_link/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/essence_link]
	if(!ability)
		return
	ability.disconnection_heal_percentage += (new_amount - previous_amount) * max_health_percentage_per_structure
