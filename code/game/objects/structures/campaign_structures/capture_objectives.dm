#define CAPTURE_OBJECTIVE_RECAPTURABLE (1<<0)

/obj/structure/campaign_objective/capture_objective
	name = "GENERIC CAPTURABLE OBJECTIVE"
	resistance_flags = RESIST_ALL
	///Channel time to capture or activate this objective
	var/activation_time = 10 SECONDS
	///How long capture takes to come into effect, if applicable
	var/capture_delay = 30 SECONDS
	///Special capture behavior flags for this objectives
	var/capture_flags = NONE
	///Who controls this objective. Mainly used for objectives that can be recaptured
	var/owning_faction
	///Faction currently trying to change the objective's ownership
	var/capturing_faction
	///Timer holder for the current capture/decapture timer
	var/capture_timer

/obj/structure/campaign_objective/capture_objective/Initialize(mapload)
	. = ..()
	countdown = new(src)

/obj/structure/campaign_objective/capture_objective/Destroy()
	if(capture_timer)
		deltimer(capture_timer)
		capture_timer = null
	QDEL_NULL(countdown)
	return ..()

/obj/structure/campaign_objective/capture_objective/update_control_minimap_icon()
	SSminimaps.remove_marker(src)
	var/new_icon_state
	if(!owning_faction)
		switch(capturing_faction)
			if(FACTION_TERRAGOV)
				new_icon_state = "campaign_objective_capturing_tgmc"
			if(null)
				new_icon_state = "campaign_objective"
			else
				new_icon_state = "campaign_objective_capturing_som"
	else
		switch(owning_faction)
			if(FACTION_TERRAGOV)
				new_icon_state = capturing_faction ? "campaign_objective_decap_tgmc" : "campaign_objective_tgmc"
			else
				new_icon_state = capturing_faction ? "campaign_objective_decap_som" : "campaign_objective_som"

	SSminimaps.add_marker(src, MINIMAP_FLAG_ALL, image('icons/UI_icons/map_blips.dmi', null, new_icon_state, MINIMAP_LABELS_LAYER))

/obj/structure/campaign_objective/capture_objective/attack_hand(mob/living/user)
	if(!ishuman(user))
		return
	if(user.stat)
		return
	if(!capture_check(user))
		return
	if(user.do_actions)
		user.balloon_alert(user, "busy!")
		return
	begin_capture(user)

///Starts the capture process
/obj/structure/campaign_objective/capture_objective/proc/begin_capture(mob/living/user)
	user.balloon_alert_to_viewers("activating...")
	if(!do_after(user, activation_time, NONE, src))
		return
	if(!capture_check(user))
		return

	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CAMPAIGN_CAPTURE_OBJECTIVE_CAP_STARTED, src, user)
	if(capture_timer)
		deltimer(capture_timer)
		capture_timer = null
		countdown.stop()
	if(owning_faction == user.faction) //we already own it, we just stopped the enemy cap
		capturing_faction = null
		update_icon()
		return
	capturing_faction = user.faction
	update_icon()
	capture_timer = addtimer(CALLBACK(src, PROC_REF(do_capture), user), capture_delay, TIMER_STOPPABLE)
	countdown.start()

///Checks if this objective can be captured
/obj/structure/campaign_objective/capture_objective/proc/capture_check(mob/living/user)
	if(capturing_faction)
		if(capturing_faction == user.faction)
			user.balloon_alert(user, "already capturing!")
			return FALSE
		else
			return TRUE //someone else is trying to cap it, whether you already own it or not

	if(owning_faction)
		if(owning_faction == user.faction)
			user.balloon_alert(user, "already yours!")
			return FALSE
		if(!(capture_flags & CAPTURE_OBJECTIVE_RECAPTURABLE))
			user.balloon_alert(user, "can't recapture!")
			return FALSE
	return TRUE

///Tries to capture or decapture the objective
/obj/structure/campaign_objective/capture_objective/proc/do_capture(mob/living/user)
	capturing_faction = null
	capture_timer = null
	countdown.stop()

	if(owning_faction)
		if(owning_faction == user.faction)
			CRASH("objective captured by own faction")
		owning_faction = null
		update_icon()
		SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CAMPAIGN_CAPTURE_OBJECTIVE_DECAPTURED, src, user)
		if(user.ckey)
			var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[user.ckey]
			personal_statistics.mission_objective_decaptured ++
		return
	finish_capture(user)

///Fully captures or activates the objective
/obj/structure/campaign_objective/capture_objective/proc/finish_capture(mob/living/user)
	SHOULD_CALL_PARENT(TRUE)
	owning_faction = user.faction
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CAMPAIGN_CAPTURE_OBJECTIVE_CAPTURED, src, user)
	if(user.ckey)
		var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[user.ckey]
		personal_statistics.mission_objective_captured ++
	update_icon()

/obj/structure/campaign_objective/capture_objective/get_time_left()
	return capture_timer ? round(timeleft(capture_timer) MILLISECONDS) : null

//sensor tower
/obj/effect/landmark/campaign_structure/sensor_tower
	name = "sensor tower objective"
	icon = 'icons/obj/structures/sensor.dmi'
	icon_state = "sensor"
	mission_types = list(
		/datum/campaign_mission/tdm,
		/datum/campaign_mission/tdm/orion,
		/datum/campaign_mission/tdm/first_mission,
		/datum/campaign_mission/tdm/mech_wars,
		/datum/campaign_mission/tdm/mech_wars/som,
	)
	spawn_object = /obj/structure/campaign_objective/capture_objective/sensor_tower

