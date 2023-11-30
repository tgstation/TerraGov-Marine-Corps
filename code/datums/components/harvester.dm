#define NO_REAGENT_COLOR "#FFFFFF"

#define VALI_CODEX "<b>Reagent info:</b><BR>\
	All chems - Deal an additional 60% of the weapons damage as true damage<BR>\
	Bicaridine - Heals yourself and restores stamina upon attacking an enemy. Channel a heal on help intent to restore more health to allies<BR>\
	Kelotane - Set your target aflame<BR>\
	Tramadol - Slow your target for 1 second<BR>\
	Tricordrazine - Sunders and shatters your targets armor<BR>\
	<BR>\
	<b>Tips:</b><BR>\
	> Needs to be connected to the Vali system to collect green blood. You can connect it though the Vali system's configurations menu.<BR>\
	> Filled by liquid reagent containers. Emptied by using an empty liquid reagent container. Can also be filled by pills.<BR>\
	> Press your unique action key (SPACE by default) to load a single-use of the reagent effect after the blade has been filled up.<BR>"

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
		/datum/reagent/medicine/tricordrazine = 5,
	)
	///Amount of reagents loaded into the blade
	var/list/loaded_reagents = list()
	///Selects the active reagent
	var/datum/action/harvester/reagent_select/reagent_select_action
	///The maximum amount that one chemical can be loaded
	var/max_loadable_reagent_amount = 30
	var/loadup_on_attack = FALSE

/datum/component/harvester/Initialize(max_reagent_amount, loadup_on_attack)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	var/obj/item/item_parent = parent

	if(max_reagent_amount)
		max_loadable_reagent_amount = max_reagent_amount
	if(loadup_on_attack)
		src.loadup_on_attack = loadup_on_attack

	reagent_select_action = new
	LAZYADD(item_parent.actions, reagent_select_action)

	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(examine))
	RegisterSignal(parent, COMSIG_ITEM_UNIQUE_ACTION, PROC_REF(activate_blade))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(attack))
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(attackby))
	RegisterSignal(reagent_select_action, COMSIG_ACTION_TRIGGER, PROC_REF(select_reagent))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(update_loaded_color))
	RegisterSignal(parent, COMSIG_ITEM_APPLY_CUSTOM_OVERLAY, PROC_REF(upate_mob_overlay))
	RegisterSignal(parent, COMSIG_ATOM_GET_MECHANICS_INFO, PROC_REF(get_mechanics_info))

	item_parent.update_icon() //So that our sprite realizes it's empty when it spawns

/datum/component/harvester/Destroy(force, silent)
	var/obj/item/item_parent = parent
	LAZYREMOVE(item_parent.actions, reagent_select_action)
	QDEL_NULL(reagent_select_action)
	return ..()

/datum/component/harvester/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_EXAMINE,
		COMSIG_ITEM_UNIQUE_ACTION,
		COMSIG_ITEM_ATTACK,
		COMSIG_ATOM_ATTACKBY,
	))

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

///Adds mechanics info to the weapon
/datum/component/harvester/proc/get_mechanics_info(datum/source, list/mechanics_text)
	SIGNAL_HANDLER
	mechanics_text += (VALI_CODEX)
	return COMPONENT_MECHANICS_CHANGE

///Handles behavior for when item is clicked on
/datum/component/harvester/proc/attackby_async(datum/source, obj/item/cont, mob/user)
	if(user.do_actions)
		return

	if(!isreagentcontainer(cont))
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

	if(loaded_reagents[reagent_to_load] > max_loadable_reagent_amount)
		user.balloon_alert(user, "full")
		return

	user.balloon_alert(user, "filling up...")
	if(!do_after(user, 1 SECONDS, NONE, source, BUSY_ICON_BAR, null, PROGRESS_BRASS))
		return

	if(!loaded_reagents[reagent_to_load])
		loaded_reagents[reagent_to_load] = 0

	var/added_amount = min(container.reagents.total_volume, max_loadable_reagent_amount - loaded_reagents[reagent_to_load])
	container.reagents.remove_reagent(reagent_to_load, added_amount)
	loaded_reagents[reagent_to_load] += added_amount
	user.balloon_alert(user, "[loaded_reagents[reagent_to_load]]u")
	if(length(loaded_reagents) == 1)
		update_selected_reagent(reagent_to_load)
	if(istype(container, /obj/item/reagent_containers/pill))
		qdel(container)

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
	if(!do_after(user, 2 SECONDS, IGNORE_USER_LOC_CHANGE, source, BUSY_ICON_BAR))
		to_chat(user, span_rose("Due to the sudden movement, the safety mechanism siphons the substance back."))
		return

	loaded_reagent = selected_reagent
	loaded_reagents[selected_reagent] -= use_amount
	if(!loaded_reagents[selected_reagent])
		loaded_reagents -= selected_reagent

	var/obj/item/item_parent = parent
	item_parent.update_icon()
	user.update_inv_r_hand()
	user.update_inv_l_hand()

	user.balloon_alert(user, "loaded")

