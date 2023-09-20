//effects are placed on maps but only generate objectives for applicable missions, so maps can be valid for multiple missions if desired.
/obj/effect/landmark/campaign_objective
	name = "GENERIC CAMPAIGN STRUCTURE"
	desc = "THIS SHOULDN'T BE VISIBLE"
	icon = 'icons/obj/structures/campaign_structures.dmi'
	///Missions that trigger this landmark to spawn an objective
	var/list/mission_types
	///Objective spawned by this landmark
	var/obj/structure/campaign_objective/objective_type

/obj/effect/landmark/campaign_objective/Initialize(mapload)
	. = ..()
	var/datum/game_mode/hvh/campaign/mode = SSticker.mode
	if(!istype(mode))
		return
	var/datum/campaign_mission/current_mission = mode.current_mission
	if(current_mission.type in mission_types)
		new objective_type(loc)
	qdel(src)


/obj/structure/campaign_objective
	name = "GENERIC CAMPAIGN STRUCTURE"
	desc = "THIS SHOULDN'T BE VISIBLE"
	density = TRUE
	anchored = TRUE
	allow_pass_flags = PASSABLE
	destroy_sound = 'sound/effects/meteorimpact.ogg'

	icon = 'icons/obj/structures/campaign_structures.dmi'

/obj/structure/campaign_objective/Initialize(mapload)
	. = ..()
	GLOB.campaign_objectives += src
	SSminimaps.add_marker(src, MINIMAP_FLAG_ALL, image('icons/UI_icons/map_blips.dmi', null, "campaign_objective"))

/obj/structure/campaign_objective/Destroy()
	disable()
	return ..()

///Handles the objective being destroyed, disabled or otherwise completed
/obj/structure/campaign_objective/proc/disable()
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CAMPAIGN_OBJECTIVE_DESTROYED, src)
	GLOB.campaign_objectives -= src

/obj/structure/campaign_objective/destruction_objective
	name = "GENERIC CAMPAIGN DESTRUCTION OBJECTIVE"
	soft_armor = list(MELEE = 200, BULLET = 200, LASER = 200, ENERGY = 200, BOMB = 200, BIO = 200, FIRE = 200, ACID = 200) //require c4 normally

/obj/effect/landmark/campaign_objective/howitzer_objective
	name = "howitzer objective"
	icon = 'icons/Marine/howitzer.dmi'
	icon_state = "howitzer_deployed"
	mission_types = list(/datum/campaign_mission/destroy_mission/fire_support_raid)
	objective_type = /obj/structure/campaign_objective/destruction_objective/howitzer

/obj/structure/campaign_objective/destruction_objective/howitzer
	name = "\improper TA-100Y howitzer"
	desc = "A manual, crew-operated and towable howitzer, will rain down 150mm laserguided and accurate shells on any of your foes."
	icon = 'icons/Marine/howitzer.dmi'
	icon_state = "howitzer_deployed"
	pixel_x = -16

/obj/effect/landmark/campaign_objective/bluespace_core
	name = "Bluespace Core objective"
	icon = 'icons/obj/machines/bluespacedrive.dmi'
	icon_state = "bsd_core"
	pixel_y = -18
	pixel_x = -16
	mission_types = list(/datum/campaign_mission/destroy_mission/teleporter_raid)
	objective_type = /obj/structure/campaign_objective/destruction_objective/bluespace_core

#define BLUESPACE_CORE_OK "bluespace_core_ok"
#define BLUESPACE_CORE_UNSTABLE "bluespace_core_unstable"
#define BLUESPACE_CORE_BROKEN "bluespace_core_broken"

/obj/structure/campaign_objective/destruction_objective/bluespace_core
	name = "\improper Bluespace Teleportation Displacement Core"
	desc = "An incredibly sophisticated piece of bluespace technology that is the engine behind any number of quantum entangled bluespace teleporter devices in the system."
	icon = 'icons/obj/machines/bluespacedrive.dmi'
	icon_state = "bsd_core"
	bound_height = 64
	bound_width = 64
	pixel_y = -18
	pixel_x = -16
	var/status = BLUESPACE_CORE_OK

/obj/structure/campaign_objective/destruction_objective/bluespace_core/Initialize(mapload)
	. = ..()
	update_icon()

/obj/structure/campaign_objective/destruction_objective/bluespace_core/update_icon_state()
	. = ..()
	if(status == BLUESPACE_CORE_BROKEN)
		icon_state = "bsd_core_broken"
	else
		icon_state = "bsd_core"

