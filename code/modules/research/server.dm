/obj/machinery/rnd/server
	name = "R&D Server"
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "server"
	req_access = list(ACCESS_MARINE_CMO)


/obj/machinery/rnd/server/centcom
	name = "Centcom Central R&D Database"


/obj/machinery/computer/rdservercontrol
	name = "R&D Server Controller"
	icon_state = "rdcomp"
	circuit = /obj/item/circuitboard/computer/rdservercontrol


/obj/machinery/rnd/server/robotics
	name = "Robotics R&D Server"


/obj/machinery/rnd/server/core
	name = "Core R&D Server"

/obj/machinery/rnd/server/core/alt
	icon_state = "server_alt"
