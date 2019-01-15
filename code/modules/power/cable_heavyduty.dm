/obj/item/stack/cable_coil/heavyduty
	name = "heavy cable coil"
	icon = 'icons/obj/power.dmi'
	icon_state = "wire"

/obj/structure/cable/heavyduty
	icon = 'icons/obj/power_cond_heavy.dmi'
	name = "large power cable"
	desc = "This cable is tough. It cannot be cut with simple hand tools."
	layer = BELOW_ATMOS_PIPE_LAYER

/obj/structure/cable/heavyduty/attackby(obj/item/W, mob/user)

	var/turf/T = src.loc
	if(T.intact_tile)
		return

	if(istype(W, /obj/item/tool/wirecutters))
		to_chat(usr, "\blue These cables are too tough to be cut with those [W.name].")
		return
	else if(istype(W, /obj/item/stack/cable_coil))
		to_chat(usr, "\blue You will need heavier cables to connect to these.")
		return
	else
		..()

/obj/structure/cable/heavyduty/cableColor(var/colorC)
	return