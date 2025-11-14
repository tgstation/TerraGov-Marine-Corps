/obj/machinery/tank_part_fabricator
	name = "vehicle part fabricator"
	desc = "A large automated 3D printer for producing new vehicle parts and maintaining old ones."
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	req_access = list(ACCESS_MARINE_ARMORED)
	idle_power_usage = 20
	bound_width = 64
	icon = 'icons/obj/machines/drone_fab.dmi'
	icon_state = "drone_fab_idle"
	resistance_flags = RESIST_ALL
	/// actual UI that will be interacted with
	var/datum/supply_ui/vehicles/supply_ui

/obj/machinery/tank_part_fabricator/interact(mob/user)
	. = ..()
	if(.)
		return
	if(!allowed(user))
		return
	if(!supply_ui)
		supply_ui = new(src)
		supply_ui.shuttle_id = SHUTTLE_VEHICLE_SUPPLY
		supply_ui.home_id = "vehicle_home"
		supply_ui.faction = FACTION_TERRAGOV
	return supply_ui.interact(user)
