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

	///List of all loadouts. Format is list(list(loadout_job, loadout_name)) //todo: code more args, to include typepath, quantity, desc if needed, etc. Will need to update UI as well as vendor code as where)
	var/list/loadouts_data = list(
		list("SOM Standard","Basic1",-1),
		list("SOM Standard","Basic2",1),
		list("SOM Veteran","vet1",-1),
		list("SOM Veteran","vet2",1),
		list("Squad Marine","AR12 rifleman",1),
		list("Squad Marine","Laser rifleman",1),
		list("Squad Marine","MG60 machinegunner",1),
		list("Squad Marine","MG27 machinegunner",1),
		list("Squad Marine","SH35 scout",1),
		list("Squad Marine","Laser carbine scout",1),
		list("Squad Engineer","Rocket man",1),
		list("Squad Engineer","Sentry technician",1),
		list("Squad Engineer","Demolition specialist",1),
		list("Squad Corpsman","AR12 standard corpsman",1),
		list("Squad Smartgunner","SG29 smart machinegunner",1),
		list("Squad Smartgunner","SG85 smart machinegunner",1),
		list("Squad Leader","AR12 patrol leader",1),
		)
	///lists the outfit datums that corrospond to the loadout options
	var/list/loadout_list = list(
		("Basic1SOM Standard") = /datum/outfit/quick/som/standard,
		("Basic2SOM Standard") = /datum/outfit/quick/som/standard/one,
		("vet1SOM Veteran") = /datum/outfit/quick/som/veteran,
		("vet2SOM Veteran") = /datum/outfit/quick/som/veteran/three,
		("AR12 riflemanSquad Marine") = /datum/outfit/quick/tgmc/marine/standard_assaultrifle,
		("Laser riflemanSquad Marine") = /datum/outfit/quick/tgmc/marine/standard_laserrifle,
		("MG60 machinegunnerSquad Marine") = /datum/outfit/quick/tgmc/marine/standard_machinegunner,
		("MG27 machinegunnerSquad Marine") = /datum/outfit/quick/tgmc/marine/medium_machinegunner,
		("SH35 scoutSquad Marine") = /datum/outfit/quick/tgmc/marine/standard_shotgun,
		("Laser carbine scoutSquad Marine") = /datum/outfit/quick/tgmc/marine/standard_lasercarbine,
		("Rocket manSquad Engineer") = /datum/outfit/quick/tgmc/engineer/rrengineer,
		("Sentry technicianSquad Engineer") = /datum/outfit/quick/tgmc/engineer/sentry,
		("Demolition specialistSquad Engineer") = /datum/outfit/quick/tgmc/engineer/demolition,
		("AR12 standard corpsmanSquad Corpsman") = /datum/outfit/quick/tgmc/corpsman/standard_medic,
		("SG29 smart machinegunnerSquad Smartgunner") = /datum/outfit/quick/tgmc/smartgunner/standard_sg,
		("SG85 smart machinegunnerSquad Smartgunner") = /datum/outfit/quick/tgmc/smartgunner/minigun_sg,
		("AR12 patrol leaderSquad Leader") = /datum/outfit/quick/tgmc/leader/standard_assaultrifle,
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
