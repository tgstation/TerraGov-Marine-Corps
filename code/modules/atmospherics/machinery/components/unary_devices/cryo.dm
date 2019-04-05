#define CRYOMOBS 'icons/obj/cryo_mobs.dmi'

/obj/machinery/atmospherics/components/unary/cryo_cell
	name = "cryo cell"
	icon = 'icons/obj/machines/cryogenics2.dmi'
	icon_state = "cell-off"
	density = TRUE
	//max_integrity = 350
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 100, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 30, "acid" = 30)
	layer = ABOVE_WINDOW_LAYER
	//state_open = FALSE
	//circuit = /obj/item/circuitboard/machine/cryo_tube
	pipe_flags = PIPING_ONE_PER_TURF | PIPING_DEFAULT_LAYER_ONLY
	//occupant_typecache = list(/mob/living/carbon, /mob/living/simple_animal)

	var/auto_release = FALSE
	var/release_notice = FALSE
	//var/volume = 100

	var/temperature = 100

	var/efficiency = 1
	var/sleep_factor = 0.00125
	var/unconscious_factor = 0.001
	var/heat_capacity = 20000
	var/conduction_coefficient = 0.3

	var/obj/item/reagent_container/glass/beaker = null
	var/reagent_transfer = 0

	var/obj/item/radio/radio
	//var/radio_key = /obj/item/encryptionkey/headset_med
	//var/radio_channel = RADIO_CHANNEL_MEDICAL
	var/idle_ticks_until_shutdown = 60 //Number of ticks permitted to elapse without a patient before the cryotube shuts itself off to save processing

	var/running_anim = FALSE

	var/escape_in_progress = FALSE
	var/message_cooldown
	var/breakout_time = 300
	//fair_market_price = 10
	//payment_department = ACCOUNT_MED

	var/mob/living/carbon/occupant

/obj/machinery/atmospherics/components/unary/cryo_cell/Initialize()
	. = ..()
	initialize_directions = dir
	beaker = new /obj/item/reagent_container/glass/beaker/cryomix
/*
	radio = new(src)
	radio.keyslot = new radio_key
	radio.subspace_transmission = TRUE
	radio.canhear_range = 0
	radio.recalculateChannels()*/

/obj/machinery/atmospherics/components/unary/cryo_cell/proc/process_occupant()
	if(occupant)
		if(occupant.stat == DEAD)
			return
		if(occupant.health > (occupant.maxHealth - 2) && auto_release) //release the patient automatically when at, or near full health
			go_out(TRUE)
			return
		occupant.bodytemperature = 100 //Temp fix for broken atmos
		occupant.stat = 1
		if(occupant.bodytemperature < T0C)
			occupant.KnockDown(10)
			if(occupant.getOxyLoss())
				occupant.adjustOxyLoss(-1)

			//severe damage should heal waaay slower without proper chemicals
			if(occupant.bodytemperature < 225)
				if (occupant.getToxLoss())
					occupant.adjustToxLoss(max(-1, -20/occupant.getToxLoss()))
				var/heal_brute = occupant.getBruteLoss() ? min(1, 20/occupant.getBruteLoss()) : 0
				var/heal_fire = occupant.getFireLoss() ? min(1, 20/occupant.getFireLoss()) : 0
				occupant.heal_limb_damage(heal_brute,heal_fire)
		var/has_cryo = occupant.reagents.get_reagent_amount("cryoxadone") >= 1
		var/has_clonexa = occupant.reagents.get_reagent_amount("clonexadone") >= 1
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
	..()
	if(in_range(user, src) || isobserver(user))
		to_chat(user, "<span class='notice'>The status display reads: Efficiency at <b>[efficiency*100]%</b>.<span>")

/obj/machinery/atmospherics/components/unary/cryo_cell/Destroy()
	//QDEL_NULL(radio)
	QDEL_NULL(beaker)
	return ..()

///obj/machinery/atmospherics/components/unary/cryo_cell/contents_explosion(severity, target)
//	..()
//	if(beaker)
//		beaker.ex_act(severity, target)

///obj/machinery/atmospherics/components/unary/cryo_cell/handle_atom_del(atom/A)
//	..()
//	if(A == beaker)
//		beaker = null
//		updateUsrDialog()

/obj/machinery/atmospherics/components/unary/cryo_cell/update_icon()
	if(on)
		if(occupant)
			icon_state = "cell-occupied"
			return
		icon_state = "cell-on"
		return
	icon_state = "cell-off"

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
	addtimer(CALLBACK(src, .proc/run_anim, anim_up, occupant_overlay), 7, TIMER_UNIQUE)

