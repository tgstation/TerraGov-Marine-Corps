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
	///Special behavior flags
	var/fire_support_flags = FIRESUPPORT_AVAILABLE
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

/datum/fire_support/New()
	. = ..()
	if(uses > 0)
		disable()

///Enables the firesupport option
/datum/fire_support/proc/enable_firesupport(additional_uses)
	uses += additional_uses
	fire_support_flags |= FIRESUPPORT_AVAILABLE

///Disables the firesupport entirely
/datum/fire_support/proc/disable(clear_uses = TRUE)
	if(clear_uses)
		uses = 0
	fire_support_flags &= ~FIRESUPPORT_AVAILABLE

///Initiates fire support proc chain
/datum/fire_support/proc/initiate_fire_support(turf/target_turf, mob/user)
	if(!uses || !(fire_support_flags & FIRESUPPORT_AVAILABLE))
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
	cooldown_timer = addtimer(VARSET_CALLBACK(src, cooldown_timer, null), cooldown_duration, TIMER_STOPPABLE)
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
	name = "Gun run"
	fire_support_type = FIRESUPPORT_TYPE_GUN
	impact_quantity = 5
	uses = 5
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

	if(length(strafelist))
		addtimer(CALLBACK(src, PROC_REF(strafe_turfs), strafelist), 0.2 SECONDS)

/datum/fire_support/gau/unlimited
	fire_support_type = FIRESUPPORT_TYPE_GUN_UNLIMITED
	uses = -1

/datum/fire_support/laser
	name = "Laser run"
	fire_support_type = FIRESUPPORT_TYPE_LASER
	impact_quantity = 4
	uses = 2
	icon_state = "cas_laser"
	initiate_chat_message = "TARGET ACQUIRED LASER RUN INBOUND."
	initiate_screen_message = "Target received, laser run inbound."

/datum/fire_support/laser/do_impact(turf/target_turf)
	var/turf/start_turf = locate(clamp(target_turf.x + rand(-3, 3), 1, world.maxx), clamp(target_turf.y - 6, 1, world.maxy), target_turf.z)
	var/turf/end_turf = locate(clamp(target_turf.x + rand(-3, 3), 1, world.maxx), clamp(target_turf.y + 6, 1, world.maxy), target_turf.z)

	var/list/strafelist = get_line(start_turf, end_turf)
	strafe_turfs(strafelist)

///lases each turf in the line one by one
/datum/fire_support/laser/proc/strafe_turfs(list/strafelist)
	var/turf/strafed = strafelist[1]
	playsound(strafed, 'sound/effects/pred_vision.ogg', 30, 1)
	for(var/target in strafed)
		if(isliving(target))
			var/mob/living/living_target = target
			living_target.adjustFireLoss(100)
			living_target.adjust_fire_stacks(20)
			living_target.IgniteMob()
		else if(ismecha(target))
			var/obj/vehicle/sealed/mecha/mech_target = target
			mech_target.take_damage(300, BURN, LASER, TRUE, null, 50)
		else if(isobj(target))
			var/obj/obj_target = target
			obj_target.take_damage(120, BURN, LASER, TRUE, null, 50)
	strafed.ignite(5, 30)

	strafelist -= strafed
	if(length(strafelist))
		INVOKE_NEXT_TICK(src, PROC_REF(strafe_turfs), strafelist)

/datum/fire_support/rockets
	name = "Rocket barrage"
	fire_support_type = FIRESUPPORT_TYPE_ROCKETS
	scatter_range = 9
	impact_quantity = 15
	uses = 3
	icon_state = "rockets"
	initiate_chat_message = "TARGET ACQUIRED ROCKET RUN INBOUND."
	initiate_screen_message = "Rockets hot, incoming!"

/datum/fire_support/rockets/do_impact(turf/target_turf)
	explosion(target_turf, 0, 2, 4, 6, 2)

/datum/fire_support/rockets/unlimited
	fire_support_type = FIRESUPPORT_TYPE_ROCKETS_UNLIMITED
	uses = -1

