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

	var/list/strafelist = get_traversal_line(start_turf, end_turf)
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
	playsound(strafelist[1], 'sound/weapons/guns/fire/volkite_4.ogg', 60, FALSE, 25, falloff = 3)
	strafed = strafelist[1]
	strafelist -= strafed
	explosion(strafed, light_impact_range = 2, flame_range = 2, throw_range = 0, explosion_cause=name)
	if(length(strafelist))
		addtimer(CALLBACK(src, PROC_REF(strafe_turfs), strafelist), 0.2 SECONDS)
