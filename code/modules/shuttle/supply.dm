GLOBAL_LIST_INIT(blacklisted_cargo_types, typecacheof(list(
		/mob/living,
		/obj/item/disk/nuclear,
		/obj/item/radio/beacon
	)))

GLOBAL_LIST_EMPTY(exports_types)

/datum/supply_order
	var/id
	var/orderer
	var/orderer_rank
	var/orderer_ckey
	var/reason
	var/authorised_by
	var/list/datum/supply_packs/pack

/obj/item/paper/manifest
	name = "Supply Manifest"

/proc/setupExports()
	for(var/typepath in subtypesof(/datum/supply_export))
		var/datum/supply_export/E = new typepath()
		GLOB.exports_types += E

/obj/docking_port/stationary/supply
	id = "supply_away"

	width = 5
	dwidth = 2
	dheight = 2
	height = 5

/obj/docking_port/stationary/supply/reqs
	id = "supply_home"
	roundstart_template = /datum/map_template/shuttle/supply

/obj/docking_port/mobile/supply
	name = "supply shuttle"
	id = "supply"
	callTime = 15 SECONDS

	dir = WEST
	port_direction = EAST
	width = 5
	dwidth = 2
	dheight = 2
	height = 5
	movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)
	use_ripples = FALSE
	var/list/gears = list()
	var/list/obj/machinery/door/poddoor/railing/railings = list()


/obj/docking_port/mobile/supply/Destroy(force)
	for(var/i in railings)
		var/obj/machinery/door/poddoor/railing/railing = i
		railing.linked_pad = null
	railings.Cut()
	return ..()


	//Export categories for this run, this is set by console sending the shuttle.
//	var/export_categories = EXPORT_CARGO

/obj/docking_port/mobile/supply/afterShuttleMove()
	. = ..()
	if(getDockedId() == "supply_home" || getDockedId() == "supply_away")
		for(var/i in gears)
			var/obj/machinery/gear/G = i
			G.stop_moving()

	if(getDockedId() == "supply_home")
		for(var/j in railings)
			var/obj/machinery/door/poddoor/railing/R = j
			R.open()

/obj/docking_port/mobile/supply/on_ignition()
	if(getDockedId() == "supply_home")
		for(var/j in railings)
			var/obj/machinery/door/poddoor/railing/R = j
			R.close()
		for(var/i in gears)
			var/obj/machinery/gear/G = i
			G.start_moving(NORTH)
	else
		for(var/i in gears)
			var/obj/machinery/gear/G = i
			G.start_moving(SOUTH)

/obj/docking_port/mobile/supply/register()
	. = ..()
	SSshuttle.supply = src
	// bit clunky but shuttles need to init after atoms
	for(var/obj/machinery/gear/G in GLOB.machines)
		if(G.id == "supply_elevator_gear")
			gears += G
	for(var/obj/machinery/door/poddoor/railing/R in GLOB.machines)
		if(R.id == "supply_elevator_railing")
			railings += R
			R.linked_pad = src
			R.open()

/obj/docking_port/mobile/supply/canMove()
	if(is_station_level(z))
		return check_blacklist(shuttle_areas)
	return ..()

/obj/docking_port/mobile/supply/proc/check_blacklist(areaInstances)
	if(!areaInstances)
		areaInstances = shuttle_areas
	for(var/place in areaInstances)
		var/area/shuttle/shuttle_area = place
		for(var/trf in shuttle_area)
			var/turf/T = trf
			for(var/a in T.GetAllContents())
				if(isxeno(a))
					var/mob/living/L = a
					if(L.stat == DEAD)
						continue
				if(is_type_in_typecache(a, GLOB.blacklisted_cargo_types))
					return FALSE
	return TRUE

/obj/docking_port/mobile/supply/request(obj/docking_port/stationary/S)
	if(mode != SHUTTLE_IDLE)
		return 2
	return ..()

/obj/docking_port/mobile/supply/initiate_docking()
	if(getDockedId() == "supply_away") // Buy when we leave home.
		buy()
	. = ..() // Fly/enter transit.
	if(. != DOCKING_SUCCESS)
		return
	if(getDockedId() == "supply_away") // Sell when we get home
		sell()

