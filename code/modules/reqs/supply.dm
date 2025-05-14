GLOBAL_LIST_INIT(blacklisted_cargo_types, typecacheof(list(
		/mob/living,
		/obj/item/disk/nuclear,
		/obj/item/radio/beacon,
		/obj/vehicle,
	)))

/datum/supply_order
	var/id
	var/orderer
	var/orderer_rank
	var/orderer_ckey
	var/reason
	var/authorised_by
	var/list/datum/supply_packs/pack
	///What faction ordered this
	var/faction = FACTION_TERRAGOV

/obj/item/paper/manifest
	name = "Supply Manifest"

/obj/docking_port/stationary/supply
	id = "supply_home"
	roundstart_template = /datum/map_template/shuttle/supply
	width = 5
	dwidth = 2
	dheight = 2
	height = 5

/obj/docking_port/stationary/supplyhq
	id = "supply_hq"
	roundstart_template = /datum/map_template/shuttle/supplyhq
	width = 5
	dwidth = 2
	dheight = 2
	height = 5

/obj/docking_port/stationary/supplysom
	id = "supply_som"
	roundstart_template = /datum/map_template/shuttle/supplysom
	width = 3
	dwidth = 1
	dheight = 0
	height = 1

/obj/docking_port/stationary/supplyclf
	id = "supply_clf"
	roundstart_template = /datum/map_template/shuttle/supplyclf
	width = 3
	dwidth = 1
	dheight = 0
	height = 1

/obj/docking_port/mobile/supply
	name = "supply shuttle"
	id = SHUTTLE_SUPPLY
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
	///The faction of this docking port (aka, on which ship it is located)
	var/faction = FACTION_TERRAGOV
	/// Id of the home docking port
	var/home_id = "supply_home"
	///prefix for railings and gear todo should probbaly be defines instead?
	var/railing_gear_name = "supply"

/obj/docking_port/mobile/supply/Destroy(force)
	for(var/i in railings)
		var/obj/machinery/door/poddoor/railing/railing = i
		railing.linked_pad = null
	railings.Cut()
	return ..()


/obj/docking_port/mobile/supply/afterShuttleMove()
	. = ..()
	if(getDockedId() == home_id)
		for(var/j in railings)
			var/obj/machinery/door/poddoor/railing/R = j
			R.open()

/obj/docking_port/mobile/supply/on_ignition()
	if(getDockedId() == home_id)
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
	for(var/obj/machinery/gear/G in GLOB.machines)
		if(G.id == (railing_gear_name+"_elevator_gear"))
			gears += G
			RegisterSignal(G, COMSIG_QDELETING, PROC_REF(clean_gear))
	for(var/obj/machinery/door/poddoor/railing/R in GLOB.machines)
		if(R.id == (railing_gear_name+"_elevator_railing"))
			railings += R
			RegisterSignal(R, COMSIG_QDELETING, PROC_REF(clean_railing))
			R.linked_pad = src
			R.open()

///Signal handler when a gear is destroyed
/obj/docking_port/mobile/supply/proc/clean_gear(datum/source)
	SIGNAL_HANDLER
	gears -= source

///Signal handler when a railing is destroyed
/obj/docking_port/mobile/supply/proc/clean_railing(datum/source)
	SIGNAL_HANDLER
	railings -= source

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
				if(ishuman(a))
					var/mob/living/carbon/human/human_to_sell = a
					if(human_to_sell.stat == DEAD && can_sell_human_body(human_to_sell, faction))
						continue
				if(is_type_in_typecache(a, GLOB.blacklisted_cargo_types))
					return FALSE
	return TRUE

/obj/docking_port/mobile/supply/request(obj/docking_port/stationary/S)
	if(mode != SHUTTLE_IDLE)
		return 2
	return ..()

