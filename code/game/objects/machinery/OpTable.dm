/obj/machinery/optable
	name = "Operating Table"
	desc = "Used for advanced medical procedures. Right-click for utility options."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "table2-idle"
	density = TRUE
	coverage = 10
	layer = TABLE_LAYER
	anchored = TRUE
	allow_pass_flags = PASS_LOW_STRUCTURE|PASSABLE|PASS_WALKOVER
	use_power = IDLE_POWER_USE
	idle_power_usage = 1
	active_power_usage = 5
	var/mob/living/carbon/human/victim = null
	var/strapped = 0
	buckle_flags = CAN_BUCKLE
	buckle_lying = 90
	///optable sending blood to patient
	var/blood_flow_on = FALSE
	///anesthetic tank to connect to optable
	var/obj/item/tank/anesthetic/anes_tank
	///blood pack to connect to optable
	var/obj/item/reagent_containers/blood/blood_pack
	///operating computer connected to optable
	var/obj/machinery/computer/operating/computer = null
	///body scanner function for optable
	var/datum/health_scan/scanner = null

/obj/machinery/optable/Initialize(mapload)
	. = ..()
	var/static/list/connections = list(
		COMSIG_OBJ_TRY_ALLOW_THROUGH = PROC_REF(can_climb_over),
		COMSIG_FIND_FOOTSTEP_SOUND = TYPE_PROC_REF(/atom/movable, footstep_override),
		COMSIG_TURF_CHECK_COVERED = TYPE_PROC_REF(/atom/movable, turf_cover_check),
	)
	AddElement(/datum/element/connect_loc, connections)
	AddComponent(/datum/component/climbable)
	scanner = new(src)

	return INITIALIZE_HINT_LATELOAD


/obj/machinery/optable/Destroy(force, ...)
	QDEL_NULL(scanner)
	return ..()

/obj/machinery/optable/LateInitialize()
	for(dir in list(NORTH, EAST, SOUTH, WEST))
		computer = locate(/obj/machinery/computer/operating, get_step(src, dir))
		if(computer)
			computer.table = src
			break

/obj/machinery/optable/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			if (prob(50))
				qdel(src)





/obj/machinery/optable/examine(mob/user)
	. = ..()
	if(get_dist(user, src) > 2 && !isobserver(user))
		return
	if(anes_tank)
		. += span_information("It has an [anes_tank] connected with the gauge showing [round(anes_tank.pressure,0.1)] kPa.")
	if(blood_pack)
		. += span_information("It has a [blood_pack] connected with the meter showing [round(blood_pack.reagents.get_reagent_amount(/datum/reagent/blood),1)] units of [blood_pack.blood_type] blood.")

#define EJECT_ANESTHETIC "Eject Anesthetic"
#define EJECT_BLOOD_PACK "Eject Blood Pack"
#define TOGGLE_BLOOD_FLOW "Toggle Blood Flow"
#define ANALYZE_VITALS "Analyze Vitals"
/obj/machinery/optable/attack_hand_alternate(mob/living/user)
	. = ..()
	if(.)
		return
	var/list/radial_options = list(
		EJECT_ANESTHETIC = image(icon='icons/obj/items/tank.dmi', icon_state="anesthetic"),
		EJECT_BLOOD_PACK = image(icon='icons/obj/items/bloodpack.dmi', icon_state="full"),
		TOGGLE_BLOOD_FLOW = image(icon='icons/obj/iv_drip.dmi', icon_state="hooked"),
	)
	if(victim)
		radial_options[ANALYZE_VITALS] = image(icon='icons/obj/device.dmi', icon_state="health")
	var/choice = show_radial_menu(user, src, radial_options, null, 48, require_near = TRUE, tooltips = TRUE)
	if(!choice)
		return
	switch(choice)
		if(EJECT_ANESTHETIC)
			if(anes_tank)
				user.put_in_active_hand(anes_tank)
				balloon_alert(user, "You remove \the [anes_tank] from \the [src].")
				playsound(loc, 'sound/effects/air_release.ogg', 25, 1)
				anes_tank = null
				update_appearance(UPDATE_ICON)
			else
				balloon_alert(user, "There is no anesthetic tank connected.")
		if(EJECT_BLOOD_PACK)
			if(blood_pack)
				user.put_in_active_hand(blood_pack)
				balloon_alert(user, "You remove \the [blood_pack] from \the [src].")
				playsound(loc, 'sound/effects/pop.ogg', 25, 1)
				blood_pack = null
				update_appearance(UPDATE_ICON)
			else
				balloon_alert(user, "There is no blood pack connected.")
		if(TOGGLE_BLOOD_FLOW)
			blood_flow_on = !blood_flow_on
			balloon_alert(user, "Blood flow is now [blood_flow_on ? "on" : "off"].")
		if(ANALYZE_VITALS)
			if(victim && scanner)
				scanner.analyze_vitals(victim, user)
			else
				balloon_alert(user, "There is no patient to scan.")
