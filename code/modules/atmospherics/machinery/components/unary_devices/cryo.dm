#define CRYOMOBS 'icons/obj/cryo_mobs.dmi'

/obj/machinery/atmospherics/components/unary/cryo_cell
	name = "cryo cell"
	icon = 'icons/obj/machines/cryogenics2.dmi'
	icon_state = "cell_mapper"
	density = TRUE
	max_integrity = 350
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, BIO = 100, FIRE = 30, ACID = 30)
	layer = ABOVE_MOB_LAYER
	pipe_flags = PIPING_ONE_PER_TURF|PIPING_DEFAULT_LAYER_ONLY
	interaction_flags = INTERACT_MACHINE_TGUI
	can_see_pipes = FALSE
	light_range = 2
	light_power = 0.5
	light_color = LIGHT_COLOR_EMISSIVE_GREEN

	var/autoeject = FALSE
	var/release_notice = FALSE

	var/temperature = 100

	var/efficiency = 1
	var/sleep_factor = 0.00125
	var/unconscious_factor = 0.001
	var/heat_capacity = 20000
	var/conduction_coefficient = 0.3

	var/obj/item/reagent_containers/glass/beaker = null
	var/reagent_transfer = 0

	var/obj/item/radio/headset/mainship/doc/radio
	var/idle_ticks_until_shutdown = 60 //Number of ticks permitted to elapse without a patient before the cryotube shuts itself off to save processing

	var/running_anim = FALSE

	var/escape_in_progress = FALSE
	var/message_cooldown
	var/breakout_time = 300

	var/mob/living/carbon/occupant

/obj/machinery/atmospherics/components/unary/cryo_cell/Initialize(mapload)
	. = ..()
	initialize_directions = dir
	beaker = new /obj/item/reagent_containers/glass/beaker/cryomix
	radio = new(src)
	update_icon()

/obj/machinery/atmospherics/components/unary/cryo_cell/proc/process_occupant()
	if(!occupant)
		return
	if(occupant.stat == DEAD)
		return
	if(!occupant.getBruteLoss(TRUE) && !occupant.getFireLoss(TRUE) && !occupant.getCloneLoss() && autoeject) //release the patient automatically when brute and burn are handled on non-robotic limbs
		go_out(TRUE)
		return
	occupant.bodytemperature = 100 //Atmos is long gone, we'll just set temp directly.
	occupant.Sleeping(20 SECONDS)

	//You'll heal slowly just from being in an active pod, but chemicals speed it up.
	if(occupant.getOxyLoss())
		occupant.adjustOxyLoss(-1)
	if (occupant.getToxLoss())
		occupant.adjustToxLoss(-1)
	occupant.heal_overall_damage(1, 1, updating_health = TRUE)
	var/has_cryo = occupant.reagents.get_reagent_amount(/datum/reagent/medicine/cryoxadone) >= 1
	var/has_clonexa = occupant.reagents.get_reagent_amount(/datum/reagent/medicine/clonexadone) >= 1
	var/has_cryo_medicine = has_cryo || has_clonexa
	if(beaker && !has_cryo_medicine)
		beaker.reagents.trans_to(occupant, 1, 10)
		beaker.reagents.reaction(occupant)

/obj/machinery/atmospherics/components/unary/cryo_cell/on_construction()
	..(dir, dir)

/obj/machinery/atmospherics/components/unary/cryo_cell/RefreshParts()
	var/C
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		C += M.rating

	efficiency = initial(efficiency) * C
	sleep_factor = initial(sleep_factor) * C
	unconscious_factor = initial(unconscious_factor) * C
	heat_capacity = initial(heat_capacity) / C
	conduction_coefficient = initial(conduction_coefficient) * C

/obj/machinery/atmospherics/components/unary/cryo_cell/examine(mob/user) //this is leaving out everything but efficiency since they follow the same idea of "better beaker, better results"
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. +=  span_notice("The status display reads: Efficiency at <b>[efficiency*100]%</b>.")
	if(occupant)
		if(on)
			. += "Someone's inside [src]!"
		else
			. += "You can barely make out a form floating in [src]."
	else
		. += "[src] seems empty."

/obj/machinery/atmospherics/components/unary/cryo_cell/Destroy()
	QDEL_NULL(radio)
	QDEL_NULL(beaker)
	return ..()

