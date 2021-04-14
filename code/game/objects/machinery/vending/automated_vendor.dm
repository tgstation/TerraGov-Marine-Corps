/obj/machinery/automated_vendor
	name = "\improper automated vendor"
	desc = ""
	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "marinearmory"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	req_access = null
	req_one_access = null
	interaction_flags = INTERACT_MACHINE_TGUI

	idle_power_usage = 60
	active_power_usage = 3000
	var/current_loadout_items_data = list()


/obj/machinery/automated_vendor/update_icon()
	if(is_operational())
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"

/obj/machinery/automated_vendor/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(!allowed(H))
			return FALSE

		var/obj/item/card/id/I = H.get_idcard()
		if(!istype(I)) //not wearing an ID
			return FALSE

		if(I.registered_name != H.real_name)
			return FALSE

	return TRUE

/obj/machinery/automated_vendor/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/inventory),
	)

/obj/machinery/automated_vendor/proc/prepare_items_data(mob/user)
	for (var/item_slot_key in GLOB.visible_item_slot_list)
		var/list/result = list()

		var/datum/item_representation/item = user.client.prefs.loadout_manager.current_loadout.item_list[item_slot_key]
		if (isnull(item))
			result["icon"] = icon2base64(icon("icons/misc/empty.dmi", "empty"))
			current_loadout_items_data[item_slot_key] = result
			continue

		var/obj/item/item_type = item.item_type
		result["icon"] = icon2base64(icon(initial(item_type.icon), initial(item_type.icon_state)))
		result["name"] = initial(item_type.name)

		current_loadout_items_data[item_slot_key] = result

/obj/machinery/automated_vendor/ui_interact(mob/user, datum/tgui/ui)
	prepare_items_data(user)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "LoadoutMaker", name)
		ui.open()

/obj/machinery/automated_vendor/ui_data(mob/user)
	var/list/data = list()
	
	data["items"] = current_loadout_items_data
	return data

/obj/machinery/automated_vendor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("equipLoadout")
			ui.user.client.prefs.loadout_manager.current_loadout.equip_mob(ui.user, loc)
		if("selectLoadout")
			ui.user.client.prefs.loadout_manager.ui_interact(ui.user)
	

