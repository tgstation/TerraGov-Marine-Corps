#define CRADLE_NOTICE_SUCCESS 1
#define CRADLE_NOTICE_DEATH 2
#define CRADLE_NOTICE_NO_RECORD 3
#define CRADLE_NOTICE_NO_POWER 4
#define CRADLE_NOTICE_XENO_FUCKERY 5
#define CRADLE_NOTICE_IDIOT_EJECT 6
#define CRADLE_NOTICE_FORCE_EJECT 7
//Cradle

/obj/machinery/robotic_cradle
	name = "Robotic Cradle"
	icon = 'icons/obj/machines/synthpod.dmi'
	icon_state = "idle"
	density = TRUE
	anchored = TRUE
	max_integrity = 350
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, BIO = 100, FIRE = 30, ACID = 30)

	var/locked = FALSE

	var/repairing = FALSE

	var/release_notice = TRUE

	var/mob/living/carbon/human/occupant = null

	var/forceeject = FALSE

	var/event = 0

	//It uses power
	use_power = ACTIVE_POWER_USE
	idle_power_usage = 15
	active_power_usage = 120000 // It rebuilds you from nothing...

	var/obj/item/radio/headset/mainship/doc/radio

/obj/machinery/robotic_cradle/Initialize(mapload)
	. = ..()
	radio = new(src)

/obj/machinery/robotic_cradle/update_icon_state()
	if(machine_stat & NOPOWER)
		icon_state = "No power"
	else if(repairing)
		icon_state = "pod_1"
	else if (occupant)
		icon_state = "pod_0"
	else
		icon_state = "idle"

/obj/machinery/robotic_cradle/power_change()
	. = ..()
	if(is_operational() || !occupant)
		return
	visible_message("[src] engages the safety override, ejecting the occupant.")
	repairing = FALSE
	go_out(CRADLE_NOTICE_NO_POWER)

/obj/machinery/robotic_cradle/process()
	if(!occupant)
		return

	if(occupant.stat == DEAD)
		say("Patient has expired.")
		repairing = FALSE
		go_out(CRADLE_NOTICE_DEATH)
		return

	if(!repairing)
		return

/obj/machinery/robotic_cradle/proc/repair_op()

	if(QDELETED(occupant) || occupant.stat == DEAD)
		if(!ishuman(occupant))
			stack_trace("Non-human occupant made its way into the autodoc: [occupant] | [occupant?.type].")
		visible_message("[src] buzzes.")
		go_out(CRADLE_NOTICE_DEATH) //kick them out too.
		return

	occupant.revive()
	visible_message("\The [src] clicks and opens up having finished the requested operations.")
	repairing = 0
	go_out(CRADLE_NOTICE_SUCCESS)

/obj/machinery/robotic_cradle/attack_alien(mob/living/carbon/xenomorph/X, damage_amount, damage_type, damage_flag, effects, armor_penetration, isrightclick)
	if(!occupant)
		to_chat(X, span_xenowarning("There is nothing of interest in there."))
		return
	if(X.status_flags & INCORPOREAL || X.do_actions)
		return
	visible_message(span_warning("[X] begins to pry the [src]'s cover!"), 3)
	playsound(src,'sound/effects/metal_creaking.ogg', 25, 1)
	if(!do_after(X, 2 SECONDS))
		return
	playsound(loc, 'sound/effects/metal_creaking.ogg', 25, 1)
	go_out()

