/datum/component/harvester
	var/force = 0
	var/obj/item/reagent_containers/glass/beaker/vial/beaker = null
	var/datum/reagent/loaded_reagent = null
	var/list/loadable_reagents = list(
		/datum/reagent/medicine/bicaridine,
		/datum/reagent/medicine/tramadol,
		/datum/reagent/medicine/kelotane,
	)

/datum/component/harvester/Initialize()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	beaker = new /obj/item/reagent_containers/glass/beaker/vial

	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/examine)
	RegisterSignal(parent, COMSIG_ITEM_UNIQUE_ACTION, .proc/unique_action)
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, .proc/attack)
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/attackby)

/datum/component/chem_booster/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_PARENT_EXAMINE,
		COMSIG_ITEM_UNIQUE_ACTION,
		COMSIG_ITEM_ATTACK,
		COMSIG_PARENT_ATTACKBY))

/datum/component/harvester/proc/examine(datum/source, mob/user)
	SIGNAL_HANDLER
	to_chat(user, span_rose("[length(beaker.reagents.reagent_list) ? "It currently holds [beaker.reagents.total_volume]u of [beaker.reagents.reagent_list[1].name]" : "The internal storage is empty"].\n<b>Compatible chemicals:</b>"))
	for(var/R in loadable_reagents)
		var/atom/L = R
		to_chat(user, "[initial(L.name)]")

/datum/component/harvester/proc/attackby(datum/source, obj/item/I, mob/user)
	if(user.do_actions)
		return TRUE

	if(!isreagentcontainer(I) || istype(I, /obj/item/reagent_containers/pill))
		to_chat(user, span_rose("[I] isn't compatible with [source]."))
		return TRUE

	var/trans
	var/obj/item/reagent_containers/container = I

	if(!container.reagents.total_volume)
		trans = beaker.reagents.trans_to(container, 30)
		to_chat(user, span_rose("[trans ? "You take [trans]u out of the internal storage. It now contains [beaker.reagents.total_volume]u" : "[source]'s storage is empty."]."))
		return TRUE

	if(length(container.reagents.reagent_list) > 1)
		to_chat(user, span_rose("The solution needs to be uniform and contain only a single type of reagent to be compatible."))
		return TRUE

	if(beaker.reagents.total_volume && (container.reagents.reagent_list[1].type != beaker.reagents.reagent_list[1].type))
		to_chat(user, span_rose("[source]'s internal storage can contain only one kind of solution at the same time. It currently contains <b>[beaker.reagents.reagent_list[1].name]</b>"))
		return TRUE

	if(!locate(container.reagents.reagent_list[1].type) in loadable_reagents)
		to_chat(user, span_rose("This reagent is not compatible with the weapon's mechanism. Check the engraved symbols for further information."))
		return TRUE

	if(container.reagents.total_volume < 5)
		to_chat(user, span_rose("At least 5u of the substance is needed."))
		return TRUE

	if(beaker.reagents.total_volume >= 30)
		to_chat(user, span_rose("The internal storage is full."))
		return TRUE

	to_chat(user, span_notice("You begin filling up the [source] with [container.reagents.reagent_list[1]]."))
	if(!do_after(user, 1 SECONDS, TRUE, source, BUSY_ICON_BAR, null, PROGRESS_BRASS))
		return TRUE

	trans = container.reagents.trans_to(beaker, container.amount_per_transfer_from_this)
	to_chat(user, span_rose("You load [trans]u into the internal system. It now holds [beaker.reagents.total_volume]u."))
	return TRUE

/datum/component/harvester/proc/unique_action(datum/source, mob/user)
	if(loaded_reagent)
		to_chat(user, span_rose("The blade is powered with [loaded_reagent.name]. You can release the effect by stabbing a creature."))
		return FALSE

	if(beaker.reagents.total_volume < 5)
		to_chat(user, span_rose("You don't have enough substance."))
		return FALSE

	if(user.do_actions)
		return FALSE

	to_chat(user, span_rose("You start filling up the small chambers along the blade's edge."))
	if(!do_after(user, 2 SECONDS, TRUE, source, BUSY_ICON_BAR, ignore_turf_checks = TRUE))
		to_chat(user, span_rose("Due to the sudden movement, the safety machanism drains out the reagent back into the main storage."))
		return FALSE

	loaded_reagent = beaker.reagents.reagent_list[1]
	beaker.reagents.remove_any(5)
	return TRUE

/datum/component/harvester/proc/apply_flame_cone(mob/living/target, mob/living/user)
	target.flamer_fire_act(10)
	target.apply_damage(max(0, 20 - 20*target.hard_armor.getRating("fire")), BURN, user.zone_selected, target.get_soft_armor("fire", user.zone_selected))

/datum/component/harvester/proc/attack(datum/source, mob/living/M, mob/living/user)
	if(!loaded_reagent)
		return

	if(M.status_flags & INCORPOREAL || user.status_flags & INCORPOREAL) //Incorporeal beings cannot attack or be attacked
		return FALSE

	switch(loaded_reagent.type)
		if(/datum/reagent/medicine/tramadol)
			M.apply_damage(force*0.6, BRUTE, user.zone_selected)
			M.apply_status_effect(/datum/status_effect/incapacitating/harvester_slowdown, 1 SECONDS)

		if(/datum/reagent/medicine/kelotane)
			src.apply_flame_cone(M, user)
			var/list/cone_turfs = generate_cone(M, 1, 0, 181, Get_Angle(user, M.loc))
			for(var/X in cone_turfs)
				var/turf/T = X
				for(var/mob/living/victim in T)
					src.apply_flame_cone(victim, user)
					//TODO BRAVEMOLE

		if(/datum/reagent/medicine/bicaridine)
			if(isxeno(M))
				return
			to_chat(user, span_rose("You prepare to stab <b>[M != user ? "[M]" : "yourself"]</b>!"))
			new /obj/effect/temp_visual/telekinesis(get_turf(M))
			if((M != user) && do_after(user, 2 SECONDS, TRUE, M, BUSY_ICON_DANGER))
				M.heal_overall_damage(12.5, 0, TRUE)
			else
				M.adjustStaminaLoss(-30)
				M.heal_overall_damage(6, 0, TRUE)
			loaded_reagent = null
			return FALSE

	loaded_reagent = null
	return
