/obj/item/circuitboard/computer/fire_support
	name = "circuit board (fire support terminal)"
	build_path = /obj/machinery/computer/fire_support


/obj/machinery/computer/fire_support
	name = "fire support requisition terminal"
	desc = "Allows for the selection and purchase of munitions to be used for close air support, called in via fire support binoculars in the field."
	icon_state = "computer_small"
	screen_overlay = "fire_support"
	circuit = /obj/item/circuitboard/computer/fire_support
	interaction_flags = INTERACT_MACHINE_TGUI
	faction = FACTION_TERRAGOV

/obj/machinery/computer/fire_support/ui_interact(mob/user, datum/tgui/ui)
	if(!SSticker.mode || !istype(SSticker.mode, /datum/game_mode/infestation/sovl_war))
		to_chat(user, span_warning("Fire support not currently available."))
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FireSupport", "Fire Support Requisition")
		ui.open()

/obj/machinery/computer/fire_support/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/spritesheet/campaign/fire_support))

/obj/machinery/computer/fire_support/ui_data(mob/user)
	var/list/data = list()
	data["points"] = floor(SSpoints.dropship_points)

	var/list/munition_list = list()
	for(var/munition_type in GLOB.hvx_munition_types)
		var/datum/fire_support/munition = GLOB.fire_support_types[munition_type]
		var/list/munition_data = list()
		munition_data["munition_type"] = munition_type
		munition_data["munition_name"] = munition.name
		munition_data["munition_uses"] = munition.uses
		munition_data["munition_cost"] = munition.purchase_cost
		munition_data["munition_desc"] = munition.description
		munition_data["munition_icon"] = munition.icon_state
		munition_list += list(munition_data)

	data["munition_list"] = munition_list
	return data

/obj/machinery/computer/fire_support/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	var/mob/living/user = ui.user

	switch(action)
		if("purchase")
			var/munition_type = params["munition_type"]
			if(!(munition_type in GLOB.fire_support_types))
				return
			var/datum/fire_support/munition = GLOB.fire_support_types[munition_type]
			if(SSpoints.dropship_points < munition.purchase_cost)
				return
			munition.uses ++
			SSpoints.dropship_points -= munition.purchase_cost
			user.playsound_local(user, 'sound/machines/terminal_prompt_confirm.ogg', 75)

/obj/machinery/computer/fire_support/mrap
	icon = 'icons/obj/structures/campaign/tall_structures.dmi'
	icon_state = "overwatch"
	screen_overlay = "overwatch_screen"
