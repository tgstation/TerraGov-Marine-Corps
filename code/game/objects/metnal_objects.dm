// Metnal Operation objects, props, etc.
/obj/item/instrument/jukebox
	name = "jukebox"
	desc = "Wow, this thing is ancient!"
	icon = 'icons/obj/items/metnal_objects.dmi'
	icon_state = "jukebox"
	allowed_instrument_ids = "r3celeste"

	var/use_power = IDLE_POWER_USE
	var/idle_power_usage = 0
	var/wrenchable = FALSE
	interaction_flags = INTERACT_MACHINE_DEFAULT
	use_power = IDLE_POWER_USE
	density = TRUE
	anchored = TRUE
	idle_power_usage = 2
	light_range = 2
	light_power = 0.5
	light_color = COLOR_PULSE_BLUE
	var/screen_overlay = "jukebox_emissive"
