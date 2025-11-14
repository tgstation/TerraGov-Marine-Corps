/obj/machinery/portable_atmospherics
	name = "portable_atmospherics"
	icon = 'icons/obj/machines/atmos.dmi'
	use_power = NO_POWER_USE
	max_integrity = 250
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, BIO = 100, FIRE = 60, ACID = 30)
	anchored = FALSE

	/// The port we are currently connected to
	var/obj/machinery/atmospherics/components/unary/portables_connector/connected_port
	/// The gas tank we are currently holding inside us
	var/obj/item/tank/holding

/obj/machinery/portable_atmospherics/Initialize(mapload)
	. = ..()
	SSair.atmos_machinery += src

/obj/machinery/portable_atmospherics/Destroy()
	SSair.atmos_machinery -= src
	holding = null
	disconnect()
	return ..()

/obj/machinery/portable_atmospherics/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return
	if(!istype(I, /obj/item/tank))
		return
	holding = I
	user.temporarilyRemoveItemFromInventory(I)
	I.forceMove(src)
	update_icon()

/obj/machinery/portable_atmospherics/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	if(!holding)
		return
	balloon_alert(user, "pried [holding] out")
	playsound(src, 'sound/items/crowbar.ogg', 25, 1)
	holding.forceMove(drop_location())
	holding = null
	update_icon()

/obj/machinery/portable_atmospherics/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	if(!connected_port)
		var/obj/machinery/atmospherics/components/unary/portables_connector/new_port = locate() in drop_location()
		connect(user, new_port)
		return
	disconnect(user)

/// Connect the machine to a port
/obj/machinery/portable_atmospherics/proc/connect(mob/user, obj/machinery/atmospherics/components/unary/portables_connector/new_port)
	//Make sure not already connected to something else
	if(connected_port || !new_port || new_port.connected_device)
		return FALSE

	//Make sure are close enough for a valid connection
	if(new_port.loc != get_turf(src))
		return FALSE

	//Perform the connection
	connected_port = new_port
	connected_port.connected_device = src

	anchored = TRUE //Prevent movement
	pixel_x = new_port.pixel_x
	pixel_y = new_port.pixel_y
	update_icon()

	playsound(src, 'sound/items/ratchet.ogg', 25, TRUE)
	if(user)
		balloon_alert(user, "connected to [new_port]")

	return TRUE

/obj/machinery/portable_atmospherics/Moved(atom/old_loc, movement_dir, forced, list/old_locs)
	. = ..()
	disconnect()

/// Disconnect the machine from a port
/obj/machinery/portable_atmospherics/proc/disconnect(mob/user)
	if(!connected_port)
		return FALSE
	anchored = FALSE
	connected_port.connected_device = null
	connected_port = null
	pixel_x = initial(pixel_x)
	pixel_y = initial(pixel_y)
	update_icon()

	playsound(src, 'sound/items/ratchet.ogg', 25, TRUE)
	if(user)
		balloon_alert(user, "disconnected")

	return TRUE

/obj/machinery/portable_atmospherics/examine(mob/user)
	. = ..()
	if(holding)
		. += span_notice("\The [src] contains [holding]. Alt-click [src] to remove it.")
		. += span_notice("Click [src] with another gas tank to hot swap [holding].")
