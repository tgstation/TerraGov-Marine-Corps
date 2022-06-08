/obj/machinery/portable_atmospherics
	name = "portable_atmospherics"
	icon = 'icons/obj/machines/atmos.dmi'
	use_power = NO_POWER_USE
	max_integrity = 250
	soft_armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 100, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 60, "acid" = 30)
	anchored = FALSE

	var/datum/gas_mixture/air_contents
	var/obj/machinery/atmospherics/components/unary/portables_connector/connected_port
	var/obj/item/tank/holding

	var/volume = 0

	var/maximum_pressure = 90 * ONE_ATMOSPHERE

/obj/machinery/portable_atmospherics/Initialize()
	. = ..()
	SSair.atmos_machinery += src

/obj/machinery/portable_atmospherics/Destroy()
	SSair.atmos_machinery -= src
	disconnect()
	return ..()

/obj/machinery/portable_atmospherics/proc/connect(obj/machinery/atmospherics/components/unary/portables_connector/new_port)
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
	return TRUE

/obj/machinery/portable_atmospherics/Moved(atom/old_loc, movement_dir, forced, list/old_locs)
	. = ..()
	disconnect()

/obj/machinery/portable_atmospherics/proc/disconnect()
	if(!connected_port)
		return FALSE
	anchored = FALSE
	connected_port.connected_device = null
	connected_port = null
	pixel_x = 0
	pixel_y = 0
	return TRUE

/obj/machinery/portable_atmospherics/examine(mob/user)
	. = ..()
	if(holding)
		. += span_notice("\The [src] contains [holding]. Alt-click [src] to remove it.")
		. += span_notice("Click [src] with another gas tank to hot swap [holding].")
