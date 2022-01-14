/datum/component/harvester
	///Force is used to define damage dealt by tramadol reagent
	var/force
	///Beaker sets volume of internal storage
	var/obj/item/reagent_containers/glass/beaker/vial/beaker = null
	///Loaded reagent
	var/datum/reagent/loaded_reagent = null
	///List of loadable reagents
	var/static/list/loadable_reagents = list(
		/datum/reagent/medicine/bicaridine,
		/datum/reagent/medicine/tramadol,
		/datum/reagent/medicine/kelotane,
	)

/datum/component/harvester/Initialize()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	beaker = new /obj/item/reagent_containers/glass/beaker/vial

	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/examine)
	RegisterSignal(parent, COMSIG_ITEM_UNIQUE_ACTION, .proc/activate_blade)
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, .proc/attack)
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/attackby)

/datum/component/harvester/Destroy(force, silent)
	QDEL_NULL(beaker)
	return ..()

/datum/component/chem_booster/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_PARENT_EXAMINE,
		COMSIG_ITEM_UNIQUE_ACTION,
		COMSIG_ITEM_ATTACK,
		COMSIG_PARENT_ATTACKBY))

///Adds additional text for the component when examining the item
/datum/component/harvester/proc/examine(datum/source, mob/user)
	SIGNAL_HANDLER
	to_chat(user, span_rose("[length(beaker.reagents.reagent_list) ? "It currently holds [beaker.reagents.total_volume]u of [beaker.reagents.reagent_list[1].name]" : "The internal storage is empty"].\n<b>Compatible chemicals:</b>"))
	for(var/atom/reagent AS in loadable_reagents)
		to_chat(user, "[initial(reagent.name)]")

///Handles behavior for when item is clicked on
/datum/component/harvester/proc/attackby_async(datum/source, obj/item/cont, mob/user)
	if(user.do_actions)
		return

	if(!isreagentcontainer(cont) || istype(cont, /obj/item/reagent_containers/pill))
		to_chat(user, span_rose("[cont] isn't compatible with [source]."))
		return

	var/trans
	var/obj/item/reagent_containers/container = cont

	if(!container.reagents.total_volume)
		trans = beaker.reagents.trans_to(container, 30)
		to_chat(user, span_rose("[trans ? "You take [trans]u out of the internal storage. It now contains [beaker.reagents.total_volume]u" : "[source]'s storage is empty."]."))
		return

	if(length(container.reagents.reagent_list) > 1)
		to_chat(user, span_rose("The solution needs to be uniform and contain only a single type of reagent to be compatible."))
		return

	if(beaker.reagents.total_volume && (container.reagents.reagent_list[1].type != beaker.reagents.reagent_list[1].type))
		to_chat(user, span_rose("[source]'s internal storage can contain only one kind of solution at the same time. It currently contains <b>[beaker.reagents.reagent_list[1].name]</b>"))
		return

	if(!locate(container.reagents.reagent_list[1].type) in loadable_reagents)
		to_chat(user, span_rose("This reagent is not compatible with the weapon's mechanism. Check the engraved symbols for further information."))
		return

	if(container.reagents.total_volume < 5)
		to_chat(user, span_rose("At least 5u of the substance is needed."))
		return

	if(beaker.reagents.total_volume >= 30)
		to_chat(user, span_rose("The internal storage is full."))
		return

	to_chat(user, span_notice("You begin filling up the [source] with [container.reagents.reagent_list[1]]."))
	if(!do_after(user, 1 SECONDS, TRUE, source, BUSY_ICON_BAR, null, PROGRESS_BRASS))
		return

	trans = container.reagents.trans_to(beaker, container.amount_per_transfer_from_this)
	to_chat(user, span_rose("You load [trans]u into the internal system. It now holds [beaker.reagents.total_volume]u."))
	return

///Handles behavior when activating the weapon
/datum/component/harvester/proc/activate_blade_async(datum/source, mob/user)
	if(loaded_reagent)
		to_chat(user, span_rose("The blade is powered with [loaded_reagent.name]. You can release the effect by stabbing a creature."))
		return

	if(beaker.reagents.total_volume < 5)
		to_chat(user, span_rose("You don't have enough substance."))
		return

	if(user.do_actions)
		return

	to_chat(user, span_rose("You start filling up the small chambers along the blade's edge."))
	if(!do_after(user, 2 SECONDS, TRUE, source, BUSY_ICON_BAR, ignore_turf_checks = TRUE))
		to_chat(user, span_rose("Due to the sudden movement, the safety machanism drains out the reagent back into the main storage."))
		return

	loaded_reagent = beaker.reagents.reagent_list[1]
	beaker.reagents.remove_any(5)

///Handles behavior when attacking a mob
/datum/component/harvester/proc/attack_async(datum/source, mob/living/target, mob/living/user, obj/item/weapon)
	to_chat(user, span_rose("You prepare to stab <b>[target != user ? "[target]" : "yourself"]</b>!"))
	new /obj/effect/temp_visual/telekinesis(get_turf(target))
	if((target != user) && do_after(user, 2 SECONDS, TRUE, target, BUSY_ICON_DANGER))
		target.heal_overall_damage(12.5, 0, TRUE)
	else
		target.adjustStaminaLoss(-30)
		target.heal_overall_damage(6, 0, TRUE)
	loaded_reagent = null

///Signal handler calling when user is filling the harvester
/datum/component/harvester/proc/attackby(datum/source, obj/item/cont, mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/attackby_async, source, cont, user)

///Signal handler calling activation of the harvester
/datum/component/harvester/proc/activate_blade(datum/source, mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/activate_blade_async, source, user)

///Signal handler calling when user attacks
/datum/component/harvester/proc/attack(datum/source, mob/living/target, mob/living/user, obj/item/weapon)
	SIGNAL_HANDLER
	weapon = user.get_active_held_item()
	if(!loaded_reagent)
		return

	if(target.status_flags & INCORPOREAL || user.status_flags & INCORPOREAL) //Incorporeal beings cannot attack or be attacked
		return

	switch(loaded_reagent.type)
		if(/datum/reagent/medicine/tramadol)
			target.apply_damage(weapon.force*0.6, BRUTE, user.zone_selected)
			target.apply_status_effect(/datum/status_effect/incapacitating/harvester_slowdown, 1 SECONDS)

		if(/datum/reagent/medicine/kelotane)
			target.flamer_fire_act(10)
			target.apply_damage(max(0, 20 - 20*target.hard_armor.getRating("fire")), BURN, user.zone_selected, target.get_soft_armor("fire", user.zone_selected))
			var/list/cone_turfs = generate_cone(target, 1, 0, 181, Get_Angle(user, target.loc))
			for(var/turf/tiles AS in cone_turfs)
				for(var/mob/living/victim in tiles)
					victim.flamer_fire_act(10)
					victim.apply_damage(max(0, 20 - 20*victim.hard_armor.getRating("fire")), BURN, user.zone_selected, victim.get_soft_armor("fire", user.zone_selected))

		if(/datum/reagent/medicine/bicaridine)
			if(isxeno(target))
				return
			INVOKE_ASYNC(src, .proc/attack_async, source, target, user, weapon)
			return COMPONENT_ITEM_NO_ATTACK

	loaded_reagent = null