#undef EJECT_ANESTHETIC
#undef EJECT_BLOOD_PACK
#undef TOGGLE_BLOOD_FLOW
#undef ANALYZE_VITALS



/obj/machinery/optable/user_buckle_mob(mob/living/buckling_mob, mob/user, check_loc = TRUE, silent)
	if(!ishuman(buckling_mob))
		return FALSE
	if(buckling_mob == user)
		return FALSE
	if(!ishuman(user)) //xenos buckling humans into op tables and applying anesthetic masks? no way.
		to_chat(user, span_xenowarning("We don't have the manual dexterity to do this."))
		return FALSE
	if(buckling_mob != victim)
		balloon_alert(user, "Lay the patient on the table first!")
		return FALSE
	if(!anes_tank)
		balloon_alert(user, "There is no anesthetic tank connected to the table, load one first.")
		return FALSE
	buckling_mob.visible_message(span_notice("[user] begins to connect [buckling_mob] to the anesthetic system."))
	if(!do_after(user, 2.5 SECONDS, IGNORE_HELD_ITEM, src, BUSY_ICON_GENERIC))
		if(buckling_mob != victim)
			balloon_alert(user, "The patient must remain on the table!")
			return FALSE
		balloon_alert(user, "You stop placing the mask on [buckling_mob]'s face.")
		return FALSE
	if(!anes_tank)
		to_chat(user, span_warning("There is no anesthetic tank connected to the table, load one first."))
		return FALSE
	if(!blood_pack || blood_pack.reagents.get_reagent_amount(/datum/reagent/blood) <= 0)
		balloon_alert(user, "Blood reservoir is empty.")
	var/mob/living/carbon/human/buckling_human = buckling_mob
	if(buckling_human.wear_mask && !buckling_human.dropItemToGround(buckling_human.wear_mask))
		balloon_alert(user, "You can't remove their mask!")
		return FALSE
	if(!buckling_human.equip_to_slot_or_del(new /obj/item/clothing/mask/breath/medical(buckling_human), SLOT_WEAR_MASK))
		balloon_alert(user, "You can't fit the gas mask over their face!")
		return FALSE
	buckling_human.visible_message("[span_notice("[user] fits the mask over [buckling_human]'s face and turns on the anesthetic.")]")
	to_chat(buckling_human, span_information("You begin to feel sleepy."))
	addtimer(CALLBACK(src, PROC_REF(knock_out_buckled), buckling_human), rand(2 SECONDS, 4 SECONDS))
	buckling_human.setDir(SOUTH)
	return ..()

///Knocks out someone buckled to the op table a few seconds later. Won't knock out if they've been unbuckled since.
/obj/machinery/optable/proc/knock_out_buckled(mob/living/buckled_mob)
	if(!victim || victim != buckled_mob)
		return
	ADD_TRAIT(buckled_mob, TRAIT_KNOCKEDOUT, OPTABLE_TRAIT)

/obj/machinery/optable/user_unbuckle_mob(mob/living/buckled_mob, mob/user, silent)
	. = ..()
	if(!.)
		return
	if(!silent)
		buckled_mob.visible_message(span_notice("[user] turns off the anesthetic and removes the mask from [buckled_mob]."))


/obj/machinery/optable/post_unbuckle_mob(mob/living/buckled_mob)
	if(!ishuman(buckled_mob)) // sanity check
		return
	var/mob/living/carbon/human/buckled_human = buckled_mob
	var/obj/item/anesthetic_mask = buckled_human.wear_mask
	buckled_human.dropItemToGround(anesthetic_mask)
	qdel(anesthetic_mask)
	addtimer(TRAIT_CALLBACK_REMOVE(buckled_mob, TRAIT_KNOCKEDOUT, OPTABLE_TRAIT), rand(2 SECONDS, 4 SECONDS))
	return ..()

/obj/machinery/optable/MouseDrop_T(atom/A, mob/user)

	if(istype(A, /obj/item))
		var/obj/item/I = A
		if (!istype(I) || user.get_active_held_item() != I)
			return
		if(user.drop_held_item())
			if (I.loc != loc)
				step(I, get_dir(I, src))
	else if(ismob(A))
		..(A, user)

/obj/machinery/optable/ai_should_stay_buckled(mob/living/carbon/npc)
	return TRUE //nurse, hold him down

/obj/machinery/optable/proc/check_victim()
	if(locate(/mob/living/carbon/human, loc))
		var/mob/living/carbon/human/M = locate(/mob/living/carbon/human, loc)
		if(M.lying_angle)
			victim = M
			icon_state = M.handle_pulse() ? "table2-active" : "table2-idle"
			return 1
	victim = null
	stop_processing()
	icon_state = "table2-idle"
	return 0

/obj/machinery/optable/update_overlays()
	. = ..()

	if(blood_pack)
		var/datum/reagents/reagents = blood_pack.reagents
		if(reagents?.total_volume)
			var/image/filling = image('icons/obj/surgery.dmi', src, "blood")

			var/percent = round((reagents.total_volume / blood_pack.volume) * 100)
			switch(percent)
				if(0 to 9)
					filling.icon_state = "blood0"
				if(10 to 24)
					filling.icon_state = "blood10"
				if(25 to 49)
					filling.icon_state = "blood25"
				if(50 to 74)
					filling.icon_state = "blood50"
				if(75 to 79)
					filling.icon_state = "blood75"
				if(80 to 90)
					filling.icon_state = "blood80"
				if(91 to INFINITY)
					filling.icon_state = "blood100"

			filling.color = mix_color_from_reagents(reagents.reagent_list)
			. += filling

	if(anes_tank)
		var/image/anesthetic_overlay = image('icons/obj/surgery.dmi', src, "tank")
		. += anesthetic_overlay

/obj/machinery/optable/process()
	check_victim()
	if(blood_flow_on && victim && blood_pack && blood_pack.reagents.get_reagent_amount(/datum/reagent/blood) > 0)
		var/transfer_amount = 4
		if(victim.blood_volume <= BLOOD_VOLUME_NORMAL)
			victim.inject_blood(blood_pack, transfer_amount)
			update_appearance(UPDATE_ICON)
		else
			blood_flow_on = FALSE

/obj/machinery/optable/proc/take_victim(mob/living/carbon/C, mob/living/carbon/user)
	if (C == user)
		user.visible_message(span_notice("[user] climbs on the operating table."), span_notice("You climb on the operating table."), null, null, 4)
	else
		visible_message(span_notice("[C] has been laid on the operating table by [user]."), null, null, 4)
	C.set_resting(TRUE)
	C.forceMove(loc)

	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		victim = H
		start_processing()
		icon_state = H.handle_pulse() ? "table2-active" : "table2-idle"
	else
		icon_state = "table2-idle"

/obj/machinery/optable/verb/climb_on()
	set name = "Climb On Table"
	set category = "IC.Object"
	set src in oview(1)

	if(usr.stat || !ishuman(usr) || usr.restrained() || !check_table(usr))
		return

	take_victim(usr,usr)

/obj/machinery/optable/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(istype(I, /obj/item/tank/anesthetic))
		if(anes_tank)
			return
		user.transferItemToLoc(I, src)
		anes_tank = I
		to_chat(user, span_notice("You connect \the [anes_tank] to \the [src]."))
		playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
		update_appearance(UPDATE_ICON)

	if(istype(I, /obj/item/reagent_containers/blood))
		if(blood_pack)
			return
		user.transferItemToLoc(I, src)
		blood_pack = I
		to_chat(user, span_notice("You connect \the [blood_pack] to \the [src]."))
		playsound(loc, 'sound/items/hypospray.ogg', 25, 1)
		update_appearance(UPDATE_ICON)

	if(istype(I, /obj/item/riding_offhand))
		var/obj/item/riding_offhand/carry_obj = I
		if(carry_obj.is_rider(user))
			return
		if(victim)
			balloon_alert(user, "already has a patient!")
			return
		if(!take_victim(carry_obj.rider, user))
			return
		qdel(carry_obj)

/obj/machinery/optable/grab_interact(obj/item/grab/grab, mob/user, base_damage = BASE_OBJ_SLAM_DAMAGE, is_sharp = FALSE)
	. = ..()
	if(.)
		return
	if(victim && victim != grab.grabbed_thing)
		to_chat(user, span_warning("The table is already occupied!"))
		return
	var/mob/living/carbon/grabbed_mob
	if(iscarbon(grab.grabbed_thing))
		grabbed_mob = grab.grabbed_thing
		if(grabbed_mob.buckled)
			to_chat(user, span_warning("Unbuckle first!"))
			return
	else if(istype(grab.grabbed_thing, /obj/structure/closet/bodybag/cryobag))
		var/obj/structure/closet/bodybag/cryobag/cryobag = grab.grabbed_thing
		if(!cryobag.bodybag_occupant)
			return
		grabbed_mob = cryobag.bodybag_occupant
		cryobag.open()
		user.stop_pulling()
		user.start_pulling(grabbed_mob)

	if(!grabbed_mob)
		return

	take_victim(grabbed_mob, user)
	return TRUE

/obj/machinery/optable/proc/check_table(mob/living/carbon/patient as mob)
	if(victim)
		to_chat(usr, span_boldnotice("The table is already occupied!"))
		return 0

	if(patient.buckled)
		to_chat(usr, span_boldnotice("Unbuckle first!"))
		return 0

	return 1
