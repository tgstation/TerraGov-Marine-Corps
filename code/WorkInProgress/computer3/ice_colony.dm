
//ice colony computer3

//TESTING
/datum/file/program/door_control
	name = "Door control"
	desc = "This program can control doors on range."
	active_state = "comm_log"
	var/id = null
	var/range = 10
	var/normaldoorcontrol = CONTROL_POD_DOORS
		//0 = Pod Doors
		//1 = Normal Doors
		//2 = Emmiters
	var/desiredstate = 0
		//0 = Closed
		//1 = Open
		//2 = Toggle
	var/specialfunctions = 1
		//Bitflag, 	1 = Open
		//			2 = IDscan
		//			4 = Bolts
		//			8 = Shock
		//			16 = Door safties
	var/door_name = "" // Used for data only
	var/action_name = "" // Used for button name

/datum/file/program/door_control/interact()
	if(!interactable())
		return

	var/dat = ""
	dat += "<b>[door_name]</b> access control"
	dat += "<br><b>Controls: </b>"
	dat += "<br><b>[topic_link(src,"doorcontrol","[action_name]")]"
	popup.set_content(dat)
	popup.open()

/datum/file/program/door_control/proc/handle_door()
	for(var/obj/machinery/door/airlock/D in range(range))
		if(D.id_tag == src.id)
			if(specialfunctions & OPEN)
				if (D.density)
					spawn(0)
						D.open()
						return
				else
					spawn(0)
						D.close()
						return
			switch(desiredstate)
				//Close
				if(0)
					if(specialfunctions & IDSCAN)
						D.aiDisabledIdScanner = 0
					if(specialfunctions & BOLTS)
						if(!D.isWireCut(4) && D.arePowerSystemsOn())
							D.unlock()
					if(specialfunctions & SHOCK)
						D.secondsElectrified = 0
					if(specialfunctions & SAFE)
						D.safe = 1
				//Open
				if(1)
					if(specialfunctions & IDSCAN)
						D.aiDisabledIdScanner = 1
					if(specialfunctions & BOLTS)
						D.lock()
					if(specialfunctions & SHOCK)
						D.secondsElectrified = -1
					if(specialfunctions & SAFE)
						D.safe = 0
				//Toggle
				if(2)
					if(specialfunctions & IDSCAN && D.aiDisabledIdScanner == 0)
						D.aiDisabledIdScanner = 1
					else
						D.aiDisabledIdScanner = 0
					if(specialfunctions & BOLTS && D.locked == 0)
						D.lock()
					else
						D.unlock()
					if(specialfunctions & SHOCK && D.secondsElectrified == 0)
						D.secondsElectrified = -1
					else
						D.secondsElectrified = 0
					if(specialfunctions & SAFE && D.safe == 0)
						D.safe = 1
					else
						D.safe = 0

/datum/file/program/door_control/proc/handle_pod()
	for(var/obj/machinery/door/poddoor/M in machines)
		if(M.id == src.id)
			if(M.density)
				spawn(0)
					M.open()
					return
			else
				spawn(0)
					M.close()
					return

/datum/file/program/door_control/proc/handle_emitters()
	for(var/obj/machinery/power/emitter/E in range(range))
		if(E.id == src.id)
			spawn(0)
				E.activate()
				return

/datum/file/program/door_control/Topic(href, list/href_list)
	if(!interactable() || ..(href,href_list))
		return
	..()
	if ("doorcontrol" in href_list)
		switch(normaldoorcontrol)
			if(CONTROL_NORMAL_DOORS)
				handle_door()
			if(CONTROL_POD_DOORS)
				handle_pod()
			//if(CONTROL_EMITTERS)
				//handle_emitters()



//ICE LAPTOPS
//Generic Ice planet laptop
/obj/machinery/computer3/laptop/ice_planet
	spawn_parts = list(/obj/item/computer3_part/storage/hdd, /obj/item/computer3_part/storage/removable)


//XENOBIO LAB-----
//-----Laptop-----
/obj/machinery/computer3/laptop/ice_planet/xenobio_lab

	New()
		..()
		spawn_files += (/datum/file/program/data/text/xenobio_log)
		update_spawn_files()

//-----Xenobio Lab Research Reports
/datum/file/program/data/text/xenobio_log
	name = "Xenobio Research Report"
	extension = "txt"
	image = 'icons/ntos/file.png'
	dat = "text goes here!"
	active_state = "text"



//ANOMALY LAB-----
//-----Laptop-----
/obj/machinery/computer3/laptop/ice_planet/anomaly_lab

	New()
		..()
		spawn_files += (/datum/file/program/data/text/anomaly_log)
		update_spawn_files()

//-----Anomaly Lab Research Reports
/datum/file/program/data/text/anomaly_log
	name = "Anomaly Research Report"
	extension = "txt"
	image = 'icons/ntos/file.png'
	dat = "text goes here!"
	active_state = "text"

//ACES LAB-----
//-----Laptop-----
/obj/machinery/computer3/laptop/ice_planet/aces_lab

	New()
		..()
		spawn_files += (/datum/file/program/data/text/aces_log)
		spawn_files += (/datum/file/program/door_control/aces_storage)
		update_spawn_files()

/obj/item/disk/file/test
	spawn_files = list(/datum/file/program/door_control/aces_storage)

//-----ACES Research Reports
/datum/file/program/data/text/aces_log
	name = "ACES Research Reports"
	extension = "txt"
	image = 'icons/ntos/file.png'
	dat = "<b><font face=\"verdana\" color=\"green\">ACES Research Reports</font></b><br>"
	active_state = "text"
	logs = list(
				"Research Log I" = "<b><font face=\"verdana\" color=\"green\">Research Log I</font></b><br><br>This log is very nice looking!"
				)


//-----ACES Storage Access Program
/datum/file/program/door_control/aces_storage
	name = "ACES Storage Access"
	desc = "This program can control doors on range."
	active_state = "comm_log"
	id = "aces_secure"
	range = 20
	normaldoorcontrol = 0
	desiredstate = 2
	specialfunctions = 1
	door_name = "ACES Lab Storage Secure Door"
	action_name = "Toggle Door"

//-----PaperWork-----


//RD OFFICE-----
//-----Laptop-----
/obj/machinery/computer3/laptop/ice_planet/rd

	New()
		..()
		spawn_files += (/datum/file/program/data/text/rd_log)
		spawn_files += (/datum/file/program/door_control/armory)
		update_spawn_files()

//-----Research Director Reports
/datum/file/program/data/text/rd_log
	name = "Research Director's Report"
	extension = "txt"
	image = 'icons/ntos/file.png'
	dat = "text goes here!"
	active_state = "text"

//-----Armory Access Program
/datum/file/program/door_control/armory
	name = "Armory Access"
	desc = "This program can control doors on range."
	active_state = "comm_log"
	id = "armory_secure"
	range = 20
	normaldoorcontrol = 0
	desiredstate = 2
	specialfunctions = 1
	door_name = "Armory Secure Door"
	action_name = "Toggle Door"
