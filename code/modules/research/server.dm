/obj/machinery/r_n_d/server
	name = "R&D Server"
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "server"
	req_access = list(ACCESS_MARINE_CMO)


/obj/machinery/r_n_d/server/centcom
	name = "Centcom Central R&D Database"


/obj/machinery/computer/rdservercontrol
	name = "R&D Server Controller"
	icon_state = "rdcomp"
	circuit = /obj/item/circuitboard/computer/rdservercontrol


/obj/machinery/r_n_d/server/robotics
	name = "Robotics R&D Server"


/obj/machinery/r_n_d/server/core
	name = "Core R&D Server"

/obj/machinery/r_n_d/server/core/alt
	icon_state = "server_alt"