/obj/machinery/robotic_cradle/proc/go_out(notice_code = FALSE)
	for(var/i in contents)
		var/atom/movable/AM = i
		AM.forceMove(loc)
	if(release_notice && occupant) //If auto-release notices are on as they should be, let the doctors know what's up
		var/reason = "Reason for discharge: Procedural completion."
		switch(notice_code)
			if(CRADLE_NOTICE_SUCCESS)
				playsound(src.loc, 'sound/machines/ping.ogg', 50, FALSE) //All steps finished properly; this is the 'normal' notification.
			if(CRADLE_NOTICE_NO_RECORD)
				playsound(src.loc, 'sound/machines/warning-buzzer.ogg', 50, FALSE)
				reason = "Reason for discharge: Medical records not detected. Alerting security advised."
			if(CRADLE_NOTICE_NO_POWER)
				playsound(src.loc, 'sound/machines/warning-buzzer.ogg', 50, FALSE)
				reason = "Reason for discharge: Power failure."
			if(CRADLE_NOTICE_XENO_FUCKERY)
				playsound(src.loc, 'sound/machines/warning-buzzer.ogg', 50, FALSE)
				reason = "Reason for discharge: Unauthorized manual release. Alerting security advised."
			if(CRADLE_NOTICE_IDIOT_EJECT)
				playsound(src.loc, 'sound/machines/warning-buzzer.ogg', 50, FALSE)
				reason = "Reason for discharge: Unauthorized manual release during repair. Alerting security advised."
			if(CRADLE_NOTICE_FORCE_EJECT)
				playsound(src.loc, 'sound/machines/warning-buzzer.ogg', 50, FALSE)
				reason = "Reason for discharge: Destruction of linked CRADLE Engineering System. Alerting security advised."
		radio.talk_into(src, "<b>Patient: [occupant] has been released from [src] at: [get_area(src)]. [reason]</b>", RADIO_CHANNEL_MEDICAL)
	occupant = null
	update_icon()
	stop_processing()

