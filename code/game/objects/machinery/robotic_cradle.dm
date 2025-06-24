#define CRADLE_NOTICE_SUCCESS 1
#define CRADLE_NOTICE_DEATH 2
#define CRADLE_NOTICE_NO_POWER 3
#define CRADLE_NOTICE_XENO_FUCKERY 4
#define CRADLE_NOTICE_EARLY_EJECT 5
//Cradle

/obj/machinery/robotic_cradle
	name = "robotic cradle"
	desc = "A highly experimental robotic maintenence machine using a bath of industrial nanomachines to quickly restore any robotic machine inserted."
	icon = 'icons/obj/machines/suit_cycler.dmi'
	icon_state = "suit_cycler"
	density = TRUE
	max_integrity = 350
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, BIO = 100, FIRE = 30, ACID = 30)
	//It uses power
	use_power = ACTIVE_POWER_USE
	idle_power_usage = 15
	active_power_usage = 10000 // It rebuilds you from nothing...

	///This var is used to see if the machine is currently repairing or not.
	var/repairing = FALSE
	///This var is the reference used for the patient
	var/mob/living/carbon/human/occupant
	///This var is in reference to the radio the cradle uses to speak to the crew
	var/obj/item/radio/headset/mainship/doc/radio
	///This var is so we can call deltimer() it if we need to abort the operation early
	var/operation_timer

/obj/machinery/robotic_cradle/Initialize(mapload)
	. = ..()
	radio = new(src)

/obj/machinery/robotic_cradle/Destroy()
	if(occupant)
		visible_message("\The [src] malfunctions as it is destroyed mid-repair, ejecting [occupant] with unfinished repair wounds and showering them in debris.")
		occupant.take_limb_damage(rand(30,50),rand(30,50))
		remove_occupant()
	if(radio)
		QDEL_NULL(radio)
	return ..()

/obj/machinery/robotic_cradle/update_icon_state()
	if(occupant && !(machine_stat & NOPOWER))
		icon_state = "suit_cycler_active"
		return ..()
	icon_state = "suit_cycler"

/obj/machinery/robotic_cradle/power_change()
	. = ..()
	if(is_operational() || !occupant)
		return
	visible_message("[src] engages the safety override, ejecting the occupant.")
	perform_eject(CRADLE_NOTICE_NO_POWER)

/obj/machinery/robotic_cradle/process()
	if(!occupant)
		return

	if(occupant.stat == DEAD)
		say("Patient has expired.")
		perform_eject(CRADLE_NOTICE_DEATH)
		return

	if(!repairing)
		return

/obj/machinery/robotic_cradle/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	if(!occupant)
		to_chat(xeno_attacker, span_xenowarning("There is nothing of interest in there."))
		return
	if(xeno_attacker.status_flags & INCORPOREAL || xeno_attacker.do_actions)
		return
	start_emergency_eject(xeno_attacker)

///This proc acts as a heads up to the doctors/engineers about the patient exiting the cradle for whatever reason. Takes CRADLE_NOTICE defines as arguments
/obj/machinery/robotic_cradle/proc/notify_about_eject(notice_code = FALSE)
	var/reason = "Reason for discharge: Procedural completion."
	switch(notice_code)
		if(CRADLE_NOTICE_SUCCESS)
			playsound(src, 'sound/machines/ping.ogg', 50, FALSE) //All steps finished properly; this is the 'normal' notification.
		if(CRADLE_NOTICE_DEATH)
			playsound(src, 'sound/machines/warning-buzzer.ogg', 50, FALSE)
			reason = "Reason for discharge: Patient has expired."
		if(CRADLE_NOTICE_NO_POWER)
			playsound(src, 'sound/machines/warning-buzzer.ogg', 50, FALSE)
			reason = "Reason for discharge: Power failure."
		if(CRADLE_NOTICE_XENO_FUCKERY)
			playsound(src, 'sound/machines/warning-buzzer.ogg', 50, FALSE)
			reason = "Reason for discharge: Unauthorized manual release. Alerting security advised."
		if(CRADLE_NOTICE_EARLY_EJECT)
			playsound(src,'sound/machines/buzz-two.ogg',50,FALSE)
			reason = "Reason for discharge: Operation manually terminated by end user."
	if(!radio)//The radio shouldn't ever be deleted, but this is a sanity check just in case
		return
	radio.talk_into(src, "<b>Patient: [occupant] has been released from [src] at: [get_area(src)]. [reason]</b>", RADIO_CHANNEL_MEDICAL)

