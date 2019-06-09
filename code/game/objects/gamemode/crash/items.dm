/obj/machinery/nuclearbomb/crash
	deployable = TRUE

/obj/machinery/nuclearbomb/crash/explode()
	. = ..()
	if (iscrashgamemode(SSticker.mode))
		var/datum/game_mode/crash/C = SSticker.mode
		C.planet_nuked = TRUE

/obj/machinery/nuclearbomb/crash/make_deployable()
	set hidden = TRUE