/obj/docking_port/mobile/supply/proc/buy()
	if(!length(SSpoints.shoppinglist))
		return

	var/list/empty_turfs = list()
	for(var/place in shuttle_areas)
		var/area/shuttle/shuttle_area = place
		for(var/turf/open/floor/T in shuttle_area)
			if(is_blocked_turf(T))
				continue
			empty_turfs += T

	for(var/i in SSpoints.shoppinglist)
		if(!empty_turfs.len)
			break
		var/datum/supply_order/SO = SSpoints.shoppinglist[i]

		var/datum/supply_packs/firstpack = SO.pack[1]

		var/obj/structure/crate_type = firstpack.containertype || firstpack.contains[1]

		var/obj/structure/A = new crate_type(pick_n_take(empty_turfs))
		if(firstpack.containertype)
			A.name = "Order #[SO.id] for [SO.orderer]"

		//supply manifest generation begin

		var/obj/item/paper/manifest/slip = new /obj/item/paper/manifest(A)
		slip.info = "<h3>Automatic Storage Retrieval Manifest</h3><hr><br>"
		slip.info +="Order #[SO.id]<br>"
		slip.info +="[length(SO.pack)] PACKAGES IN THIS SHIPMENT<br>"
		slip.info +="CONTENTS:<br><ul>"
		slip.update_icon()

		var/list/contains = list()
		//spawn the stuff, finish generating the manifest while you're at it
		for(var/P in SO.pack)
			var/datum/supply_packs/SP = P
			// yes i know
			if(SP.access)
				A.req_access = list()
				A.req_access += text2num(SP.access)

			if(SP.randomised_num_contained)
				if(length(SP.contains))
					for(var/j in 1 to SP.randomised_num_contained)
						contains += pick(SP.contains)
			else
				contains += SP.contains

		for(var/typepath in contains)
			if(!typepath)
				continue
			if(!firstpack.containertype)
				break
			var/atom/B2 = new typepath(A)
			slip.info += "<li>[B2.name]</li>" //add the item to the manifest

		//manifest finalisation
		slip.info += "</ul><br>"
		slip.info += "CHECK CONTENTS AND STAMP BELOW THE LINE TO CONFIRM RECEIPT OF GOODS<hr>"

		SSpoints.shoppinglist -= "[SO.id]"
		SSpoints.shopping_history += SO

/obj/docking_port/mobile/supply/proc/sell()
	if(!GLOB.exports_types.len) // No exports list? Generate it!
		setupExports()

	// TODO: fix this
	for(var/place in shuttle_areas)
		var/area/shuttle/shuttle_area = place
		for(var/atom/movable/AM in shuttle_area)
			if(AM.anchored)
				continue
			//Sell Xeno Corpses
			if (isxeno(AM))
				var/cost = 0
				for(var/datum/supply_export in GLOB.exports_types)
					var/datum/supply_export/E = supply_export
					if(AM.type == E.export_obj)
						cost = E.cost
				SSpoints.supply_points += cost
				SSpoints.export_history += "Xenomorphs ([cost] points)"
			// Sell ore boxes
			if(istype(AM, /obj/structure/ore_box/platinum))
				SSpoints.export_history += "Platinum ([POINTS_PER_PLATINUM] points)"
				SSpoints.supply_points += POINTS_PER_PLATINUM

			if(istype(AM, /obj/structure/ore_box/phoron))
				SSpoints.export_history += "Phoron ([POINTS_PER_PHORON] points)"
				SSpoints.supply_points += POINTS_PER_PHORON

			qdel(AM)

/obj/item/supplytablet
	name = "ASRS tablet"
	desc = "A tablet for an Automated Storage and Retrieval System"
	icon = 'icons/obj/items/req_tablet.dmi'
	icon_state = "req_tablet_off"
	req_access = list(ACCESS_MARINE_CARGO)
	flags_equip_slot = ITEM_SLOT_POCKET
	w_class = WEIGHT_CLASS_NORMAL
	var/datum/supply_ui/SU

/obj/item/supplytablet/interact(mob/user)
	. = ..()
	if(.)
		return

	if(!SU)
		SU = new(src)
	return SU.interact(user)

/obj/machinery/computer/supplycomp
	name = "ASRS console"
	desc = "A console for an Automated Storage and Retrieval System"
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "supply"
	req_access = list(ACCESS_MARINE_CARGO)
	circuit = null
	var/datum/supply_ui/SU