/obj/machinery/atmospherics/components/unary/cryo_cell/proc/go_out(auto_eject = null, dead = null)
	if(!( occupant ))
		return
	if (occupant.client)
		occupant.client.eye = occupant.client.mob
		occupant.client.perspective = MOB_PERSPECTIVE
	if(occupant in contents)
		occupant.loc = get_step(loc, SOUTH)	//this doesn't account for walls or anything, but i don't forsee that being a problem.
	if (occupant.bodytemperature < 261 && occupant.bodytemperature >= 70) //Patch by Aranclanos to stop people from taking burn damage after being ejected
		occupant.bodytemperature = 261									  // Changed to 70 from 140 by Zuhayr due to reoccurance of bug.
	if(auto_eject) //Turn off and announce if auto-ejected because patient is recovered or dead.
		turn_off()
		if(release_notice) //If auto-release notices are on as it should be, let the doctors know what's up
			playsound(src.loc, 'sound/machines/ping.ogg', 100, 14)
			var/reason = "Reason for release:</b> Patient recovery."
			if(dead)
				reason = "<b>Reason for release:</b> Patient death."
			var/mob/living/silicon/ai/AI = new/mob/living/silicon/ai(src, null, null, 1)
			AI.SetName("Cryotube Notification System")
			AI.aiRadio.talk_into(AI,"Patient [occupant] has been automatically released from [src] at: [get_area(occupant)]. [reason]","MedSci","announces")
			qdel(AI)
	occupant = null
	update_use_power(1)
	update_icon()
	return

/obj/machinery/atmospherics/components/unary/cryo_cell/proc/turn_off()
	on = FALSE
	stop_processing()
	update_icon()

/obj/machinery/atmospherics/components/unary/cryo_cell/process()
	..()
	if(machine_stat & (NOPOWER|BROKEN))
		turn_off()
		updateUsrDialog()
		return

	if(!on)
		updateUsrDialog()
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

	updateUsrDialog()
	return 1
/*
/obj/machinery/atmospherics/components/unary/cryo_cell/process_atmos()
	..()

	if(!on)
		return

	var/datum/gas_mixture/air1 = airs[1]

	if(!nodes[1] || !airs[1] || !air1.gases.len || air1.gases[/datum/gas/oxygen][MOLES] < 5) // Turn off if the machine won't work.
		on = FALSE
		update_icon()
		return

	if(occupant)
		var/mob/living/mob_occupant = occupant
		var/cold_protection = 0
		var/temperature_delta = air1.temperature - mob_occupant.bodytemperature // The only semi-realistic thing here: share temperature between the cell and the occupant.

		if(ishuman(occupant))
			var/mob/living/carbon/human/H = occupant
			cold_protection = H.get_cold_protection(air1.temperature)

		if(abs(temperature_delta) > 1)
			var/air_heat_capacity = air1.heat_capacity()

			var/heat = ((1 - cold_protection) * 0.1 + conduction_coefficient) * temperature_delta * (air_heat_capacity * heat_capacity / (air_heat_capacity + heat_capacity))

			air1.temperature = max(air1.temperature - heat / air_heat_capacity, TCMB)
			mob_occupant.adjust_bodytemperature(heat / heat_capacity, TCMB)

		air1.gases[/datum/gas/oxygen][MOLES] = max(0,air1.gases[/datum/gas/oxygen][MOLES] - 0.5 / efficiency) // Magically consume gas? Why not, we run on cryo magic.
		air1.garbage_collect()
*/
/obj/machinery/atmospherics/components/unary/cryo_cell/power_change()
	..()
	update_icon()

/obj/machinery/atmospherics/components/unary/cryo_cell/relaymove(mob/user)
	if(message_cooldown <= world.time)
		message_cooldown = world.time + 50
		to_chat(user, "<span class='warning'>[src]'s door won't budge!</span>")
/*
/obj/machinery/atmospherics/components/unary/cryo_cell/open_machine(drop = FALSE)
	if(!state_open && !panel_open)
		on = FALSE
	for(var/mob/M in contents) //only drop mobs
		M.forceMove(get_turf(src))
		if(isliving(M))
			var/mob/living/L = M
			L.update_mobility()
	occupant = null
	flick("pod-open-anim", src)
	..()

/obj/machinery/atmospherics/components/unary/cryo_cell/close_machine(mob/living/carbon/user)
	if((isnull(user) || istype(user)) && state_open && !panel_open)
		flick("pod-close-anim", src)
		..(user)
		return occupant*/

/obj/machinery/atmospherics/components/unary/cryo_cell/verb/move_eject()
	set name = "Eject occupant"
	set category = "Object"
	set src in oview(1)
	if(usr == occupant)//If the user is inside the tube...
		if (usr.stat == 2)//and he's not dead....
			return
		to_chat(usr, "<span class='notice'>Auto release sequence activated. You will be released when you have recovered.</span>")
		auto_release = TRUE
	else
		if (usr.stat != 0)
			return
		go_out()
	add_fingerprint(usr)
	return