///Forces the occupant out of the cradle, leaves it empty for someone else to enter.
/obj/machinery/robotic_cradle/proc/remove_occupant()
	if(!occupant)
		return
	occupant.forceMove(drop_location())
	occupant = null
	update_icon()
	stop_processing()

///Finishes ejecting the patient after the cradle is done. Takes CRADLE_NOTICE defines as arguments, used in notify_about_eject()
/obj/machinery/robotic_cradle/proc/perform_eject(notice_code = FALSE)
	repairing = FALSE
	if(operation_timer)
		deltimer(operation_timer)
	notify_about_eject(notice_code)
	remove_occupant()

///Handles any mob placing themselves or someone else into the cradle. target_mob is the mob being placed in, operating_mob is the person placing the mob in. Returns true if the mob got placed inside, false otherwise
/obj/machinery/robotic_cradle/proc/place_mob_inside(mob/living/target_mob, mob/operating_mob)
	if(operating_mob.incapacitated()||!ishuman(operating_mob)||!ishuman(target_mob))
		return FALSE
	if(occupant)
		to_chat(operating_mob, span_notice("[src] is already occupied!"))
		return FALSE
	var/mob/living/carbon/human/patient = target_mob
	if(!(patient.species.species_flags & ROBOTIC_LIMBS))
		visible_message(span_warning("[src] buzzes. Subject is biological, cannot repair"))
		playsound(src, 'sound/machines/buzz-two.ogg', 50, FALSE)
		return FALSE
	if(patient.abiotic())
		visible_message(span_warning("[src] buzzes. Subject cannot wear abiotic items."))
		playsound(src, 'sound/machines/buzz-two.ogg', 50, FALSE)
		return FALSE
	if(machine_stat & (NOPOWER|BROKEN))
		to_chat(operating_mob, span_notice("[src] is non-functional!"))
		return FALSE

	if(operating_mob == patient)
		patient.visible_message(span_notice("[patient] starts climbing into \the [src]."),
		span_notice("You start climbing into \the [src]."))
	else
		operating_mob.visible_message(span_notice("[operating_mob] starts placing [patient] \the [src]."),
		span_notice("You start placing [patient] into \the [src]."))

	if(!do_after(patient, 1 SECONDS, IGNORE_HELD_ITEM, src, BUSY_ICON_GENERIC))
		return FALSE
	if(occupant) //In case someone tried climbing in earlier than us, while the cradle was empty
		to_chat(operating_mob, span_notice("[src] is already occupied!"))
		return FALSE
	patient.stop_pulling()
	patient.forceMove(src)
	occupant = patient
	return TRUE
///Starts the repair operation of the cradle
/obj/machinery/robotic_cradle/proc/start_repair_operation()
	if(!occupant)
		return

	if(powered())
		use_power(active_power_usage)
		playsound(loc, 'sound/machines/ping.ogg', 25, 1)
	else
		perform_eject(CRADLE_NOTICE_NO_POWER)
		return

	start_processing()
	update_icon()
	repairing = TRUE
	say("Automatic mode engaged, initialising repair procedure.")
	operation_timer = addtimer(CALLBACK(src, PROC_REF(handle_repair_operation)), 20 SECONDS,TIMER_STOPPABLE)

///Callback to start repair on someone entering the cradle
/obj/machinery/robotic_cradle/proc/handle_repair_operation()
	if(!occupant) //sanity check, in case we get teleported outside the cradle midrepair without calling perform_eject()
		if(operation_timer)
			deltimer(operation_timer)
		repairing = FALSE
		visible_message(span_warning("[src] buzzes. Occupant missing, procedures canceled."))
		playsound(src, 'sound/machines/buzz-two.ogg', 50, FALSE)
		return
	say("Repair procedure complete.")
	perform_repair()