/obj/docking_port/mobile/supply/proc/buy(mob/user, datum/supply_ui/supply_ui)
	if(!length(SSpoints.shoppinglist[faction]))
		return
	log_game("Supply pack orders have been purchased by [key_name(user)]")

	var/list/empty_turfs = list()
	for(var/place in shuttle_areas)
		var/area/shuttle/shuttle_area = place
		for(var/turf/open/floor/T in shuttle_area)
			if(is_blocked_turf(T))
				continue
			empty_turfs += T

	for(var/i in SSpoints.shoppinglist[faction])
		if(!length(empty_turfs))
			break
		var/datum/supply_order/SO = LAZYACCESSASSOC(SSpoints.shoppinglist, faction, i)

		var/datum/supply_packs/firstpack = SO.pack[1]

		var/obj/structure/crate_type = firstpack.containertype || firstpack.contains[1]

		var/obj/structure/A = new crate_type(pick_n_take(empty_turfs))
		if(firstpack.containertype)
			A.name = "Order #[SO.id] for [SO.orderer]"


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
			new typepath(A)

		SSpoints.shoppinglist[faction] -= "[SO.id]"
		SSpoints.shopping_history += SO


/datum/export_report
	/// How many points from that export
	var/points
	/// Name of the item exported
	var/export_name
	/// What faction did the export
	var/faction

/datum/export_report/New(_points, _export_name, _faction)
	points = _points
	export_name = _export_name
	faction = _faction

/obj/docking_port/mobile/supply/proc/sell()
	for(var/place in shuttle_areas)
		var/area/shuttle/shuttle_area = place
		for(var/atom/movable/AM in shuttle_area)
			if(AM.anchored)
				continue
			var/list/datum/export_report = AM.supply_export(faction)
			if(export_report)
				SSpoints.export_history += export_report
			qdel(AM)

/obj/item/supplytablet
	name = "ASRS tablet"
	desc = "A tablet for an Automated Storage and Retrieval System"
	icon_state = "req_tablet_off"
	req_access = list(ACCESS_MARINE_CARGO)
	equip_slot_flags = ITEM_SLOT_POCKET
	w_class = WEIGHT_CLASS_NORMAL
	var/datum/supply_ui/SU
	///Id of the shuttle controlled
	var/shuttle_id = SHUTTLE_SUPPLY
	/// Id of the home docking port
	var/home_id = "supply_home"
	/// Faction of the tablet
	var/faction = FACTION_TERRAGOV

/obj/item/supplytablet/interact(mob/user)
	. = ..()
	if(.)
		return
	if(!allowed(user))
		return
	if(!SU)
		SU = new(src)
		SU.shuttle_id = shuttle_id
		SU.home_id = home_id
		SU.faction = faction
	return SU.interact(user)

/obj/machinery/computer/supplycomp
	name = "ASRS console"
	desc = "A console for an Automated Storage and Retrieval System"
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "computer"
	screen_overlay = "supply"
	req_access = list(ACCESS_MARINE_CARGO)
	circuit = /obj/item/circuitboard/computer/supplycomp
	var/datum/supply_ui/SU
	///Id of the shuttle controlled
	var/shuttle_id = SHUTTLE_SUPPLY
	/// Id of the home docking port
	var/home_id = "supply_home"
	/// Faction of the computer
	var/faction = FACTION_TERRAGOV

/obj/machinery/computer/supplycomp/interact(mob/user)
	. = ..()
	if(.)
		return
	if(isliving(user) && !allowed(user))
		return
	if(!SU)
		SU = new(src)
		SU.shuttle_id = shuttle_id
		SU.home_id = home_id
		SU.faction = faction
	return SU.interact(user)

/datum/supply_ui
	interaction_flags = INTERACT_MACHINE_TGUI
	var/atom/source_object
	var/tgui_name = "Cargo"
	///Id of the shuttle controlled
	var/shuttle_id = ""
	///Reference to the supply shuttle
	var/obj/docking_port/mobile/supply/supply_shuttle
	///Faction of the supply console linked
	var/faction = FACTION_TERRAGOV
	///Id of the home port
	var/home_id = ""

/datum/supply_ui/New(atom/source_object)
	. = ..()
	src.source_object = source_object
	RegisterSignal(source_object, COMSIG_QDELETING, PROC_REF(clean_ui))

///Signal handler to delete the ui when the source object is deleting
/datum/supply_ui/proc/clean_ui()
	SIGNAL_HANDLER
	qdel(src)