/obj/machinery/atmospherics/components/unary/cryo_cell/examine(mob/user)
	..()
	if(occupant)
		if(on)
			to_chat(user, "Someone's inside [src]!")
		else
			to_chat(user, "You can barely make out a form floating in [src].")
	else
		to_chat(user, "[src] seems empty.")

/obj/machinery/atmospherics/components/unary/cryo_cell/attackby(obj/item/W, mob/living/user)
	if(istype(W, /obj/item/reagent_container/glass))
		if(beaker)
			to_chat(user, "<span class='warning'>A beaker is already loaded into the machine.</span>")
			return

		if(istype(W, /obj/item/reagent_container/glass/bucket))
			to_chat(user, "<span class='warning'>That's too big to fit!</span>")
			return

		beaker =  W

		var/reagentnames = ""
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			reagentnames += ";[R.name]"

		log_admin("[key_name(usr)] put a [beaker] into [src], containing [reagentnames] at [AREACOORD(src.loc)].")
		message_admins("[ADMIN_TPMONTY(usr)] put a [beaker] into [src], containing [reagentnames].")


		if(user.transferItemToLoc(W, src))
			user.visible_message("[user] adds \a [W] to \the [src]!", "You add \a [W] to \the [src]!")
		return

	else if(istype(W, /obj/item/device/healthanalyzer) && occupant) //Allows us to use the analyzer on the occupant without taking him out.
		var/obj/item/device/healthanalyzer/J = W
		J.attack(occupant, user)
		return

	if(!istype(W, /obj/item/grab))
		return

	if(machine_stat & (NOPOWER|BROKEN))
		to_chat(user, "<span class='notice'>\ [src] is non-functional!</span>")
		return

	if(src.occupant)
		to_chat(user, "<span class='notice'>\ [src] is already occupied!</span>")
		return

	var/obj/item/grab/G = W
	var/mob/M
	if(ismob(G.grabbed_thing))
		M = G.grabbed_thing
	else if(istype(G.grabbed_thing,/obj/structure/closet/bodybag/cryobag))
		var/obj/structure/closet/bodybag/cryobag/C = G.grabbed_thing
		if(!C.stasis_mob)
			to_chat(user, "<span class='warning'>The stasis bag is empty!</span>")
			return
		M = C.stasis_mob
		C.open()
		user.start_pulling(M)
	else
		return

	if(!ishuman(M)) // stop fucking monkeys and xenos being put in.
		to_chat(user, "<span class='notice'>\ [src] is compatible with humanoid anatomies only!</span>")
		return

	if (M.abiotic())
		to_chat(user, "<span class='warning'>Subject cannot have abiotic items on.</span>")
		return

	put_mob(M, TRUE)

	updateUsrDialog()

/obj/machinery/atmospherics/components/unary/cryo_cell/proc/put_mob(mob/living/carbon/M as mob, put_in = null)
	if (machine_stat & (NOPOWER|BROKEN))
		to_chat(usr, "<span class='warning'>The cryo cell is not functioning.</span>")
		return
	if(!ishuman(M)) // stop fucking monkeys and xenos being put in.
		to_chat(usr, "<span class='notice'>\ [src] is compatible with humanoid anatomies only!</span>")
		return
	if (occupant)
		to_chat(usr, "<span class='danger'>The cryo cell is already occupied!</span>")
		return
	if (M.abiotic())
		to_chat(usr, "<span class='warning'>Subject may not have abiotic items on.</span>")
		return
	if(put_in) //Select an appropriate message
		visible_message("<span class='notice'>[usr] puts [M] in [src].</span>", 3)
	else
		visible_message("<span class='notice'>[usr] climbs into [src].</span>", 3)
	M.forceMove(src)
	if(M.health > -100 && (M.health < 0 || M.sleeping))
		to_chat(M, "<span class='boldnotice'>You feel a cold liquid surround you. Your skin starts to freeze up.</span>")
	occupant = M
	update_use_power(2)
//	M.metabslow = 1
	add_fingerprint(usr)
	update_icon()
	return 1

/obj/machinery/atmospherics/components/unary/cryo_cell/Topic(href, href_list)
	if (!href_list["scanreport"])
		return
	if(!hasHUD(usr,"medical"))
		return
	if(get_dist(usr, src) > 7)
		to_chat(usr, "<span class='warning'>[src] is too far away.</span>")
		return
	if(!ishuman(occupant))
		return
	var/mob/living/carbon/human/H = occupant
	for(var/datum/data/record/R in GLOB.datacore.medical)
		if (!R.fields["name"] == H.real_name)
			continue
		if(R.fields["last_scan_time"] && R.fields["last_scan_result"])
			usr << browse(R.fields["last_scan_result"], "window=scanresults;size=430x600")
		break

