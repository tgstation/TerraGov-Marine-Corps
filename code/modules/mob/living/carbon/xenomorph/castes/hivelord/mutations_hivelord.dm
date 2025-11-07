//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/hardened_travel
	name = "Hardened Travel"
	desc = "Resin Walk increases all soft armor by 10/15/20, but prevents you from regenerating plasma."
	/// For the first structure, the amount of armor that Resin Walk should be granting.
	var/armor_initial = 5
	/// For each structure, the amount of armor that Resin Walk should be granting.
	var/armor_per_structure = 5

/datum/mutation_upgrade/shell/hardened_travel/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Resin Walk increases all soft armor by [get_armor(new_amount)], but prevents you from regenerating plasma."

/datum/mutation_upgrade/shell/hardened_travel/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/toggle_speed/speed_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_speed]
	if(!speed_ability)
		return
	speed_ability.set_plasma(FALSE)
	speed_ability.set_armor(speed_ability.armor_amount + get_armor(0))

/datum/mutation_upgrade/shell/hardened_travel/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/xeno_action/toggle_speed/speed_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_speed]
	if(!speed_ability)
		return
	speed_ability.set_plasma(initial(speed_ability.can_plasma_regenerate))
	speed_ability.set_armor(speed_ability.armor_amount - get_armor(0))

/datum/mutation_upgrade/shell/hardened_travel/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/toggle_speed/speed_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_speed]
	if(!speed_ability)
		return
	speed_ability.set_armor(speed_ability.armor_amount + get_armor(new_amount - previous_amount, FALSE))

/// Returns the amount of armor that Resin Walk should be granting.
/datum/mutation_upgrade/shell/hardened_travel/proc/get_armor(structure_count, include_initial = TRUE)
	return (include_initial ? armor_initial : 0) + (armor_per_structure * structure_count)

/datum/mutation_upgrade/shell/costly_travel
	name = "Costly Travel"
	desc = "Resin Walk creates temporary weeds as you move. Each created weed consumes 75/50/25 plasma."
	/// For the first structure, the amount of plasma to consume if a weed is created through Resin Walk.
	var/plasma_initial = 100
	/// For each structure, the additional amount of plasma to consume if a weed is created through Resin Walk.
	var/plasma_per_structure = -25

/datum/mutation_upgrade/shell/costly_travel/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Resin Walk creates temporary weeds as you move. Each created weed consumes [get_plasma(new_amount)] plasma."

/datum/mutation_upgrade/shell/costly_travel/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/toggle_speed/speed_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_speed]
	if(!speed_ability)
		return
	speed_ability.weeding_cost += get_plasma(0)

/datum/mutation_upgrade/shell/costly_travel/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/xeno_action/toggle_speed/speed_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_speed]
	if(!speed_ability)
		return
	speed_ability.weeding_cost -= get_plasma(0)

/datum/mutation_upgrade/shell/costly_travel/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/toggle_speed/speed_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_speed]
	if(!speed_ability)
		return
	speed_ability.weeding_cost += get_plasma(new_amount - previous_amount, FALSE)

/// Returns the amount of plasma to consume if a weed is created through Resin Walk.
/datum/mutation_upgrade/shell/costly_travel/proc/get_plasma(structure_count, include_initial = TRUE)
	return (include_initial ? plasma_initial : 0) + (plasma_per_structure * structure_count)

/datum/mutation_upgrade/shell/rejuvenating_build
	name = "Rejuvenating Build"
	desc = "You heal 1/2/3% of your maximum health whenever you successfully use Secrete Resin."
	/// For each structure, the percentage of maximum health that will be healed when a structure is built via Secrete Resin.
	var/percentage_per_structure = 0.01

/datum/mutation_upgrade/shell/rejuvenating_build/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "You heal [PERCENT(get_percentage(new_amount))]% of your maximum health whenever you successfully use Secrete Resin."

/datum/mutation_upgrade/shell/rejuvenating_build/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/secrete_resin/hivelord/resin_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/secrete_resin/hivelord]
	if(!resin_ability)
		return
	resin_ability.heal_percentage += get_percentage(new_amount - previous_amount)