/datum/supply_ui/Destroy(force, ...)
	source_object = null
	return ..()

/datum/supply_ui/ui_host()
	return source_object

/datum/supply_ui/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE
	if(!user.CanReach(source_object))
		return FALSE
	return TRUE

/datum/supply_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		if(shuttle_id)
			supply_shuttle = SSshuttle.getShuttle(shuttle_id)
			supply_shuttle.home_id = home_id
			supply_shuttle.faction = faction
		ui = new(user, src, tgui_name, source_object.name)
		ui.open()

/datum/supply_ui/ui_static_data(mob/user)
	. = list()
	.["categories"] = GLOB.all_supply_groups
	.["supplypacks"] = SSpoints.supply_packs_ui
	.["supplypackscontents"] = SSpoints.supply_packs_contents
	.["elevator_size"] = supply_shuttle?.return_number_of_turfs()

/datum/supply_ui/ui_data(mob/living/user)
	. = list()
	.["currentpoints"] = round(SSpoints.supply_points[user.faction])
	.["requests"] = list()
	for(var/key in SSpoints.requestlist)
		var/datum/supply_order/SO = SSpoints.requestlist[key]
		if(SO.faction != user.faction)
			continue
		var/list/packs = list()
		var/cost = 0
		for(var/P in SO.pack)
			var/datum/supply_packs/SP = P
			if(packs[SP.type])
				packs[SP.type] += 1
			else
				packs[SP.type] = 1
			cost += SP.cost
		.["requests"] += list(list("id" = SO.id, "orderer" = SO.orderer, "orderer_rank" = SO.orderer_rank, "reason" = SO.reason, "cost" = cost, "packs" = packs, "authed_by" = SO.authorised_by))
	.["deniedrequests"] = list()
	for(var/i in length(SSpoints.deniedrequests) to 1 step -1)
		var/datum/supply_order/SO = SSpoints.deniedrequests[SSpoints.deniedrequests[i]]
		if(SO.faction != user.faction)
			continue
		var/list/packs = list()
		var/cost = 0
		for(var/P in SO.pack)
			var/datum/supply_packs/SP = P
			if(packs[SP.type])
				packs[SP.type] += 1
			else
				packs[SP.type] = 1
			cost += SP.cost
		.["deniedrequests"] += list(list("id" = SO.id, "orderer" = SO.orderer, "orderer_rank" = SO.orderer_rank, "reason" = SO.reason, "cost" = cost, "packs" = packs, "authed_by" = SO.authorised_by))
	.["approvedrequests"] = list()
	for(var/i in length(SSpoints.approvedrequests) to 1 step -1)
		var/datum/supply_order/SO = SSpoints.approvedrequests[SSpoints.approvedrequests[i]]
		if(SO.faction != user.faction)
			continue
		var/list/packs = list()
		var/cost = 0
		for(var/P in SO.pack)
			var/datum/supply_packs/SP = P
			if(packs[SP.type])
				packs[SP.type] += 1
			else
				packs[SP.type] = 1
			cost += SP.cost
		.["approvedrequests"] += list(list("id" = SO.id, "orderer" = SO.orderer, "orderer_rank" = SO.orderer_rank, "reason" = SO.reason, "cost" = cost, "packs" = packs, "authed_by" = SO.authorised_by))
	.["awaiting_delivery"] = list()
	.["awaiting_delivery_orders"] = 0
	for(var/key in SSpoints.shoppinglist[faction])
		var/datum/supply_order/SO = LAZYACCESSASSOC(SSpoints.shoppinglist, faction, key)
		.["awaiting_delivery_orders"]++
		var/list/packs = list()
		var/cost = 0
		for(var/P in SO.pack)
			var/datum/supply_packs/SP = P
			if(packs[SP.type])
				packs[SP.type] += 1
			else
				packs[SP.type] = 1
			cost += SP.cost
		.["awaiting_delivery"] += list(list("id" = SO.id, "orderer" = SO.orderer, "orderer_rank" = SO.orderer_rank, "reason" = SO.reason, "cost" = cost, "packs" = packs, "authed_by" = SO.authorised_by))
	.["export_history"] = list()
	var/id = 0
	var/lastexport = ""
	for(var/datum/export_report/report AS in SSpoints.export_history)
		if(report.faction != user.faction)
			continue
		if(report.points == 0)
			continue
		if(report.export_name == lastexport)
			.["export_history"][id]["amount"] += 1
			.["export_history"][id]["total"] += report.points
		else
			.["export_history"] += list(list("id" = id, "name" = report.export_name, "points" = report.points, "amount" = 1, total = report.points))
			id++
			lastexport = report.export_name
	.["shopping_history"] = list()
	for(var/datum/supply_order/SO AS in SSpoints.shopping_history)
		if(SO.faction != user.faction)
			continue
		var/list/packs = list()
		var/cost = 0
		for(var/P in SO.pack)
			var/datum/supply_packs/SP = P
			if(packs[SP.type])
				packs[SP.type] += 1
			else
				packs[SP.type] = 1
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
	if(supply_shuttle)
		if(supply_shuttle?.mode == SHUTTLE_CALL)
			if(is_mainship_level(supply_shuttle.destination.z) || is_antagmainship_level(supply_shuttle.destination.z))
				.["elevator"] = "Raising"
				.["elevator_dir"] = "up"
			else
				.["elevator"] = "Lowering"
				.["elevator_dir"] = "down"
		else if(supply_shuttle?.mode == SHUTTLE_IDLE)
			if(is_mainship_level(supply_shuttle.z) || is_antagmainship_level(supply_shuttle.z))
				.["elevator"] = "Raised"
				.["elevator_dir"] = "down"
			else
				.["elevator"] = "Lowered"
				.["elevator_dir"] = "up"
		else
			if(is_mainship_level(supply_shuttle.z) || is_antagmainship_level(supply_shuttle.z))
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
	. = ..()
	if(.)
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
					var/mob/living/ui_user = ui.user
					var/cart_cost = 0
					for(var/i in shopping_cart)
						var/datum/supply_packs/SP = SSpoints.supply_packs[i]
						cart_cost += SP.cost * shopping_cart[SP.type]
					var/excess_points = SSpoints.supply_points[ui_user.faction] - cart_cost
					var/number_to_buy = min(round(excess_points / P.cost), 20) //hard cap at 20
					if(shopping_cart[P.type])
						shopping_cart[P.type] += number_to_buy
					else
						shopping_cart[P.type] = number_to_buy
			. = TRUE
		if("send")
			if(supply_shuttle.mode != SHUTTLE_IDLE)
				return
			if(is_mainship_level(supply_shuttle.z) || is_antagmainship_level(supply_shuttle.z))
				if (!supply_shuttle.check_blacklist())
					to_chat(usr, "For safety reasons, the Automated Storage and Retrieval System cannot store live, friendlies, classified nuclear weaponry or homing beacons.")
					playsound(supply_shuttle.return_center_turf(), 'sound/machines/buzz-two.ogg', 50, 0)
				else
					playsound(supply_shuttle.return_center_turf(), 'sound/machines/elevator_move.ogg', 50, 0)
					SSshuttle.moveShuttleToTransit(shuttle_id, TRUE)
					addtimer(CALLBACK(supply_shuttle, TYPE_PROC_REF(/obj/docking_port/mobile/supply, sell)), 15 SECONDS)
			else
				var/obj/docking_port/D = SSshuttle.getDock(home_id)
				supply_shuttle.buy(usr, src)
				playsound(D.return_center_turf(), 'sound/machines/elevator_move.ogg', 50, 0)
				SSshuttle.moveShuttle(shuttle_id, home_id, TRUE)
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