/obj/machinery/computer/supplycomp/interact(mob/user)
	. = ..()
	if(.)
		return

	if(!SU)
		SU = new(src)
	return SU.interact(user)

/datum/supply_ui
	interaction_flags = INTERACT_MACHINE_TGUI
	var/atom/source_object
	var/ui_x = 900
	var/ui_y = 700
	var/tgui_name = "Cargo"

/datum/supply_ui/New(atom/source_object)
	. = ..()
	src.source_object = source_object

/datum/supply_ui/ui_host()
	return source_object

/datum/supply_ui/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE
	if(!user.CanReach(source_object))
		return FALSE
	return TRUE

/datum/supply_ui/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
										datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)

	if(!ui)
		ui = new(user, src, ui_key, tgui_name, source_object.name, ui_x, ui_y, master_ui, state)
		ui.open()

/datum/supply_ui/ui_static_data(mob/user)
	. = list()
	.["categories"] = GLOB.all_supply_groups
	.["supplypacks"] = SSpoints.supply_packs_ui
	.["supplypackscontents"] = SSpoints.supply_packs_contents
	.["elevator_size"] = SSshuttle.supply?.return_number_of_turfs()

/datum/supply_ui/ui_data(mob/user)
	. = list()
	.["currentpoints"] = round(SSpoints.supply_points)
	.["requests"] = list()
	for(var/i in SSpoints.requestlist)
		var/datum/supply_order/SO = SSpoints.requestlist[i]
		var/list/packs = list()
		var/cost = 0
		for(var/P in SO.pack)
			var/datum/supply_packs/SP = P
			packs += SP.type
			cost += SP.cost
		.["requests"] += list(list("id" = SO.id, "orderer" = SO.orderer, "orderer_rank" = SO.orderer_rank, "reason" = SO.reason, "cost" = cost, "packs" = packs, "authed_by" = SO.authorised_by))
	.["deniedrequests"] = list()
	for(var/i in length(SSpoints.deniedrequests) to 1 step -1)
		var/datum/supply_order/SO = SSpoints.deniedrequests[SSpoints.deniedrequests[i]]
		var/list/packs = list()
		var/cost = 0
		for(var/P in SO.pack)
			var/datum/supply_packs/SP = P
			packs += SP.type
			cost += SP.cost
		.["deniedrequests"] += list(list("id" = SO.id, "orderer" = SO.orderer, "orderer_rank" = SO.orderer_rank, "reason" = SO.reason, "cost" = cost, "packs" = packs, "authed_by" = SO.authorised_by))
	.["approvedrequests"] = list()
	for(var/i in length(SSpoints.approvedrequests) to 1 step -1)
		var/datum/supply_order/SO = SSpoints.approvedrequests[SSpoints.approvedrequests[i]]
		var/list/packs = list()
		var/cost = 0
		for(var/P in SO.pack)
			var/datum/supply_packs/SP = P
			packs += SP.type
			cost += SP.cost
		.["approvedrequests"] += list(list("id" = SO.id, "orderer" = SO.orderer, "orderer_rank" = SO.orderer_rank, "reason" = SO.reason, "cost" = cost, "packs" = packs, "authed_by" = SO.authorised_by))
	.["export_history"] = SSpoints.export_history
	.["awaiting_delivery"] = list()
	.["awaiting_delivery_orders"] = 0
	for(var/i in SSpoints.shoppinglist)
		var/datum/supply_order/SO = SSpoints.shoppinglist[i]
		.["awaiting_delivery_orders"]++
		var/list/packs = list()
		for(var/P in SO.pack)
			var/datum/supply_packs/SP = P
			packs += SP.type
		.["awaiting_delivery"] += list(list("id" = SO.id, "orderer" = SO.orderer, "orderer_rank" = SO.orderer_rank, "reason" = SO.reason, "packs" = packs, "authed_by" = SO.authorised_by))
	.["shopping_history"] = list()
	for(var/i in SSpoints.shopping_history)
		var/datum/supply_order/SO = i
		var/list/packs = list()
		var/cost = 0
		for(var/P in SO.pack)
			var/datum/supply_packs/SP = P
			packs += SP.type
			cost += SP.cost
		.["shopping_history"] += list(list("id" = SO.id, "orderer" = SO.orderer, "orderer_rank" = SO.orderer_rank, "reason" = SO.reason, "cost" = cost, "packs" = packs, "authed_by" = SO.authorised_by))
	.["shopping_list_cost"] = 0
	.["shopping_list_items"] = 0
	.["shopping_list"] = list()
	for(var/i in SSpoints.shopping_cart)
		var/datum/supply_packs/SP = SSpoints.supply_packs[i]
		.["shopping_list_items"] += SSpoints.shopping_cart[i]
		.["shopping_list_cost"] += SP.cost * SSpoints.shopping_cart[SP.type]
		.["shopping_list"][SP.type] = list("count" = SSpoints.shopping_cart[SP.type])
	if(SSshuttle.supply)
		if(SSshuttle.supply.mode == SHUTTLE_CALL)
			if(is_mainship_level(SSshuttle.supply.destination.z))
				.["elevator"] = "Raising"
				.["elevator_dir"] = "up"
			else
				.["elevator"] = "Lowering"
				.["elevator_dir"] = "down"
		else if(SSshuttle.supply.mode == SHUTTLE_IDLE)
			if(is_mainship_level(SSshuttle.supply.z))
				.["elevator"] = "Raised"
				.["elevator_dir"] = "down"
			else
				.["elevator"] = "Lowered"
				.["elevator_dir"] = "up"
		else
			if(is_mainship_level(SSshuttle.supply.z))
				.["elevator"] = "Lowering"
				.["elevator_dir"] = "down"
			else
				.["elevator"] = "Raising"
				.["elevator_dir"] = "up"
	else
		.["elevator"] = "MISSING!"

