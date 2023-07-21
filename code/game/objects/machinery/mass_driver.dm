/obj/machinery/mass_driver
	name = "mass driver"
	desc = "The finest in spring-loaded piston toy technology, now on an installation near you."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "mass_driver"
	var/power = 1
	var/id = 1
	var/drive_range = 10

/obj/machinery/mass_driver/proc/drive(amount)
	if(machine_stat & (BROKEN|NOPOWER))
		return
	use_power(active_power_usage)
	var/O_limit
	var/atom/target = get_edge_target_turf(src, dir)
	for(var/atom/movable/O in loc)
		if(!O.anchored)
			if(ismob(O) && !isliving(O))
				continue
			O_limit++
			if(O_limit >= 20)
				audible_message(span_notice("[src] lets out a screech, it doesn't seem to be able to handle the load."))
				break
			use_power(active_power_usage)
			O.throw_at(target, drive_range * power, power, spin = TRUE)
	flick("mass_driver1", src)

/obj/machinery/mass_driver/indestructible
	resistance_flags = INDESTRUCTIBLE|UNACIDABLE