/datum/supply_ui/requests/ui_data(mob/living/user)
	. = list()
	.["currentpoints"] = round(SSpoints.supply_points[user.faction])
	.["requests"] = list()
	for(var/i in SSpoints.requestlist)
		var/datum/supply_order/SO = SSpoints.requestlist[i]
		if(SO.faction != user.faction)
			continue
		var/list/packs = list()
		var/cost = 0
		for(var/P in SO.pack)
			var/datum/supply_packs/SP = P
			if(packs[SP.type])
				packs[SP.type] += 1
			else
				packs[SP.type] = 1
			cost += SP.cost
		.["requests"] += list(list("id" = SO.id, "orderer" = SO.orderer, "orderer_rank" = SO.orderer_rank, "reason" = SO.reason, "cost" = cost, "packs" = packs, "authed_by" = SO.authorised_by))
	.["deniedrequests"] = list()
	for(var/i in length(SSpoints.deniedrequests) to 1 step -1)
		var/datum/supply_order/SO = SSpoints.deniedrequests[SSpoints.deniedrequests[i]]
		if(SO.faction != user.faction)
			continue
		var/list/packs = list()
		var/cost = 0
		for(var/P in SO.pack)
			var/datum/supply_packs/SP = P
			if(packs[SP.type])
				packs[SP.type] += 1
			else
				packs[SP.type] = 1
			cost += SP.cost
		.["deniedrequests"] += list(list("id" = SO.id, "orderer" = SO.orderer, "orderer_rank" = SO.orderer_rank, "reason" = SO.reason, "cost" = cost, "packs" = packs, "authed_by" = SO.authorised_by))
	.["approvedrequests"] = list()
	for(var/i in length(SSpoints.approvedrequests) to 1 step -1)
		var/datum/supply_order/SO = SSpoints.approvedrequests[SSpoints.approvedrequests[i]]
		if(SO.faction != user.faction)
			continue
		var/list/packs = list()
		var/cost = 0
		for(var/P in SO.pack)
			var/datum/supply_packs/SP = P
			if(packs[SP.type])
				packs[SP.type] += 1
			else
				packs[SP.type] = 1
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
	. = ..()
	if(.)
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
	icon_state = "computer"
	screen_overlay = "request"
	broken_icon = "computer_orange_broken"
	circuit = /obj/item/circuitboard/computer/ordercomp
	var/datum/supply_ui/requests/SU

