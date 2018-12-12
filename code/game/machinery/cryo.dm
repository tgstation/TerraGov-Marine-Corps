#define HEAT_CAPACITY_HUMAN 100 //249840 J/K, for a 72 kg person.

/obj/machinery/cryo_cell
	name = "cryo cell"
	icon = 'icons/obj/machines/cryogenics2.dmi'
	icon_state = "cell-off"
	density = 0
	anchored = 1.0
	layer = BELOW_OBJ_LAYER

	var/temperature = 100

	var/on = FALSE
	var/auto_release = FALSE
	var/release_notice = FALSE
	use_power = 1
	idle_power_usage = 20
	active_power_usage = 200
	var/idle_ticks_until_shutdown = 60 //Number of ticks permitted to elapse without a patient before the cryotube shuts itself off to save processing

	var/mob/living/carbon/occupant = null
	var/obj/item/reagent_container/glass/beaker = null

/obj/machinery/cryo_cell/Destroy()
	stop_processing()
	return ..()

/obj/machinery/cryo_cell/New()
	beaker = new /obj/item/reagent_container/glass/beaker/cryomix
	return ..()

/obj/machinery/cryo_cell/examine(mob/living/user)
	..()
	var/active = ""
	if(occupant) //Compile and disclose details of operation.
		active += "It contains: [occupant]."
	else
		active += "It is empty."
	if(auto_release)
		active += " Auto-release is active."
	if(release_notice)
		active += " Auto-notifications are active."
	to_chat(user, "<span class='notice'>[active]</span>")
	if(!hasHUD(user,"medical"))
		return
	if(!ishuman(occupant))
		return
	var/mob/living/carbon/human/H = occupant
	for(var/datum/data/record/R in data_core.medical) //Allows us to reference medical files/scan reports for cryo via examination.
		if (R.fields["name"] == H.real_name)
			if(!(R.fields["last_scan_time"]))
				to_chat(user, "<span class = 'deptradio'>No medical scan report for [occupant] on record.</span>\n")
			else
				to_chat(user, "<span class = 'deptradio'>Last medical scan for [occupant]: <a href='?src=\ref[occupant];scanreport=1'>[R.fields["last_scan_time"]]</a></span>\n")
			break

/obj/machinery/cryo_cell/Topic(href, href_list)
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
	for(var/datum/data/record/R in data_core.medical)
		if (!R.fields["name"] == H.real_name)
			continue
		if(R.fields["last_scan_time"] && R.fields["last_scan_result"])
			usr << browse(R.fields["last_scan_result"], "window=scanresults;size=430x600")
		break

/obj/machinery/cryo_cell/process()
	..()
	if(stat & (NOPOWER|BROKEN))
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


/obj/machinery/cryo_cell/allow_drop()
	return 0


/obj/machinery/cryo_cell/relaymove(mob/user)
	if(user.is_mob_incapacitated(TRUE)) return
	go_out()


/obj/machinery/cryo_cell/attack_hand(mob/user)
	ui_interact(user)

 /**
  * The ui_interact proc is used to open and update Nano UIs
  * If ui_interact is not used then the UI will not update correctly
  * ui_interact is currently defined for /atom/movable (which is inherited by /obj and /mob)
  *
  * @param user /mob The mob who is interacting with this ui
  * @param ui_key string A string key to use for this ui. Allows for multiple unique uis on one obj/mob (defaut value "main")
  * @param ui /datum/nanoui This parameter is passed by the nanoui process() proc when updating an open ui
  *
  * @return nothing
  */
/obj/machinery/cryo_cell/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)

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
		occupantData["minHealth"] = config.health_threshold_dead
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

/obj/machinery/cryo_cell/Topic(href, href_list)
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