/obj/structure/campaign_objective/capture_objective/sensor_tower
	name = "sensor tower"
	desc = "A tall tower with a sensor array at the top and a control box at the bottom. Used to hack into colony control."
	icon = 'icons/obj/structures/sensor.dmi'
	icon_state = "sensor"
	obj_flags = BLOCK_Z_OUT_DOWN|BLOCK_Z_IN_UP
	capture_flags = CAPTURE_OBJECTIVE_RECAPTURABLE

/obj/structure/campaign_objective/capture_objective/sensor_tower/Initialize(mapload)
	. = ..()
	countdown.pixel_x = 5
	countdown.pixel_y = 90

/obj/structure/campaign_objective/capture_objective/sensor_tower/update_icon_state()
	. = ..()
	icon_state = initial(icon_state)
	if(!owning_faction)
		switch(capturing_faction)
			if(FACTION_TERRAGOV)
				icon_state += "_cap_tgmc"
			if(null)
				return
			else
				icon_state += "_cap_som"
		return
	switch(owning_faction)
		if(FACTION_TERRAGOV)
			icon_state += capturing_faction ? "_decap_tgmc" : "_tgmc"
		else
			icon_state += capturing_faction ? "_decap_som" : "_som"

//fulton objectives = they qdel after being captured
/obj/effect/landmark/campaign_structure/phoron_crate
	name = "phoron crate objective"
	icon = 'icons/obj/structures/campaign_structures.dmi'
	icon_state = "orebox_phoron"
	mission_types = list(/datum/campaign_mission/capture_mission/phoron_capture)
	spawn_object = /obj/structure/campaign_objective/capture_objective/fultonable

/obj/structure/campaign_objective/capture_objective/fultonable
	name = "phoron crate"
	desc = "A crate packed full of valuable phoron, ready to claim."
	icon_state = "orebox_phoron"
	activation_time = 3 SECONDS
	capture_delay = 90 SECONDS

/obj/structure/campaign_objective/capture_objective/fultonable/finish_capture(mob/living/user)
	. = ..()
	var/obj/effect/fulton_extraction_holder/holder_obj = new(loc)
	var/atom/movable/vis_obj/fulton_balloon/balloon = new()
	holder_obj.appearance = appearance
	if(anchored)
		anchored = FALSE
	holder_obj.vis_contents += balloon

	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), get_turf(holder_obj), 'sound/items/fultext_deploy.ogg', 50, TRUE), 0.4 SECONDS)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), get_turf(holder_obj), 'sound/items/fultext_launch.ogg', 50, TRUE), 7.4 SECONDS)
	QDEL_IN(holder_obj, 8 SECONDS)
	QDEL_IN(balloon, 8 SECONDS)

	flick("fulton_expand", balloon)
	balloon.icon_state = "fulton_balloon"
	animate(holder_obj, pixel_z = 0, time = 0.4 SECONDS)
	animate(pixel_z = 10, time = 2 SECONDS)
	animate(pixel_z = 15, time = 1 SECONDS)
	animate(pixel_z = 10, time = 1 SECONDS)
	animate(pixel_z = 15, time = 1 SECONDS)
	animate(pixel_z = 10, time = 1 SECONDS)
	animate(pixel_z = SCREEN_PIXEL_SIZE, time = 1 SECONDS)

	user.visible_message(span_notice("[user] finishes attaching the fulton to [src] and activates it."),\
	span_notice("You attach a fulton to [src] and activate it."), null, 5)
	qdel(src)

/obj/effect/landmark/campaign_structure/asat_system
	name = "ASAT system"
	icon = 'icons/obj/structures/campaign/ASAT.dmi'
	icon_state = "silo"
	pixel_x = -26
	pixel_y = -7
	mission_types = list(/datum/campaign_mission/capture_mission/asat)
	spawn_object = /obj/structure/campaign_objective/capture_objective/asat_system

/obj/structure/campaign_objective/capture_objective/asat_system
	name = "\improper T-4000 ASAT system"
	icon = 'icons/obj/structures/campaign/ASAT.dmi'
	icon_state = "silo"
	desc = "A sophisticated surface to space missile system designed for attacking orbiting satellites or spacecraft."
	bound_height = 64
	bound_width = 96
	bound_x = -32
	pixel_x = -26
	pixel_y = -7
	capture_flags = CAPTURE_OBJECTIVE_RECAPTURABLE
	owning_faction = FACTION_TERRAGOV
	activation_time = 3 SECONDS
	capture_delay = 90 SECONDS

/obj/structure/campaign_objective/capture_objective/asat_system/capture_check(mob/living/user)
	//This is a 'defend' objective. The defending faction can't actually claim it for themselves, just decap it.
	if((user.faction == owning_faction) && !capturing_faction)
		user.balloon_alert(user, "defend this objective!")
		return FALSE
	return ..()

/obj/structure/campaign_objective/capture_objective/asat_system/do_capture(mob/living/user)
	capturing_faction = null
	capture_timer = null
	countdown.stop()
	finish_capture(user)

/obj/structure/campaign_objective/capture_objective/asat_system/finish_capture(mob/living/user)
	. = ..()
	playsound(loc, 'sound/magic/lightningbolt.ogg', 75, 0)
	new /obj/effect/temp_visual/teleporter_array(loc)
	visible_message(span_danger("Reality warps around [src] as the missile vanishes in a flash of light!"))
	capture_flags = NONE

/obj/structure/campaign_objective/capture_objective/asat_system/update_icon_state()
	icon_state = initial(icon_state)
	if(owning_faction == initial(owning_faction))
		return
	icon_state = "silo_empty"