/obj/structure/campaign_objective/destruction_objective/bluespace_core/update_overlays()
	. = ..()
	switch(status)
		if(BLUESPACE_CORE_OK)
			. += image(icon, icon_state = "top_overlay", layer = ABOVE_MOB_LAYER)
			. += image(icon, icon_state = "bsd_c_s", layer = TANK_BARREL_LAYER)
		if(BLUESPACE_CORE_UNSTABLE)
			. += image(icon, icon_state = "top_overlay", layer = ABOVE_MOB_LAYER)
			. += image(icon, icon_state = "bsd_c_u", layer = TANK_BARREL_LAYER)
		if(BLUESPACE_CORE_BROKEN)
			. += image(icon, icon_state = "top_overlay_broken", layer = ABOVE_MOB_LAYER)

///Changes the status of the object
/obj/structure/campaign_objective/destruction_objective/bluespace_core/proc/change_status(new_status)
	if(status == new_status)
		return
	status = new_status
	update_icon()
	if(status == BLUESPACE_CORE_BROKEN)
		disable()

#define CAPTURE_OBJECTIVE_RECAPTURABLE "capture_objective_recapturable"

//capturable objectives
/obj/structure/campaign_objective/capture_objective
	name = "GENERIC CAPTURABLE OBJECTIVE"
	resistance_flags = RESIST_ALL
	///Channel time to capture or activate this objective
	var/capture_time = 10 SECONDS
	///Special capture behavior flags for this objectives
	var/capture_flags = NONE
	///Who controls this objective. Mainly used for objectives that can be recaptured
	var/owning_faction

/obj/structure/campaign_objective/capture_objective/attack_hand(mob/living/user)
	if(!ishuman(user))
		return
	if(user.stat)
		return
	if(!capture_check(user))
		return
	if(user.do_actions)
		user.balloon_alert(user, "You are already doing something!")
		return
	begin_capture(user)

///Starts the capture process
/obj/structure/campaign_objective/capture_objective/proc/begin_capture(mob/living/user)
	user.balloon_alert_to_viewers("Activating!")
	if(!do_after(user, capture_time, TRUE, src))
		return
	if(!capture_check(user))
		return
	do_capture(user)

///Checks if this objective can be captured
/obj/structure/campaign_objective/capture_objective/proc/capture_check(mob/living/user)
	if(owning_faction)
		if(owning_faction == user.faction)
			user.balloon_alert(user, "Already yours!")
			return FALSE
		if(!(capture_flags & CAPTURE_OBJECTIVE_RECAPTURABLE))
			user.balloon_alert(user, "Cannot recaptured!")
			return FALSE
	return TRUE

///Captures or activates the objective
/obj/structure/campaign_objective/capture_objective/proc/do_capture(mob/living/user)
	SHOULD_CALL_PARENT(TRUE)
	owning_faction = user.faction
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CAMPAIGN_CAPTURE_OBJECTIVE_CAPTURED, src, user)

/obj/effect/landmark/campaign_objective/phoron_crate
	name = "phoron crate objective"
	icon = 'icons/obj/structures/campaign_structures.dmi'
	icon_state = "orebox_phoron"
	mission_types = list(/datum/campaign_mission/capture_mission)
	objective_type = /obj/structure/campaign_objective/capture_objective/fultonable

/obj/structure/campaign_objective/capture_objective/fultonable
	name = "phoron crate"
	desc = "A crate packed full of valuable phoron, ready to claim."
	icon_state = "orebox_phoron"

/obj/structure/campaign_objective/capture_objective/fultonable/do_capture(mob/living/user)
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

/obj/effect/landmark/campaign_objective/asat_system
	name = "ASAT system"
	icon = 'icons/obj/structures/campaign_structures.dmi'
	icon_state = "asat"
	mission_types = list(/datum/campaign_mission/capture_mission/asat)
	objective_type = /obj/structure/campaign_objective/capture_objective/fultonable/asat_system

/obj/structure/campaign_objective/capture_objective/fultonable/asat_system
	name = "\improper T-4000 ASAT system"
	icon = 'icons/obj/structures/campaign_structures.dmi'
	icon_state = "asat"
	desc = "A sophisticated surface to space missile system designed for attacking orbiting satellites or spacecraft."
	capture_time = 12 SECONDS
	capture_flags = CAPTURE_OBJECTIVE_RECAPTURABLE
	owning_faction = FACTION_TERRAGOV //this could have a coded solution, but the mission is tgmc specific
