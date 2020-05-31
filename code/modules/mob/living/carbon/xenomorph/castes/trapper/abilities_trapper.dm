// ***************************************
// *********** Xeno Sensor
// ***************************************
/datum/action/xeno_action/sensor
	name = "Place sensor"
	action_icon_state = "sensor"
	mechanics_text = "Place a sensor on weeds to get an alert when a host passes by it."
	plasma_cost = 400

/datum/action/xeno_action/sensor/can_use_action(silent = FALSE, override_flags)
	. = ..()
	var/turf/T = get_turf(owner)
	if(!T || !T.is_weedable() || T.density)
		if(!silent)
			to_chat(owner, "<span class='warning'>We can't do that here.</span>")
		return FALSE

	if(!(locate(/obj/effect/alien/weeds) in T))
		if(!silent)
			to_chat(owner, "<span class='warning'>We can only shape on weeds. We must find some resin before we start building!</span>")
		return FALSE

	if(!T.check_alien_construction(owner, silent))
		return FALSE

	if(locate(/obj/effect/alien/weeds/node) in T)
		if(!silent)
			to_chat(owner, "<span class='warning'>There is a resin node in the way!</span>")
		return FALSE
		
/datum/action/xeno_action/sensor/action_activate()
	var/turf/T = get_turf(owner)

	succeed_activate()

	playsound(T, "alien_resin_build", 25)
	new /obj/effect/alien/resin/sensor(T, owner)
	to_chat(owner, "<span class='xenonotice'>We place a hugger trap on the weeds, it still needs a facehugger.</span>")

// ***************************************
// *********** Xeno Tripwire
// ***************************************
/datum/action/xeno_action/tripwire
	name = "Place tripwire"
	action_icon_state = "tripwire"
	mechanics_text = "Place a tripwire that notifies you when a host trips over it."
	plasma_cost = 100

/datum/action/xeno_action/tripwire/can_use_action(silent = FALSE, override_flags)
	. = ..()
	var/turf/T = get_turf(owner)
	if(!T || !T.is_weedable() || T.density)
		if(!silent)
			to_chat(owner, "<span class='warning'>We can't do that here.</span>")
		return FALSE

	if(!(locate(/obj/effect/alien/weeds) in T))
		if(!silent)
			to_chat(owner, "<span class='warning'>We can only shape on weeds. We must find some resin before we start building!</span>")
		return FALSE

	if(!T.check_alien_construction(owner, silent))
		return FALSE

	if(locate(/obj/effect/alien/weeds/node) in T)
		if(!silent)
			to_chat(owner, "<span class='warning'>There is a resin node in the way!</span>")
		return FALSE
		
/datum/action/xeno_action/tripwire/action_activate()
	var/turf/T = get_turf(owner)

	succeed_activate()

	playsound(T, "alien_resin_build", 25)
	new /obj/effect/alien/resin/tripwire(T, owner)
	to_chat(owner, "<span class='xenonotice'>We place a hugger trap on the weeds, it still needs a facehugger.</span>")