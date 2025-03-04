/obj/machinery/power/apc/update_appearance(updates=check_updates())
	icon_update_needed = FALSE
	if(!updates)
		return
	. = ..()
	// And now, separately for cleanness, the lighting changing
	if(!update_state)
		switch(charging)
			if(APC_NOT_CHARGING)
				set_light_color(LIGHT_COLOR_RED)
			if(APC_CHARGING)
				set_light_color(LIGHT_COLOR_BLUE)
			if(APC_FULLY_CHARGED)
				set_light_color(LIGHT_COLOR_GREEN)
		set_light(initial(light_range))
		return
	set_light(0)

/obj/machinery/power/apc/update_icon_state()
	. = ..()

	var/broken = CHECK_BITFIELD(update_state, UPSTATE_BROKE) ? "-b" : ""
	var/status = (CHECK_BITFIELD(update_state, UPSTATE_WIREEXP) && !CHECK_BITFIELD(update_state, UPSTATE_OPENED1)) ? "-wires" : broken
	icon_state = "apc[opened][status]"

/obj/machinery/power/apc/update_overlays()
	. = ..()

	if(opened && cell)
		. += "apco-cell"

	if((machine_stat & (BROKEN|MAINT)) || update_state)
		return

	. += emissive_appearance(icon, "apcox-[locked]", src)
	. += mutable_appearance(icon, "apcox-[locked]")
	. += emissive_appearance(icon, "apco3-[charging]", src)
	. += mutable_appearance(icon, "apco3-[charging]")

	. += emissive_appearance(icon, "apco0-[operating ? equipment : 0]", src)
	. += mutable_appearance(icon, "apco0-[operating ? equipment : 0]")
	. += emissive_appearance(icon, "apco1-[operating ? lighting : 0]", src)
	. += mutable_appearance(icon, "apco1-[operating ? lighting : 0]")
	. += emissive_appearance(icon, "apco2-[operating ? environ : 0]", src)
	. += mutable_appearance(icon, "apco2-[operating ? environ : 0]")

/// Checks for what icon updates we will need to handle
/obj/machinery/power/apc/proc/check_updates()
	SIGNAL_HANDLER
	. = NONE

	// Handle icon status:
	var/new_update_state = NONE
	if(machine_stat & BROKEN)
		new_update_state |= UPSTATE_BROKE
	if(machine_stat & MAINT)
		new_update_state |= UPSTATE_MAINT

	if(opened)
		new_update_state |= (opened << UPSTATE_COVER_SHIFT)

	else if(CHECK_BITFIELD(machine_stat, PANEL_OPEN))
		new_update_state |= UPSTATE_WIREEXP

	if(new_update_state != update_state)
		update_state = new_update_state
		. |= UPDATE_ICON_STATE

	// Handle overlay status:
	var/new_update_overlay = NONE
	if(operating)
		new_update_overlay |= UPOVERLAY_OPERATING

	if(!update_state)
		if(locked)
			new_update_overlay |= UPOVERLAY_LOCKED

		new_update_overlay |= (charging << UPOVERLAY_CHARGING_SHIFT)
		new_update_overlay |= (equipment << UPOVERLAY_EQUIPMENT_SHIFT)
		new_update_overlay |= (lighting << UPOVERLAY_LIGHTING_SHIFT)
		new_update_overlay |= (environ << UPOVERLAY_ENVIRON_SHIFT)

	if(new_update_overlay != update_overlay)
		update_overlay = new_update_overlay
		. |= UPDATE_OVERLAYS

/obj/machinery/power/apc/proc/queue_icon_update()
	icon_update_needed = TRUE
