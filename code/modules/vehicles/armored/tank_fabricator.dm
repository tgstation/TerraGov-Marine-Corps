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
	faction = FACTION_TERRAGOV // NTF edit - faction tanks
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
		supply_ui.faction = faction
	return supply_ui.interact(user)

/obj/machinery/tank_part_fabricator/som
	req_access = list(ACCESS_SOM_ASSAULT) // Temporary access
	faction = FACTION_SOM
	var/datum/supply_ui/vehicles/som/som_supply_ui

/obj/machinery/tank_part_fabricator/som/interact(mob/user)
	if(!allowed(user))
		return
	if(!som_supply_ui)
		som_supply_ui = new(src)
		som_supply_ui.shuttle_id = SHUTTLE_SOM_VEHICLE_SUPPLY
		som_supply_ui.home_id = "som_vehicle_home"
		som_supply_ui.faction = faction
	return som_supply_ui.interact(user)
