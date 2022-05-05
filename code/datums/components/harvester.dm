#define MAX_LOADABLE_REAGENT_AMOUNT 60

/datum/component/harvester
	///reagent selected for actions
	var/selected_reagent
	///Loaded reagent
	var/datum/reagent/loaded_reagent
	///List of loadable reagents
	var/static/list/loadable_reagents = list(
		/datum/reagent/medicine/bicaridine = 5,
		/datum/reagent/medicine/tramadol = 5,
		/datum/reagent/medicine/kelotane = 5,
	)
	///Amount of reagents loaded into the blade
	var/list/loaded_reagents = list()
	///Selects the active reagent
	var/datum/action/harvester/reagent_select/reagent_select_action

/datum/component/harvester/Initialize(chem_component)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	if(!istype(chem_component, /datum/component/chem_booster))
		return COMPONENT_INCOMPATIBLE

	reagent_select_action = new
	reagent_select_action.selected_reagent_overlay = image('icons/mob/actions.dmi', null, "selected_reagent")
	reagent_select_action.button.overlays += reagent_select_action.selected_reagent_overlay

	var/obj/item/item_parent = parent
	item_parent.actions += reagent_select_action

	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/examine)
	RegisterSignal(parent, COMSIG_ITEM_UNIQUE_ACTION, .proc/activate_blade)
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, .proc/attack)
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/attackby)
	RegisterSignal(reagent_select_action, COMSIG_ACTION_TRIGGER, .proc/select_reagent)

/datum/component/harvester/Destroy(force, silent)
	var/obj/item/item_parent = parent
	item_parent.actions -= reagent_select_action
	QDEL_NULL(reagent_select_action)
	return ..()

/datum/component/chem_booster/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_PARENT_EXAMINE,
		COMSIG_ITEM_UNIQUE_ACTION,
		COMSIG_ITEM_ATTACK,
		COMSIG_PARENT_ATTACKBY))

///Adds additional text for the component when examining the item
/datum/component/harvester/proc/examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	var/output = ""
	if(length(loaded_reagents))
		output += "It currently holds:<br>"
		for(var/datum/reagent/reagent_type AS in loaded_reagents)
			output += "<span style='color:[initial(reagent_type.color)];font-weight:bold'>[initial(reagent_type.name)]</span> - [loaded_reagents[reagent_type]]\n"
	else
		output += "The internal storage is empty\n"

	output += "<b>Compatible chemicals:</b>\n"
	for(var/datum/reagent/reagent AS in loadable_reagents)
		output += "<span style='color:[initial(reagent.color)];font-weight:bold'>[initial(reagent.name)]</span>\n"

	to_chat(user, output)

///Handles behavior for when item is clicked on
/datum/component/harvester/proc/attackby_async(datum/source, obj/item/cont, mob/user)
	if(user.do_actions)
		return

	if(!isreagentcontainer(cont) || istype(cont, /obj/item/reagent_containers/pill))
		to_chat(user, span_rose("[cont] isn't compatible with [source]."))
		return

	var/obj/item/reagent_containers/container = cont

	if(!container.reagents.total_volume)
		to_chat(user, span_rose("Empty container."))
		return

	if(length(container.reagents.reagent_list) > 1)
		to_chat(user, span_rose("The solution needs to contain only a single type of reagent."))
		return

	var/datum/reagent/reagent_to_load = container.reagents.reagent_list[1].type

	if(!loadable_reagents[reagent_to_load])
		to_chat(user, span_rose("Incompatible reagent. Check the reagents list for which you can use."))
		return

	if(loaded_reagents[reagent_to_load] > MAX_LOADABLE_REAGENT_AMOUNT)
		to_chat(user, span_rose("[reagent_to_load] storage is full."))
		return

	to_chat(user, span_notice("You begin filling up [source] with [reagent_to_load]."))
	if(!do_after(user, 1 SECONDS, TRUE, source, BUSY_ICON_BAR, null, PROGRESS_BRASS))
		to_chat(user, span_rose("Reservoir for [reagent_to_load] is full."))
		return

	if(!loaded_reagents[reagent_to_load])
		loaded_reagents[reagent_to_load] = 0

	var/added_amount = min(container.reagents.total_volume, MAX_LOADABLE_REAGENT_AMOUNT - loaded_reagents[reagent_to_load])
	container.reagents.remove_reagent(reagent_to_load, added_amount)
	loaded_reagents[reagent_to_load] += added_amount
	to_chat(user, span_rose("You load [added_amount]u. It now holds [loaded_reagents[reagent_to_load]]u."))

///Handles behavior when activating the weapon
/datum/component/harvester/proc/activate_blade_async(datum/source, mob/user)
	if(loaded_reagent)
		to_chat(user, span_rose("The blade is powered with [initial(loaded_reagent.name)]. Stab a creature to release the substance."))
		return

	if(!selected_reagent)
		to_chat(user, span_rose("Select a reagent."))
		return

	var/use_amount = loadable_reagents[selected_reagent]

	if(loaded_reagents[selected_reagent] < use_amount)
		to_chat(user, span_rose("Not enough substance."))
		return

	if(user.do_actions)
		return

	to_chat(user, span_rose("You start filling up the small chambers along the blade's edge."))
	if(!do_after(user, 2 SECONDS, TRUE, source, BUSY_ICON_BAR, ignore_turf_checks = TRUE))
		to_chat(user, span_rose("Due to the sudden movement, the safety mechanism siphons the substance back."))
		return

	loaded_reagent = selected_reagent
	loaded_reagents[selected_reagent] -= use_amount

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

	switch(loaded_reagent)
		if(/datum/reagent/medicine/tramadol)
			target.apply_damage(weapon.force*0.6, BRUTE, user.zone_selected)
			target.apply_status_effect(/datum/status_effect/incapacitating/harvester_slowdown, 1 SECONDS)

		if(/datum/reagent/medicine/kelotane)
			var/list/cone_turfs = generate_cone(get_turf(target), 10, 90, Get_Angle(user, target.loc))
			for(var/row_turfs in cone_turfs)
				for(var/turf/checked_turf AS in row_turfs)
					checked_turf.ignite()

		if(/datum/reagent/medicine/bicaridine)
			if(isxeno(target))
				return
			INVOKE_ASYNC(src, .proc/attack_async, source, target, user, weapon)
			return COMPONENT_ITEM_NO_ATTACK

	loaded_reagent = null

#undef MAX_LOADABLE_REAGENT_AMOUNT

/datum/component/harvester/proc/select_reagent(datum/source)
	var/datum/reagent/selected_reagent = tgui_input_list(reagent_select_action.owner, "Selection", "Available reagents", loaded_reagents)
	if(!loaded_reagents[selected_reagent])
		return

	var/button_overlay = reagent_select_action.selected_reagent_overlay

	button_overlay.color = initial(selected_reagent.color)
	reagent_select_action.button.overlays -= button_overlay
	reagent_select_action.button.overlays += button_overlay

	src.selected_reagent = selected_reagent

/datum/action/harvester/reagent_select
	name = "Select Reagent"
	var/image/selected_reagent_overlay
