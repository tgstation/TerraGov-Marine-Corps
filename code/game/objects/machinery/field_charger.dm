/*!
 * Pretty much a better cell recharger
 * Mobile, charges multiple cells, can store cells, can charge devices with cells in them, doesn't violate the first law of thermodynamics
 * Does not recharge itself wirelessly via APCs; must be wrenched down over a cable node or a terminal
 * Is a child of /power/ because they have the code needed for connecting to cables and terminals already
 */
/obj/machinery/power/field_charger
	name = "mobile field charger"
	desc = "A study automated charger and storage rack for power cells and electronic devices. Has an internal battery that charges off the power grid when wrenched down."
	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "lascharger"
	interaction_flags = INTERACT_MACHINE_TGUI
	resistance_flags = XENO_DAMAGEABLE|UNACIDABLE	//Don't want benos to cheese it by sneaking in and melting it
	density = TRUE
	anchored = FALSE
	wrenchable = TRUE
	drag_delay = FALSE
	max_integrity = 1000
	soft_armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 100, FIRE = 50, ACID = 75)	//Harder to break with spit and gas
	machine_max_charge = 100000	//Large power bank for when on the move
	active_power_usage = 50000	//Looks like a lot but it's actually still pretty slow to re/charge
	///List of references to power cells that are within this charger's contents list
	var/list/obj/item/cell/stored_cells
	///Like the contents list but stored in this manner so it doesn't have to be rebuilt unless an item is added/removed
	var/list/stored_item_references
	var/obj/machinery/power/apc/registered_apc

/obj/machinery/power/field_charger/Initialize(mapload)
	. = ..()
	machine_current_charge = machine_max_charge

/obj/machinery/power/field_charger/examine(mob/user)
	. = ..()
	. += "Charge: [span_bold("[PERCENT(machine_current_charge/machine_max_charge)]%")]"
	. += "Integrity: [span_bold("[obj_integrity]/[max_integrity]")]"	//Not a percentage so players can see the exact values of both current and max integrity
	. += "Has [span_bold("[LAZYLEN(stored_cells)]")] objects stored."

/obj/machinery/power/field_charger/update_icon_state()
	icon_state = initial(icon_state)
	//Prevent divide by zero
	if(!machine_current_charge)
		icon_state += "_0"
		return

	switch(machine_current_charge / max(1, machine_max_charge))	//Max is in case it is 0
		if(0 to 0.25)
			icon_state += "_25"
		if(0.25 to 0.5)
			icon_state += "_50"
		if(0.5 to 0.75)
			icon_state += "_75"

//Overriding this proc to change how the machine recharges itself because it does not draw from APCs; also why use_power() is not used
/obj/machinery/power/field_charger/auto_use_power()
	if(!powernet || machine_current_charge >= machine_max_charge)
		return

	//Find how much power the closest functioning APC connected to this grid has
	var/apc_available_power = 0
	//Check if there is an APC registered to this machine, if the breaker is on, if it's still on the same powernet, and if it has a cell with energy in it
	if(!registered_apc || !registered_apc.operating || registered_apc?.powernet != powernet || registered_apc?.cell?.charge <= 0)
		registered_apc = null
		var/obj/machinery/power/terminal/nearest_terminal
		var/nearest_terminal_distance = 0
		for(var/obj/machinery/power/terminal/terminal in powernet.nodes)
			if(!terminal.master || !isAPC(terminal.master))	//Only care about APCs
				continue

			var/obj/machinery/power/apc/apc = terminal.master
			if(!apc.operating || apc?.cell?.charge <= 0)	//Don't care about an APC without a charged cell
				continue

			var/terminal_distance = get_dist_euclidian(src, terminal)
			if(!nearest_terminal)
				nearest_terminal = terminal
				nearest_terminal_distance = terminal_distance
				continue

			if(terminal_distance > nearest_terminal_distance)
				continue

			nearest_terminal = terminal
			nearest_terminal_distance = terminal_distance

		//Assign our new lucky APC suck energy from
		if(nearest_terminal)
			registered_apc = nearest_terminal.master
			apc_available_power = registered_apc.cell.charge

	else	//There is a powered APC already registered, just use that
		apc_available_power = registered_apc.cell.charge

	//Find how much power is in the grid (like from generators)
	var/powernet_available_power = avail() - powernet.load

	//If there is no power in the grid and no APC to draw from, don't bother
	if(powernet_available_power <= 0 && !registered_apc)
		return

	var/draw_from_powernet = powernet_available_power >= apc_available_power ? TRUE : FALSE
	//Determine how much power the machine can draw from the grid or the APC
	var/transfer_amount = min(draw_from_powernet ? powernet_available_power : apc_available_power,
							machine_max_charge - machine_current_charge,
							active_power_usage * GLOB.CELLRATE)

	if(draw_from_powernet)
		powernet.load += transfer_amount
	else
		registered_apc.cell.use(transfer_amount)

	machine_current_charge += transfer_amount
	power_change()

