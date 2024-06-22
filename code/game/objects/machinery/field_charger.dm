//Pretty much a better cell recharger
//Mobile, charges multiple cells, can store cells, can charge devices with cells in them, doesn't violate the first law of thermodynamics
/obj/machinery/field_charger
	name = "mobile field charger"
	desc = "An automated charger and storage rack for power cells and electronic devices. Has an internal battery that charges off the power grid when wrenched down."
	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "lascharger"
	interaction_flags = INTERACT_MACHINE_TGUI
	density = TRUE
	wrenchable = TRUE
	drag_delay = FALSE
	machine_max_charge = 50000
	active_power_usage = 50000	//Looks like a lot but it's actually still pretty slow
	///List of references to power cells that are within this charger's contents list
	var/list/obj/item/cell/stored_cells
	///Like the contents list but stored in this manner so it doesn't have to be rebuilt unless an item is added/removed
	var/list/stored_item_references

/obj/machinery/field_charger/Initialize(mapload)
	. = ..()
	machine_current_charge = machine_max_charge

/obj/machinery/field_charger/examine(mob/user)
	. = ..()
	. += "Charge: [span_bold("[PERCENT(machine_current_charge/machine_max_charge)]%")]"
	. += "Has [span_bold("[LAZYLEN(stored_cells)]")] objects stored."

/obj/machinery/field_charger/update_icon_state()
	icon_state = initial(icon_state)
	//Prevent divide by zero
	if(!machine_current_charge)
		icon_state += "_0"
		return

	switch(machine_current_charge / max(1, machine_max_charge))	//Max is in case it is 0
		if(0 to 0.25)
			icon_state += "lascharger_25"
		if(0.25 to 0.5)
			icon_state += "lascharger_50"
		if(0.5 to 0.75)
			icon_state += "lascharger_75"

/obj/machinery/field_charger/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(machine_stat & BROKEN)
		return

	if(iscell(I))
		if(istype(I, /obj/item/cell/night_vision_battery))
			balloon_alert(user, "Not rechargeable")
			return

		if(!user.transferItemToLoc(I, src))
			return

		LAZYADD(stored_cells, I)
		return TRUE

	if(isgun(I))
		var/obj/item/weapon/gun/gun = I
		if(!length(gun.chamber_items))
			balloon_alert(user, "No power cell inside")
			return

		var/magazine = gun.chamber_items[gun.current_chamber_position]
		if(!iscell(magazine) || CHECK_BITFIELD(gun.get_magazine_features_flags(magazine), MAGAZINE_WORN))
			balloon_alert(user, "No power cell inside")
			return

		if(!user.transferItemToLoc(I, src))
			return

		LAZYADD(stored_cells, magazine)
		return TRUE

/obj/machinery/field_charger/wrench_act(mob/living/user, obj/item/I)
	anchored = !anchored
	balloon_alert(user, anchored ? "anchored" : "unanchored")
	playsound(loc, 'sound/items/ratchet.ogg', 25, 1)

/obj/machinery/field_charger/ui_interact(mob/user, datum/tgui/ui)
	if(!is_operational())
		return

	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "FieldCharger", name)
		ui.open()

/obj/machinery/field_charger/ui_data(mob/user)
	. = list()
	//Build a list of items with keys that correspond to the UI's expected keys
	var/list/formatted_list_of_items = list()
	for(var/list/item in stored_item_references)
		var/obj/item/cell/cell = item["cell"]	//So that the cell's charge is automatically updated for the UI

		if(!cell)	//This shit broke, get rid of the item
			eject_item(item)

		formatted_list_of_items += list(list("name" = item["name"], "charge" = cell.percent(), "icon" = item["icon"], "ref" = REF(item["ref"])))

	//Return the list of items
	.["items"] = formatted_list_of_items

/obj/machinery/field_charger/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	if(!is_operational())
		return

	switch(action)
		if("eject")
			eject_item(params["eject"], usr)
			. = TRUE

///Handles dispensing items from the charger; reference_to_item MUST be a reference, user is optional
/obj/machinery/field_charger/proc/eject_item(reference_to_item, mob/user)
	//Look for the item in the stored references list; only way to convert from a reference back to an item
	var/atom/movable/item
	for(var/list/list AS in stored_item_references)
		var/atom/item_entry = list["ref"]
		if(!item_entry)	//Maybe the item got deleted
			stored_item_references.Remove(list)
			continue

		if(REF(item_entry) == reference_to_item)
			item = item_entry

	if(!item)	//If perhaps the item was deleted or something
		if(user)
			to_chat(user, span_warning("ERROR: Vended item not found!"))
		return

	if(iscell(item))
		LAZYREMOVE(stored_cells, item)
	else
		var/cell = locate(/obj/item/cell) in item.contents
		if(cell)	//If this item managed to have it's cell disappear while inside... /shrug, just eject it anyways
			LAZYREMOVE(stored_cells, cell)

	item.forceMove(get_turf(src))

///Rebuilds the list of references to items inside this charger
/obj/machinery/field_charger/proc/build_ui_list()
	LAZYNULL(stored_item_references)
	//Not using AS in because only items should be added to this list, not effects or other things
	for(var/obj/item/item in contents)
		LAZYADD(stored_item_references, list(list("name" = item.name, "cell" = iscell(item) ? item : locate(/obj/item/cell) in item.contents, "icon" = icon2base64(icon(item.icon, item.icon_state, SOUTH)), "ref" = item)))

/obj/machinery/field_charger/Entered(atom/movable/arrived, atom/old_loc)
	. = ..()
	build_ui_list()
	if(LAZYLEN(stored_cells))
		start_processing()

/obj/machinery/field_charger/Exited(atom/movable/gone, direction)
	. = ..()
	build_ui_list()
	if(!LAZYLEN(stored_cells))
		stop_processing()

/obj/machinery/field_charger/process()
	if(!is_operational())
		return

	if(!machine_max_charge)
		machine_max_charge = 1
		stack_trace("For some reason, someone or something set the max charge to 0. Setting it to 1.")

	if(!LAZYLEN(stored_cells))
		stop_processing()
		return

	for(var/obj/item/cell/cell in stored_cells)
		if(cell.is_fully_charged())
			continue

		var/transfer_amount = min(active_power_usage * GLOB.CELLRATE, machine_current_charge)
		transfer_amount = cell.give(transfer_amount)
		if(transfer_amount)
			machine_current_charge -= transfer_amount
			if(!machine_current_charge)
				balloon_alert_to_viewers("Out of power!")
				playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE, 7)
				machine_stat |= NOPOWER
				break

	update_icon()
