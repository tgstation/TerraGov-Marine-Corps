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
	playsound(strafelist[1], 'sound/weapons/gauimpact.ogg', 40, TRUE, LOUD_SOUND_RANGE, 3)
	for(var/i=1 to 3)
		strafed = strafelist[1]
		strafelist -= strafed
		strafed.ex_act(EXPLODE_HEAVY)
		new /obj/effect/temp_visual/heavyimpact(strafed)

	if(length(strafelist))
		addtimer(CALLBACK(src, PROC_REF(strafe_turfs), strafelist), 0.2 SECONDS)

/datum/fire_support/gau/standard
	fire_support_type = FIRESUPPORT_TYPE_GUN_STANDARD
	fire_support_flags = FIRESUPPORT_AVAILABLE|FIRESUPPORT_ROUNDSTART
	uses = 12
	purchase_cost = 20
	description = "A gun run using 30mm cannons. Capable of strafing large areas for respectable damage. The cheap and cheerful munition of choice for over 150 years among the TGMC."

/datum/fire_support/laser
	name = "Laser run"
	fire_support_type = FIRESUPPORT_TYPE_LASER
	impact_quantity = 4
	uses = 2
	icon_state = "cas_laser"
	initiate_chat_message = "TARGET ACQUIRED LASER RUN INBOUND."
	initiate_screen_message = "Target received, laser run inbound."
	///damage done to mobs
	var/mob_damage = 100

/datum/fire_support/laser/do_impact(turf/target_turf)
	var/turf/start_turf = locate(clamp(target_turf.x + rand(-3, 3), 1, world.maxx), clamp(target_turf.y - 6, 1, world.maxy), target_turf.z)
	var/turf/end_turf = locate(clamp(target_turf.x + rand(-3, 3), 1, world.maxx), clamp(target_turf.y + 6, 1, world.maxy), target_turf.z)

	var/list/strafelist = get_traversal_line(start_turf, end_turf)
	strafe_turfs(strafelist)

///lases each turf in the line one by one
/datum/fire_support/laser/proc/strafe_turfs(list/strafelist)
	var/turf/strafed = strafelist[1]
	strafed.laser_strafe_act(damage = mob_damage)

	strafelist -= strafed
	if(length(strafelist))
		INVOKE_NEXT_TICK(src, PROC_REF(strafe_turfs), strafelist)

/datum/fire_support/laser/standard
	fire_support_type = FIRESUPPORT_TYPE_LASER_STANDARD
	fire_support_flags = FIRESUPPORT_AVAILABLE|FIRESUPPORT_ROUNDSTART
	uses = 4
	mob_damage = 120
	purchase_cost = 30
	description = "A series of power incendiary lasers. Causes huge damage and ignition along the path of the lasers, but is difficult to precisely target."

/datum/fire_support/volkite
	name = "Volkite gun run"
	fire_support_type = FIRESUPPORT_TYPE_VOLKITE
	impact_quantity = 3
	icon_state = "volkite"
	initiate_chat_message = "TARGET ACQUIRED GUN RUN INBOUND."
	initiate_screen_message = "Target received, gun run inbound."
	initiate_title = "Avenger-4"
	portrait_type = /atom/movable/screen/text/screen_text/picture/potrait/som_pilot
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
	playsound(strafelist[1], 'sound/weapons/guns/fire/volkite_4.ogg', 60, FALSE, LOUD_SOUND_RANGE, 3)
	strafed = strafelist[1]
	strafelist -= strafed
	explosion(strafed, light_impact_range = 2, flame_range = 2, throw_range = 0, explosion_cause=name)
	if(length(strafelist))
		addtimer(CALLBACK(src, PROC_REF(strafe_turfs), strafelist), 0.2 SECONDS)
