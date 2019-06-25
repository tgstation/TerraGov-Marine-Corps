/obj/machinery/nuclearbomb/crash
	deployable = TRUE

/obj/machinery/nuclearbomb/crash/proc/set_victory_condition()
	if (iscrashgamemode(SSticker.mode))
		var/datum/game_mode/crash/C = SSticker.mode
		C.planet_nuked = TRUE

/obj/machinery/nuclearbomb/crash/explode()
	. = ..()
	addtimer(CALLBACK(src, .proc/set_victory_condition), 45 SECONDS) // TODO: Refine the time here.
	

/obj/machinery/nuclearbomb/crash/make_deployable()
	set hidden = TRUE

