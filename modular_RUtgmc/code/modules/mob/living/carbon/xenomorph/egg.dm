
/obj/alien/egg/hugger/Initialize(mapload, hivenumber)
	. = ..()
	GLOB.xeno_egg_hugger += src

/obj/alien/egg/hugger/Destroy()
	GLOB.xeno_egg_hugger -= src
	return ..()


//Observers can become playable facehuggers by clicking on the egg
/obj/alien/egg/hugger/attack_ghost(mob/dead/observer/user)
	. = ..()

	var/datum/hive_status/hive = GLOB.hive_datums[hivenumber]
	if(!hive.can_spawn_as_hugger(user))
		return FALSE

	if(maturity_stage != stage_ready_to_burst)
		balloon_alert(user, "Not fully grown")
		return FALSE
	if(!hugger_type)
		balloon_alert(user, "Empty")
		return FALSE

	advance_maturity(stage_ready_to_burst + 1)
	for(var/turf/turf_to_watch AS in filled_turfs(src, trigger_size, "circle", FALSE))
		UnregisterSignal(turf_to_watch, COMSIG_ATOM_ENTERED)
	playsound(loc, "sound/effects/alien_egg_move.ogg", 25)
	flick("egg opening", src)

	var/mob/living/carbon/xenomorph/facehugger/new_hugger = new(loc)
	new_hugger.transfer_to_hive(hivenumber)
	hugger_type = null
	addtimer(CALLBACK(new_hugger, TYPE_PROC_REF(/mob/living, transfer_mob), user), 1 SECONDS)
	return TRUE

//Sentient facehugger can get in the egg
/obj/alien/egg/hugger/attack_facehugger(mob/living/carbon/xenomorph/facehugger/F, isrightclick = FALSE)
	. = ..()

	if(tgui_alert(F, "Do you want to get into the egg?", "Get inside the egg", list("Yes", "No")) != "Yes")
		return

	if(!insert_new_hugger(new /obj/item/clothing/mask/facehugger/larval()))
		F.balloon_alert(F, span_xenowarning("We can't use this egg"))
		return

	F.visible_message(span_xenowarning("[F] slides back into [src]."),span_xenonotice("You slides back into [src]."))
	F.ghostize()
	F.death(deathmessage = "get inside the egg", silent = TRUE)
	qdel(F)
