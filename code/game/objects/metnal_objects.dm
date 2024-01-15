// Metnal Operation objects, props, etc.
/obj/item/instrument/jukebox
	name = "jukebox"
	desc = "Wow, this thing is ancient!"
	icon = 'icons/obj/machines/metnal_objects.dmi'
	icon_state = "jukebox"
	allowed_instrument_ids = "r3celeste"

	var/use_power = IDLE_POWER_USE
	var/idle_power_usage = 0
	var/wrenchable = FALSE
	anchored = TRUE
	interaction_flags = INTERACT_MACHINE_DEFAULT
	use_power = IDLE_POWER_USE
	density = TRUE
	idle_power_usage = 2
	light_range = 2
	light_power = 0.5
	light_color = LIGHT_COLOR_CYAN
	var/screen_overlay = "jukebox_emissive"

	//work on this