/obj/machinery/cryo_cell/attackby(obj/item/W, mob/living/user)
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

		message_admins("[key_name(usr)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[usr.x];Y=[usr.y];Z=[usr.z]'>JMP</a>) (<A HREF='?_src_=holder;adminplayerfollow=\ref[usr]'>FLW</a>) put a [beaker] into [src], containing [reagentnames] at ([src.loc.x],[src.loc.y],[src.loc.z]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[src.loc.x];Y=[src.loc.y];Z=[src.loc.z]'>JMP</a>).", 1)
		log_admin("[key_name(usr)] put a [beaker] into [src], containing [reagentnames] at ([src.loc.x],[src.loc.y],[src.loc.z]).")

		if(user.drop_inv_item_to_loc(W, src))
			user.visible_message("[user] adds \a [W] to \the [src]!", "You add \a [W] to \the [src]!")
		return

	else if(istype(W, /obj/item/device/healthanalyzer) && occupant) //Allows us to use the analyzer on the occupant without taking him out.
		var/obj/item/device/healthanalyzer/J = W
		J.attack(occupant, user)
		return

	if(!istype(W, /obj/item/grab))
		return

	if(stat & (NOPOWER|BROKEN))
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


/obj/machinery/cryo_cell/update_icon()
	if(on)
		if(occupant)
			icon_state = "cell-occupied"
			return
		icon_state = "cell-on"
		return
	icon_state = "cell-off"

/obj/machinery/cryo_cell/proc/process_occupant()
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



/obj/machinery/cryo_cell/proc/go_out(auto_eject = null, dead = null)
	if(!( occupant ))
		return
	if (occupant.client)
		occupant.client.eye = occupant.client.mob
		occupant.client.perspective = MOB_PERSPECTIVE
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

/obj/machinery/cryo_cell/proc/turn_off()
	on = FALSE
	stop_processing()
	update_icon()

/obj/machinery/cryo_cell/proc/turn_on()
	if (stat & (NOPOWER|BROKEN))
		to_chat(usr, "\red The cryo cell is not functioning.")
		return
	on = TRUE
	start_processing()
	update_icon()

/obj/machinery/cryo_cell/proc/put_mob(mob/living/carbon/M as mob, put_in = null)
	if (stat & (NOPOWER|BROKEN))
		to_chat(usr, "\red The cryo cell is not functioning.")
		return
	if(!ishuman(M)) // stop fucking monkeys and xenos being put in.
		to_chat(usr, "<span class='notice'>\ [src] is compatible with humanoid anatomies only!</span>")
		return
	if (occupant)
		to_chat(usr, "\red <B>The cryo cell is already occupied!</B>")
		return
	if (M.abiotic())
		to_chat(usr, "\red Subject may not have abiotic items on.")
		return
	if(put_in) //Select an appropriate message
		visible_message("<span class='notice'>[usr] puts [M] in [src].</span>", 3)
	else
		visible_message("<span class='notice'>[usr] climbs into [src].</span>", 3)
	M.forceMove(src)
	if(M.health > -100 && (M.health < 0 || M.sleeping))
		to_chat(M, "\blue <b>You feel a cold liquid surround you. Your skin starts to freeze up.</b>")
	occupant = M
	update_use_power(2)
//	M.metabslow = 1
	add_fingerprint(usr)
	update_icon()
	return 1

/obj/machinery/cryo_cell/verb/move_eject()
	set name = "Eject occupant"
	set category = "Object"
	set src in oview(1)
	if(usr == occupant)//If the user is inside the tube...
		if (usr.stat == 2)//and he's not dead....
			return
		to_chat(usr, "\blue Auto release sequence activated. You will be released when you have recovered.")
		auto_release = TRUE
	else
		if (usr.stat != 0)
			return
		go_out()
	add_fingerprint(usr)
	return

/obj/machinery/cryo_cell/verb/move_inside()
	set name = "Move Inside"
	set category = "Object"
	set src in oview(1)
	if (usr.stat != 0)
		return
	visible_message("[usr] attempts to climb inside [src].", 3)
	put_mob(usr)
	return



/datum/data/function/proc/reset()
	return

/datum/data/function/proc/r_input(href, href_list, mob/user as mob)
	return

/datum/data/function/proc/display()
	return