/obj/machinery/atmospherics/components/unary/cryo_cell/contents_explosion(severity)
	. = ..()
	if(beaker)
		beaker.ex_act(severity)

/obj/machinery/atmospherics/components/unary/cryo_cell/handle_atom_del(atom/A)
	. = ..()
	if(A == beaker)
		beaker = null

/obj/machinery/atmospherics/components/unary/cryo_cell/update_icon()
	. = ..()
	if(!on)
		set_light(0)
	else
		set_light(initial(light_range))

/obj/machinery/atmospherics/components/unary/cryo_cell/update_icon_state()
	if(!on)
		icon_state = "cell_off"
	else
		icon_state = "cell_on"
	if(occupant)
		icon_state += "_occupied"

/obj/machinery/atmospherics/components/unary/cryo_cell/update_overlays()
	. = ..()
	if(!on)
		return
	. += emissive_appearance(icon, "cell_emissive", alpha = src.alpha)

/obj/machinery/atmospherics/components/unary/cryo_cell/proc/run_anim(anim_up, image/occupant_overlay)
	if(!on || !occupant || !is_operational())
		running_anim = FALSE
		return
	cut_overlays()
	if(occupant_overlay.pixel_y != 23) // Same effect as occupant_overlay.pixel_y == 22 || occupant_overlay.pixel_y == 24
		anim_up = occupant_overlay.pixel_y == 22 // Same effect as if(occupant_overlay.pixel_y == 22) anim_up = TRUE ; if(occupant_overlay.pixel_y == 24) anim_up = FALSE
	if(anim_up)
		occupant_overlay.pixel_y++
	else
		occupant_overlay.pixel_y--
	add_overlay(occupant_overlay)
	add_overlay("cover-on")
	addtimer(CALLBACK(src, PROC_REF(run_anim), anim_up, occupant_overlay), 7, TIMER_UNIQUE)

/obj/machinery/atmospherics/components/unary/cryo_cell/proc/go_out(auto_eject = null, dead = null)
	if(!( occupant ))
		return
	if (occupant.client)
		occupant.client.eye = occupant.client.mob
		occupant.client.perspective = MOB_PERSPECTIVE
	if(occupant in contents)
		occupant.forceMove(get_step(loc, dir))
	if (occupant.bodytemperature < 261 && occupant.bodytemperature >= 70) //Patch by Aranclanos to stop people from taking burn damage after being ejected
		occupant.bodytemperature = 261									  // Changed to 70 from 140 by Zuhayr due to reoccurance of bug.
	if(auto_eject) //Turn off and announce if auto-ejected because patient is recovered or dead.
		turn_off()
		if(release_notice) //If auto-release notices are on as it should be, let the doctors know what's up
			playsound(src.loc, 'sound/machines/ping.ogg', 100, 14)
			var/reason = "Reason for release:</b> Patient recovery."
			if(dead)
				reason = "<b>Reason for release:</b> Patient death."
			radio.talk_into(src, "Patient [occupant] has been automatically released from [src] at: [get_area(occupant)]. [reason]", RADIO_CHANNEL_MEDICAL)
	occupant.record_time_in_cryo()
	occupant = null
	update_icon()

/obj/machinery/atmospherics/components/unary/cryo_cell/proc/turn_off()
	on = FALSE
	stop_processing()
	update_icon()

/obj/machinery/atmospherics/components/unary/cryo_cell/process()
	..()
	if(machine_stat & (NOPOWER|BROKEN))
		turn_off()
		return

	if(!on)
		stop_processing()
		return

	if(occupant)
		if(occupant.stat != DEAD)
			idle_ticks_until_shutdown = 60 //reset idle ticks on usage
			process_occupant()
		else
			go_out(TRUE, TRUE) //Whether auto-eject is on or not, we don't permit literal deadbeats to hang around.
	else
		idle_ticks_until_shutdown = max(idle_ticks_until_shutdown--,0) //decrement by 1 if there is no patient.
		if(!idle_ticks_until_shutdown) //shut down after all ticks elapsed to conserve on processing
			turn_off()
			idle_ticks_until_shutdown = 60 //reset idle ticks

	return TRUE


