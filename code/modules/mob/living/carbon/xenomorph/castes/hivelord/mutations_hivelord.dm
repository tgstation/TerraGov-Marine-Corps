//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/hardened_travel
	name = "Hardened Travel"
	desc = "Resin Walk increases all soft armor by 15, but prevents you from regenerating plasma during it."
	/// The amount of armor that Resin Walk should be granting.
	var/armor = 15

/datum/mutation_upgrade/shell/hardened_travel/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/toggle_speed/speed_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_speed]
	if(!speed_ability)
		return
	speed_ability.set_plasma(FALSE)
	speed_ability.set_armor(speed_ability.armor_amount + armor)

/datum/mutation_upgrade/shell/hardened_travel/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/xeno_action/toggle_speed/speed_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_speed]
	if(!speed_ability)
		return
	speed_ability.set_plasma(initial(speed_ability.can_plasma_regenerate))
	speed_ability.set_armor(speed_ability.armor_amount - armor)

/datum/mutation_upgrade/shell/costly_travel
	name = "Costly Travel"
	desc = "Resin Walk creates temporary weeds as you move. Each created weed consumes 50 plasma."
	/// The amount of plasma to consume if a weed is created through Resin Walk.
	var/plasma_cost = 50

/datum/mutation_upgrade/shell/costly_travel/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/toggle_speed/speed_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_speed]
	if(!speed_ability)
		return
	speed_ability.weeding_cost += plasma_cost

/datum/mutation_upgrade/shell/costly_travel/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/xeno_action/toggle_speed/speed_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_speed]
	if(!speed_ability)
		return
	speed_ability.weeding_cost -= plasma_cost

/datum/mutation_upgrade/shell/rejuvenating_build
	name = "Rejuvenating Build"
	desc = "You heal 2% of your maximum health whenever you successfully use Secrete Resin."
	/// The percentage of maximum health that will be healed when a structure is built via Secrete Resin. 1 = 100%, 0.01 = 1%
	var/percentage = 0.02


/datum/mutation_upgrade/shell/rejuvenating_build/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/secrete_resin/hivelord/resin_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/secrete_resin/hivelord]
	if(!resin_ability)
		return
	resin_ability.heal_percentage += percentage

/datum/mutation_upgrade/shell/rejuvenating_build/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/secrete_resin/hivelord/resin_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/secrete_resin/hivelord]
	if(!resin_ability)
		return
	resin_ability.heal_percentage -= percentage

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/combustive_jelly
	name = "Combustive Jelly"
	desc = "You lose the ability, Place Resin Jelly Pod. Resin jelly you throw no longer grants fire immunity, but creates thin sticky resin in a 3x3 where it lands for 15 seconds. Direct impacts on humans stagger for 4 seconds."
	/// The additional amount of deciseconds that thrown Resin Jelly will stagger for if it impacts a human.
	var/duration = 4 SECONDS
	/// The ability to be given back if the mutation is disabled.
	var/datum/action/ability/xeno_action/place_jelly_pod/removed_ability

/datum/mutation_upgrade/spur/combustive_jelly/on_mutation_enabled()
	RegisterSignals(xenomorph_owner, list(COMSIG_MOB_DROPPING_ITEM, COMSIG_LIVING_PICKED_UP_ITEM), PROC_REF(update_resin_jelly))
	var/datum/action/ability/xeno_action/place_jelly_pod/pod_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/place_jelly_pod]
	if(pod_ability)
		removed_ability = pod_ability
		removed_ability.remove_action(xenomorph_owner)
	update_resin_jelly(null,  xenomorph_owner.get_active_held_item())
	update_resin_jelly(null,  xenomorph_owner.get_inactive_held_item())

/datum/mutation_upgrade/spur/combustive_jelly/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, list(COMSIG_MOB_DROPPING_ITEM, COMSIG_LIVING_PICKED_UP_ITEM))
	if(removed_ability)
		removed_ability.give_action(xenomorph_owner)
		removed_ability = null
	update_resin_jelly(null,  xenomorph_owner.get_active_held_item())
	update_resin_jelly(null,  xenomorph_owner.get_inactive_held_item())

/datum/mutation_upgrade/shell/combustive_jelly/on_xenomorph_upgrade()
	var/datum/action/ability/xeno_action/place_jelly_pod/pod_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/place_jelly_pod]
	if(!pod_ability)
		return
	xenomorph_owner.remove_ability(pod_ability) // Upgrading gives abilities we have removed, thus we need to delete them.

/datum/mutation_upgrade/spur/combustive_jelly/proc/update_resin_jelly(datum/source, obj/item/item_in_question)
	SIGNAL_HANDLER
	if(!isresinjelly(item_in_question))
		return
	var/obj/item/resin_jelly/jelly_item = item_in_question
	jelly_item.combustive_duration = initial(jelly_item.combustive_duration) + duration

/datum/mutation_upgrade/spur/resin_splash
	name = "Resin Splash"
	desc = "Whenever you slash a human, 400 plasma is consumed to throw a sticky resin grenade at them. This can occur every 8 seconds."
	/// The amount of plasma to consume to attach a thin sticky resin grenade to the attacked human.
	var/plasma = 400
	/// Used to determine if it is ready to use or not.
	COOLDOWN_DECLARE(grenade_cooldown)

