/obj/machinery/computer/shuttle_control/
	var/alerted = 1

/obj/machinery/computer/shuttle_control/marine1
	name = "Dropship Console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	shuttle_tag = "Dropship 1"
	unacidable = 1
	exproof = 1
	req_one_access_txt = "1;2;12;19;200"


/obj/machinery/computer/shuttle_control/marine2
	name = "Drop Pod Console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	shuttle_tag = "Dropship 2"
	unacidable = 1
	exproof = 1
	req_one_access_txt = "1;2;12;19;200"


/obj/structure/enginesound // An invisible object to generate shuttle sounds
	name = "enginesound"
	unacidable = 1
	anchored = 1
	invisibility = 101

	ex_act(severity) //nope
		return