//Override this proc to prevent it from checking the area's power status; it's always on anyways
/obj/machinery/power/field_charger/powered(chan = -1)
	return TRUE

/obj/machinery/power/field_charger/attackby(obj/item/I, mob/user, params)
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

		add_cell_to_storage(I)
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

		//Cell is added to stored_cells on Entered() because the call for building the contents is there
		if(!user.transferItemToLoc(I, src))
			return

		add_cell_to_storage(magazine)
		return TRUE

///Use whenever adding a cell to the charger to ensure things are properly updated
/obj/machinery/power/field_charger/proc/add_cell_to_storage(cell)
	LAZYADD(stored_cells, cell)
	build_ui_list()
	start_processing()

/obj/machinery/power/field_charger/wrench_act(mob/living/user, obj/item/I)
	setAnchored(!anchored)
	balloon_alert(user, anchored ? "anchored" : "unanchored")
	playsound(get_turf(src), 'sound/items/ratchet.ogg', 25, 1)

/obj/machinery/power/field_charger/setAnchored(anchorvalue)
	. = ..()
	use_power = anchorvalue	//auto_use_power() doesn't need to be called if the machine isn't anchored
	if(anchorvalue)
		connect_to_network()
	else
		disconnect_from_network()

/obj/machinery/power/field_charger/welder_act(mob/living/user, obj/item/I)
	welder_repair_act(user, I, max_integrity/10)

/obj/machinery/power/field_charger/ui_interact(mob/user, datum/tgui/ui)
	if(!is_operational())
		return

	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "FieldCharger", name)
		ui.open()

/obj/machinery/power/field_charger/ui_data(mob/user)
	. = list()
	//Need to copy the list because it might get updated while iterating
	//Must loop through stored_item_references to copy each associative list
	//Otherwise BYOND will just create references to the sublists instead of making new ones
	var/list/formatted_list = list()
	LAZYINITLIST(stored_item_references)
	for(var/list/sublist in stored_item_references)
		//Transform the "charge" entries from cell objects to their battery levels
		var/obj/item/cell/cell = sublist["charge"]
		if(!cell)	//If a cell doesn't exist, kick this item out
			eject_item(sublist["ref"])
			continue

		var/list/copied_sublist = sublist.Copy()
		copied_sublist["charge"] = cell.percent()
		formatted_list += list(copied_sublist)

	//Return the list of items
	.["items"] = formatted_list
	//Send the UI the charger's battery level
	.["charge"] = PERCENT(machine_current_charge / machine_max_charge)
	.["connected"] = powernet ? TRUE : FALSE

/obj/machinery/power/field_charger/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	if(!is_operational())
		return

	//Best to use switch(action) but we're only looking for one type of action: the eject button
	if(action == "eject")
		eject_item(params["eject"], usr)
		. = TRUE

///Handles dispensing items from the charger; reference_to_item MUST be a reference, user is optional
/obj/machinery/power/field_charger/proc/eject_item(reference_to_item, mob/user)
	//Look for the item in the stored references list; only way to convert from a reference back to an item
	var/atom/movable/item
	for(var/list/list AS in stored_item_references)
		var/atom/item_entry = list["ref"]
		if(!item_entry)	//Maybe the item got deleted? If so, dispose of that entry
			LAZYREMOVE(stored_item_references, list)
			continue

		if(item_entry == reference_to_item)
			item = locate(item_entry) in contents

	if(!item)	//If perhaps the item was deleted or something
		if(user)
			to_chat(user, span_warning("ERROR: Vended item not found!"))
		return

	var/cell = iscell(item) ? item : locate(/obj/item/cell) in item.contents
	if(cell)	//If this item managed to have it's cell disappear while inside... /shrug, just eject it anyways
		LAZYREMOVE(stored_cells, cell)

	if(user)
		user.put_in_hands(item)
	else
		item.forceMove(get_turf(src))

///Rebuilds the list of references to items inside this charger
/obj/machinery/power/field_charger/proc/build_ui_list()
	LAZYNULL(stored_item_references)
	//Not using AS in because only items should be added to this list, not effects or other things
	for(var/obj/item/item in contents)
		//To make a list in a list, need to do master_list += list(list(value1, value2)) instead of master_list += list(value1, value2)
		LAZYADD(stored_item_references, list(list("name" = item.name, "charge" = iscell(item) ? item : locate(/obj/item/cell) in item.contents, "ref" = REF(item))))

//Rebuild the UI list and stop processing if there are no items in the charger every time an item is removed from this machine
/obj/machinery/power/field_charger/Exited(atom/movable/gone, direction)
	. = ..()
	build_ui_list()
	if(!LAZYLEN(stored_cells))
		stop_processing()

/obj/machinery/power/field_charger/process()
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

	power_change()
