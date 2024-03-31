GLOBAL_LIST_INIT(blacklisted_cargo_types, typecacheof(list(
		/mob/living,
		/obj/structure/blob,
		/obj/effect/rune,
		/obj/structure/spider/spiderling,
		/obj/item/disk/nuclear,
		/obj/machinery/nuclearbomb,
		/obj/item/beacon,
		/obj/singularity/narsie,
		/obj/singularity/wizard,
		/obj/machinery/teleport/station,
		/obj/machinery/teleport/hub,
		/obj/machinery/quantumpad,
		/obj/machinery/clonepod,
		/obj/effect/mob_spawn,
		/obj/effect/hierophant,
		/obj/structure/receiving_pad,
		/obj/item/warp_cube,
		/obj/machinery/rnd/production, //print tracking beacons, send shuttle
		/obj/machinery/autolathe, //same
		/obj/projectile/beam/wormhole,
		/obj/effect/portal,
		/obj/item/shared_storage,
		/obj/structure/extraction_point,
		/obj/machinery/syndicatebomb,
		/obj/item/hilbertshotel,
		/obj/item/swapper,
		/obj/docking_port,
		/obj/machinery/launchpad,
		/obj/machinery/disposal,
		/obj/structure/disposalpipe,
		/obj/item/hilbertshotel
	)))

/obj/docking_port/mobile/supply
	name = "supply shuttle"
	id = "supply"
#ifdef TESTSERVER
	callTime = 60
#else
	callTime = 300
#endif
	dir = NORTH
	port_direction = SOUTH
	width = 12
	dwidth = 5
	height = 7
	movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)
	var/budget = 0
	var/list/salese = list()

	//Export categories for this run, this is set by console sending the shuttle.
	var/export_categories = EXPORT_CARGO

/obj/docking_port/mobile/supply/register()
	. = ..()
	SSshuttle.supply = src
#ifdef MATURESERVER
	SSshuttle.moveShuttle("supply", "supply_home", TRUE)
#endif
/obj/docking_port/mobile/supply/canMove()
	if(is_station_level(z))
		return check_blacklist(shuttle_areas)
	return ..()

/obj/docking_port/mobile/supply/proc/check_blacklist(areaInstances)
	for(var/place in areaInstances)
		var/area/shuttle/shuttle_area = place
		for(var/trf in shuttle_area)
			var/turf/T = trf
			for(var/a in T.GetAllContents())
				if(is_type_in_typecache(a, GLOB.blacklisted_cargo_types) && !istype(a, /obj/docking_port))
					return FALSE
	return TRUE

/obj/docking_port/mobile/supply/request(obj/docking_port/stationary/S)
	if(mode != SHUTTLE_IDLE)
		return 2
	return ..()

/obj/docking_port/mobile/supply/initiate_docking()
	. = ..() // Fly/enter transit.
	if(. != DOCKING_SUCCESS)
		return
	if(getDockedId() == "supply_away")
		testing("docked away")
		sell()
		buy()
		addtimer(CALLBACK(SSshuttle, /datum/controller/subsystem/shuttle/.proc/moveShuttle, "supply", "supply_home", TRUE), 100)

/obj/docking_port/mobile/supply/proc/buy()
	var/list/obj/cat_boxes = list()

	var/list/empty_turfs = list()
	var/list/general_turfs = list()
	for(var/area/shuttle/supply/buy/shuttle_area in shuttle_areas)
		for(var/turf/open/floor/T in shuttle_area)
			general_turfs += T
			if(is_blocked_turf(T))
				continue
			empty_turfs += T

	var/list/orderse = list()

	if(SSshuttle.shoppinglist.len)
		for(var/datum/supply_order/SO in SSshuttle.shoppinglist)
			if(budget <= -30)
				continue
			budget -= SO.pack.cost
			var/turf/used_turf
			if(!empty_turfs.len)
				used_turf = pick(general_turfs)
			else
				used_turf = pick_n_take(empty_turfs)
			var/obj/structure/closet/crate/B = cat_boxes[SO.pack.group]
			if(!B)
				B = new SO.pack.crate_type(used_turf)
				cat_boxes[SO.pack.group] = B
			SO.generateCombo(B, SO.orderer, SO.pack.contains)
			orderse += "[SO.pack.name]"
			SSshuttle.shoppinglist -= SO
			qdel(SO)

	var/turf/used_turf
	if(!empty_turfs.len)
		used_turf = pick(general_turfs)
	else
		used_turf = pick_n_take(empty_turfs)

	var/moneybox = new /obj/structure/closet/crate/chest/merchant(used_turf)

	if(budget > 0)
		var/spawnedcoins = round(budget / 10)
		if(spawnedcoins >= 1)
			for(var/i in 1 to spawnedcoins)
				budget -= 10
				new /obj/item/roguecoin/gold(moneybox)
		spawnedcoins = round(budget / 5)
		if(spawnedcoins >= 1)
			for(var/i in 1 to spawnedcoins)
				budget -= 5
				new /obj/item/roguecoin/silver(moneybox)
		if(budget >= 1)
			for(var/i in 1 to budget)
				new /obj/item/roguecoin/copper(moneybox)
		budget = 0
	if(orderse.len || salese.len || budget < 0)
		generateManifest(orderse,moneybox)
	salese = list()


