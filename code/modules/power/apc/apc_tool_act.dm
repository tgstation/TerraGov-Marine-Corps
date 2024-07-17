/obj/machinery/power/apc/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	if(opened)
		if(has_electronics == APC_ELECTRONICS_INSTALLED)
			if(terminal)
				balloon_alert(user, "Disconnect the wires")
				return
			if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_ENGI)
				balloon_alert_to_viewers("Fumbles around removing cell from [src]")
				var/fumbling_time = 5 SECONDS * ( SKILL_ENGINEER_ENGI - user.skills.getRating(SKILL_ENGINEER) )
				if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
					return
			I.play_tool_sound(src)
			balloon_alert(user, "Removing APC board")
			if(I.use_tool(src, user, 50))
				if(has_electronics == APC_ELECTRONICS_INSTALLED)
					has_electronics = APC_ELECTRONICS_MISSING
					if(machine_stat & BROKEN)
						balloon_alert_to_viewers("Removes the charred control board")
						return
					else
						balloon_alert_to_viewers("Removes the control board")
						new /obj/item/circuitboard/apc(loc)
						return
		else if(opened != APC_COVER_REMOVED)
			opened = APC_COVER_CLOSED
			coverlocked = TRUE //closing cover relocks it
			update_appearance()
			return
	else if(!(machine_stat & BROKEN))
		if(coverlocked && !(machine_stat & MAINT)) // locked...
			balloon_alert(user, "Locked")
			return
		else if(machine_stat & PANEL_OPEN)
			balloon_alert(user, "Can't, wires in way")
			return
		else
			opened = APC_COVER_OPENED
			update_appearance()
			return


/obj/machinery/power/apc/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(.)
		return TRUE
	. = TRUE
	if(opened)
		if(cell)
			if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_ENGI)
				balloon_alert_to_viewers("fumbles")
				var/fumbling_time = 5 SECONDS * ( SKILL_ENGINEER_ENGI - user.skills.getRating(SKILL_ENGINEER) )
				if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
					return
			balloon_alert_to_viewers("Removes cell")
			var/turf/T = get_turf(user)
			cell.forceMove(T)
			cell.update_appearance()
			set_cell(null)
			charging = APC_NOT_CHARGING
			update_appearance()
			return
		else
			switch(has_electronics)
				if(APC_ELECTRONICS_INSTALLED)
					has_electronics = APC_ELECTRONICS_SECURED
					machine_stat &= ~MAINT
					I.play_tool_sound(src)
					balloon_alert(user, "Screws circuit board in")
				if(APC_ELECTRONICS_SECURED)
					has_electronics = APC_ELECTRONICS_INSTALLED
					machine_stat |= MAINT
					I.play_tool_sound(src)
					balloon_alert(user, "Unfastens electronics")
				else
					balloon_alert(user, "Nothing securable")
					return
			update_appearance()
	else
		TOGGLE_BITFIELD(machine_stat, PANEL_OPEN)
		balloon_alert(user, "wires [CHECK_BITFIELD(machine_stat, PANEL_OPEN) ? "exposed" : "unexposed"]")
		update_appearance()


/obj/machinery/power/apc/wirecutter_act(mob/living/user, obj/item/I)
	if(terminal && opened)
		terminal.deconstruct(user)
		return TRUE


/obj/machinery/power/apc/welder_act(mob/living/user, obj/item/I)
	if(!opened || has_electronics || terminal)
		return

	if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_ENGI)
		balloon_alert_to_viewers("fumbles")
		var/fumbling_time = 5 SECONDS * ( SKILL_ENGINEER_ENGI - user.skills.getRating(SKILL_ENGINEER) )
		if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
			return

	if(!I.tool_start_check(user, amount = 3))
		return
	balloon_alert_to_viewers("welds [src]")

	if(!I.use_tool(src, user, 50, volume = 50, amount = 3))
		return

	if((machine_stat & BROKEN) || opened == APC_COVER_REMOVED)
		new /obj/item/stack/sheet/metal(loc)
		balloon_alert_to_viewers("cuts apart [src]")
	else
		new /obj/item/frame/apc(loc)
		balloon_alert_to_viewers("cuts [src] from the wall")
	qdel(src)
	return TRUE