/obj/machinery/computer/ordercomp/interact(mob/user)
	. = ..()
	if(.)
		return
	if(!allowed(user))
		return
	if(!SU)
		SU = new(src)
	return SU.interact(user)

/obj/item/storage/backpack/marine/radiopack
	name = "\improper NTC radio operator backpack"
	desc = "A backpack that resembles the ones old-age radio operator marines would use. It has a supply ordering console installed on it, and a retractable antenna to receive supply drops. It also provides a boost to connectivity of comms of the user."
	icon_state = "radiopack"
	worn_icon_state = "radiopack"
	///Var for the window pop-up
	var/datum/supply_ui/requests/supply_interface

/obj/item/storage/backpack/marine/radiopack/equipped(mob/user, slot)
	. = ..()
	//works on hand either i guess (probably)
	RegisterSignal(user, COMSIG_CAVE_INTERFERENCE_CHECK, PROC_REF(on_interference_check))

/obj/item/storage/backpack/marine/radiopack/unequipped(mob/unequipper, slot)
	. = ..()
	UnregisterSignal(unequipper, COMSIG_CAVE_INTERFERENCE_CHECK)

/obj/item/storage/backpack/marine/radiopack/proc/on_interference_check(source, list/inplace_interference)
	SIGNAL_HANDLER
	inplace_interference[1] = max(0, inplace_interference[1] - 1)

/obj/item/storage/backpack/marine/radiopack/Initialize(mapload, ...)
	. = ..()
	AddComponent(/datum/component/beacon, FALSE, 0, icon_state + "_active")

/obj/item/storage/backpack/marine/radiopack/examine(mob/user)
	. = ..()
	. += span_notice("Right-Click with empty hand to open requisitions interface.")

/obj/item/storage/backpack/marine/radiopack/attack_hand_alternate(mob/living/user)
	if(!allowed(user))
		return ..()
	if(!supply_interface)
		supply_interface = new(src)
	return supply_interface.interact(user)

/obj/machinery/computer/supplycomp/som
	shuttle_id = "supplysom"
	faction = FACTION_SOM
	home_id = "supply_som"
	req_access = list(ACCESS_SOM_REQUESITIONS)