/obj/machinery/atmospherics/components/unary/cryo_cell/relaymove(mob/user)
	if(message_cooldown <= world.time)
		message_cooldown = world.time + 50
		to_chat(user, span_warning("[src]'s door won't budge!"))


/obj/machinery/atmospherics/components/unary/cryo_cell/verb/move_eject()
	set name = "Eject occupant"
	set category = "Object"
	set src in oview(1)
	if(usr == occupant) //If the user is inside the tube...
		if (usr.stat == DEAD) //and he's not dead....
			return
		to_chat(usr, span_notice("Auto release sequence activated. You will be released when you have recovered."))
		autoeject = TRUE
		return
	if (usr.stat != CONSCIOUS)
		return
	go_out()

/obj/machinery/atmospherics/components/unary/cryo_cell/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/reagent_containers/glass))

		for(var/datum/reagent/X in I.reagents.reagent_list)
			if(X.medbayblacklist)
				to_chat(user, span_warning("The cryo cell's automatic safety features beep softly, they must have detected a harmful substance in the beaker."))
				return

		if(beaker)
			to_chat(user, span_warning("A beaker is already loaded into the machine."))
			return

		if(istype(I, /obj/item/reagent_containers/glass/bucket))
			to_chat(user, span_warning("That's too big to fit!"))
			return

		beaker = I


		var/reagentnames = ""

		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			reagentnames += ", [R.name]"

		if(!user.transferItemToLoc(I, src))
			return

		user.visible_message("[user] adds \a [I] to \the [src]!", "You add \a [I] to \the [src]!")

	else if(istype(I, /obj/item/healthanalyzer) && occupant) //Allows us to use the analyzer on the occupant without taking him out.
		var/obj/item/healthanalyzer/J = I
		J.attack(occupant, user)

	if(!istype(I, /obj/item/grab))
		return

	if(machine_stat & (NOPOWER|BROKEN))
		to_chat(user, span_notice("\ [src] is non-functional!"))
		return

	if(occupant)
		to_chat(user, span_notice("\ [src] is already occupied!"))
		return

	var/obj/item/grab/G = I
	var/mob/M

	if(ismob(G.grabbed_thing))
		M = G.grabbed_thing

	else if(istype(G.grabbed_thing,/obj/structure/closet/bodybag/cryobag))
		var/obj/structure/closet/bodybag/cryobag/C = G.grabbed_thing
		if(!C.bodybag_occupant)
			to_chat(user, span_warning("The stasis bag is empty!"))
			return
		M = C.bodybag_occupant
		C.open()
		user.start_pulling(M)

	if(!M)
		return

	if(!ishuman(M))
		to_chat(user, span_notice("\ [src] is compatible with humanoid anatomies only!"))
		return

	if(M.abiotic())
		to_chat(user, span_warning("Subject cannot have abiotic items on."))
		return

	put_mob(M, TRUE)

/obj/machinery/atmospherics/components/unary/cryo_cell/proc/put_mob(mob/living/carbon/M as mob, put_in = null)
	if (machine_stat & (NOPOWER|BROKEN))
		to_chat(usr, span_warning("The cryo cell is not functioning."))
		return
	if(!ishuman(M))
		to_chat(usr, span_notice("\ [src] is compatible with humanoid anatomies only!"))
		return
	if (occupant)
		to_chat(usr, span_danger("The cryo cell is already occupied!"))
		return
	if (M.abiotic())
		to_chat(usr, span_warning("Subject may not have abiotic items on."))
		return
	if(put_in) //Select an appropriate message
		visible_message(span_notice("[usr] puts [M] in [src]."), 3)
	else
		visible_message(span_notice("[usr] climbs into [src]."), 3)
	M.forceMove(src)
	if(M.health > -100 && (M.health < 0 || M.IsSleeping()))
		to_chat(M, span_boldnotice("You feel a cold liquid surround you. Your skin starts to freeze up."))
	occupant = M
	occupant.time_entered_cryo = world.time
	update_icon()
	return TRUE

