/obj/machinery/refuel_station
	name = "refueling station"
	desc = "Used for bulk transfer of fuel to portable tanks. Push a fuel tank onto the station, then interact to fill it from the nearby fuel silo."
	icon = 'icons/obj/machines/chemical_machines.dmi'
	icon_state = "fuel_station"
	density = FALSE
	layer = ABOVE_MOB_LAYER
	///The adjacent CAS fuel tank used as the fuel source
	var/obj/structure/reagent_dispensers/fueltank/cas_fuel/cas_tank

/obj/machinery/refuel_station/Initialize(mapload)
	. = ..()
	find_cas_tank()

/obj/machinery/refuel_station/Destroy()
	if(cas_tank)
		UnregisterSignal(cas_tank, COMSIG_QDELETING)
	cas_tank = null
	return ..()

///Searches for an adjacent CAS fuel tank and links it as the fuel source
/obj/machinery/refuel_station/proc/find_cas_tank()
	if(cas_tank)
		UnregisterSignal(cas_tank, COMSIG_QDELETING)
	cas_tank = locate(/obj/structure/reagent_dispensers/fueltank/cas_fuel) in range(1, src)
	if(cas_tank)
		RegisterSignal(cas_tank, COMSIG_QDELETING, PROC_REF(on_cas_tank_destroyed))

///Called when the linked CAS fuel silo is destroyed; destroys this station as well
/obj/machinery/refuel_station/proc/on_cas_tank_destroyed(datum/source)
	qdel(src)

/obj/machinery/refuel_station/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	var/obj/structure/reagent_dispensers/fueltank/tank = locate(/obj/structure/reagent_dispensers/fueltank) in get_turf(src)
	if(!tank || istype(tank, /obj/structure/reagent_dispensers/fueltank/cas_fuel))
		if(cas_tank && !QDELETED(cas_tank) && cas_tank.reagents)
			to_chat(user, span_notice("Fuel silo connected: [cas_tank.reagents.total_volume] / [cas_tank.reagents.maximum_volume] units remaining. Push a fuel tank onto the station to refuel it."))
		else
			to_chat(user, span_warning("No fuel silo connected. Ensure a CAS fuel tank is adjacent to the station."))
		return
	transfer_fuel(tank, user)

/obj/machinery/refuel_station/attack_hand_alternate(mob/living/user)
	. = ..()
	if(.)
		return
	var/obj/structure/reagent_dispensers/fueltank/tank = locate(/obj/structure/reagent_dispensers/fueltank) in get_turf(src)
	if(!tank || istype(tank, /obj/structure/reagent_dispensers/fueltank/cas_fuel))
		to_chat(user, span_warning("No fuel tank in the station to drain."))
		return
	transfer_fuel(tank, user, draining = TRUE)

/**
 * Moves fuel between the CAS silo and the provided portable tank.
 * draining = FALSE (default): silo -> tank (refuel)
 * draining = TRUE:            tank -> silo (drain)
 */
/obj/machinery/refuel_station/proc/transfer_fuel(obj/structure/reagent_dispensers/fueltank/tank, mob/living/user, draining = FALSE)
	if(!cas_tank || QDELETED(cas_tank))
		find_cas_tank()
	if(!cas_tank || QDELETED(cas_tank))
		user.balloon_alert(user, "No fuel silo nearby!")
		return
	var/datum/reagents/source = draining ? tank.reagents : cas_tank.reagents
	var/datum/reagents/dest   = draining ? cas_tank.reagents : tank.reagents
	if(!source?.total_volume)
		user.balloon_alert(user, draining ? "Tank is empty!" : "Fuel silo is empty!")
		return
	if(!dest)
		return
	if(dest.total_volume >= dest.maximum_volume)
		user.balloon_alert(user, draining ? "Fuel silo is full!" : "Tank already full!")
		return
	var/space = dest.maximum_volume - dest.total_volume
	var/transferred = source.trans_to(draining ? cas_tank : tank, space)
	if(transferred > 0)
		playsound(src, 'sound/effects/refill.ogg', 25, 1, 3)
		if(draining)
			user.balloon_alert(user, "Drained ([cas_tank.reagents.total_volume]/[cas_tank.reagents.maximum_volume]u in silo)")
		else
			user.balloon_alert(user, "Refueled ([tank.reagents.total_volume]/[tank.reagents.maximum_volume]u)")
	else
		user.balloon_alert(user, "Transfer failed!")