/obj/machinery/computer/supplycomp/clf
	shuttle_id = "supplyclf"
	faction = FACTION_CLF
	home_id = "supply_clf"
	req_access = list(ACCESS_CLF_CARGO)

/obj/docking_port/mobile/supply/som
	dir = 1
	height = 1
	home_id = "supply_som"
	id = "supplysom"
	name = "som supply shuttle"
	dheight = 0
	dwidth = 0
	width = 3
	faction = FACTION_SOM

/obj/docking_port/mobile/supply/clf
	dir = 1
	height = 1
	home_id = "supply_clf"
	id = "supplyclf"
	name = "clf supply shuttle"
	dheight = 0
	dwidth = 0
	width = 3
	faction = FACTION_CLF

/obj/docking_port/mobile/supply/vehicle
	railing_gear_name = "vehicle"
	id = SHUTTLE_VEHICLE_SUPPLY
	home_id = "vehicle_home"

/obj/docking_port/mobile/supply/vehicle/buy(mob/user, datum/supply_ui/supply_ui)
	var/datum/supply_ui/vehicles/veh_ui = supply_ui
	if(!veh_ui || !veh_ui.current_veh_type)
		return
	var/obj/vehicle/sealed/armored/tanktype = veh_ui.current_veh_type
	var/obj/vehicle/sealed/armored/tank = new tanktype(loc)
	if(veh_ui.current_primary)
		var/obj/item/armored_weapon/gun = new veh_ui.current_primary(loc)
		gun.attach(tank, TRUE)
	if(veh_ui.current_secondary)
		var/obj/item/armored_weapon/gun = new veh_ui.current_secondary(loc)
		gun.attach(tank, FALSE)
	if(veh_ui.current_driver_mod)
		var/obj/item/tank_module/mod = new veh_ui.current_driver_mod(loc)
		mod.on_equip(tank)
	if(veh_ui.current_gunner_mod)
		var/obj/item/tank_module/mod = new veh_ui.current_gunner_mod(loc)
		mod.on_equip(tank)
	if(length(veh_ui.primary_ammo))
		var/turf/dumploc = get_step(get_step(loc, NORTH), NORTH) // todo should autoload depending on tank prolly
		for(var/ammo in veh_ui.primary_ammo)
			for(var/i=1 to veh_ui.primary_ammo[ammo])
				new ammo(dumploc)
	if(length(veh_ui.secondary_ammo))
		var/turf/dumploc = get_step(get_step(loc, NORTH), NORTH) // todo should autoload depending on tank prolly
		for(var/ammo in veh_ui.secondary_ammo)
			for(var/i=1 to veh_ui.secondary_ammo[ammo])
				new ammo(dumploc)
	SStgui.close_user_uis(user, veh_ui)

/obj/docking_port/stationary/supply/vehicle
	id = "vehicle_home"
	roundstart_template = /datum/map_template/shuttle/supply/vehicle



GLOBAL_LIST_EMPTY(armored_gunammo)
GLOBAL_LIST_EMPTY(armored_modtypes)
GLOBAL_LIST_INIT(armored_guntypes, armored_init_guntypes())
#define DEFAULT_MAX_ARMORED_AMMO 20

///im a lazy bum who cant use initial on lists, so we just load everything into a list
/proc/armored_init_guntypes()
	. = list()
	for(var/obj/vehicle/sealed/armored/vehtype AS in typesof(/obj/vehicle/sealed/armored))
		vehtype = new vehtype

		GLOB.armored_modtypes[vehtype.type] = list()
		for(var/obj/item/tank_module/module AS in vehtype.permitted_mods)
			if(module::tank_mod_flags & TANK_MOD_NOT_FABRICABLE)
				continue
			GLOB.armored_modtypes[vehtype.type] += module

		.[vehtype.type] = list()
		for(var/obj/item/armored_weapon/weapon AS in vehtype.permitted_weapons)
			if(weapon::armored_weapon_flags & MODULE_NOT_FABRICABLE)
				continue
			.[vehtype.type] += weapon
		qdel(vehtype)

	for(var/obj/item/armored_weapon/gun AS in typesof(/obj/item/armored_weapon))
		gun = new gun
		GLOB.armored_gunammo[gun.type] = list()
		for(var/obj/item/ammo_magazine/magazine AS in gun.accepted_ammo)
			if(magazine::magazine_flags & MAGAZINE_NOT_FABRICABLE)
				continue
			GLOB.armored_gunammo[gun.type] += magazine
		qdel(gun)