/obj/machinery/atmospherics/components/unary/cryo_cell/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if (!href_list["scanreport"])
		return
	if(!hasHUD(usr,"medical"))
		return
	if(get_dist(usr, src) > 7)
		to_chat(usr, span_warning("[src] is too far away."))
		return
	if(!ishuman(occupant))
		return
	var/mob/living/carbon/human/H = occupant
	for(var/datum/data/record/R in GLOB.datacore.medical)
		if (!R.fields["name"] == H.real_name)
			continue
		if(R.fields["last_scan_time"] && R.fields["last_scan_result"])
			var/datum/browser/popup = new(usr, "scanresults", "<div align='center'>Last Scan Result</div>", 430, 600)
			popup.set_content(R.fields["last_scan_result"])
			popup.open(FALSE)
		break

/obj/machinery/atmospherics/components/unary/cryo_cell/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	ui_interact(user)

/obj/machinery/atmospherics/components/unary/cryo_cell/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "Cryo", name)
		ui.open()

/obj/machinery/atmospherics/components/unary/cryo_cell/ui_data(mob/user)
	var/list/data = list()
	data["isOperating"] = on
	data["hasOccupant"] = occupant ? TRUE : FALSE
	data["autoEject"] = autoeject
	data["notify"] = release_notice

	data["occupant"] = list()
	if(occupant)
		var/mob/living/mob_occupant = occupant
		data["occupant"]["name"] = mob_occupant.name
		switch(mob_occupant.stat)
			if(CONSCIOUS)
				data["occupant"]["stat"] = "Conscious"
				data["occupant"]["statstate"] = "good"
			if(UNCONSCIOUS)
				data["occupant"]["stat"] = "Unconscious"
				data["occupant"]["statstate"] = "average"
			if(DEAD)
				data["occupant"]["stat"] = "Dead"
				data["occupant"]["statstate"] = "bad"
		data["occupant"]["health"] = round(mob_occupant.health, 1)
		data["occupant"]["maxHealth"] = mob_occupant.maxHealth
		data["occupant"]["minHealth"] = mob_occupant.health_threshold_dead
		data["occupant"]["bruteLoss"] = round(mob_occupant.getBruteLoss(), 1)
		data["occupant"]["oxyLoss"] = round(mob_occupant.getOxyLoss(), 1)
		data["occupant"]["toxLoss"] = round(mob_occupant.getToxLoss(), 1)
		data["occupant"]["fireLoss"] = round(mob_occupant.getFireLoss(), 1)
		data["occupant"]["bodyTemperature"] = round(mob_occupant.bodytemperature, 1)
		if(mob_occupant.bodytemperature < 255)
			data["occupant"]["temperaturestatus"] = "good"
		else if(mob_occupant.bodytemperature < T0C)
			data["occupant"]["temperaturestatus"] = "average"
		else
			data["occupant"]["temperaturestatus"] = "bad"

	data["cellTemperature"] = round(temperature)

	data["isBeakerLoaded"] = beaker ? TRUE : FALSE
	var/beakerContents = list()
	if(beaker?.reagents && length(beaker.reagents.reagent_list))
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents += list(list("name" = R.name, "volume" = R.volume))
	data["beakerContents"] = beakerContents
	return data

/obj/machinery/atmospherics/components/unary/cryo_cell/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("power")
			if(on)
				turn_off()
			else
				turn_on()
			. = TRUE
		if("eject")
			go_out()
			. = TRUE
		if("autoeject")
			autoeject = !autoeject
			. = TRUE
		if("ejectbeaker")
			if(beaker)
				beaker.forceMove(drop_location())
				if(Adjacent(usr) && !issilicon(usr))
					usr.put_in_hands(beaker)
				beaker = null
				. = TRUE
		if("notice")
			release_notice = !release_notice
			. = TRUE

/obj/machinery/atmospherics/components/unary/cryo_cell/proc/turn_on()
	if (machine_stat & (NOPOWER|BROKEN))
		to_chat(usr, span_warning("The cryo cell is not functioning."))
		return
	on = TRUE
	start_processing()
	update_icon()

/obj/machinery/atmospherics/components/unary/cryo_cell/can_crawl_through()
	return // can't ventcrawl in or out of cryo.

/obj/machinery/atmospherics/components/unary/cryo_cell/attack_alien(mob/living/carbon/xenomorph/X, damage_amount, damage_type, damage_flag, effects, armor_penetration, isrightclick)
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


#undef CRYOMOBS
