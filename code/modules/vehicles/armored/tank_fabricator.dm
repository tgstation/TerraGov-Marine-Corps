/obj/machinery/tank_part_fabricator
	name = "vehicle part fabricator"
	desc = "A large automated 3D printer for producing new vehicle parts and maintaining old ones."
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	icon = 'icons/obj/machines/drone_fab.dmi'
	icon_state = "drone_fab_idle"
	var/datum/supply_ui/vehicles/SU

/obj/machinery/tank_part_fabricator/interact(mob/user)
	. = ..()
	if(.)
		return
	if(!allowed(user))
		return
	if(!SU)
		SU = new(src)
		SU.shuttle_id = SHUTTLE_VEHICLE_SUPPLY
		SU.home_id = "vehicle_home"
		SU.faction = FACTION_TERRAGOV
	return SU.interact(user)