///This proc handles the actual repair once the timer is up and ejects the healed robot.
/obj/machinery/robotic_cradle/proc/perform_repair()
	if(!occupant)
		return
	if(QDELETED(occupant) || occupant.stat == DEAD)
		if(!ishuman(occupant))
			stack_trace("Non-human occupant made its way into the autodoc: [occupant] | [occupant?.type].")
		visible_message(span_warning("[src] buzzes."))
		perform_eject(CRADLE_NOTICE_DEATH)
		return
	occupant.revive()
	visible_message("\The [src] clicks and opens up having finished the requested operations.")
	perform_eject(CRADLE_NOTICE_SUCCESS)

/obj/machinery/robotic_cradle/MouseDrop_T(mob/dropping, mob/user)
	. = ..()
	if(place_mob_inside(dropping, user))
		start_repair_operation()

/obj/machinery/robotic_cradle/verb/move_inside()
	set name = "Enter Cradle"
	set category = "IC.Object"
	set src in oview(1)

	if(place_mob_inside(usr, usr))
		start_repair_operation()

/obj/machinery/robotic_cradle/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(istype(I, /obj/item/healthanalyzer) && occupant) //Allows us to use the analyzer on the occupant without taking him out.
		var/obj/item/healthanalyzer/J = I
		J.attack(occupant, user)
		return

/obj/machinery/robotic_cradle/attack_hand(mob/living/user)
	. = ..()
	if(user.do_actions) //stops them from spamming if they're attempting to eject someone or otherwise busy
		return
	if(!occupant)
		return
	start_emergency_eject(user)

/obj/machinery/robotic_cradle/grab_interact(obj/item/grab/grab, mob/user, base_damage = BASE_OBJ_SLAM_DAMAGE, is_sharp = FALSE)
	. = ..()
	if(.)
		return
	var/mob/grabbed_mob

	if(ismob(grab.grabbed_thing))
		grabbed_mob = grab.grabbed_thing

	else if(istype(grab.grabbed_thing,/obj/structure/closet/bodybag/cryobag))
		var/obj/structure/closet/bodybag/cryobag/cryobag = grab.grabbed_thing
		if(!cryobag.bodybag_occupant)
			to_chat(user, span_warning("The stasis bag is empty!"))
			return
		grabbed_mob = cryobag.bodybag_occupant
		cryobag.open()
		user.start_pulling(grabbed_mob)

	if(place_mob_inside(grabbed_mob,user))
		start_repair_operation()

	return TRUE

/obj/machinery/robotic_cradle/verb/eject()
	set name = "Eject cradle"
	set category = "IC.Object"
	set src in oview(1)
	if(usr.incapacitated())
		return
	start_emergency_eject(usr)

///This proc ejects whomever is inside the cradle while it is presumably operating. mob_ejecting is the mob triggering the eject
/obj/machinery/robotic_cradle/proc/start_emergency_eject(mob/mob_ejecting)
	if(!occupant)
		return
	if(!repairing)//this shouldn't be possible unless you get var edited inside without triggering start_repair_operation(), in that case just get them out
		remove_occupant()
		return
	if(!mob_ejecting)
		perform_eject(CRADLE_NOTICE_EARLY_EJECT)
		return
	if(isxeno(mob_ejecting))
		mob_ejecting.visible_message(span_notice("[mob_ejecting] pries the cover of [src]"),
		span_notice("You begin to pry at the cover of [src]."))
		playsound(mob_ejecting,'sound/effects/metal_creaking.ogg', 25, 1)
		if(!do_after(mob_ejecting, 2 SECONDS, NONE, src, BUSY_ICON_DANGER) || !occupant)
			return
		perform_eject(CRADLE_NOTICE_XENO_FUCKERY)
		return
	if(!ishuman(mob_ejecting))
		return
	if(mob_ejecting == occupant)
		to_chat(usr, span_warning("There's no way you're getting out while this thing is operating on you!"))
		return
	perform_eject(CRADLE_NOTICE_EARLY_EJECT)

#undef CRADLE_NOTICE_SUCCESS
#undef CRADLE_NOTICE_DEATH
#undef CRADLE_NOTICE_NO_POWER
#undef CRADLE_NOTICE_EARLY_EJECT