/datum/fire_support/incendiary_rockets
	name = "Incendiary rocket barrage"
	fire_support_type = FIRESUPPORT_TYPE_INCEND_ROCKETS
	scatter_range = 9
	impact_quantity = 9
	icon_state = "incendiary_rockets"
	initiate_chat_message = "TARGET ACQUIRED ROCKET RUN INBOUND."
	initiate_screen_message = "Rockets hot, incoming!"
	initiate_title = "Avenger-4"
	portrait_type = /atom/movable/screen/text/screen_text/picture/potrait/som_over
	start_visual = /obj/effect/temp_visual/dropship_flyby/som
	uses = 2

/datum/fire_support/incendiary_rockets/do_impact(turf/target_turf)
	explosion(target_turf, weak_impact_range = 4, flame_range = 4, throw_range = 2)

/datum/fire_support/cruise_missile
	name = "Cruise missile strike"
	fire_support_type = FIRESUPPORT_TYPE_CRUISE_MISSILE
	scatter_range = 1
	uses = 1
	icon_state = "cruise"
	initiate_chat_message = "TARGET ACQUIRED CRUISE MISSILE INBOUND."
	initiate_screen_message = "Cruise missile programmed, one out."
	initiate_sound = 'sound/weapons/rocket_incoming.ogg'
	start_visual = null
	start_sound = null

/datum/fire_support/cruise_missile/select_target(turf/target_turf)
	explosion(target_turf, 4, 5, 6)

/datum/fire_support/cruise_missile/unlimited
	fire_support_type = FIRESUPPORT_TYPE_CRUISE_MISSILE_UNLIMITED
	uses = -1

/datum/fire_support/droppod
	name = "Sentry drop pod"
	fire_support_type = FIRESUPPORT_TYPE_SENTRY_POD
	scatter_range = 1
	uses = -1
	icon_state = "sentry_pod"
	initiate_chat_message = "TARGET ACQUIRED SENTRY POD LAUNCHING."
	initiate_screen_message = "Co-ordinates confirmed, sentry pod launching."
	initiate_sound = null
	start_visual = null
	start_sound = null
	cooldown_duration = 1 SECONDS
	delay_to_impact = 0.5 SECONDS
	///The special pod type for this fire support mode
	var/pod_type = /obj/structure/droppod/nonmob/turret_pod

/datum/fire_support/droppod/New()
	. = ..()
	disable_pods()

/datum/fire_support/droppod/select_target(turf/target_turf)
	for(var/obj/structure/droppod/nonmob/droppod AS in GLOB.droppod_list)
		if(droppod.type != pod_type)
			continue
		if(!droppod.stored_object)
			continue
		if(!droppod.set_target(target_turf.x, target_turf.y))
			return
		droppod.start_launch_pod()
		return

///Enabled the datum for use
/datum/fire_support/droppod/proc/enable_pods(datum/source)
	SIGNAL_HANDLER
	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_MISSION_ENDED, PROC_REF(disable_pods))
	UnregisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_ENABLE_DROPPODS)
	enable_firesupport(-1) //pods can be used separately, restocked, emptied, etc. select_target will check if there's actually a pod available.

///Disabled the datum from use
/datum/fire_support/droppod/proc/disable_pods(datum/source)
	SIGNAL_HANDLER
	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_ENABLE_DROPPODS, PROC_REF(enable_pods))
	UnregisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_MISSION_ENDED)
	disable(TRUE)

/datum/fire_support/droppod/supply
	name = "Supply drop pod"
	fire_support_type = FIRESUPPORT_TYPE_SUPPLY_POD
	icon_state = "supply_pod"
	initiate_chat_message = "TARGET ACQUIRED SUPPLY POD LAUNCHING."
	initiate_screen_message = "Co-ordinates confirmed, supply pod launching."
	pod_type = /obj/structure/droppod/nonmob/supply_pod