/datum/mutation_upgrade/spur/resin_splash/on_mutation_enabled()
	RegisterSignal(xenomorph_owner, COMSIG_XENOMORPH_ATTACK_HUMAN, PROC_REF(on_attack_human))

/datum/mutation_upgrade/spur/resin_splash/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, COMSIG_XENOMORPH_ATTACK_HUMAN)

/datum/mutation_upgrade/spur/resin_splash/proc/on_attack_human(datum/source, mob/living/carbon/human/attacked_human)
	SIGNAL_HANDLER
	if(!COOLDOWN_FINISHED(src, grenade_cooldown))
		return
	if(xenomorph_owner.plasma_stored < plasma)
		return
	COOLDOWN_START(src, grenade_cooldown, 8 SECONDS)
	xenomorph_owner.use_plasma(plasma)
	var/obj/item/explosive/grenade/sticky/xeno/resin/sticky_grenade = new(xenomorph_owner.loc)
	sticky_grenade.activate(xenomorph_owner)
	sticky_grenade.throw_at(attacked_human, 2, 5, xenomorph_owner)


/datum/mutation_upgrade/spur/hostile_pylon
	name = "Hostile Pylon"
	desc = "Recovery Pylon's aura is replaced with one that increases melee damage modifier by 20%. The aura's radius is increased by 3."
	/// The additional amount that Recovery Pylon will add as a damage modifier.
	var/modifier = 0.2

/datum/mutation_upgrade/spur/hostile_pylon/on_mutation_enabled()
	var/datum/action/ability/xeno_action/place_recovery_pylon/pylon_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/place_recovery_pylon]
	if(!pylon_ability)
		return
	pylon_ability.radius += 3
	pylon_ability.damage_modifier += modifier

/datum/mutation_upgrade/spur/hostile_pylon/on_mutation_disabled()
	var/datum/action/ability/xeno_action/place_recovery_pylon/pylon_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/place_recovery_pylon]
	if(!pylon_ability)
		return
	pylon_ability.radius -= 3
	pylon_ability.damage_modifier -= modifier

//*********************//
//         Veil        //
//*********************//

/datum/mutation_upgrade/veil/protective_light
	name = "Protective Light"
	desc = "Healing Infusion now also applies the effects of resin jelly for 15 seconds. The plasma cost is now 1.75x of the original cost."
	/// The multiplier that will added to the ability cost of Healing Infusion.
	var/multiplier = 0.75
	/// The length in deciseconds of the Resin Jelly applied status effect.
	var/resin_jelly_length = 15 SECONDS

/datum/mutation_upgrade/veil/protective_light/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/healing_infusion/healing_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/healing_infusion]
	if(!healing_ability)
		return
	healing_ability.resin_jelly_duration += resin_jelly_length
	healing_ability.ability_cost += initial(healing_ability.ability_cost) * multiplier

/datum/mutation_upgrade/veil/protective_light/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/healing_infusion/healing_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/healing_infusion]
	if(!healing_ability)
		return
	healing_ability.resin_jelly_duration -= resin_jelly_length
	healing_ability.ability_cost -= initial(healing_ability.ability_cost) * multiplier

/datum/mutation_upgrade/veil/forward_light
	name = "Forward Light"
	desc = "Healing Infusion only lasts 60% as long, but grants innate healing which allows healing off of weeds."
	/// The multiplier that will added to the Healing Infusion's duration and amount of healing tick.
	var/multiplier = -0.4

/datum/mutation_upgrade/veil/forward_light/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/healing_infusion/healing_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/healing_infusion]
	if(!healing_ability)
		return
	healing_ability.innate_healing = TRUE
	healing_ability.status_multiplier += multiplier

/datum/mutation_upgrade/veil/forward_light/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/healing_infusion/healing_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/healing_infusion]
	if(!healing_ability)
		return
	healing_ability.innate_healing = initial(healing_ability.innate_healing)
	healing_ability.status_multiplier -= multiplier

/datum/mutation_upgrade/veil/weed_specialist
	name = "Weed Specialist"
	desc = "Plant Weeds now costs 65% of its initial value, but loses the option to select basic weeds."
	/// The multiplier that will added to the Plant Weeds's ability cost.
	var/multiplier = -0.35

/datum/mutation_upgrade/veil/weed_specialist/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/plant_weeds/weed_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/plant_weeds]
	if(!weed_ability)
		return
	if(/obj/alien/weeds/node in weed_ability.selectable_weed_typepaths)
		weed_ability.selectable_weed_typepaths -= /obj/alien/weeds/node
	if(weed_ability.weed_type == /obj/alien/weeds/node && length(weed_ability.selectable_weed_typepaths))
		weed_ability.weed_type = pick(weed_ability.selectable_weed_typepaths)
	weed_ability.cost_multiplier += multiplier
	weed_ability.update_ability_cost()
	weed_ability.update_button_icon()

/datum/mutation_upgrade/veil/weed_specialist/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/plant_weeds/weed_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/plant_weeds]
	if(!weed_ability)
		return
	if(!(/obj/alien/weeds/node in weed_ability.selectable_weed_typepaths))
		weed_ability.selectable_weed_typepaths += /obj/alien/weeds/node
	weed_ability.cost_multiplier -= multiplier
	weed_ability.update_ability_cost()
	weed_ability.update_button_icon()