/datum/supply_ui/vehicles
	tgui_name = "VehicleSupply"
	shuttle_id = SHUTTLE_VEHICLE_SUPPLY
	home_id = "vehicle_home"
	/// current selected vehicles typepath
	var/current_veh_type
	/// current selected primary weapons typepath
	var/current_primary
	/// current selected secondaryies typepath
	var/current_secondary
	/// current driver mod typepath
	var/current_driver_mod
	/// current gunner mod typepath
	var/current_gunner_mod
	/// current primary ammo list, type = count
	var/list/primary_ammo = list()
	/// current secondary ammo list, type = count
	var/list/secondary_ammo = list()

/datum/supply_ui/vehicles/ui_static_data(mob/user)
	var/list/data = list()
	for(var/obj/vehicle/sealed/armored/vehtype AS in typesof(/obj/vehicle/sealed/armored))
		var/flags = vehtype::armored_flags

		if(flags & ARMORED_PURCHASABLE_TRANSPORT)
			if(user.skills.getRating(SKILL_LARGE_VEHICLE) < SKILL_LARGE_VEHICLE_EXPERIENCED)
				continue
		else if(flags & ARMORED_PURCHASABLE_ASSAULT)
			if(user.skills.getRating(SKILL_LARGE_VEHICLE) < SKILL_LARGE_VEHICLE_VETERAN)
				continue
		else
			continue

		data["vehicles"] += list(list("name" = initial(vehtype.name), "desc" = initial(vehtype.desc), "type" = "[vehtype]", "isselected" = (vehtype == current_veh_type)))
		if(vehtype != current_veh_type)
			continue
		for(var/obj/item/armored_weapon/gun AS in GLOB.armored_guntypes[vehtype])
			var/primary_selected = (current_primary == gun)
			var/secondary_selected = (current_secondary == gun)
			if(initial(gun.armored_weapon_flags) & MODULE_PRIMARY)
				data["primaryWeapons"] += list(list(
					"name" = initial(gun.name),
					"desc" = initial(gun.desc),
					"type" = gun,
					"isselected" = primary_selected,
				))
				if(primary_selected)
					for(var/obj/item/ammo_magazine/mag AS in primary_ammo)
						data["primaryammotypes"] += list(list(
							"name" = initial(mag.name),
							"type" = mag,
							"current" = primary_ammo[mag],
							"max" = DEFAULT_MAX_ARMORED_AMMO, //TODO make vehicle ammo dynamic instead of fixed number
						))

			if(initial(gun.armored_weapon_flags) & MODULE_SECONDARY)
				data["secondaryWeapons"] += list(list(
					"name" = initial(gun.name),
					"desc" = initial(gun.desc),
					"type" = gun,
					"isselected" = secondary_selected,
				))
				if(secondary_selected)
					for(var/obj/item/ammo_magazine/mag AS in secondary_ammo)
						data["secondarymmotypes"] += list(list(
							"name" = initial(mag.name),
							"type" = mag,
							"current" = secondary_ammo[mag],
							"max" = DEFAULT_MAX_ARMORED_AMMO, //TODO make vehicle ammo dynamic instead of fixed number
						))

		for(var/obj/item/tank_module/mod AS in GLOB.armored_modtypes[vehtype])
			if(initial(mod.is_driver_module))
				data["driverModules"] += list(list(
					"name" = initial(mod.name),
					"desc" = initial(mod.desc),
					"type" = mod,
					"isselected" = (current_driver_mod == mod),
				))
			else
				data["gunnerModules"] += list(list(
					"name" = initial(mod.name),
					"desc" = initial(mod.desc),
					"type" = mod,
					"isselected" = (current_gunner_mod == mod),
				))
	return data