/obj/machinery/atmospherics/components/unary/cryo_cell/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/atmospherics/components/unary/cryo_cell/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)

	if(user == occupant || user.stat)
		return

	// this is the data which will be sent to the ui
	var/data[0]
	data["isOperating"] = on
	data["hasOccupant"] = occupant ? 1 : 0
	data["autoRelease"] = auto_release
	data["releaseNotice"] = release_notice

	var/occupantData[0]
	if (occupant)
		occupantData["name"] = occupant.name
		occupantData["stat"] = occupant.stat
		occupantData["health"] = occupant.health
		occupantData["maxHealth"] = occupant.maxHealth
		occupantData["minHealth"] = CONFIG_GET(number/health_threshold_dead)
		occupantData["bruteLoss"] = occupant.getBruteLoss()
		occupantData["oxyLoss"] = occupant.getOxyLoss()
		occupantData["toxLoss"] = occupant.getToxLoss()
		occupantData["fireLoss"] = occupant.getFireLoss()
		occupantData["bodyTemperature"] = occupant.bodytemperature
	data["occupant"] = occupantData;

	data["cellTemperature"] = round(temperature)
	data["cellTemperatureStatus"] = "good"
	if(temperature > T0C) // if greater than 273.15 kelvin (0 celcius)
		data["cellTemperatureStatus"] = "bad"
	else if(temperature > 225)
		data["cellTemperatureStatus"] = "average"

	data["isBeakerLoaded"] = beaker ? 1 : 0
	/* // Removing beaker contents list from front-end, replacing with a total remaining volume
	var beakerContents[0]
	if(beaker && beaker.reagents && beaker.reagents.reagent_list.len)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents.Add(list(list("name" = R.name, "volume" = R.volume))) // list in a list because Byond merges the first list...
	data["beakerContents"] = beakerContents
	*/
	data["beakerLabel"] = null
	data["beakerVolume"] = 0
	if(beaker)
		data["beakerLabel"] = beaker.label_text ? beaker.label_text : null
		if (beaker.reagents && beaker.reagents.reagent_list.len)
			for(var/datum/reagent/R in beaker.reagents.reagent_list)
				data["beakerVolume"] += R.volume

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "cryo.tmpl", "Cryo Cell Control System", 520, 410)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/machinery/atmospherics/components/unary/cryo_cell/proc/turn_on()
	if (machine_stat & (NOPOWER|BROKEN))
		to_chat(usr, "<span class='warning'>The cryo cell is not functioning.</span>")
		return
	on = TRUE
	start_processing()
	update_icon()

/obj/machinery/atmospherics/components/unary/cryo_cell/Topic(href, href_list)
	if(usr == occupant)
		return 0 // don't update UIs attached to this object

	if(..())
		return 0 // don't update UIs attached to this object

	if(href_list["switchOn"])
		turn_on()

	if(href_list["switchOff"])
		turn_off()

	if(href_list["ejectBeaker"])
		if(beaker)
			beaker.loc = get_step(loc, SOUTH)
			beaker = null

	if(href_list["ejectOccupant"])
		if(!occupant)
			return // don't update UIs attached to this object
		go_out()

	if(href_list["releaseOn"])
		auto_release = TRUE

	if(href_list["releaseOff"])
		auto_release = FALSE

	if(href_list["noticeOn"])
		release_notice = TRUE

	if(href_list["noticeOff"])
		release_notice = FALSE

	add_fingerprint(usr)
	return 1 // update UIs attached to this object


///obj/machinery/atmospherics/components/unary/cryo_cell/update_remote_sight(mob/living/user)
//	return // we don't see the pipe network while inside cryo.

///obj/machinery/atmospherics/components/unary/cryo_cell/get_remote_view_fullscreens(mob/user)
//	user.overlay_fullscreen("remote_view", /obj/screen/fullscreen/impaired, 1)

/obj/machinery/atmospherics/components/unary/cryo_cell/can_crawl_through()
	return // can't ventcrawl in or out of cryo.

/obj/machinery/atmospherics/components/unary/cryo_cell/can_see_pipes()
	return 0 // you can't see the pipe network when inside a cryo cell.

/obj/machinery/atmospherics/components/unary/cryo_cell/return_temperature()
	//var/datum/gas_mixture/G = airs[1]

	//if(G.total_moles() > 10)
	//	return G.temperature
	//return ..()
/*
/obj/machinery/atmospherics/components/unary/cryo_cell/default_change_direction_wrench(mob/user, obj/item/wrench/W)
	. = ..()
	if(.)
		SetInitDirections()
		var/obj/machinery/atmospherics/node = nodes[1]
		if(node)
			node.disconnect(src)
			nodes[1] = null
		nullifyPipenet(parents[1])
		atmosinit()
		node = nodes[1]
		if(node)
			node.atmosinit()
			node.addMember(src)
		build_network()*/

#undef CRYOMOBS
