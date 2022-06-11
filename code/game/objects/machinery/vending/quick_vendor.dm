/obj/machinery/quick_vendor
	name = "Kwik-E-Quip vendor"
	desc = "An advanced vendor to instantly arm soldiers with specific sets of equipment, allowing for immediate combat deployment."
	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "specialist"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	req_access = null
	req_one_access = null
	interaction_flags = INTERACT_MACHINE_TGUI
	///The faction of this quick load vendor
	var/faction = FACTION_NEUTRAL

	///List of all loadouts. Format is list(list(loadout_job, loadout_name))
	var/list/loadouts_data = list(
		list("Squad Marine","Basic1"),
		list("Squad Marine","Basic2"),
		list("Squad Marine","vet1"),
		list("Squad Marine","vet2"),
		list("SOM Standard","Basic1"),
		list("SOM Standard","Basic2"),
		list("SOM Veteran","vet1"),
		list("SOM Veteran","vet2"),
		)
	///lists the outfit datums that corrospond to the loadout options
	var/list/loadout_list = list(
		("Basic1SOM Standard") = /datum/outfit/quick/som/standard,
		("Basic2SOM Standard") = /datum/outfit/quick/som/standard/one,
		("vet1SOM Veteran") = /datum/outfit/quick/som/veteran,
		("vet2SOM Veteran") = /datum/outfit/quick/som/veteran/three,
		("Basic1Squad Marine") = /datum/outfit/quick/som/standard,
		("Basic2Squad Marine") = /datum/outfit/quick/som/standard/one,
		("vet1Squad Marine") = /datum/outfit/quick/som/veteran,
		("vet2Squad Marine") = /datum/outfit/quick/som/veteran/three,
	)

/obj/machinery/quick_vendor/som
	faction = FACTION_SOM

/obj/machinery/quick_vendor/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(!ishuman(user))
		return FALSE

	var/mob/living/carbon/human/H = user
	if(!allowed(H))
		return FALSE

	if(!isidcard(H.get_idcard())) //not wearing an ID
		return FALSE

	var/obj/item/card/id/I = H.get_idcard()
	if(I.registered_name != H.real_name)
		return FALSE
	return TRUE

/obj/machinery/quick_vendor/ui_interact(mob/living/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		if(faction == FACTION_SOM)
			//SOM vendor has SOM specific job titles
			ui = new(user, src, "Quickload_SOM")
		else
			ui = new(user, src, "Quickload_TGMC")
		ui.open()

/obj/machinery/quick_vendor/ui_state(mob/user)
	return GLOB.human_adjacent_state

/obj/machinery/quick_vendor/ui_data(mob/living/user)
	. = ..()
	var/data = list()
	var/list/loadouts_data_tgui = list()
	for(var/list/loadout_data in loadouts_data)
		var/next_loadout_data = list()
		next_loadout_data["job"] = loadout_data[1]
		next_loadout_data["name"] = loadout_data[2]
		loadouts_data_tgui += list(next_loadout_data)
	data["loadout_list"] = loadouts_data_tgui
	return data

/obj/machinery/quick_vendor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("selectLoadout")
			var/job = params["loadout_job"]
			var/name = params["loadout_name"]
			if(isnull(name))
				return
			var/datum/outfit/selected_loadout = loadout_list["[name + job]"]
			if(!selected_loadout)
				to_chat(ui.user, span_warning("Error when loading this loadout"))
				CRASH("Fail to load loadouts")
			//maybe could go somewhere else
			var/obj/item/card/id/I = usr.get_idcard() //ui.user better?
			if(job != I.rank)
				to_chat(usr, span_warning("You are not in the right job for this loadout!"))
				return
			if(I.marine_buy_flags & MARINE_CAN_BUY_LOADOUT)
				I.marine_buy_flags &= ~MARINE_CAN_BUY_LOADOUT
				selected_loadout = new selected_loadout
				selected_loadout.equip(ui.user) //actually equips the loadout
			else
				to_chat(usr, span_warning("You can't buy things from this category anymore.")) //make early return instead?
				return

			//todo: check if still relevant - NOTE refreshes the tgui I think, so probs best to have it.
			//update_static_data(ui.user, ui)
