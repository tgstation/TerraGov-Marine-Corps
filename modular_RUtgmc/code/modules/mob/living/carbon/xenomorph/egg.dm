
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

/obj/alien/egg/gas
	desc = "It looks like a suspiciously weird egg"
	name = "gas egg"
	icon = 'modular_RUtgmc/icons/Xeno/Effects.dmi'
	icon_state = "egg_gas"

/obj/alien/egg/gas/update_icon_state()
	. = ..()
	if(maturity_stage > stage_ready_to_burst)
		return
	switch(gas_type)
		if(/datum/effect_system/smoke_spread/xeno/neuro/medium)
			icon_state = "egg_gas_n2"
		if(/datum/effect_system/smoke_spread/xeno/ozelomelyn)
			icon_state = "egg_gas_o2"
		if(/datum/effect_system/smoke_spread/xeno/hemodile)
			icon_state = "egg_gas_h2"
		if(/datum/effect_system/smoke_spread/xeno/transvitox)
			icon_state = "egg_gas_t2"
		if(/datum/effect_system/smoke_spread/xeno/acid/light)
			icon_state = "egg_gas_a2"
	if(hivenumber != XENO_HIVE_NORMAL && GLOB.hive_datums[hivenumber])
		var/datum/hive_status/hive = GLOB.hive_datums[hivenumber]
		color = hive.color
		return
	color = null

/obj/alien/egg/gas/burst(via_damage)
	. = ..()
	if(!.)
		return
	var/spread = EGG_GAS_DEFAULT_SPREAD
	if(via_damage) // More violent destruction, more gas.
		playsound(loc, "sound/effects/alien_egg_burst.ogg", 30)
		flick("egg gas exploding", src)
		spread = EGG_GAS_KILL_SPREAD
	else
		playsound(src.loc, "sound/effects/alien_egg_move.ogg", 25)
		flick("egg gas opening", src)
	spread += gas_size_bonus

	var/datum/effect_system/smoke_spread/xeno/NS = new gas_type(src)
	NS.set_up(spread, get_turf(src))
	NS.start()