///Updates the color of the overlay on top of the item sprite based on what chem is loaded in
/datum/component/harvester/proc/update_loaded_color(datum/source, list/overlays_list)
	SIGNAL_HANDLER
	var/obj/item/item_parent = parent
	var/image/item_overlay = image('icons/obj/items/vali.dmi', item_parent, "[initial(item_parent.icon_state)]_loaded")
	if(!loaded_reagent)
		item_overlay.color = COLOR_GREEN
	else
		item_overlay.color = initial(loaded_reagent.color)
	overlays_list.Add(item_overlay)

///Updates the mob sprite
/datum/component/harvester/proc/upate_mob_overlay(datum/source, mutable_appearance/standing, inhands, icon_used, state_used)
	SIGNAL_HANDLER
	var/mutable_appearance/blade_overlay = mutable_appearance(icon_used, "[state_used]_loaded")
	if(!loaded_reagent)
		blade_overlay.color = COLOR_GREEN
	else
		blade_overlay.color = initial(loaded_reagent.color)
	standing.overlays.Add(blade_overlay)

///Signal handler calling when user is filling the harvester
/datum/component/harvester/proc/attackby(datum/source, obj/item/cont, mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(attackby_async), source, cont, user)

///Signal handler calling activation of the harvester
/datum/component/harvester/proc/activate_blade(datum/source, mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(activate_blade_async), source, user)

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
		if(/datum/reagent/medicine/bicaridine)
			if(user.a_intent == INTENT_HELP)
				. = COMPONENT_ITEM_NO_ATTACK
			INVOKE_ASYNC(src, PROC_REF(attack_bicaridine), source, target, user, weapon)

		if(/datum/reagent/medicine/kelotane)
			target.apply_damage(weapon.force*0.6, BRUTE, user.zone_selected)
			target.flamer_fire_act(10)

		if(/datum/reagent/medicine/tramadol)
			target.apply_damage(weapon.force*0.6, BRUTE, user.zone_selected)
			target.apply_status_effect(/datum/status_effect/incapacitating/harvester_slowdown, 1 SECONDS)

		if(/datum/reagent/medicine/tricordrazine)
			target.apply_damage(weapon.force*0.6, BRUTE, user.zone_selected)
			target.adjust_sunder(7.5) //Same amount as a shotgun slug
			target.apply_status_effect(/datum/status_effect/shatter, 3 SECONDS)

	if(!loaded_reagents[loaded_reagent])
		update_selected_reagent(null)
		user.balloon_alert(user, "[initial(loaded_reagent.name)]: empty")
	loaded_reagent = null

	var/obj/item/item_parent = parent
	item_parent.update_icon()
	user.update_inv_r_hand()
	user.update_inv_l_hand()

	if(loadup_on_attack)
		INVOKE_ASYNC(src, PROC_REF(activate_blade_async), source, user)

///Handles behavior when attacking a mob with bicaridine
/datum/component/harvester/proc/attack_bicaridine(datum/source, mob/living/target, mob/living/user, obj/item/weapon)
	if(user.a_intent != INTENT_HELP) //Self-heal on attacking
		new /obj/effect/temp_visual/telekinesis(get_turf(user))
		target.apply_damage(weapon.force*0.6, BRUTE, user.zone_selected)
		user.adjustStaminaLoss(-30)
		user.heal_overall_damage(5, 0, updating_health = TRUE)
		return

	to_chat(user, span_rose("You prepare to stab <b>[target != user ? "[target]" : "yourself"]</b>!"))
	new /obj/effect/temp_visual/telekinesis(get_turf(target))

	if(do_after(user, 2 SECONDS, TRUE, target, BUSY_ICON_DANGER)) //Channeled heal on help intent
		var/skill_heal_amt = user.skills.getRating(SKILL_MEDICAL) * 5
		target.heal_overall_damage(10 + skill_heal_amt, 0, updating_health = TRUE) //5u of Bica will normally heal 25 damage. Medics get this full amount
	else
		target.adjustStaminaLoss(-30)
		target.heal_overall_damage(5, 0, updating_health = TRUE)

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
#undef VALI_CODEX
