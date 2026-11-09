/obj/item/circuitboard/computer/intel_computer
	name = "circuit board (intel computer)"
	build_path = /obj/machinery/computer/fire_support


/obj/machinery/computer/fire_support
	name = "fire support requistion terminal"
	desc = "Allows for the selection and purchase a munitions to be used for close air support, called in via fire support binoculars in the field."
	icon_state = "computer_small"
	screen_overlay = "fire_support"
	interaction_flags = INTERACT_MACHINE_TGUI
	faction = FACTION_TERRAGOV

/obj/machinery/computer/fire_support/Initialize(mapload)
	. = ..()

/obj/machinery/computer/fire_support/Destroy()
	return ..()

/obj/machinery/computer/fire_support/ui_interact(mob/user, datum/tgui/ui)
	if(!SSticker.mode || istype(SSticker.mode, /datum/game_mode/infestation/sovl_war))
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FireSupport", "Fire Support Requisition")
		ui.open()

/obj/machinery/computer/fire_support/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/spritesheet/campaign/fire_support))

/obj/machinery/computer/fire_support/ui_data(mob/user)
	var/list/data = list()
	data["points"] = SSpoints.dropship_points
	return data

/obj/machinery/computer/fire_support/ui_static_data(mob/user)
	var/list/data = list()

	var/list/munition_list = list()
	for(var/munition_type in GLOB.hvz_munition_types)
		var/datum/fire_support/munition = GLOB.fire_support_types[munition_type]
		var/list/munition_data = list()
		munition_data["munition_type"] = munition_type
		munition_data["munition_name"] = munition.name
		munition_data["munition_uses"] = munition.uses
		munition_data["munition_cost"] = 1 //placeholder, todo
		munition_data["munition_desc"] = "placeholder desc" //todo
		munition_data["munition_icon"] = (munition.icon_state)
		munition_list += list(munition_data)

	data["munition_list"] = munition_list
	return data

/obj/machinery/computer/fire_support/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	var/mob/living/user = usr

	switch(action)
		if("purchase")
			var/munition_cost = text2num(params["munition_cost"])
			if(SSpoints.dropship_points < munition_cost)
				//insufficient funds
				return
			var/munition_type = params["munition_type"]
			if(!(munition_type in GLOB.fire_support_types))
				//invalid, bad
				return
			var/datum/fire_support/munition = GLOB.fire_support_types[munition_type]
			munition.uses ++
			SSpoints.dropship_points -= munition_cost
			user.playsound_local(user, 'sound/effects/menu_click.ogg', 75)