/datum/supply_ui/vehicles/ui_data(mob/living/user)
	var/list/data = list()
	if(supply_shuttle)
		if(supply_shuttle?.mode == SHUTTLE_CALL)
			if(is_mainship_level(supply_shuttle.destination.z))
				data["elevator"] = "Raising"
				data["elevator_dir"] = "up"
			else
				data["elevator"] = "Lowering"
				data["elevator_dir"] = "down"
		else if(supply_shuttle?.mode == SHUTTLE_IDLE)
			if(is_mainship_level(supply_shuttle.z))
				data["elevator"] = "Raised"
				data["elevator_dir"] = "down"
			else if(current_veh_type)
				data["elevator"] = "Purchase"
				data["elevator_dir"] = "store"
			else
				data["elevator"] = "Lowered"
				data["elevator_dir"] = "up"
		else
			if(is_mainship_level(supply_shuttle.z))
				data["elevator"] = "Lowering"
				data["elevator_dir"] = "down"
			else
				data["elevator"] = "Raising"
				data["elevator_dir"] = "up"
	else
		data["elevator"] = "MISSING!"
	return data

/datum/supply_ui/vehicles/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("setvehicle")
			var/newtype = text2path(params["type"])
			if(!ispath(newtype, /obj/vehicle/sealed/armored))
				return
			current_veh_type = newtype
			current_primary = null
			current_secondary = null
			current_driver_mod = null
			current_gunner_mod = null
			primary_ammo = list()
			secondary_ammo = list()
			. = TRUE

		if("setprimary")
			if(!current_veh_type)
				return
			var/newtype = text2path(params["type"])
			if(!(newtype in GLOB.armored_guntypes[current_veh_type]))
				return
			current_primary = newtype
			var/list/assoc_cast = GLOB.armored_gunammo[newtype]
			primary_ammo = assoc_cast.Copy()
			for(var/ammo in primary_ammo)
				primary_ammo[ammo] = 0
			. = TRUE

		if("setsecondary")
			if(!current_veh_type)
				return
			var/newtype = text2path(params["type"])
			if(!(newtype in GLOB.armored_guntypes[current_veh_type]))
				return
			current_secondary = newtype
			var/list/assoc_cast = GLOB.armored_gunammo[newtype]
			secondary_ammo = assoc_cast.Copy()
			for(var/ammo in secondary_ammo)
				secondary_ammo[ammo] = 0
			. = TRUE

		if("set_ammo_primary")
			if(!current_primary)
				return
			var/newtype = text2path(params["type"])
			if(!(newtype in primary_ammo))
				return
			var/non_adjusted_total = 0
			for(var/ammo in primary_ammo)
				if(ammo == newtype)
					continue
				non_adjusted_total += primary_ammo[ammo]
			var/newvalue = clamp(params["new_value"], 0, DEFAULT_MAX_ARMORED_AMMO-non_adjusted_total)
			primary_ammo[newtype] = newvalue
			. = TRUE

		if("set_ammo_secondary")
			if(!current_secondary)
				return
			var/newtype = text2path(params["type"])
			if(!(newtype in secondary_ammo))
				return
			var/non_adjusted_total = 0
			for(var/ammo in secondary_ammo)
				if(ammo == newtype)
					continue
				non_adjusted_total += secondary_ammo[ammo]
			var/newvalue = clamp(params["new_value"], 0, DEFAULT_MAX_ARMORED_AMMO-non_adjusted_total)
			secondary_ammo[newtype] = newvalue
			. = TRUE

		if("set_driver_mod")
			if(!current_veh_type)
				return
			var/newtype = text2path(params["type"])
			if(!ispath(newtype, /obj/item/tank_module))
				return
			if(!(newtype in GLOB.armored_modtypes[current_veh_type]))
				return
			current_driver_mod = newtype
			. = TRUE

		if("set_gunner_mod")
			if(!current_veh_type)
				return
			var/newtype = text2path(params["type"])
			if(!ispath(newtype, /obj/item/tank_module))
				return
			if(!(newtype in GLOB.armored_modtypes[current_veh_type]))
				return
			current_gunner_mod = newtype
			. = TRUE

	if(.)
		update_static_data(usr)
