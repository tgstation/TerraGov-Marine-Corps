/obj/machinery/computer/crew
	name = "Crew monitoring computer"
	desc = "Used to monitor active health sensors built into most of the crew's uniforms."
	icon_state = "crew"
	use_power = IDLE_POWER_USE
	idle_power_usage = 250
	active_power_usage = 500
//	circuit = "/obj/item/circuitboard/computer/crew"
	var/list/tracked = list()
	var/list/crewmembers = list()


/obj/machinery/computer/crew/New()
	tracked = list()
	..()

/obj/machinery/computer/crew/attack_ai(mob/living/user)
	attack_hand(user)
	ui_interact(user)


/obj/machinery/computer/crew/attack_hand(mob/living/user)
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER))
		return
	ui_interact(user)


/obj/machinery/computer/crew/update_icon()

	if(stat & BROKEN)
		icon_state = "crewb"
	else
		if(stat & NOPOWER)
			icon_state = "crew0"
			stat |= NOPOWER
		else
			icon_state = initial(icon_state)
			stat &= ~NOPOWER


/obj/machinery/computer/crew/Topic(href, href_list)
	if(..()) return
	if( href_list["close"] )
		var/mob/user = usr
		var/datum/nanoui/ui = nanomanager.get_open_ui(user, src, "main")
		user.unset_interaction()
		ui.close()
		return 0
	if(href_list["update"])
		updateDialog()
		return 1

/obj/machinery/computer/crew/interact(mob/living/user)
	ui_interact(user)

/obj/machinery/computer/crew/ui_interact(mob/living/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	if(stat & (BROKEN|NOPOWER))
		return
	user.set_interaction(src)
	scan()

	var/data[0]
	crewmembers = list()

	for(var/obj/item/clothing/under/C in tracked)

		var/turf/pos = get_turf(C)

		if(C && pos)
			if(istype(C.loc, /mob/living/carbon/human))

				var/mob/living/carbon/human/H = C.loc
				if(H.mind.special_role && H.loc.z == 1) continue // survivors
				if(H.w_uniform != C)
					continue

				var/list/crewmemberData = list()

				crewmemberData["sensor_type"] = C.sensor_mode
				crewmemberData["dead"] = H.stat > 1
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
				else if(H.wear_id && istype(H.wear_id, /obj/item/device/pda) )
					var/obj/item/device/pda/P = H.wear_id
					crewmemberData["name"] = (P.id ? P.id.name : "Unknown")
					crewmemberData["rank"] = (P.id ? P.id.rank : "Unknown")

				var/area/A = get_area(H)
				crewmemberData["area"] = sanitize(A.name)
//				crewmemberData["x"] = pos.x
//				crewmemberData["y"] = pos.y

				// Works around list += list2 merging lists; it's not pretty but it works
				crewmembers += "temporary item"
				crewmembers[crewmembers.len] = crewmemberData

	data["crewmembers"] = sortRecord(crewmembers, "name")

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "crew_monitor.tmpl", "Crew Monitoring Computer", 900, 800)

		// adding a template with the key "mapContent" enables the map ui functionality
//		ui.add_template("mapContent", "crew_monitor_map_content.tmpl")
		// adding a template with the key "mapHeader" replaces the map header content
//		ui.add_template("mapHeader", "crew_monitor_map_header.tmpl")

		ui.set_initial_data(data)
		ui.open()

		// should make the UI auto-update; doesn't seem to?
		ui.set_auto_update(1)


/obj/machinery/computer/crew/proc/scan()
	for(var/mob/living/carbon/human/H in mob_list)
		if(!H || !istype(H)) continue
		if(isYautja(H)) continue
		var/obj/item/clothing/under/C = H.w_uniform
		if(!C || !istype(C)) continue
		if(C.has_sensor && H.mind)
			tracked |= C
	return 1