/datum/fire_support/volkite
	name = "Volkite gun run"
	fire_support_type = FIRESUPPORT_TYPE_VOLKITE
	impact_quantity = 3
	icon_state = "volkite"
	initiate_chat_message = "TARGET ACQUIRED GUN RUN INBOUND."
	initiate_screen_message = "Target received, gun run inbound."
	initiate_title = "Avenger-4"
	portrait_type = /atom/movable/screen/text/screen_text/picture/potrait/som_over
	start_visual = /obj/effect/temp_visual/dropship_flyby/som
	uses = 3

/datum/fire_support/volkite/do_impact(turf/target_turf)
	var/revdir = REVERSE_DIR(NORTH)
	for(var/i=0 to 2)
		target_turf = get_step(target_turf, revdir) //picks a turf 2 tiles south of target turf

	var/list/strafelist = list()

	strafelist += get_step(target_turf, turn(NORTH, -90)) //we get the turfs on either side
	//strafelist += get_step(target_turf, turn(NORTH, -90))

	for(var/b=0 to 6)
		target_turf = get_ranged_target_turf(target_turf, NORTH, 2)
		strafelist += get_step(target_turf, turn(NORTH, b % 2 ? 90 : -90))

	if(!length(strafelist))
		return

	strafe_turfs(strafelist)

///Takes the top 3 turfs and miniguns them, then repeats until none left
/datum/fire_support/volkite/proc/strafe_turfs(list/strafelist)
	var/turf/strafed
	playsound(strafelist[1], 'sound/weapons/guns/fire/volkite_4.ogg', 60, FALSE, 25, falloff = 3)
	strafed = strafelist[1]
	strafelist -= strafed
	explosion(strafed, light_impact_range = 2, flame_range = 2, throw_range = 0)
	if(length(strafelist))
		addtimer(CALLBACK(src, PROC_REF(strafe_turfs), strafelist), 0.2 SECONDS)

/datum/fire_support/mortar
	name = "Mortar barrage"
	fire_support_type = FIRESUPPORT_TYPE_HE_MORTAR
	scatter_range = 8
	impact_quantity = 5
	cooldown_duration = 20 SECONDS
	uses = 6
	icon_state = "he_mortar"
	initiate_chat_message = "COORDINATES CONFIRMED. MORTAR BARRAGE INCOMING."
	initiate_screen_message = "Coordinates confirmed, high explosive inbound!"
	initiate_title = "Rhino-1"
	initiate_sound = 'sound/weapons/guns/misc/mortar_travel.ogg'
	portrait_type = /atom/movable/screen/text/screen_text/picture/potrait
	start_visual = null
	start_sound = 'sound/weapons/guns/misc/mortar_long_whistle.ogg'

/datum/fire_support/mortar/do_impact(turf/target_turf)
	explosion(target_turf, 0, 2, 3, 5, 2)

/datum/fire_support/mortar/som
	fire_support_type = FIRESUPPORT_TYPE_HE_MORTAR_SOM
	initiate_title = "Guardian-1"
	portrait_type = /atom/movable/screen/text/screen_text/picture/potrait/som_over

/datum/fire_support/mortar/incendiary
	name = "Incendiary mortar barrage"
	fire_support_type = FIRESUPPORT_TYPE_INCENDIARY_MORTAR
	uses = 3
	icon_state = "incendiary_mortar"
	initiate_chat_message = "COORDINATES CONFIRMED. MORTAR BARRAGE INCOMING."
	initiate_screen_message = "Coordinates confirmed, incendiary inbound!"

/datum/fire_support/mortar/incendiary/do_impact(turf/target_turf)
	explosion(target_turf, weak_impact_range = 4, flame_range = 5, throw_range = 0)
	playsound(target_turf, 'sound/weapons/guns/fire/flamethrower2.ogg', 35)

/datum/fire_support/mortar/incendiary/som
	fire_support_type = FIRESUPPORT_TYPE_INCENDIARY_MORTAR_SOM
	initiate_title = "Guardian-1"
	portrait_type = /atom/movable/screen/text/screen_text/picture/potrait/som_over

