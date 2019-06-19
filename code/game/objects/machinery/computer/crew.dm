#define DISPLAY_ON_SHIP    0
#define DISPLAY_PLANETSIDE 1
#define DISPLAY_IN_TRANSIT 2

/obj/machinery/computer/crew
	name = "Crew monitoring computer"
	desc = "Used to monitor active health sensors built into most of the crew's uniforms."
	icon_state = "crew"
	use_power = IDLE_POWER_USE
	idle_power_usage = 250
	active_power_usage = 500
//	circuit = "/obj/item/circuitboard/computer/crew"
	var/list/tracked = list()
	var/list/crewmembers_planetside = list()
	var/list/crewmembers_on_ship = list()
	var/list/crewmembers_in_transit = list()
	var/displayed_z_level = DISPLAY_ON_SHIP
	var/cmp_proc = /proc/cmp_list_asc
	var/sortkey = "name"


/obj/machinery/computer/crew/attack_ai(mob/living/user)
	attack_hand(user)
	ui_interact(user)


/obj/machinery/computer/crew/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(machine_stat & (BROKEN|NOPOWER))
		return
	ui_interact(user)


/obj/machinery/computer/crew/update_icon()
	if(machine_stat & BROKEN)
		icon_state = "crewb"
	else if(machine_stat & NOPOWER)
		icon_state = "crew0"
		machine_stat |= NOPOWER
	else
		icon_state = initial(icon_state)
		machine_stat &= ~NOPOWER

/obj/machinery/computer/crew/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if( href_list["close"] )
		var/mob/user = usr
		var/datum/nanoui/ui = SSnano.get_open_ui(user, src, "main")
		user.unset_interaction()
		ui.close()
		return FALSE
	if(href_list["update"])
		updateDialog()
		return TRUE
	if(href_list["sortkey"])
		if(sortkey == href_list["sortkey"])
			cmp_proc = (cmp_proc == /proc/cmp_list_asc) ? /proc/cmp_list_dsc : /proc/cmp_list_asc
		else
			sortkey = href_list["sortkey"]
			cmp_proc = /proc/cmp_list_asc
		return TRUE
	if(href_list["zlevel"])
		displayed_z_level = text2num(href_list["zlevel"])
		return TRUE

/obj/machinery/computer/crew/interact(mob/living/user)
	ui_interact(user)

/obj/machinery/computer/crew/ui_interact(mob/living/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = TRUE)
	if(machine_stat & (BROKEN|NOPOWER))
		return
	user.set_interaction(src)
	scan()

	var/list/data = list()
	crewmembers_on_ship.Cut()
	crewmembers_planetside.Cut()
	crewmembers_in_transit.Cut()

	for(var/obj/item/clothing/under/C in tracked)
		var/turf/pos = get_turf(C)

		if(C && pos)
			if(ishuman(C.loc))

				var/mob/living/carbon/human/H = C.loc

				if(issurvivor(H) && is_ground_level(H.loc.z))
					continue // survivors

				if(H.w_uniform != C)
					continue

				var/list/crewmemberData = list()

				crewmemberData["sensor_type"] = C.sensor_mode
				crewmemberData["status"] = "[H.stat]"
				crewmemberData["oxy"] = round(H.getOxyLoss(), 1)
				crewmemberData["tox"] = round(H.getToxLoss(), 1)
				crewmemberData["fire"] = round(H.getFireLoss(), 1)
				crewmemberData["brute"] = round(H.getBruteLoss(), 1)

				crewmemberData["name"] = "Unknown"
				crewmemberData["rank"] = "Unknown"
				if(H.wear_id && istype(H.wear_id, /obj/item/card/id) )
					var/obj/item/card/id/I = H.wear_id
					crewmemberData["name"] = I.name
					crewmemberData["rank"] = I.rank

				var/area/A = get_area(H)
				crewmemberData["area"] = sanitize(A.name)
				crewmemberData["x"] = pos.x
				crewmemberData["y"] = pos.y

				if(is_ground_level(pos.z))
					crewmembers_planetside += list(crewmemberData)
				else if(is_mainship_level(pos.z))
					crewmembers_on_ship += list(crewmemberData)
				else if(is_reserved_level(pos.z))
					crewmembers_in_transit += list(crewmemberData)

	switch(displayed_z_level)
		if(DISPLAY_ON_SHIP)
			data["crewmembers"] = sortListUsingKey(crewmembers_on_ship, cmp_proc, sortkey)
		if(DISPLAY_PLANETSIDE)
			data["crewmembers"] = sortListUsingKey(crewmembers_planetside, cmp_proc, sortkey)
		if(DISPLAY_IN_TRANSIT)
			data["crewmembers"] = sortListUsingKey(crewmembers_in_transit, cmp_proc, sortkey)

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "crew_monitor.tmpl", "Crew Monitoring Computer", 900, 800)

		// adding a template with the key "mapContent" enables the map ui functionality
//		ui.add_template("mapContent", "crew_monitor_map_content.tmpl")
		// adding a template with the key "mapHeader" replaces the map header content
//		ui.add_template("mapHeader", "crew_monitor_map_header.tmpl")

		ui.set_initial_data(data)
		ui.open()

		// should make the UI auto-update; doesn't seem to?
		ui.set_auto_update(TRUE)


/obj/machinery/computer/crew/proc/scan()
	for(var/mob/living/carbon/human/H in GLOB.human_mob_list)
		if(!H || !istype(H)) continue
		var/obj/item/clothing/under/C = H.w_uniform
		if(!C || !istype(C)) continue
		if(C.has_sensor && H.mind)
			tracked |= C
	return TRUE

#undef DISPLAY_ON_SHIP
#undef DISPLAY_PLANETSIDE
#undef DISPLAY_IN_TRANSIT