/datum/supply_ui/proc/get_shopping_cart(mob/user)
	return SSpoints.shopping_cart

/datum/supply_ui/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	switch(action)
		if("cart")
			var/datum/supply_packs/P = SSpoints.supply_packs[text2path(params["id"])]
			if(!P)
				return
			var/shopping_cart = get_shopping_cart(ui.user)
			switch(params["mode"])
				if("removeall")
					shopping_cart -= P.type
				if("removeone")
					if(shopping_cart[P.type] > 1)
						shopping_cart[P.type]--
					else
						shopping_cart -= P.type
				if("addone")
					if(shopping_cart[P.type])
						shopping_cart[P.type]++
					else
						shopping_cart[P.type] = 1
				if("addall")
					var/cart_cost = 0
					for(var/i in shopping_cart)
						var/datum/supply_packs/SP = SSpoints.supply_packs[i]
						cart_cost += SP.cost * shopping_cart[SP.type]
					var/excess_points = SSpoints.supply_points - cart_cost
					var/number_to_buy = round(excess_points / P.cost)
					if(shopping_cart[P.type])
						shopping_cart[P.type] += number_to_buy
					else
						shopping_cart[P.type] = number_to_buy
			. = TRUE
		if("send")
			if(SSshuttle.supply.mode == SHUTTLE_IDLE && is_mainship_level(SSshuttle.supply.z))
				if (!SSshuttle.supply.check_blacklist())
					to_chat(usr, "For safety reasons, the Automated Storage and Retrieval System cannot store live, non-xeno organisms, classified nuclear weaponry or homing beacons.")
					playsound(SSshuttle.supply.return_center_turf(), 'sound/machines/buzz-two.ogg', 50, 0)
				else
					playsound(SSshuttle.supply.return_center_turf(), 'sound/machines/elevator_move.ogg', 50, 0)
					SSshuttle.moveShuttle("supply", "supply_away", TRUE)
			else
				var/obj/docking_port/D = SSshuttle.getDock("supply_home")
				playsound(D.return_center_turf(), 'sound/machines/elevator_move.ogg', 50, 0)
				SSshuttle.moveShuttle("supply", "supply_home", TRUE)
			. = TRUE
		if("approve")
			var/datum/supply_order/O = SSpoints.requestlist["[params["id"]]"]
			if(!O)
				O = SSpoints.deniedrequests["[params["id"]]"]
			if(!O)
				return
			SSpoints.approve_request(O, ui.user)
			. = TRUE
		if("deny")
			var/datum/supply_order/O = SSpoints.requestlist["[params["id"]]"]
			if(!O)
				return
			SSpoints.deny_request(O)
			. = TRUE
		if("approveall")
			for(var/i in SSpoints.requestlist)
				var/datum/supply_order/O = SSpoints.requestlist[i]
				SSpoints.approve_request(O, ui.user)
			. = TRUE
		if("denyall")
			for(var/i in SSpoints.requestlist)
				var/datum/supply_order/O = SSpoints.requestlist[i]
				SSpoints.deny_request(O)
			. = TRUE
		if("buycart")
			SSpoints.buy_cart(ui.user)
			. = TRUE
		if("clearcart")
			var/list/shopping_cart = get_shopping_cart(ui.user)
			shopping_cart.Cut()
			. = TRUE