/// Returns the percentage of maximum health that will be healed when a structure is built via Secrete Resin.
/datum/mutation_upgrade/shell/rejuvenating_build/proc/get_percentage(structure_count)
	return percentage_per_structure * structure_count

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/combustive_jelly
	name = "Combustive Jelly"
	desc = "You lose the ability, Place Resin Jelly Pod. Resin jelly you throw no longer grants fire immunity, but creates thin sticky resin in a 3x3 where it lands for 15 seconds. Direct impacts on humans stagger for 2/4/6 seconds."
	/// For each structure, the additional amount of deciseconds that thrown Resin Jelly will stagger for if it impacts a human.
	var/duration_per_structure = 2 SECONDS

/datum/mutation_upgrade/spur/combustive_jelly/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "You lose the ability, Place Resin Jelly Pod. Resin jelly you throw no longer grants fire immunity, but creates thin sticky resin in a 3x3 where it lands for 15 seconds. Direct impacts on humans stagger for [get_duration(new_amount) / 10] seconds."

/datum/mutation_upgrade/spur/combustive_jelly/on_mutation_enabled()
	var/datum/action/ability/xeno_action/place_jelly_pod/pod_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/place_jelly_pod]
	if(pod_ability)
		pod_ability.remove_action(xenomorph_owner)
	RegisterSignals(xenomorph_owner, list(COMSIG_MOB_DROPPING_ITEM, COMSIG_LIVING_PICKED_UP_ITEM), PROC_REF(update_resin_jelly))
	return ..()

/datum/mutation_upgrade/spur/combustive_jelly/on_mutation_disabled()
	var/datum/action/ability/xeno_action/place_jelly_pod/pod_ability = new()
	pod_ability.give_action(xenomorph_owner)
	UnregisterSignal(xenomorph_owner, list(COMSIG_MOB_DROPPING_ITEM, COMSIG_LIVING_PICKED_UP_ITEM))
	return ..()

/datum/mutation_upgrade/spur/combustive_jelly/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/place_jelly_pod/pod_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/place_jelly_pod]
	if(!pod_ability)
		return
	update_resin_jelly(null,  xenomorph_owner.get_active_held_item())
	update_resin_jelly(null,  xenomorph_owner.get_inactive_held_item())

/datum/mutation_upgrade/shell/combustive_jelly/on_xenomorph_upgrade()
	var/datum/action/ability/xeno_action/place_jelly_pod/pod_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/place_jelly_pod]
	if(pod_ability)
		pod_ability.remove_action(xenomorph_owner)

/datum/mutation_upgrade/spur/combustive_jelly/proc/update_resin_jelly(datum/source, obj/item/item_in_question)
	SIGNAL_HANDLER
	if(!isresinjelly(item_in_question))
		return
	var/obj/item/resin_jelly/jelly_item = item_in_question
	jelly_item.combustive_duration = initial(jelly_item.combustive_duration) + get_duration(get_total_structures())

/// Returns the amount of deciseconds that thrown Resin Jelly will stagger for if it impacts a human.
/datum/mutation_upgrade/spur/combustive_jelly/proc/get_duration(structure_count)
	return duration_per_structure * structure_count

/datum/mutation_upgrade/spur/resin_splash
	name = "Resin Splash"
	desc = "Whenever you slash a human, 600/400/200 plasma is consumed to throw a sticky resin grenade at them. This can occur every 8 seconds."
	/// For the first structure, the amount of plasma to consume to attach a thin sticky resin grenade to the attacked human.
	var/plasma_initial = 800
	/// For each structure, the additional amount of plasma to consume to attach a thin sticky resin grenade to the attacked human.
	var/plasma_per_structure = -200
	/// Used to determine if it is ready to use or not.
	COOLDOWN_DECLARE(grenade_cooldown)

/datum/mutation_upgrade/spur/resin_splash/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Whenever you slash a human, [get_plasma(new_amount)] plasma is consumed to throw a sticky resin grenade at them. This can occur every 8 seconds."

/datum/mutation_upgrade/spur/resin_splash/on_mutation_enabled()
	RegisterSignal(xenomorph_owner, COMSIG_XENOMORPH_ATTACK_HUMAN, PROC_REF(on_attack_human))
	return ..()

/datum/mutation_upgrade/spur/resin_splash/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, COMSIG_XENOMORPH_ATTACK_HUMAN)
	return ..()

