#define MAX_LOADABLE_REAGENT_AMOUNT 30
#define NO_REAGENT_COLOR "#FFFFFF"

/datum/component/harvester
	///reagent selected for actions
	var/datum/reagent/selected_reagent
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

	var/obj/item/item_parent = parent

	reagent_select_action = new
	LAZYADD(item_parent.actions, reagent_select_action)

	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/examine)
	RegisterSignal(parent, COMSIG_ITEM_UNIQUE_ACTION, .proc/activate_blade)
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, .proc/attack)
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/attackby)
	RegisterSignal(reagent_select_action, COMSIG_ACTION_TRIGGER, .proc/select_reagent)

/datum/component/harvester/Destroy(force, silent)
	var/obj/item/item_parent = parent
	LAZYREMOVE(item_parent.actions, reagent_select_action)
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
		user.balloon_alert(user, "incompatible")
		return

	var/obj/item/reagent_containers/container = cont

	if(!container.reagents.total_volume)
		user.balloon_alert(user, "empty")
		return

	if(length(container.reagents.reagent_list) > 1)
		user.balloon_alert(user, "homogeneous mixture required")
		return

	var/datum/reagent/reagent_to_load = container.reagents.reagent_list[1].type

	if(!loadable_reagents[reagent_to_load])
		user.balloon_alert(user, "incompatible reagent, check description")
		return

	if(loaded_reagents[reagent_to_load] > MAX_LOADABLE_REAGENT_AMOUNT)
		user.balloon_alert(user, "full")
		return

	user.balloon_alert(user, "filling up...")
	if(!do_after(user, 1 SECONDS, TRUE, source, BUSY_ICON_BAR, null, PROGRESS_BRASS))
		return

	if(!loaded_reagents[reagent_to_load])
		loaded_reagents[reagent_to_load] = 0

	var/added_amount = min(container.reagents.total_volume, MAX_LOADABLE_REAGENT_AMOUNT - loaded_reagents[reagent_to_load])
	container.reagents.remove_reagent(reagent_to_load, added_amount)
	loaded_reagents[reagent_to_load] += added_amount
	user.balloon_alert(user, "[loaded_reagents[reagent_to_load]]u")
	if(length(loaded_reagents) == 1)
		update_selected_reagent(reagent_to_load)

///Handles behavior when activating the weapon
/datum/component/harvester/proc/activate_blade_async(datum/source, mob/user)

	if(loaded_reagent)
		user.balloon_alert(user, "[initial(loaded_reagent.name)]")
		return

	if(!selected_reagent)
		user.balloon_alert(user, "no reagent")
		return

	var/use_amount = loadable_reagents[selected_reagent]

	if(loaded_reagents[selected_reagent] < use_amount)
		user.balloon_alert(user, "insufficient liquid")
		return

	if(user.do_actions)
		return

	to_chat(user, span_rose("You start filling up the small chambers along the blade's edge."))
	if(!do_after(user, 2 SECONDS, TRUE, source, BUSY_ICON_BAR, ignore_turf_checks = TRUE))
		to_chat(user, span_rose("Due to the sudden movement, the safety mechanism siphons the substance back."))
		return

	loaded_reagent = selected_reagent
	loaded_reagents[selected_reagent] -= use_amount
	if(!loaded_reagents[selected_reagent])
		loaded_reagents -= selected_reagent
	user.balloon_alert(user, "loaded")

///Handles behavior when attacking a mob
/datum/component/harvester/proc/attack_async(datum/source, mob/living/target, mob/living/user, obj/item/weapon)
	to_chat(user, span_rose("You prepare to stab <b>[target != user ? "[target]" : "yourself"]</b>!"))
	new /obj/effect/temp_visual/telekinesis(get_turf(target))
	if((target != user) && do_after(user, 2 SECONDS, TRUE, target, BUSY_ICON_DANGER))
		target.heal_overall_damage(12.5, 0, updating_health = TRUE)
	else
		target.adjustStaminaLoss(-30)
		target.heal_overall_damage(6, 0, updating_health = TRUE)

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
	. = FALSE
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
			target.flamer_fire_act(10)
			target.apply_damage(target.modify_by_armor(20, FIRE, weapon.penetration, user.zone_selected), BURN, user.zone_selected)
			var/list/cone_turfs = generate_true_cone(target, 1, 0, 181, Get_Angle(user, target.loc))
			for(var/turf/checked_turf AS in cone_turfs)
				for(var/mob/living/victim in checked_turf)
					victim.flamer_fire_act(10)
					victim.apply_damage(target.modify_by_armor(20, FIRE, weapon.penetration, user.zone_selected), BURN, user.zone_selected)

		if(/datum/reagent/medicine/bicaridine)
			if(isxeno(target))
				return
			INVOKE_ASYNC(src, .proc/attack_async, source, target, user, weapon)
			. = COMPONENT_ITEM_NO_ATTACK

	if(!loaded_reagents[loaded_reagent])
		update_selected_reagent(null)
		user.balloon_alert(user, "[initial(loaded_reagent.name)]: empty")
	loaded_reagent = null

#undef MAX_LOADABLE_REAGENT_AMOUNT

/datum/component/harvester/proc/select_reagent(datum/source)
	var/list/options = list()
	for(var/datum/reagent/reagent_entry AS in loaded_reagents)
		options += initial(reagent_entry.name)

	var/selected_option = tgui_input_list(reagent_select_action.owner, "Selection", "Available reagents", options)

	if(!selected_option)
		return

	var/datum/reagent/selected_reagent = null
	for(var/datum/reagent/reagent_entry AS in loaded_reagents)
		if(initial(reagent_entry.name) == selected_option)
			selected_reagent = reagent_entry

	update_selected_reagent(selected_reagent)


/datum/component/harvester/proc/update_selected_reagent(datum/reagent/new_reagent)
	selected_reagent = new_reagent

	var/image/button_overlay = reagent_select_action.selected_reagent_overlay
	button_overlay.color = new_reagent ? initial(new_reagent.color) : NO_REAGENT_COLOR
	reagent_select_action.update_button_icon()

/datum/action/harvester/reagent_select
	name = "Select Reagent"
	var/image/selected_reagent_overlay

/datum/action/harvester/reagent_select/New(Target)
	. = ..()
	selected_reagent_overlay = image('icons/mob/actions.dmi', null, "selected_reagent")
	update_button_icon()

/datum/action/harvester/reagent_select/update_button_icon()
	. = ..()
	button.overlays += selected_reagent_overlay

#undef NO_REAGENT_COLOR
