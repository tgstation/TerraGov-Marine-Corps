//*********************//
//        Shell        //
//*********************//

/datum/mutation_upgrade/shell/scout
	name = "Scout"
	desc = "You gain 10 armor in all categories. You lose this armor if you've been on weeds for longer than 5 seconds."
	/// The additional amount of armor for all categories when entering weeds.
	var/armor = 10
	/// The attached armor that been given, if any.
	var/datum/armor/attached_armor
	/// Timer ID for a proc that revokes the armor given when it times out.
	var/timer_id
	/// How long should the armor be given?
	var/timer_length = 5 SECONDS

/datum/mutation_upgrade/shell/scout/on_mutation_enabled()
	RegisterSignal(xenomorph_owner, COMSIG_LIVING_WEEDS_AT_LOC_CREATED, PROC_REF(entered_weeds))
	RegisterSignal(xenomorph_owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_movement))
	if(!xenomorph_owner.loc_weeds_type)
		grant_armor()
		return
	entered_weeds(xenomorph_owner, xenomorph_owner.loc_weeds_type)

/datum/mutation_upgrade/shell/scout/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, list(COMSIG_LIVING_WEEDS_AT_LOC_CREATED, COMSIG_MOVABLE_MOVED))
	revoke_armor()

/// Grants armor and removes the timer.
/datum/mutation_upgrade/shell/scout/proc/grant_armor()
	if(timer_id)
		deltimer(timer_id)
		timer_id = null
	if(attached_armor)
		return
	attached_armor = new(armor, armor, armor, armor, armor, armor, armor, armor)
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
	desc = "While connected with Essence Link, you heal for 15% of your partner's damage when they slash a human."
	/// The percentage of damage dealt to lifesteal. 1 = 100%, 0 = 0%
	var/percentage = 0.15

/datum/mutation_upgrade/shell/together_in_claws/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/essence_link/link_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/essence_link]
	if(link_ability)
		link_ability.lifesteal_percentage += percentage
		link_ability.existing_link?.set_lifesteal(link_ability.lifesteal_percentage)

/datum/mutation_upgrade/shell/together_in_claws/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/essence_link/link_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/essence_link]
	if(link_ability)
		link_ability.lifesteal_percentage -= percentage
		link_ability.existing_link?.set_lifesteal(link_ability.lifesteal_percentage)

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/revenge
	name = "Revenge"
	desc = "While connected with Essence Link and it ends due to death, the survivor temporarily gains 100% additional melee damage for 10 seconds."
	/// The melee damage multiplier to increase by.
	var/modifier = 1

/datum/mutation_upgrade/spur/revenge/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/essence_link/link_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/essence_link]
	if(!link_ability)
		return
	link_ability.revenge_modifier += modifier
	link_ability.existing_link?.revenge_modifier += modifier

/datum/mutation_upgrade/spur/revenge/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/essence_link/link_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/essence_link]
	if(!link_ability)
		return
	link_ability.revenge_modifier -= modifier
	link_ability.existing_link?.revenge_modifier += modifier

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/saving_grace
	name = "Saving Grace"
	desc = "Salve Heal has no cast time on your Essence Link partner if they qualify for bonus healing. Bonus healing multiplier is increased by an additive of 2."
	/// The multiplier as an additive to increase the bonus healing by.
	var/multiplier = 2

/datum/mutation_upgrade/veil/saving_grace/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/psychic_cure/acidic_salve/salve_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_cure/acidic_salve]
	if(!salve_ability)
		return
	salve_ability.bypass_cast_time_on_threshold = TRUE
	salve_ability.bonus_healing_additive_multiplier += multiplier

/datum/mutation_upgrade/veil/saving_grace/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/psychic_cure/acidic_salve/salve_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_cure/acidic_salve]
	if(!salve_ability)
		return
	salve_ability.bypass_cast_time_on_threshold = initial(salve_ability.bypass_cast_time_on_threshold)
	salve_ability.bonus_healing_additive_multiplier -= multiplier

/datum/mutation_upgrade/veil/vitality_transfer
	name = "Vitality Transfer"
	desc = "While connected with Essence Link, you can manually disconnect to heal your partner for 10% of their maximum health multiplied by the attunement amount. However, you take true damage equal to the amount healed. This damage can kill you."
	/// The additional percentage of maximum health to heal by. 1 = 100%, 0 = 0%
	var/percentage = 0.1

/datum/mutation_upgrade/veil/vitality_transfer/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/essence_link/link_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/essence_link]
	link_ability?.disconnection_heal_percentage += percentage

/datum/mutation_upgrade/veil/vitality_transfer/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/essence_link/link_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/essence_link]
	link_ability?.disconnection_heal_percentage -= percentage
