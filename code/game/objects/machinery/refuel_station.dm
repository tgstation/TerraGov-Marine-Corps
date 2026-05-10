/obj/machinery/refuel_station
	name = "refueling station"
	desc = "Used for bulk transfer of fuel to portable tanks. Push a fuel tank onto the station, then interact to fill it from the nearby fuel silo."
	icon = 'icons/obj/machines/chemical_machines.dmi'
	icon_state = "fuel_station"
	density = FALSE
	layer = ABOVE_MOB_LAYER
	///The adjacent CAS fuel tank used as the fuel source
	var/obj/structure/reagent_dispensers/fueltank/cas_fuel/cas_tank

/// Locates and links the adjacent CAS fuel tank on startup.
/obj/machinery/refuel_station/Initialize(mapload)
	. = ..()
	find_cas_tank()

/// Clears station fuel tank references during deletion.
/obj/machinery/refuel_station/Destroy()
	cas_tank = null
	return ..()

/// Finds the adjacent CAS tank and updates deletion signal tracking.
/obj/machinery/refuel_station/proc/find_cas_tank()
	if(cas_tank)
		UnregisterSignal(cas_tank, COMSIG_QDELETING)
	cas_tank = locate(/obj/structure/reagent_dispensers/fueltank/cas_fuel) in range(1, src)
	if(cas_tank)
		RegisterSignal(cas_tank, COMSIG_QDELETING, PROC_REF(on_cas_tank_destroyed))

/// Deletes the station when its linked CAS tank is deleted.
/obj/machinery/refuel_station/proc/on_cas_tank_destroyed(datum/source)
	qdel(src)

/// Handles normal interaction and refuels a tank on the station.
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

/// Handles alternate interaction and drains a station tank back into the silo.
/obj/machinery/refuel_station/attack_hand_alternate(mob/living/user)
	. = ..()
	if(.)
		return
	var/obj/structure/reagent_dispensers/fueltank/tank = locate(/obj/structure/reagent_dispensers/fueltank) in get_turf(src)
	if(!tank || istype(tank, /obj/structure/reagent_dispensers/fueltank/cas_fuel))
		to_chat(user, span_warning("No fuel tank in the station to drain."))
		return
	transfer_fuel(tank, user, draining = TRUE)

/// Transfers fuel between the silo and station tank depending on direction.
/obj/machinery/refuel_station/proc/transfer_fuel(obj/structure/reagent_dispensers/fueltank/tank, mob/living/user, draining = FALSE)
	if(QDELETED(cas_tank))
		find_cas_tank()
	if(QDELETED(cas_tank))
		user.balloon_alert(user, "No fuel silo nearby!")
		return
	var/obj/structure/reagent_dispensers/fueltank/source = draining ? tank : cas_tank
	var/obj/structure/reagent_dispensers/fueltank/destination = draining ? cas_tank : tank
	destination.try_refuel(source, source.get_fueltype(), user)
