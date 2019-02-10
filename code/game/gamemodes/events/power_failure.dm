
/proc/power_failure(var/announce = TRUE)
	var/list/skipped_areas = list(/area/turret_protected/ai)

	for(var/obj/machinery/power/smes/S in GLOB.machines)
		var/area/current_area = get_area(S)
		if(current_area.type in skipped_areas || S.z != 3) // Ship only
			continue
		S.charge = 0
		S.output_level = 0
		S.outputting = FALSE
		S.update_icon()
		S.power_change()

	for(var/obj/machinery/power/apc/C in GLOB.machines)
		if(C.cell && C.z == 3)
			C.cell.charge = 0

	playsound_z(3, 'sound/effects/powerloss.ogg')

	sleep(100)
	if(announce)
		command_announcement.Announce("Abnormal activity detected in the ship power system. As a precaution, power must be shut down for an indefinite duration.", "Critical Power Failure", new_sound = 'sound/AI/poweroff.ogg')

/proc/power_restore(var/announce = TRUE)
	var/list/skipped_areas = list(/area/turret_protected/ai)

	for(var/obj/machinery/power/smes/S in GLOB.machines)
		var/area/current_area = get_area(S)
		if(current_area.type in skipped_areas || S.z != 3)
			continue
		S.charge = S.capacity
		S.output_level = S.output_level_max
		S.outputting = TRUE
		S.update_icon()
		S.power_change()

	for(var/obj/machinery/power/apc/C in GLOB.machines)
		if(C.cell && C.z == 3)
			C.cell.charge = C.cell.maxcharge

	sleep(100)
	if(announce)
		command_announcement.Announce("Power has been restored. Reason: Unknown.", "Power Systems Nominal", new_sound = 'sound/AI/poweron.ogg')

/proc/power_restore_quick(var/announce = 1)

	for(var/obj/machinery/power/smes/S in GLOB.machines)
		if(S.z != 3) // Ship only
			continue
		S.charge = S.capacity
		S.output_level = S.output_level_max
		S.outputting = TRUE
		S.update_icon()
		S.power_change()

	sleep(100)
	if(announce)
		command_announcement.Announce("Power has been restored. Reason: Unknown.", "Power Systems Nominal", new_sound = 'sound/AI/poweron.ogg')

/proc/power_restore_everything(var/announce = 1)

	for(var/obj/machinery/power/smes/S in GLOB.machines)
		S.charge = S.capacity
		S.output_level = S.output_level_max
		S.outputting = TRUE
		S.update_icon()
		S.power_change()

	for(var/obj/machinery/power/apc/C in GLOB.machines)
		if(C.cell)
			C.cell.charge = C.cell.maxcharge

	sleep(100)
	if(announce)
		command_announcement.Announce("Power has been restored. Reason: Unknown.", "Power Systems Nominal", new_sound = 'sound/AI/poweron.ogg')
