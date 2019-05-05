GLOBAL_LIST_INIT(blacklisted_cargo_types, typecacheof(list(
		/mob/living,
		/obj/effect/rune,
		/obj/item/disk/nuclear,
		/obj/machinery/nuclearbomb,
		/obj/effect/portal
	)))

GLOBAL_LIST_EMPTY(exports_types)

/datum/supply_order
	var/id
	var/orderer
	var/orderer_rank
	var/orderer_ckey
	var/reason
	var/datum/supply_packs/pack

/obj/item/paper/manifest
	name = "Supply Manifest"

/proc/setupExports()
	for(var/typepath in subtypesof(/datum/supply_export))
		var/datum/supply_export/E = new typepath()
		GLOB.exports_types += E

/obj/docking_port/stationary/supply
	id = "supply"

	width = 5
	dwidth = 2
	dheight = 2
	height = 5

/obj/docking_port/stationary/supply/reqs
	roundstart_template = /datum/map_template/shuttle/supply

/obj/docking_port/mobile/supply
	name = "supply shuttle"
	id = "supply"
	callTime = 600

	dir = WEST
	port_direction = EAST
	width = 5
	dwidth = 2
	dheight = 2
	height = 5
	movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)


	//Export categories for this run, this is set by console sending the shuttle.
//	var/export_categories = EXPORT_CARGO

/obj/docking_port/mobile/supply/register()
	. = ..()
	SSshuttle.supply = src

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
	if(!SSshuttle.shoppinglist.len)
		return

	var/list/empty_turfs = list()
	for(var/place in shuttle_areas)
		var/area/shuttle/shuttle_area = place
		for(var/turf/open/floor/T in shuttle_area)
			if(is_blocked_turf(T))
				continue
			empty_turfs += T

	for(var/datum/supply_order/SO in SSshuttle.shoppinglist)
		if(!empty_turfs.len)
			break

		var/datum/supply_packs/SP = SO.pack

		var/atom/A = new SP.containertype(pick_n_take(empty_turfs))
		A.name = "[SP.containername][SO.reason ? " ([SO.reason])" : ""]"

		//supply manifest generation begin

		var/obj/item/paper/manifest/slip = new /obj/item/paper/manifest(A)
		slip.info = "<h3>Automatic Storage Retrieval Manifest</h3><hr><br>"
		slip.info +="Order #[SO.id]<br>"
		slip.info +="[SSshuttle.shoppinglist.len] PACKAGES IN THIS SHIPMENT<br>"
		slip.info +="CONTENTS:<br><ul>"

		//spawn the stuff, finish generating the manifest while you're at it
		if(SP.access)
			A:req_access = list()
			A:req_access += text2num(SP.access)

		var/list/contains
		if(SP.randomised_num_contained)
			contains = list()
			if(SP.contains.len)
				for(var/j=1,j<=SP.randomised_num_contained,j++)
					contains += pick(SP.contains)
		else
			contains = SP.contains

		for(var/typepath in contains)
			if(!typepath)	continue
			var/atom/B2 = new typepath(A)
			//if(SP.amount && B2:amount) 
			//	B2:amount = SP.amount
			slip.info += "<li>[B2.name]</li>" //add the item to the manifest

		//manifest finalisation
		slip.info += "</ul><br>"
		slip.info += "CHECK CONTENTS AND STAMP BELOW THE LINE TO CONFIRM RECEIPT OF GOODS<hr>"
		if (SP.contraband) 
			slip.loc = null	//we are out of blanks for Form #44-D Ordering Illicit Drugs.

/obj/docking_port/mobile/supply/proc/sell()
	if(!GLOB.exports_types.len) // No exports list? Generate it!
		setupExports()

	var/plat_count = 0

	for(var/place in shuttle_areas)
		var/area/shuttle/shuttle_area = place
		for(var/atom/movable/AM in shuttle_area)
			if(AM.anchored)
				continue

			// Must be in a crate!
			if(istype(AM,/obj/structure/closet/crate))

				SSpoints.supply_points += POINTS_PER_CRATE
				var/find_slip = 1

				for(var/atom in AM)
					// Sell manifests
					var/atom/A = atom
					if(find_slip && istype(A,/obj/item/paper/manifest))
						var/obj/item/paper/slip = A
						if(slip.stamped && slip.stamped.len) //yes, the clown stamp will work. clown is the highest authority on the station, it makes sense
							SSpoints.supply_points += POINTS_PER_SLIP
							find_slip = 0
						continue

					// Sell platinum
					if(istype(A, /obj/item/stack/sheet/mineral/platinum))
						var/obj/item/stack/sheet/mineral/platinum/P = A
						plat_count += P.get_amount()

			//Sell Xeno Corpses
			if (isxeno(AM))
				var/cost = 0
				for(var/datum/supply_export in GLOB.exports_types)
					var/datum/supply_export/E = supply_export
					if(AM.type == E.export_obj)
						cost = E.cost
				SSpoints.supply_points += cost


			qdel(AM)

	if(plat_count)
		SSpoints.supply_points += plat_count * POINTS_PER_PLATINUM

//	if(ex.exported_atoms)
//		ex.exported_atoms += "." //ugh

//	for(var/datum/export/E in ex.total_amount)
//		var/export_text = E.total_printout(ex)
//		if(!export_text)
//			continue

//		msg += export_text + "\n"
		//D.adjust_money(ex.total_value[E])

//	SSshuttle.centcom_message = msg
	//investigate_log("Shuttle contents sold for [D.account_balance - presale_points] credits. Contents: [ex.exported_atoms ? ex.exported_atoms.Join(",") + "." : "none."] Message: [SSshuttle.centcom_message || "none."]", INVESTIGATE_CARGO)

/obj/machinery/computer/supplycomp
	name = "ASRS console"
	desc = "A console for an Automated Storage and Retrieval System"
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "supply"
	req_access = list(ACCESS_MARINE_CARGO)
	circuit = "/obj/item/circuitboard/computer/supplycomp"

/obj/machinery/computer/ordercomp
	name = "Supply ordering console"
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "request"
	circuit = "/obj/item/circuitboard/computer/ordercomp"
