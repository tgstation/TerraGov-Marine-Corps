/obj/machinery/computer/shuttle/labor
	name = "labor shuttle console"
	desc = ""
	circuit = /obj/item/circuitboard/computer/labor_shuttle
	shuttleId = "laborcamp"
	possible_destinations = "laborcamp_home;laborcamp_away"
	req_access = list(ACCESS_BRIG)


/obj/machinery/computer/shuttle/labor/one_way
	name = "prisoner shuttle console"
	desc = ""
	possible_destinations = "laborcamp_away"
	circuit = /obj/item/circuitboard/computer/labor_shuttle/one_way
	req_access = list( )

/obj/machinery/computer/shuttle/labor/one_way/Topic(href, href_list)
	if(href_list["move"])
		var/obj/docking_port/mobile/M = SSshuttle.getShuttle("laborcamp")
		if(!M)
			to_chat(usr, "<span class='warning'>Cannot locate shuttle!</span>")
			return 0
		var/obj/docking_port/stationary/S = M.get_docked()
		if(S && S.name == "laborcamp_away")
			to_chat(usr, "<span class='warning'>Shuttle is already at the outpost!</span>")
			return 0
	..()