/obj/machinery/robotic_cradle/proc/move_inside_wrapper(mob/living/dropped, mob/dragger)
	if(dragger.incapacitated() || !ishuman(dragger))
		return

	if(occupant)
		to_chat(dragger, span_notice("[src] is already occupied!"))
		return

	if(machine_stat & (NOPOWER|BROKEN))
		to_chat(dragger, span_notice("[src] is non-functional!"))
		return

	if(dragger.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_ENGI && !event)
		dropped.visible_message(span_notice("[dropped] fumbles around figuring out how to get into \the [src]."),
		span_notice("You fumble around figuring out how to get into \the [src]."))
		var/fumbling_time = max(0 , SKILL_TASK_TOUGH - ( SKILL_TASK_EASY * dragger.skills.getRating(SKILL_ENGINEER) ))// 8 secs non-trained, 5 amateur
		if(!do_after(dropped, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
			return

	dropped.visible_message(span_notice("[dropped] starts climbing into \the [src]."),
	span_notice("You start climbing into \the [src]."))
	if(do_after(dropped, 1 SECONDS, FALSE, src, BUSY_ICON_GENERIC))
		if(occupant)
			to_chat(dragger, span_notice("[src] is already occupied!"))
			return
		dropped.stop_pulling()
		dropped.forceMove(src)
		occupant = dropped
		icon_state = "pod_0"
		var/implants = list(/obj/item/implant/neurostim)
		var/mob/living/carbon/human/H = occupant
		var/doc_dat
		med_scan(H, doc_dat, implants, TRUE)
		start_processing()
		for(var/obj/O in src)
			qdel(O)

	say("Automatic mode engaged, initialising procedure.")
	addtimer(CALLBACK(src, PROC_REF(auto_start)), 20 SECONDS)

///Callback to start auto mode on someone entering
/obj/machinery/robotic_cradle/proc/auto_start()
	if(repairing)
		return
	if(!occupant)
		say("Occupant missing, procedures canceled.")
	say("Beginning repair procedure.")
	repair_op()

/obj/machinery/robotic_cradle/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(!ishuman(user))
		return // no

	else if(istype(I, /obj/item/healthanalyzer) && occupant) //Allows us to use the analyzer on the occupant without taking him out.
		var/obj/item/healthanalyzer/J = I
		J.attack(occupant, user)
		return

	else if(!istype(I, /obj/item/grab))
		return

	if(machine_stat & (NOPOWER|BROKEN))
		to_chat(user, span_notice("[src] is non-functional!"))
		return

	else if(occupant)
		to_chat(user, span_notice("[src] is already occupied!"))
		return

	if(!istype(I, /obj/item/grab))
		return

	var/obj/item/grab/G = I

	var/mob/M
	if(ismob(G.grabbed_thing))
		M = G.grabbed_thing
	else if(istype(G.grabbed_thing, /obj/structure/closet/bodybag/cryobag))
		var/obj/structure/closet/bodybag/cryobag/C = G.grabbed_thing
		if(!C.bodybag_occupant)
			to_chat(user, span_warning("The stasis bag is empty!"))
			return
		M = C.bodybag_occupant
		C.open()
		user.start_pulling(M)

	if(!M)
		return

	else if(!ishuman(M)) // No monkee or beano
		to_chat(user, span_notice("[src] is compatible with humanoid anatomies only!"))
		return

	else if(M.abiotic())
		to_chat(user, span_warning("Subject cannot have abiotic items on."))
		return

	if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_ENGI && !event)
		user.visible_message(span_notice("[user] fumbles around figuring out how to put [M] into [src]."),
		span_notice("You fumble around figuring out how to put [M] into [src]."))
		var/fumbling_time = max(0 , SKILL_TASK_TOUGH - ( SKILL_TASK_EASY * user.skills.getRating(SKILL_ENGINEER) ))// 8 secs non-trained, 5 amateur
		if(!do_after(user, fumbling_time, TRUE, M, BUSY_ICON_UNSKILLED) || QDELETED(src))
			return

	visible_message("[user] starts putting [M] into [src].", 3)

	if(!do_after(user, 10, FALSE, M, BUSY_ICON_GENERIC) || QDELETED(src))
		return

	if(occupant)
		to_chat(user, span_notice("[src] is already occupied!"))
		return

	if(!M || !G)
		return

	M.forceMove(src)
	occupant = M
	icon_state = "pod_1"
	var/implants = list(/obj/item/implant/neurostim)
	var/mob/living/carbon/human/H = occupant
	med_scan(H, null, implants, TRUE)
	start_processing()
	say("Automatic mode engaged, initialising procedure.")
	addtimer(CALLBACK(src, PROC_REF(auto_start)), 20 SECONDS)

/obj/machinery/robotic_cradle/verb/eject()
	set name = "Eject cradle"
	set category = "Object"
	set src in oview(1)
	if(usr.incapacitated())
		return // nooooooooooo
	if(locked && !allowed(usr)) //Check access if locked.
		to_chat(usr, span_warning("Access denied."))
		playsound(loc,'sound/machines/buzz-two.ogg', 25, 1)
		return
	do_eject()

/obj/machinery/robotic_cradle/proc/do_eject()
	if(!occupant)
		return
	if(forceeject)
		if(!repairing)
			visible_message("\The [src] is destroyed, ejecting [occupant] and showering them in debris.")
			occupant.take_limb_damage(rand(10,20),rand(10,20))
		else
			visible_message("\The [src] malfunctions as it is destroyed mid-repair, ejecting [occupant] with unfinished repair wounds and showering them in debris.")
			occupant.take_limb_damage(rand(30,50),rand(30,50))
		go_out(CRADLE_NOTICE_FORCE_EJECT)
		return
	if(isxeno(usr) && !repairing) // let xenos eject people hiding inside; a xeno ejecting someone during repair does so like someone untrained
		go_out(CRADLE_NOTICE_XENO_FUCKERY)
		return
	if(!ishuman(usr))
		return
	if(usr == occupant)
		if(repairing)
			to_chat(usr, span_warning("There's no way you're getting out while this thing is operating on you!"))
			return
		else
			visible_message("[usr] engages the internal release mechanism, and climbs out of \the [src].")
	if(usr.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_ENGI && !event)
		usr.visible_message(span_notice("[usr] fumbles around figuring out how to use [src]."),
		span_notice("You fumble around figuring out how to use [src]."))
		var/fumbling_time = max(0 , SKILL_TASK_TOUGH - ( SKILL_TASK_EASY * usr.skills.getRating(SKILL_ENGINEER) ))// 8 secs non-trained, 5 amateur
		if(!do_after(usr, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED) || !occupant)
			return
	if(repairing)
		repairing = 0
		if(usr.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_ENGI) //Untrained people will fail to terminate the repair properly.
			visible_message("\The [src] malfunctions as [usr] aborts the rapair in progress.")
			occupant.take_limb_damage(rand(30,50),rand(30,50))
			log_game("[key_name(usr)] ejected [key_name(occupant)] from the cradle during repair causing damage.")
			message_admins("[ADMIN_TPMONTY(usr)] ejected [ADMIN_TPMONTY(occupant)] from the cradle during repair causing damage.")
			go_out(CRADLE_NOTICE_IDIOT_EJECT)
			return
	go_out()
