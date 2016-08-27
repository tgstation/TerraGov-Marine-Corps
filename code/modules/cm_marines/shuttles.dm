/obj/machinery/computer/shuttle_control/
	var/alerted = 1

/obj/machinery/computer/shuttle_control/marine1
	name = "Dropship Console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	shuttle_tag = "Dropship 1"
	unacidable = 1
	exproof = 1
	req_one_access_txt = "22;200"


/obj/machinery/computer/shuttle_control/marine2
	name = "Drop Pod Console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	shuttle_tag = "Dropship 2"
	unacidable = 1
	exproof = 1
	req_one_access_txt = "12;22;200"


/obj/structure/engine_startup_sound // An invisible object to generate shuttle sounds
	name = "engine_startup_sound"
	unacidable = 1
	anchored = 1
	invisibility = 101
	layer = 1.5

	ex_act(severity) //nope
		return

/obj/structure/engine_landing_sound // An invisible object to generate shuttle sounds that sits on the ground where the shuttle lands. This object is ignored when the Move proc moves the shuttles around. Place it somewhere in the center of where a shuttle will land.
	name = "engine_landing_sound"
	unacidable = 1
	anchored = 1
	invisibility = 101
	layer = 1.5

	ex_act(severity) //nope
		return

/obj/structure/engine_inside_sound // The invisible object to generate shuttle sounds that stays inside the shuttle as it moves. Players inside the shuttle will hear the landing sound before it touches down.
	name = "engine_inside_sound"
	unacidable = 1
	anchored = 1
	invisibility = 101
	layer = 1.5

	ex_act(severity) //nope
		return
