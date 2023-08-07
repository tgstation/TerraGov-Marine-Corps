/datum/fire_support
	///Fire support name
	var/name = "misc firesupport"
	///icon_state for radial menu
	var/icon_state
	///define name of the firesupport, used for assoc
	var/fire_support_type
	///How frequently this canbe used
	var/cooldown_duration = 2 MINUTES
	///Holder for the cooldown timer
	var/cooldown_timer
	///Number of uses available. Negative for no limit
	var/uses = -1
	///How far the fire support can land from the target turf
	var/scatter_range = 6
	///How many impacts per use
	var/impact_quantity = 1
	///Chat message when initiating fire support
	var/initiate_chat_message = "TARGET ACQUIRED. FIRE SUPPORT INBOUND."
	///screentext message when initiating fire support
	var/initiate_screen_message = "fire support inbound."
	///Screentext message title
	var/initiate_title = "Garuda-1"
	///Portrait used for screentext message
	var/portrait_type = /atom/movable/screen/text/screen_text/picture/potrait/pilot
	///Initiating sound effect
	var/initiate_sound = 'sound/effects/dropship_sonic_boom.ogg'
	///Delay between initiation and impact
	var/delay_to_impact = 4 SECONDS
	///visual when impact starts
	var/start_visual = /obj/effect/temp_visual/dropship_flyby
	///sound when impact starts
	var/start_sound = 'sound/effects/casplane_flyby.ogg'

///Initiates fire support proc chain
/datum/fire_support/proc/initiate_fire_support(turf/target_turf, mob/user)
	if(!uses)
		to_chat(user, span_notice("FIRE SUPPORT UNAVAILABLE"))
		return
	uses --
	addtimer(CALLBACK(src, PROC_REF(start_fire_support), target_turf), delay_to_impact)

	if(initiate_sound)
		playsound(target_turf, initiate_sound, 100)
	if(initiate_chat_message)
		to_chat(user, span_notice(initiate_chat_message))
	if(portrait_type && initiate_screen_message && initiate_title)
		user.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>[initiate_title]</u></span><br>" + initiate_screen_message, portrait_type)

///Actually begins the fire support attack
/datum/fire_support/proc/start_fire_support(turf/target_turf)
	cooldown_timer = addtimer(VARSET_CALLBACK(src, cooldown_timer, null), cooldown_duration)
	select_target(target_turf)

	if(start_visual)
		new start_visual(target_turf)
	if(start_sound)
		playsound(target_turf, start_sound, 100)

///Selects the final target turf(s) and calls impact procs
/datum/fire_support/proc/select_target(turf/target_turf)
	var/list/turf_list = list()
	for(var/turf/spread_turf in RANGE_TURFS(scatter_range, target_turf))
		turf_list += spread_turf
	for(var/i = 1 to impact_quantity)
		var/turf/impact_turf = pick(turf_list)
		addtimer(CALLBACK(src, PROC_REF(do_impact), impact_turf), 0.15 SECONDS * i)

///The actual impact of the fire support
/datum/fire_support/proc/do_impact(turf/target_turf)
	return

/datum/fire_support/gau
	name = "gun run"
	fire_support_type = FIRESUPPORT_TYPE_GUN
	fire_support_flags
	impact_quantity = 5
	icon_state = "gau"
	initiate_chat_message = "TARGET ACQUIRED GUN RUN INBOUND."
	initiate_screen_message = "Target received, gun run inbound."

/datum/fire_support/gau/do_impact(turf/target_turf)
	var/revdir = REVERSE_DIR(NORTH)
	for(var/i=0 to 2)
		target_turf = get_step(target_turf, revdir)
	var/list/strafelist = list(target_turf)
	strafelist += get_step(target_turf, turn(NORTH, 90))
	strafelist += get_step(target_turf, turn(NORTH, -90)) //Build this list 3 turfs at a time for strafe_turfs
	for(var/b=0 to 6)
		target_turf = get_step(target_turf, NORTH)
		strafelist += target_turf
		strafelist += get_step(target_turf, turn(NORTH, 90))
		strafelist += get_step(target_turf, turn(NORTH, -90))

	if(!length(strafelist))
		return

	strafe_turfs(strafelist)

///Takes the top 3 turfs and miniguns them, then repeats until none left
/datum/fire_support/gau/proc/strafe_turfs(list/strafelist)
	var/turf/strafed
	playsound(strafelist[1], 'sound/weapons/gauimpact.ogg', 40, 1, 20, falloff = 3)
	for(var/i=1 to 3)
		strafed = strafelist[1]
		strafelist -= strafed
		strafed.ex_act(EXPLODE_HEAVY)
		new /obj/effect/temp_visual/heavyimpact(strafed)
		for(var/atom/movable/AM AS in strafed)
			AM.ex_act(EXPLODE_HEAVY)

	if(length(strafelist))
		addtimer(CALLBACK(src, PROC_REF(strafe_turfs), strafelist), 0.2 SECONDS)

/datum/fire_support/rockets
	name = "rocket barrage"
	fire_support_type = FIRESUPPORT_TYPE_ROCKETS
	fire_support_flags
	scatter_range = 9
	impact_quantity = 15
	icon_state = "rockets"
	initiate_chat_message = "TARGET ACQUIRED ROCKET RUN INBOUND."
	initiate_screen_message = "Rockets hot, incoming!"

/datum/fire_support/rockets/do_impact(turf/target_turf)
	explosion(target_turf, 0, 2, 5, 2)

/datum/fire_support/cruise_missile
	name = "cruise missile strike"
	fire_support_type = FIRESUPPORT_TYPE_CRUISE_MISSILE
	fire_support_flags
	scatter_range = 1
	icon_state = "cruise"
	initiate_chat_message = "TARGET ACQUIRED CRUISE MISSILE INBOUND."
	initiate_screen_message = "Cruise missile programmed, one out."
	initiate_sound = 'sound/weapons/rocket_incoming.ogg'
	start_visual = null
	start_sound = null

/datum/fire_support/cruise_missile/select_target(turf/target_turf)
	explosion(target_turf, 4, 5, 6)
