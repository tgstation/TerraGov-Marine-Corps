GLOBAL_LIST_INIT(blacklisted_cargo_types, typecacheof(list(
		/mob/living,
		/obj/item/disk/nuclear,
		/obj/item/radio/beacon,
		/obj/item/stack/sheet/mineral/phoron
	)))

GLOBAL_LIST_EMPTY(exports_types)

#define SUPPLY_COST_MULTIPLIER 1.08

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
	var/list/railings = list()

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
	if(!length(SSshuttle.shoppinglist))
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
		slip.update_icon()

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

		SSshuttle.shoppinglist -= SO

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

/obj/machinery/computer/supplycomp
	name = "ASRS console"
	desc = "A console for an Automated Storage and Retrieval System"
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "supply"
	req_access = list(ACCESS_MARINE_CARGO)
	circuit = "/obj/item/circuitboard/computer/supplycomp"
	var/temp = null
	var/reqtime = 0 //Cooldown for requisitions - Quarxink
	var/hacked = 0
	var/can_order_contraband = 0
	var/last_viewed_group = "categories"

/obj/machinery/computer/ordercomp
	name = "Supply ordering console"
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "request"
	circuit = "/obj/item/circuitboard/computer/ordercomp"
	var/temp = null
	var/reqtime = 0 //Cooldown for requisitions - Quarxink
	var/last_viewed_group = "categories"

