GLOBAL_LIST_INIT(quick_loadouts, init_quick_loadouts())

/proc/init_quick_loadouts()
	. = list()
	var/list/loadout_list = list(
		/datum/outfit/quick/tgmc/marine/standard_assaultrifle,
		/datum/outfit/quick/tgmc/marine/standard_laserrifle,
		/datum/outfit/quick/tgmc/marine/standard_machinegunner,
		/datum/outfit/quick/tgmc/marine/medium_machinegunner,
		/datum/outfit/quick/tgmc/marine/standard_shotgun,
		/datum/outfit/quick/tgmc/marine/standard_lasercarbine,
		/datum/outfit/quick/tgmc/engineer/rrengineer,
		/datum/outfit/quick/tgmc/engineer/sentry,
		/datum/outfit/quick/tgmc/engineer/demolition,
		/datum/outfit/quick/tgmc/corpsman/standard_medic,
		/datum/outfit/quick/tgmc/smartgunner/standard_sg,
		/datum/outfit/quick/tgmc/smartgunner/minigun_sg,
		/datum/outfit/quick/tgmc/leader/standard_assaultrifle,
		/datum/outfit/quick/som/marine/mpi,
		/datum/outfit/quick/som/marine/charger,
		/datum/outfit/quick/som/marine/caliver,
		/datum/outfit/quick/som/veteran/charger,
		/datum/outfit/quick/som/veteran/culverin,
	)

	for(var/X in loadout_list)
		.[X] = new X


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
	var/list/data = list()
	var/list/loadouts_data_tgui = list()
	for(var/loadout_data in GLOB.quick_loadouts)
		var/list/next_loadout_data = list() //makes a list item with the below lines, for each loadout entry in the list
		var/datum/outfit/quick/current_loadout = GLOB.quick_loadouts[loadout_data]
		next_loadout_data["job"] = current_loadout.jobtype
		next_loadout_data["name"] = current_loadout.name
		next_loadout_data["desc"] = current_loadout.desc
		next_loadout_data["amount"] = current_loadout.quantity
		next_loadout_data["outfit"] = current_loadout.type
		loadouts_data_tgui += list(next_loadout_data)
	data["loadout_list"] = loadouts_data_tgui
	return data


/obj/machinery/quick_vendor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("selectLoadout")
			var/datum/outfit/quick/selected_loadout = GLOB.quick_loadouts[text2path(params["loadout_outfit"])]
			if(!selected_loadout)
				to_chat(ui.user, span_warning("Error when loading this loadout"))
				CRASH("Fail to load loadouts")
			if(selected_loadout.quantity == 0)
				to_chat(usr, span_warning("This loadout has been depleted, you'll need to pick another."))
				return
			var/obj/item/card/id/I = usr.get_idcard() //ui.user better?
			if(selected_loadout.jobtype != I.rank)
				to_chat(usr, span_warning("You are not in the right job for this loadout!"))
				return
			if(I.marine_buy_flags & MARINE_CAN_BUY_LOADOUT)
				I.marine_buy_flags &= ~MARINE_CAN_BUY_LOADOUT
				selected_loadout.quantity --
				selected_loadout.equip(ui.user) //actually equips the loadout
			else
				to_chat(usr, span_warning("You can't buy things from this category anymore."))