/datum/mutation_upgrade/spur/resin_splash/proc/on_attack_human(datum/source, mob/living/carbon/human/attacked_human)
	SIGNAL_HANDLER
	if(!COOLDOWN_FINISHED(src, grenade_cooldown))
		return
	var/required_plasma = get_plasma(get_total_structures())
	if(xenomorph_owner.plasma_stored < required_plasma)
		return
	COOLDOWN_START(src, grenade_cooldown, 8 SECONDS)
	xenomorph_owner.use_plasma(required_plasma)
	var/obj/item/explosive/grenade/sticky/xeno/resin/sticky_grenade = new(xenomorph_owner.loc)
	sticky_grenade.activate(xenomorph_owner)
	sticky_grenade.throw_at(attacked_human, 2, 5, xenomorph_owner)

/// Returns the amount of plasma to consume to attach a thin sticky resin grenade to the attacked human.
/datum/mutation_upgrade/spur/resin_splash/proc/get_plasma(structure_count, include_initial = TRUE)
	return (include_initial ? plasma_initial : 0) + (plasma_per_structure * structure_count)

/datum/mutation_upgrade/spur/hostile_pylon
	name = "Hostile Pylon"
	desc = "Recovery Pylon's aura is replaced with one that increases melee damage modifier by 10/20/30%. The aura's radius is increased by 3."
	/// For each structure, the additional amount that Recovery Pylon will add as a damage modifier.
	var/modifier_per_structure = 0.1

/datum/mutation_upgrade/spur/hostile_pylon/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Recovery Pylon's aura is replaced with one that increases melee damage modifier by [PERCENT(get_modifier(new_amount))]%. The aura's radius is increased by 3."

/datum/mutation_upgrade/spur/hostile_pylon/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/place_recovery_pylon/pylon_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/place_recovery_pylon]
	if(!pylon_ability)
		return
	pylon_ability.radius += 3

/datum/mutation_upgrade/spur/hostile_pylon/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/xeno_action/place_recovery_pylon/pylon_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/place_recovery_pylon]
	if(!pylon_ability)
		return
	pylon_ability.radius -= 3

/datum/mutation_upgrade/spur/hostile_pylon/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/place_recovery_pylon/pylon_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/place_recovery_pylon]
	if(!pylon_ability)
		return
	pylon_ability.damage_modifier += get_modifier(new_amount - previous_amount)

/// Returns the amount that Recovery Pylon will add as a damage modifier.
/datum/mutation_upgrade/spur/hostile_pylon/proc/get_modifier(structure_count)
	return modifier_per_structure * structure_count

//*********************//
//         Veil        //
//*********************//

/datum/mutation_upgrade/veil/protective_light
	name = "Protective Light"
	desc = "Healing Infusion now also applies the effects of resin jelly for 15 seconds. The plasma cost is now 2x/1.75x/1.5x of the original cost."
	/// For the first structure, the multiplier that will added to the ability cost of Healing Infusion.
	var/multiplier_initial = 1.25
	/// For each structure, the multiplier that will added to the ability cost of Healing Infusion.
	var/multiplier_per_structure = -0.25
	/// The length in deciseconds of the Resin Jelly applied status effect.
	var/resin_jelly_length = 15 SECONDS

/datum/mutation_upgrade/veil/protective_light/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Healing Infusion now also applies the effects of resin jelly for [resin_jelly_length / 10] seconds. The plasma cost is now [1 + get_multiplier(new_amount)]x of the original cost."

/datum/mutation_upgrade/veil/protective_light/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/healing_infusion/healing_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/healing_infusion]
	if(!healing_ability)
		return
	healing_ability.resin_jelly_duration += resin_jelly_length
	healing_ability.ability_cost += initial(healing_ability.ability_cost) * get_multiplier(0)

/datum/mutation_upgrade/veil/protective_light/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/healing_infusion/healing_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/healing_infusion]
	if(!healing_ability)
		return
	healing_ability.resin_jelly_duration -= resin_jelly_length
	healing_ability.ability_cost -= initial(healing_ability.ability_cost) * get_multiplier(0)