/obj/docking_port/mobile/supply/proc/generateManifest(var/list/orders,loc) //generates-the-manifests.
	var/obj/item/paper/scroll/P = new(loc)

	P.name = "shipping manifest - [station_time_timestamp()]"
	P.info += "<h2>Shipping Manifest - [station_time_timestamp()]</h2>"
	P.info += "<hr/>"

	if(orders.len)
		P.info += "Trades: <br/>"
		P.info += "<ul>"
		for(var/A in orders)
			P.info += "<li>[A]</li>"
		P.info += "</ul>"

	P.info += "<br/>"

	if(salese.len)
		P.info += "Liquidation: <br/>"
		P.info += "<ul>"
		for(var/A in salese)
			P.info += "<li>[A]</li>"
		P.info += "</ul>"

	P.info += "<br/>"

	if(budget < 0)
		if(budget > -30)
			P.info += "<font color=#6600cc>You have a negative balance ([budget]) with our guild. Pay your dues or be fined further.</font>"
		else
			budget -= 30
			P.info += "<font color=#6600cc>Your negative balance ([budget]) has strained our relationship. We have taken our share of this sale and will not be sending orders until we are settled.</font>"


	return P


/obj/docking_port/mobile/supply/proc/remake_ledger()
	var/list/general_turfs = list()
	for(var/area/shuttle/supply/buy/shuttle_area in shuttle_areas)
		for(var/turf/open/floor/T in shuttle_area)
			general_turfs += T
			new /obj/item/book/rogue/ledger(pick(general_turfs))

/obj/docking_port/mobile/supply/proc/sell()
	var/msg = ""

	var/datum/export_report/ex = new

	var/newbudget = 0

	for(var/area/shuttle/supply/sell/place in shuttle_areas)
		for(var/atom/movable/AM in place)
			if(iscameramob(AM))
				continue
			if(QDELETED(AM))
				continue
			var/list/contents = AM.GetAllContents()
			for(var/i in reverseRange(contents))
				var/atom/movable/thing = i
				if(QDELETED(thing))
					continue
				thing.pre_sell()
			AM.pre_sell()

	for(var/area/shuttle/supply/sell/place in shuttle_areas)
		for(var/atom/movable/AM in place)
			if(iscameramob(AM))
				continue
			if(QDELETED(AM))
				continue
//			if(bounty_ship_item_and_contents(AM, dry_run = FALSE))
//				matched_bounty = TRUE
			if(!AM.anchored || istype(AM, /obj/mecha))
				if(istype(AM, /obj/item/paper/scroll/cargo))
					var/obj/item/paper/scroll/cargo/C = AM
					if(C.signedjob in list("Priest", "Court Magician", "Merchant", "King", "Sheriff"))
						for(var/datum/supply_order/SO in C.orders)
							SSshuttle.shoppinglist += SO
							C.orders -= SO
						qdel(C)
						continue
				var/list/contents = AM.GetAllContents()
				for(var/i in reverseRange(contents))
					var/atom/movable/thing = i
					if(QDELETED(thing))
						continue
					if(istype(thing, /obj/item/paper/scroll/cargo))
						var/obj/item/paper/scroll/cargo/C = AM
						if(C.signedjob in list("Priest", "Court Magician", "Merchant", "King", "Sheriff"))
							for(var/datum/supply_order/SO in C.orders)
								SSshuttle.shoppinglist += SO
								C.orders -= SO
							qdel(C)
							continue
					if(thing.get_real_price() > 0)
						newbudget += thing.get_real_price()
						ex.total_value[thing] += thing.get_real_price()
						ex.total_amount[thing] += 1
						ex.exported_atoms += " [thing.name]"
						salese += "[thing.name] ([thing.get_real_price()])"
						thing.on_sold()
						qdel(thing)

	budget += newbudget

	if(budget < 0)
		if(budget > -30)
			msg += "You have a negative balance ([budget]) with our guild. Pay your dues or be fined further."
		else
			budget -= 30
			msg += "Your negative balance ([budget]) has strained our relationship. We have taken our share of this sale and will not be sending orders until we are settled."
	return msg