/obj/machinery/computer/ordercomp/attack_ai(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/ordercomp/attack_paw(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/supplycomp/attack_ai(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/supplycomp/attack_paw(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/ordercomp/attack_hand(var/mob/user as mob)
	if(..())
		return
	user.set_interaction(src)
	var/dat
	if(temp)
		dat = temp
	else
		if (SSshuttle.supply)
			dat += "<BR><B>Automated Storage and Retrieval System</B><HR>Location: "
			if(is_centcom_level(SSshuttle.supply.z))
				dat += "Lowered"
			else if(is_mainship_level(SSshuttle.supply.z))
				dat += "Raised"
			else if(is_mainship_level(SSshuttle.supply.destination?.z))
				dat += "Raising platform"
			else
				dat += "Lowering platform"
			dat += "<BR><HR>Supply points: [round(SSpoints.supply_points)]<BR>"
		dat += {"<BR>\n<A href='?src=\ref[src];order=categories'>Request items</A><BR><BR>
		<A href='?src=\ref[src];vieworders=1'>View approved orders</A><BR><BR>
		<A href='?src=\ref[src];viewrequests=1'>View requests</A><BR><BR>
		<A href='?src=\ref[user];mach_close=computer'>Close</A>"}

	var/datum/browser/popup = new(user, "computer", "<div align='center'>Ordering Console</div>", 575, 450)
	popup.set_content(dat)
	popup.open(FALSE)
	onclose(user, "computer")


/obj/machinery/computer/ordercomp/Topic(href, href_list)
	if(..())
		return

	if( isturf(loc) && (in_range(src, usr) || issilicon(usr)) )
		usr.set_interaction(src)

	if(href_list["order"])
		if(href_list["order"] == "categories")
			//all_supply_groups
			//Request what?
			last_viewed_group = "categories"
			temp = "<b>Supply points: [round(SSpoints.supply_points)]</b><BR>"
			temp += "<A href='?src=\ref[src];mainmenu=1'>Main Menu</A><HR><BR><BR>"
			temp += "<b>Select a category</b><BR><BR>"
			for(var/supply_group_name in all_supply_groups )
				temp += "<A href='?src=\ref[src];order=[supply_group_name]'>[supply_group_name]</A><BR>"
		else
			last_viewed_group = href_list["order"]
			temp = "<b>Supply points: [round(SSpoints.supply_points)]</b><BR>"
			temp += "<A href='?src=\ref[src];order=categories'>Back to all categories</A><HR><BR><BR>"
			temp += "<b>Request from: [last_viewed_group]</b><BR><BR>"
			for(var/supply_type in SSshuttle.supply_packs )
				var/datum/supply_packs/N = SSshuttle.supply_packs[supply_type]
				if(N.hidden || N.contraband || N.group != last_viewed_group) continue								//Have to send the type instead of a reference to
				temp += "<A href='?src=\ref[src];doorder=[N.name]'>[N.name]</A> Cost: [round(N.cost)]<BR>"		//the obj because it would get caught by the garbage

	else if (href_list["doorder"])
		if(world.time < reqtime)
			for(var/mob/V in hearers(src))
				V.show_message("<b>[src]</b>'s monitor flashes, \"[world.time - reqtime] seconds remaining until another requisition form may be printed.\"")
			return

		//Find the correct supply_pack datum
		var/datum/supply_packs/P = SSshuttle.supply_packs[href_list["doorder"]]
		if(!istype(P))	return

		var/timeout = world.time + 600
		var/reason = copytext(sanitize(input(usr,"Reason:","Why do you require this item?","") as null|text),1,MAX_MESSAGE_LEN)
		if(world.time > timeout)	return
		if(!reason)	return

		var/idname = "*None Provided*"
		var/idrank = "*None Provided*"
		if(ishuman(usr))
			var/mob/living/carbon/human/H = usr
			idname = H.get_authentification_name()
			idrank = H.get_assignment()
		else if(issilicon(usr))
			idname = usr.real_name

		SSshuttle.ordernum++
		var/obj/item/paper/reqform = new /obj/item/paper(loc)
		reqform.name = "Requisition Form - [P.name]"
		reqform.info += "<h3>[CONFIG_GET(string/ship_name)] Supply Requisition Form</h3><hr>"
		reqform.info += "INDEX: #[SSshuttle.ordernum]<br>"
		reqform.info += "REQUESTED BY: [idname]<br>"
		reqform.info += "RANK: [idrank]<br>"
		reqform.info += "REASON: [reason]<br>"
		reqform.info += "SUPPLY CRATE TYPE: [P.name]<br>"
		reqform.info += "ACCESS RESTRICTION: [oldreplacetext(get_access_desc(P.access))]<br>"
		reqform.info += "CONTENTS:<br>"
		reqform.info += P.manifest
		reqform.info += "<hr>"
		reqform.info += "STAMP BELOW TO APPROVE THIS REQUISITION:<br>"

		reqform.update_icon()	//Fix for appearing blank when printed.
		reqtime = (world.time + 5) % 1e5

		//make our supply_order datum
		var/datum/supply_order/O = new /datum/supply_order()
		O.id = SSshuttle.ordernum
		O.pack = P
		O.orderer = idname
		SSshuttle.requestlist += O

		temp = "Thanks for your request. The cargo team will process it as soon as possible.<BR>"
		temp += "<BR><A href='?src=\ref[src];order=[last_viewed_group]'>Back</A> <A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"

	else if (href_list["vieworders"])
		temp = "Current approved orders: <BR><BR>"
		for(var/S in SSshuttle.shoppinglist)
			var/datum/supply_order/SO = S
			temp += "[SO.pack.name] approved by [SO.orderer] [SO.reason ? "([SO.reason])":""]<BR>"
		temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"

	else if (href_list["viewrequests"])
		temp = "Current requests: <BR><BR>"
		for(var/S in SSshuttle.requestlist)
			var/datum/supply_order/SO = S
			temp += "#[SO.id] - [SO.pack.name] requested by [SO.orderer]<BR>"
		temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"

	else if (href_list["mainmenu"])
		temp = null

	updateUsrDialog()
	return

/obj/machinery/computer/supplycomp/attack_hand(var/mob/user as mob)
	if(!allowed(user))
		to_chat(user, "<span class='warning'>Access Denied.</span>")
		return

	if(..())
		return
	user.set_interaction(src)
	var/dat
	if (temp)
		dat = temp
	else
		if (SSshuttle.supply)
			dat += "\nPlatform position: "
			if (SSshuttle.supply.mode == SHUTTLE_CALL)
				dat += "Moving<BR>"
			else
				if (is_mainship_level(SSshuttle.supply.z))
					dat += "Raised<BR>"

					if (SSshuttle.supply.mode == SHUTTLE_IDLE)
						dat += "<A href='?src=\ref[src];send=1'>Lower platform</A>"
					else if (SSshuttle.supply.mode == SHUTTLE_IGNITING)
						dat += "<A href='?src=\ref[src];cancel_send=1'>Cancel</A>"
					else
						dat += "*ASRS is busy*"
					dat += "<BR>\n<BR>"
				else
					dat += "Lowered<BR>"
					if (SSshuttle.supply.mode == SHUTTLE_IDLE)
						dat += "<A href='?src=\ref[src];send=1'>Raise platform</A>"
					else if (SSshuttle.supply.mode == SHUTTLE_IGNITING)
						dat += "<A href='?src=\ref[src];cancel_send=1'>Cancel</A>"
					else
						dat += "*ASRS is busy*"
					dat += "<BR>\n<BR>"


		dat += {"<HR>\nSupply points: [round(SSpoints.supply_points)]<BR>\n<BR>
		\n<A href='?src=\ref[src];order=categories'>Order items</A><BR>\n<BR>
		\n<A href='?src=\ref[src];viewrequests=1'>View requests</A><BR>\n<BR>
		\n<A href='?src=\ref[src];vieworders=1'>View orders</A><BR>\n<BR>
		\n<A href='?src=\ref[user];mach_close=computer'>Close</A>"}


	var/datum/browser/popup = new(user, "computer", "<div align='center'>Automated Storage and Retrieval System</div>", 575, 450)
	popup.set_content(dat)
	popup.open(FALSE)
	onclose(user, "computer")


/obj/machinery/computer/supplycomp/attackby(I as obj, user as mob)
	if(istype(I,/obj/item/card/emag) && !hacked)
		to_chat(user, "<span class='notice'>Special supplies unlocked.</span>")
		hacked = 1
		return
	else
		..()
	return

/obj/machinery/computer/supplycomp/Topic(href, href_list)
	if(..())
		return

	if(isturf(loc) && ( in_range(src, usr) || issilicon(usr) ) )
		usr.set_interaction(src)

	//Calling the shuttle
	if(href_list["send"])
		if(SSshuttle.supply.mode == SHUTTLE_IDLE && is_mainship_level(SSshuttle.supply.z))
			if (!SSshuttle.supply.check_blacklist())
				temp = "For safety reasons, the Automated Storage and Retrieval System cannot store live, non-xeno organisms, classified nuclear weaponry or homing beacons.<BR><BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"
				playsound(SSshuttle.supply.return_center_turf(), 'sound/machines/buzz-two.ogg', 50, 0)
			else
				playsound(SSshuttle.supply.return_center_turf(), 'sound/machines/elevator_move.ogg', 50, 0)
				SSshuttle.moveShuttle("supply", "supply_away", TRUE)
				temp = "Lowering platform. \[<span class='warning'><A href='?src=\ref[src];force_send=1'>Force</A></span>\]<BR><BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"
		else
			var/obj/docking_port/D = SSshuttle.getDock("supply_home")
			playsound(D.return_center_turf(), 'sound/machines/elevator_move.ogg', 50, 0)
			SSshuttle.moveShuttle("supply", "supply_home", TRUE)
			temp = "Raising platform.<BR><BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"

	//if (href_list["force_send"])
		//shuttle.force_launch(src)

	//if (href_list["cancel_send"])
		//shuttle.cancel_launch(src)

	else if (href_list["order"])
		//if(!shuttle.idle()) return	//this shouldn't be necessary it seems
		if(href_list["order"] == "categories")
			//all_supply_groups
			//Request what?
			last_viewed_group = "categories"
			temp = "<b>Supply points: [round(SSpoints.supply_points)]</b><BR>"
			temp += "<A href='?src=\ref[src];mainmenu=1'>Main Menu</A><HR><BR><BR>"
			temp += "<b>Select a category</b><BR><BR>"
			for(var/supply_group_name in all_supply_groups )
				temp += "<A href='?src=\ref[src];order=[supply_group_name]'>[supply_group_name]</A><BR>"
		else
			last_viewed_group = href_list["order"]
			temp = "<b>Supply points: [round(SSpoints.supply_points)]</b><BR>"
			temp += "<A href='?src=\ref[src];order=categories'>Back to all categories</A><HR><BR><BR>"
			temp += "<b>Request from: [last_viewed_group]</b><BR><BR>"
			for(var/supply_type in SSshuttle.supply_packs )
				var/datum/supply_packs/N = SSshuttle.supply_packs[supply_type]
				if((N.hidden && !hacked) || (N.contraband && !can_order_contraband) || N.group != last_viewed_group) continue								//Have to send the type instead of a reference to
				temp += "<A href='?src=\ref[src];doorder=[N.name]'>[N.name]</A> Cost: [round(N.cost)]<BR>"		//the obj because it would get caught by the garbage

		/*temp = "Supply points: [round(SSpoints.supply_points)]<BR><HR><BR>Request what?<BR><BR>"
		for(var/supply_name in supply_controller.supply_packs )
			var/datum/supply_packs/N = supply_controller.supply_packs[supply_name]
			if(N.hidden && !hacked) continue
			if(N.contraband && !can_order_contraband) continue
			temp += "<A href='?src=\ref[src];doorder=[supply_name]'>[supply_name]</A> Cost: [N.cost]<BR>"    //the obj because it would get caught by the garbage
		temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"*/

	else if (href_list["doorder"])
		if(world.time < reqtime)
			for(var/mob/V in hearers(src))
				V.show_message("<b>[src]</b>'s monitor flashes, \"[world.time - reqtime] seconds remaining until another requisition form may be printed.\"")
			return

		//Find the correct supply_pack datum
		var/datum/supply_packs/P = SSshuttle.supply_packs[href_list["doorder"]]
		if(!istype(P))	return

		var/timeout = world.time + 600
		//var/reason = copytext(sanitize(input(usr,"Reason:","Why do you require this item?","") as null|text),1,MAX_MESSAGE_LEN)
		var/reason = "*None Provided*"
		if(world.time > timeout)	return
		if(!reason)	return

		var/idname = "*None Provided*"
		var/idrank = "*None Provided*"
		if(ishuman(usr))
			var/mob/living/carbon/human/H = usr
			idname = H.get_authentification_name()
			idrank = H.get_assignment()
		else if(issilicon(usr))
			idname = usr.real_name

		SSshuttle.ordernum++
		var/obj/item/paper/reqform = new /obj/item/paper(loc)
		reqform.name = "Requisition Form - [P.name]"
		reqform.info += "<h3>[CONFIG_GET(string/ship_name)] Supply Requisition Form</h3><hr>"
		reqform.info += "INDEX: #[SSshuttle.ordernum]<br>"
		reqform.info += "REQUESTED BY: [idname]<br>"
		reqform.info += "RANK: [idrank]<br>"
		reqform.info += "REASON: [reason]<br>"
		reqform.info += "SUPPLY CRATE TYPE: [P.name]<br>"
		reqform.info += "ACCESS RESTRICTION: [oldreplacetext(get_access_desc(P.access))]<br>"
		reqform.info += "CONTENTS:<br>"
		reqform.info += P.manifest
		reqform.info += "<hr>"
		reqform.info += "STAMP BELOW TO APPROVE THIS REQUISITION:<br>"

		reqform.update_icon()	//Fix for appearing blank when printed.
		reqtime = (world.time + 5) % 1e5

		//make our supply_order datum
		var/datum/supply_order/O = new /datum/supply_order()
		O.id = SSshuttle.ordernum
		O.pack = P
		O.orderer = idname
		SSshuttle.requestlist += O

		temp = "Order request placed.<BR>"
		temp += "<BR><A href='?src=\ref[src];order=[last_viewed_group]'>Back</A>|<A href='?src=\ref[src];mainmenu=1'>Main Menu</A>|<A href='?src=\ref[src];confirmorder=[O.id]'>Authorize Order</A>"

	else if(href_list["confirmorder"])
		//Find the correct supply_order datum
		var/ordernum = text2num(href_list["confirmorder"])
		var/datum/supply_order/O
		var/datum/supply_packs/P
		temp = "Invalid Request"
		temp += "<BR><A href='?src=\ref[src];order=[last_viewed_group]'>Back</A>|<A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"

		if(SSshuttle.shoppinglist.len > 20)
			to_chat(usr, "<span class='warning'>Current retrieval load has reached maximum capacity.</span>")
			return

		for(var/i in SSshuttle.requestlist)
			var/datum/supply_order/SO = i
			if(SO.id == ordernum)
				O = SO
				P = O.pack
				if(SSpoints.supply_points >= round(P.cost))
					log_game("[key_name(usr)] approved the [P.name] supply pack.")
					SSshuttle.requestlist -= SO
					SSpoints.supply_points -= round(P.cost)
					SSshuttle.shoppinglist += O
					P.cost = P.cost * SUPPLY_COST_MULTIPLIER
					temp = "Thank you for your order.<BR>"
					temp += "<BR><A href='?src=\ref[src];viewrequests=1'>Back</A> <A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"
				else
					temp = "Not enough supply points.<BR>"
					temp += "<BR><A href='?src=\ref[src];viewrequests=1'>Back</A> <A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"
				break

	else if (href_list["vieworders"])
		temp = "Current approved orders: <BR><BR>"
		for(var/S in SSshuttle.shoppinglist)
			var/datum/supply_order/SO = S
			temp += "#[SO.id] - [SO.pack.name] approved by [SO.orderer][SO.reason ? " ([SO.reason])":""]<BR>"// <A href='?src=\ref[src];cancelorder=[S]'>(Cancel)</A><BR>"
		temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"
/*
	else if (href_list["cancelorder"])
		var/datum/supply_order/remove_supply = href_list["cancelorder"]
		supply_shuttle_shoppinglist -= remove_supply
		supply_shuttle_points += remove_supply.object.cost
		temp += "Canceled: [remove_supply.object.name]<BR><BR><BR>"
		for(var/S in supply_shuttle_shoppinglist)
			var/datum/supply_order/SO = S
			temp += "[SO.object.name] approved by [SO.orderedby][SO.comment ? " ([SO.comment])":""] <A href='?src=\ref[src];cancelorder=[S]'>(Cancel)</A><BR>"
		temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"
*/
	else if (href_list["viewrequests"])
		temp = "Current requests: <BR><BR>"
		for(var/S in SSshuttle.requestlist)
			var/datum/supply_order/SO = S
			temp += "#[SO.id] - [SO.pack.name] requested by [SO.orderer] <A href='?src=\ref[src];confirmorder=[SO.id]'>Approve</A> <A href='?src=\ref[src];rreq=[SO.id]'>Remove</A><BR>"

		temp += "<BR><A href='?src=\ref[src];clearreq=1'>Clear list</A>"
		temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"

	else if (href_list["rreq"])
		var/ordernum = text2num(href_list["rreq"])
		temp = "Invalid Request.<BR>"
		for(var/i in SSshuttle.requestlist)
			var/datum/supply_order/SO = i
			if(SO.id == ordernum)
				SSshuttle.requestlist -= SO
				temp = "Request removed.<BR>"
				break
		temp += "<BR><A href='?src=\ref[src];viewrequests=1'>Back</A> <A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"

	else if (href_list["clearreq"])
		SSshuttle.requestlist.Cut()
		temp = "List cleared.<BR>"
		temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"

	else if (href_list["mainmenu"])
		temp = null

	updateUsrDialog()
	return
