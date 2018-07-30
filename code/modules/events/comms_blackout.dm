
/proc/communications_blackout(var/silent = 1)

	if(!silent)
		command_announcement.Announce("Ionic radiation flare detected from nearby star. Imminent telecommunication failu*3mga;b4;'1v�-BZZZT", new_sound = 'sound/misc/interference.ogg')
	else // AIs will always know if there's a comm blackout, rogue AIs could then lie about comm blackouts in the future while they shutdown comms
		for(var/mob/living/silicon/ai/A in player_list)
			A << "<br>"
			A << "<span class='warning'><b>Ionic radiation flare detected from nearby star. Imminent telecommunication failu*3mga;b4;'1v�-BZZZT<b></span>"
			A << "<br>"
	for(var/obj/machinery/telecomms/T in telecomms_list)
		T.emp_act(1)