/datum/supply_ui/requests
	tgui_name = "CargoRequest"

// yes these are copy pasted from above because SPEEEEEEEEEEEEED
/datum/supply_ui/requests/ui_static_data(mob/user)
	. = list()
	.["categories"] = GLOB.all_supply_groups
	.["supplypacks"] = SSpoints.supply_packs_ui
	.["supplypackscontents"] = SSpoints.supply_packs_contents

/datum/supply_ui/requests/ui_data(mob/user)
	. = list()
	.["currentpoints"] = round(SSpoints.supply_points)
	.["requests"] = list()
	for(var/i in SSpoints.requestlist)
		var/datum/supply_order/SO = SSpoints.requestlist[i]
		var/list/packs = list()
		var/cost = 0
		for(var/P in SO.pack)
			var/datum/supply_packs/SP = P
			packs += SP.type
			cost += SP.cost
		.["requests"] += list(list("id" = SO.id, "orderer" = SO.orderer, "orderer_rank" = SO.orderer_rank, "reason" = SO.reason, "cost" = cost, "packs" = packs, "authed_by" = SO.authorised_by))
	.["deniedrequests"] = list()
	for(var/i in length(SSpoints.deniedrequests) to 1 step -1)
		var/datum/supply_order/SO = SSpoints.deniedrequests[SSpoints.deniedrequests[i]]
		var/list/packs = list()
		var/cost = 0
		for(var/P in SO.pack)
			var/datum/supply_packs/SP = P
			packs += SP.type
			cost += SP.cost
		.["deniedrequests"] += list(list("id" = SO.id, "orderer" = SO.orderer, "orderer_rank" = SO.orderer_rank, "reason" = SO.reason, "cost" = cost, "packs" = packs, "authed_by" = SO.authorised_by))
	.["approvedrequests"] = list()
	for(var/i in length(SSpoints.approvedrequests) to 1 step -1)
		var/datum/supply_order/SO = SSpoints.approvedrequests[SSpoints.approvedrequests[i]]
		var/list/packs = list()
		var/cost = 0
		for(var/P in SO.pack)
			var/datum/supply_packs/SP = P
			packs += SP.type
			cost += SP.cost
		.["approvedrequests"] += list(list("id" = SO.id, "orderer" = SO.orderer, "orderer_rank" = SO.orderer_rank, "reason" = SO.reason, "cost" = cost, "packs" = packs, "authed_by" = SO.authorised_by))
	if(!SSpoints.request_shopping_cart[user.ckey])
		SSpoints.request_shopping_cart[user.ckey] = list()
	.["shopping_list_cost"] = 0
	.["shopping_list_items"] = 0
	.["shopping_list"] = list()
	for(var/i in SSpoints.request_shopping_cart[user.ckey])
		var/datum/supply_packs/SP = SSpoints.supply_packs[i]
		.["shopping_list_items"] += SSpoints.request_shopping_cart[user.ckey][i]
		.["shopping_list_cost"] += SP.cost * SSpoints.request_shopping_cart[user.ckey][SP.type]
		.["shopping_list"][SP.type] = list("count" = SSpoints.request_shopping_cart[user.ckey][SP.type])

/datum/supply_ui/requests/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return TRUE
	switch(action)
		if("submitrequest")
			SSpoints.submit_request(ui.user, params["reason"])
			. = TRUE

/datum/supply_ui/requests/get_shopping_cart(mob/user)
	return SSpoints.request_shopping_cart[user.ckey]

/obj/machinery/computer/ordercomp
	name = "Supply ordering console"
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "request"
	circuit = null
	var/datum/supply_ui/requests/SU

/obj/machinery/computer/ordercomp/interact(mob/user)
	. = ..()
	if(.)
		return

	if(!SU)
		SU = new(src)
	return SU.interact(user)
