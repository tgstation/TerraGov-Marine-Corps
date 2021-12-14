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
