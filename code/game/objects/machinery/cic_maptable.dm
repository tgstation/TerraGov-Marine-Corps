/obj/machinery/cic_maptable
	name = "map table"
	desc = "A table that displays a map of the current target location"
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "maptable"
	interaction_flags = INTERACT_MACHINE_DEFAULT
	use_power = IDLE_POWER_USE
	density = TRUE
	idle_power_usage = 2
	///flags that we want to be shown when you interact with this table
	var/allowed_flags = MINIMAP_FLAG_MARINE
	///by default Zlevel 2, groundside is targetted
	var/targetted_zlevel = 2
	///minimap obj ref that we will display to users
	var/obj/screen/minimap/map

/obj/machinery/cic_maptable/Destroy()
	map = null
	return ..()

/obj/machinery/cic_maptable/interact(mob/user)
	. = ..()
	if(.)
		return
	if(!user.client)
		return
	if(!map)
		map = SSminimaps.fetch_minimap_object(targetted_zlevel, allowed_flags)
	user.client.screen += map

/obj/machinery/cic_maptable/on_unset_interaction(mob/user)
	. = ..()
	user.client.screen -= map