/datum/fire_support/mortar/smoke
	name = "Smoke mortar barrage"
	fire_support_type = FIRESUPPORT_TYPE_SMOKE_MORTAR
	impact_quantity = 3
	uses = 2
	icon_state = "smoke_mortar"
	initiate_chat_message = "COORDINATES CONFIRMED. MORTAR BARRAGE INCOMING."
	initiate_screen_message = "Coordinates confirmed, smoke inbound!"
	///smoke type created when the grenade is primed
	var/datum/effect_system/smoke_spread/smoketype = /datum/effect_system/smoke_spread/bad
	///radius this smoke grenade will encompass
	var/smokeradius = 6
	///The duration of the smoke
	var/smoke_duration = 11

/datum/fire_support/mortar/smoke/do_impact(turf/target_turf)
	var/datum/effect_system/smoke_spread/smoke = new smoketype()
	playsound(target_turf, "explosion_small", 50)
	playsound(target_turf, 'sound/effects/smoke_bomb.ogg', 25, TRUE)
	smoke.set_up(smokeradius, target_turf, smoke_duration)
	smoke.start()

/datum/fire_support/mortar/smoke/som
	fire_support_type = FIRESUPPORT_TYPE_SMOKE_MORTAR_SOM
	initiate_title = "Guardian-1"
	portrait_type = /atom/movable/screen/text/screen_text/picture/potrait/som_over

/datum/fire_support/mortar/smoke/acid
	name = "Acid smoke mortar barrage"
	fire_support_type = FIRESUPPORT_TYPE_ACID_SMOKE_MORTAR
	uses = 2
	icon_state = "acid_smoke_mortar"
	initiate_chat_message = "COORDINATES CONFIRMED. MORTAR BARRAGE INCOMING."
	initiate_screen_message = "Coordinates confirmed, acid smoke inbound!"
	smoketype = /datum/effect_system/smoke_spread/xeno/acid
	smokeradius = 5

/datum/fire_support/mortar/smoke/satrapine
	name = "Satrapine mortar barrage"
	fire_support_type = FIRESUPPORT_TYPE_SATRAPINE_SMOKE_MORTAR
	uses = 2
	icon_state = "satrapine_mortar"
	initiate_chat_message = "COORDINATES CONFIRMED. MORTAR BARRAGE INCOMING."
	initiate_screen_message = "Coordinates confirmed, satrapine inbound!"
	smoketype = /datum/effect_system/smoke_spread/satrapine
	smokeradius = 5

/datum/fire_support/rad_missile
	name = "Radioactive missile"
	fire_support_type = FIRESUPPORT_TYPE_RAD_MISSILE
	scatter_range = 4
	impact_quantity = 1
	icon_state = "rad_missile"
	initiate_chat_message = "TARGET ACQUIRED RAD MISSILE INBOUND."
	initiate_screen_message = "Target locked, rads inbound!"
	initiate_title = "Avenger-4"
	portrait_type = /atom/movable/screen/text/screen_text/picture/potrait/som_over
	start_visual = /obj/effect/temp_visual/dropship_flyby/som
	uses = 2
	///Base strength of the rad effects
	var/rad_strength = 30
	///Range for the maximum rad effects
	var/inner_range = 3
	///Range for the moderate rad effects
	var/mid_range = 6
	///Range for the minimal rad effects
	var/outer_range = 9

/datum/fire_support/rad_missile/do_impact(turf/target_turf)
	playsound(target_turf, 'sound/effects/portal_opening.ogg', 100, FALSE)
	for(var/mob/living/victim in hearers(outer_range, target_turf))
		var/strength
		var/sound_level
		if(get_dist(victim, target_turf) <= inner_range)
			strength = rad_strength
			sound_level = 4
		else if(get_dist(victim, target_turf) <= mid_range)
			strength = rad_strength * 0.7
			sound_level = 3
		else
			strength = rad_strength * 0.3
			sound_level = 2

		strength = victim.modify_by_armor(strength, BIO, 25)
		victim.apply_radiation(strength, sound_level)

	explosion(target_turf, 0, 1, 0, 4)