/datum/mutation_upgrade/veil/protective_light/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/healing_infusion/healing_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/healing_infusion]
	if(!healing_ability)
		return
	healing_ability.ability_cost += get_multiplier(new_amount - previous_amount, FALSE)

/// Returns the multiplier that will added to the ability cost of Healing Infusion.
/datum/mutation_upgrade/veil/protective_light/proc/get_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? multiplier_initial : 0) + (multiplier_per_structure * structure_count)

/datum/mutation_upgrade/veil/forward_light
	name = "Forward Light"
	desc = "Healing Infusion only lasts 50/60/70% as long, but grants innate healing which allows healing off of weeds."
	/// For the first structure, the multiplier that will added to the Healing Infusion's duration and amount of healing tick.
	var/multiplier_initial = -0.6
	/// For each structure, the additional multiplier that will added to the Healing Infusion's duration and amount of healing tick.
	var/multiplier_per_structure = 0.1

/datum/mutation_upgrade/veil/forward_light/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Healing Infusion only lasts [PERCENT(1 + get_multiplier(new_amount))]% as long, but grants innate healing which allows healing off of weeds."

/datum/mutation_upgrade/veil/forward_light/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/healing_infusion/healing_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/healing_infusion]
	if(!healing_ability)
		return
	healing_ability.innate_healing = TRUE
	healing_ability.status_multiplier += get_multiplier(0)

/datum/mutation_upgrade/veil/forward_light/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/healing_infusion/healing_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/healing_infusion]
	if(!healing_ability)
		return
	healing_ability.innate_healing = initial(healing_ability.innate_healing)
	healing_ability.status_multiplier -= get_multiplier(0)

/datum/mutation_upgrade/veil/forward_light/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/healing_infusion/healing_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/healing_infusion]
	if(!healing_ability)
		return
	healing_ability.status_multiplier += get_multiplier(new_amount - previous_amount, FALSE)

/// Returns the multiplier that will added to the Healing Infusion's duration and amount of healing tick.
/datum/mutation_upgrade/veil/forward_light/proc/get_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? multiplier_initial : 0) + (multiplier_per_structure * structure_count)

/datum/mutation_upgrade/veil/weed_specialist
	name = "Weed Specialist"
	desc = "Plant Weeds now costs 80/65/50% of its initial value, but loses the option to select basic weeds."
	/// For the first structure, the multiplier that will added to the Plant Weeds's ability cost.
	var/multiplier_initial = -0.05
	/// For each structure, the additional multiplier that will added to the Plant Weeds's ability cost.
	var/multiplier_per_structure = -0.15

/datum/mutation_upgrade/veil/weed_specialist/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Plant Weeds now costs [PERCENT(1 + get_multiplier(new_amount))]% of its initial value, but loses the option to select basic weeds."

/datum/mutation_upgrade/veil/weed_specialist/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/plant_weeds/weed_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/plant_weeds]
	if(!weed_ability)
		return
	if(/obj/alien/weeds/node in weed_ability.selectable_weed_typepaths)
		weed_ability.selectable_weed_typepaths -= /obj/alien/weeds/node
	if(weed_ability.weed_type == /obj/alien/weeds/node && length(weed_ability.selectable_weed_typepaths))
		weed_ability.weed_type = pick(weed_ability.selectable_weed_typepaths)
	weed_ability.cost_multiplier += get_multiplier(0)

/datum/mutation_upgrade/veil/weed_specialist/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/plant_weeds/weed_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/plant_weeds]
	if(!weed_ability)
		return
	if(!(/obj/alien/weeds/node in weed_ability.selectable_weed_typepaths))
		weed_ability.selectable_weed_typepaths += /obj/alien/weeds/node
		return
	weed_ability.cost_multiplier -= get_multiplier(0)

/datum/mutation_upgrade/veil/weed_specialist/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/plant_weeds/weed_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/plant_weeds]
	if(!weed_ability)
		return
	weed_ability.cost_multiplier += get_multiplier(new_amount - previous_amount, FALSE)
	weed_ability.update_ability_cost()
	weed_ability.update_button_icon()

/// Returns the multiplier that will added to the Plant Weeds's ability cost.
/datum/mutation_upgrade/veil/weed_specialist/proc/get_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? multiplier_initial : 0) + (multiplier_per_structure * structure_count)


