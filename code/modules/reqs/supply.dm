GLOBAL_LIST_INIT(blacklisted_cargo_types, typecacheof(list(
		/mob/living,
		/obj/item/disk/nuclear,
		/obj/item/radio/beacon
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
		if(G.id == "supply_elevator_gear")
			gears += G
			RegisterSignal(G, COMSIG_QDELETING, PROC_REF(clean_gear))
	for(var/obj/machinery/door/poddoor/railing/R in GLOB.machines)
		if(R.id == "supply_elevator_railing")
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

/obj/docking_port/mobile/supply/proc/buy(mob/user)
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
			var/datum/export_report = AM.supply_export(faction)
			if(export_report)
				SSpoints.export_history += export_report
			qdel(AM)

/obj/item/supplytablet
	name = "ASRS tablet"
	desc = "A tablet for an Automated Storage and Retrieval System"
	icon = 'icons/Marine/marine-navigation.dmi'
	icon_state = "req_tablet_off"
	req_access = list(ACCESS_MARINE_CARGO)
	flags_equip_slot = ITEM_SLOT_POCKET
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
			packs += SP.type
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
			packs += SP.type
			cost += SP.cost
		.["deniedrequests"] += list(list("id" = SO.id, "orderer" = SO.orderer, "orderer_rank" = SO.orderer_rank, "reason" = SO.reason, "cost" = cost, "packs" = packs, "authed_by" = SO.authorised_by))
	.["approvedrequests"] = list()
	for(var/i in length(SSpoints.approvedrequests) to 1 step -1)
		var/datum/supply_order/SO = SSpoints.approvedrequests[SSpoints.approvedrequests[i]]
		if(SO.faction != user.faction)
			continue
		var/list/packs = list()
		var/cost = 0
		for(var/datum/supply_packs/SP AS in SO.pack)
			packs += SP.type
			cost += SP.cost
		.["approvedrequests"] += list(list("id" = SO.id, "orderer" = SO.orderer, "orderer_rank" = SO.orderer_rank, "reason" = SO.reason, "cost" = cost, "packs" = packs, "authed_by" = SO.authorised_by))
	.["awaiting_delivery"] = list()
	.["awaiting_delivery_orders"] = 0
	for(var/key in SSpoints.shoppinglist[faction])
		var/datum/supply_order/SO = LAZYACCESSASSOC(SSpoints.shoppinglist, faction, key)
		.["awaiting_delivery_orders"]++
		var/list/packs = list()
		for(var/datum/supply_packs/SP AS in SO.pack)
			packs += SP.type
		.["awaiting_delivery"] += list(list("id" = SO.id, "orderer" = SO.orderer, "orderer_rank" = SO.orderer_rank, "reason" = SO.reason, "packs" = packs, "authed_by" = SO.authorised_by))
	.["export_history"] = list()
	var/id = 0
	for(var/datum/export_report/report AS in SSpoints.export_history)
		if(report.faction != user.faction)
			continue
		.["export_history"] += list(list("id" = id, "name" = report.export_name, "points" = report.points))
		id++
	.["shopping_history"] = list()
	for(var/datum/supply_order/SO AS in SSpoints.shopping_history)
		if(SO.faction != user.faction)
			continue
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
	if(supply_shuttle)
		if(supply_shuttle?.mode == SHUTTLE_CALL)
			if(is_mainship_level(supply_shuttle.destination.z))
				.["elevator"] = "Raising"
				.["elevator_dir"] = "up"
			else
				.["elevator"] = "Lowering"
				.["elevator_dir"] = "down"
		else if(supply_shuttle?.mode == SHUTTLE_IDLE)
			if(is_mainship_level(supply_shuttle.z))
				.["elevator"] = "Raised"
				.["elevator_dir"] = "down"
			else
				.["elevator"] = "Lowered"
				.["elevator_dir"] = "up"
		else
			if(is_mainship_level(supply_shuttle.z))
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
			if(is_mainship_level(supply_shuttle.z))
				if (!supply_shuttle.check_blacklist())
					to_chat(usr, "For safety reasons, the Automated Storage and Retrieval System cannot store live, friendlies, classified nuclear weaponry or homing beacons.")
					playsound(supply_shuttle.return_center_turf(), 'sound/machines/buzz-two.ogg', 50, 0)
				else
					playsound(supply_shuttle.return_center_turf(), 'sound/machines/elevator_move.ogg', 50, 0)
					SSshuttle.moveShuttleToTransit(shuttle_id, TRUE)
					addtimer(CALLBACK(supply_shuttle, TYPE_PROC_REF(/obj/docking_port/mobile/supply, sell)), 15 SECONDS)
			else
				var/obj/docking_port/D = SSshuttle.getDock(home_id)
				supply_shuttle.buy(usr)
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
			packs += SP.type
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
			packs += SP.type
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
	name = "\improper TGMC radio operator backpack"
	desc = "A backpack that resembles the ones old-age radio operator marines would use. It has a supply ordering console installed on it, and a retractable antenna to receive supply drops."
	icon_state = "radiopack"
	item_state = "radiopack"
	///Var for the window pop-up
	var/datum/supply_ui/requests/supply_interface
	/// Reference to the datum used by the supply drop console
	var/datum/supply_beacon/beacon_datum

/obj/item/storage/backpack/marine/radiopack/Destroy()
	if(beacon_datum)
		UnregisterSignal(beacon_datum, COMSIG_QDELETING)
		QDEL_NULL(beacon_datum)
	return ..()

/obj/item/storage/backpack/marine/radiopack/examine(mob/user)
	. = ..()
	. += span_notice("Right-Click with empty hand to open requisitions interface.")
	. += span_notice("Activate in hand to create a supply beacon signal.")

/obj/item/storage/backpack/marine/radiopack/attack_hand_alternate(mob/living/user)
	if(!allowed(user))
		return ..()
	if(!supply_interface)
		supply_interface = new(src)
	return supply_interface.interact(user)

/obj/item/storage/backpack/marine/radiopack/attack_self(mob/living/user)
	if(beacon_datum)
		UnregisterSignal(beacon_datum, COMSIG_QDELETING)
		QDEL_NULL(beacon_datum)
		user.show_message(span_warning("The [src] beeps and states, \"Your last position is no longer accessible by the supply console"), EMOTE_AUDIBLE, span_notice("The [src] vibrates but you can not hear it!"))
		return
	if(!is_ground_level(user.z))
		to_chat(user, span_warning("You have to be on the planet to use this or it won't transmit."))
		return FALSE
	var/turf/location = get_turf(src)
	beacon_datum = new /datum/supply_beacon(user.name, user.loc, user.faction, 4 MINUTES)
	RegisterSignal(beacon_datum, COMSIG_QDELETING, PROC_REF(clean_beacon_datum))
	user.show_message(span_notice("The [src] beeps and states, \"Your current coordinates were registered by the supply console. LONGITUDE [location.x]. LATITUDE [location.y]. Area ID: [get_area(src)]\""), EMOTE_AUDIBLE, span_notice("The [src] vibrates but you can not hear it!"))

/// Signal handler to nullify beacon datum
/obj/item/storage/backpack/marine/radiopack/proc/clean_beacon_datum()
	SIGNAL_HANDLER
	beacon_datum = null
