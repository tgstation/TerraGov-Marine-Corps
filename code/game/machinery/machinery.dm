/*
Overview:
   Used to create objects that need a per step proc call.  Default definition of 'New()'
   stores a reference to src machine in global 'machines list'.  Default definition
   of 'Del' removes reference to src machine in global 'machines list'.

Class Variables:
   use_power (num)
      current state of auto power use.
      Possible Values:
         0 -- no auto power use
         1 -- machine is using power at its idle power level
         2 -- machine is using power at its active power level

   active_power_usage (num)
      Value for the amount of power to use when in active power mode

   idle_power_usage (num)
      Value for the amount of power to use when in idle power mode

   power_channel (num)
      What channel to draw from when drawing power for power mode
      Possible Values:
         EQUIP:0 -- Equipment Channel
         LIGHT:2 -- Lighting Channel
         ENVIRON:3 -- Environment Channel

   component_parts (list)
      A list of component parts of machine used by frame based machines.

   uid (num)
      Unique id of machine across all machines.

   gl_uid (global num)
      Next uid value in sequence

   stat (bitflag)
      Machine status bit flags.
      Possible bit flags:
         BROKEN:1 -- Machine is broken
         NOPOWER:2 -- No power is being supplied to machine.
         POWEROFF:4 -- tbd
         MAINT:8 -- machine is currently under going maintenance.
         EMPED:16 -- temporary broken by EMP pulse

   manual (num)
      Currently unused.

Class Procs:
   New()                     'game/machinery/machine.dm'

   Destroy()                     'game/machinery/machine.dm'

   auto_use_power()            'game/machinery/machine.dm'
      This proc determines how power mode power is deducted by the machine.
      'auto_use_power()' is called by the 'master_controller' game_controller every
      tick.

      Return Value:
         return:1 -- if object is powered
         return:0 -- if object is not powered.

      Default definition uses 'use_power', 'power_channel', 'active_power_usage',
      'idle_power_usage', 'powered()', and 'use_power()' implement behavior.

   powered(chan = EQUIP)         'modules/power/power.dm'
      Checks to see if area that contains the object has power available for power
      channel given in 'chan'.

   use_power(amount, chan=EQUIP, autocalled)   'modules/power/power.dm'
      Deducts 'amount' from the power channel 'chan' of the area that contains the object.
      If it's autocalled then everything is normal, if something else calls use_power we are going to
      need to recalculate the power two ticks in a row.

   power_change()               'modules/power/power.dm'
      Called by the area that contains the object when ever that area under goes a
      power state change (area runs out of power, or area channel is turned off).

   RefreshParts()               'game/machinery/machine.dm'
      Called to refresh the variables in the machine that are contributed to by parts
      contained in the component_parts list. (example: glass and material amounts for
      the autolathe)

      Default definition does nothing.

   assign_uid()               'game/machinery/machine.dm'
      Called by machine to assign a value to the uid variable.

   process()                  'game/machinery/machine.dm'
      Called by the 'master_controller' once per game tick for each machine that is listed in the 'machines' list.


	Compiled by Aygar
*/

/obj/machinery
	name = "machinery"
	icon = 'icons/obj/stationobjs.dmi'
	var/machine_stat = NOFLAGS
	var/emagged = 0
	var/use_power = IDLE_POWER_USE
		//0 = dont run the auto
		//1 = run auto, use idle
		//2 = run auto, use active
	var/idle_power_usage = 0
	var/active_power_usage = 0
	var/machine_current_charge = 0 //Does it have an integrated, unremovable capacitor? Normally 10k if so.
	var/machine_max_charge = 0
	var/power_channel = EQUIP
	var/panel_open = FALSE
	var/mob/living/carbon/human/operator = null //Had no idea where to put this so I put this here. Used for operating machines with RELAY_CLICK
		//EQUIP,ENVIRON or LIGHT
	var/list/component_parts = list() //list of all the parts used to build it, if made from certain kinds of frames.
	var/uid
	var/manual = 0
	var/global/gl_uid = 1
	layer = OBJ_LAYER
	var/machine_processing = 0 // whether the machine is busy and requires process() calls in scheduler.

	var/wrenchable = FALSE
	var/damage = 0
	var/damage_cap = 1000 //The point where things start breaking down.

/obj/machinery/attackby(obj/item/C as obj, mob/user as mob)
	. = ..()
	if(istype(C, /obj/item/tool/pickaxe/plasmacutter) && !user.action_busy && !CHECK_BITFIELD(resistance_flags, UNACIDABLE|INDESTRUCTIBLE))
		var/obj/item/tool/pickaxe/plasmacutter/P = C
		if(!P.start_cut(user, name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_LOW_MOD))
			return
		if(do_after(user, P.calc_delay(user) * PLASMACUTTER_LOW_MOD, TRUE, 5, BUSY_ICON_HOSTILE) && P)
			P.cut_apart(user, name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_LOW_MOD)
			qdel()
		return

/obj/machinery/Initialize()
	. = ..()
	GLOB.machines += src
	var/area/A = get_area(src)
	if(A)
		A.area_machines += src

/obj/machinery/Destroy()
	GLOB.machines -= src
	processing_machines -= src
	var/area/A = get_area(src)
	if(A)
		A.area_machines -= src
	. = ..()

/obj/machinery/proc/dropContents(list/subset = null)
	var/turf/T = get_turf(src)
	for(var/atom/movable/A in contents)
		if(subset && !(A in subset))
			continue
		A.forceMove(T)
//		if(isliving(A))
//			var/mob/living/L = A
//			L.update_mobility()

/obj/machinery/proc/is_operational()
	return !(machine_stat & (NOPOWER|BROKEN|MAINT))

/obj/machinery/proc/deconstruct()
	return

//called on machinery construction (i.e from frame to machinery) but not on initialization
/obj/machinery/proc/on_construction()
	return

/obj/machinery/proc/start_processing()
	if(!machine_processing)
		machine_processing = TRUE
		processing_machines += src

/obj/machinery/proc/stop_processing()
	if(machine_processing)
		machine_processing = FALSE
		processing_machines -= src

/obj/machinery/process()//If you dont use process or power why are you here
	return PROCESS_KILL

/obj/machinery/emp_act(severity)
	if(CHECK_BITFIELD(resistance_flags, INDESTRUCTIBLE))
		return FALSE
	if(use_power && machine_stat == 0)
		use_power(7500/severity)
	new /obj/effect/overlay/temp/emp_sparks (loc)
	..()


/obj/machinery/ex_act(severity)
	if(CHECK_BITFIELD(resistance_flags, INDESTRUCTIBLE))
		return FALSE
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return
		if(3.0)
			if (prob(25))
				qdel(src)
				return
		else
	return

//sets the use_power var and then forces an area power update
/obj/machinery/proc/update_use_power(var/new_use_power, var/force_update = 0)
	if ((new_use_power == use_power) && !force_update)
		return	//don't need to do anything

	use_power = new_use_power

	//force area power update
	force_power_update()

/obj/machinery/proc/force_power_update()
	var/area/A = get_area(src)
	if(A && A.master)
		A.master.powerupdate = 1

/obj/machinery/proc/power_change()
	if(!powered(power_channel) && (machine_current_charge <= 0))
		machine_stat |= NOPOWER
	else
		machine_stat &= ~NOPOWER

/obj/machinery/proc/auto_use_power()
	if(!powered(power_channel))
		if(use_power && (machine_current_charge > idle_power_usage)) //Does it have an integrated battery/reserve power to tap into?
			machine_current_charge -= min(machine_current_charge, idle_power_usage) //Sterilize with min; no negatives allowed.
			update_icon()
			return TRUE
		else if(machine_current_charge > active_power_usage)
			machine_current_charge -= min(machine_current_charge, active_power_usage)
			update_icon()
			return TRUE
		else
			return FALSE

	switch(use_power)
		if(IDLE_POWER_USE)
			if((machine_current_charge < machine_max_charge) && anchored) //here we handle recharging the internal battery of machines
				var/power_usage = (min(500,max(0,machine_max_charge - machine_current_charge)))
				machine_current_charge += power_usage //recharge internal cell at max rate of 500
				use_power(power_usage,power_channel, TRUE)
				update_icon()
			else
				use_power(idle_power_usage,power_channel, TRUE)

		if(ACTIVE_POWER_USE)
			use_power(active_power_usage,power_channel, TRUE)
	return TRUE

/obj/machinery/proc/operable(var/additional_flags = 0)
	return !inoperable(additional_flags)

/obj/machinery/proc/inoperable(var/additional_flags = 0)
	return (machine_stat & (NOPOWER|BROKEN|additional_flags))

/obj/machinery/Topic(href, href_list)
	..()
	if(inoperable())
		return 1
	if(usr.restrained() || usr.lying || usr.stat)
		return 1
	if (!ishuman(usr) && !ismonkey(usr) && !issilicon(usr) && !isxeno(usr))
		to_chat(usr, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return 1

	var/norange = 0
	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		if(istype(H.l_hand, /obj/item/tk_grab))
			norange = 1
		else if(istype(H.r_hand, /obj/item/tk_grab))
			norange = 1

	if(!norange)
		if ((!in_range(src, usr) || !istype(src.loc, /turf)) && !issilicon(usr))
			return 1

	src.add_fingerprint(usr)

	var/area/A = get_area(src)
	A.master.powerupdate = 1

	return 0

/obj/machinery/attack_ai(mob/user as mob)
	if(iscyborg(user))
		// For some reason attack_robot doesn't work
		// This is to stop robots from using cameras to remotely control machines.
		if(user.client && user.client.eye == user)
			return src.attack_hand(user)
	else
		return src.attack_hand(user)

/obj/machinery/attack_paw(mob/user as mob)
	return src.attack_hand(user)

//Xenomorphs can't use machinery, not even the "intelligent" ones
//Exception is Queen and shuttles, because plot power
/obj/machinery/attack_alien(mob/living/carbon/Xenomorph/M)
	to_chat(M, "<span class='warning'>You stare at \the [src] cluelessly.</span>")

/obj/machinery/attack_hand(mob/user as mob)
	if(inoperable(MAINT))
		return 1
	if(user.lying || user.stat)
		return 1
	if (!ishuman(usr) && !ismonkey(usr) && !issilicon(usr) && !isxeno(usr))
		to_chat(usr, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return 1
/*
	//distance checks are made by atom/proc/clicked()
	if ((get_dist(src, user) > 1 || !istype(src.loc, /turf)) && !issilicon(user))
		return 1
*/
	if (ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.getBrainLoss() >= 60)
			visible_message("<span class='warning'> [H] stares cluelessly at [src] and drools.</span>")
			return 1
		else if(prob(H.getBrainLoss()))
			to_chat(user, "<span class='warning'>You momentarily forget how to use [src].</span>")
			return 1

	src.add_fingerprint(user)

	var/area/A = get_area(src)
	A.master.powerupdate = 1

	return 0

/obj/machinery/proc/RefreshParts() //Placeholder proc for machines that are built using frames.
	return
	return 0

/obj/machinery/proc/assign_uid()
	uid = gl_uid
	gl_uid++

/obj/machinery/proc/state(var/msg)
  for(var/mob/O in hearers(src, null))
    O.show_message("[icon2html(src, O)] <span class = 'notice'>[msg]</span>", 2)

/obj/machinery/proc/ping(text=null)
  if (!text)
    text = "\The [src] pings."

  state(text, "blue")
  playsound(src.loc, 'sound/machines/ping.ogg', 25, 0)

/obj/machinery/proc/shock(mob/user, prb)
	if(inoperable())
		return 0
	if(!prob(prb))
		return 0
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	if (electrocute_mob(user, get_area(src), src, 0.7))
		return 1
	else
		return 0

/obj/machinery/proc/dismantle()
	playsound(loc, 'sound/items/Crowbar.ogg', 25, 1)
	var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(loc)
	M.state = 2
	M.icon_state = "box_1"
	for(var/obj/I in component_parts)
		if(I.reliability != 100 && crit_fail)
			I.crit_fail = 1
		I.loc = loc
	qdel(src)
	return 1

obj/machinery/proc/med_scan(mob/living/carbon/human/H, dat, var/list/known_implants)
	var/datum/data/record/N = null
	for(var/datum/data/record/R in GLOB.datacore.medical)
		if (R.fields["name"] == H.real_name)
			N = R
	if(isnull(N))
		N = create_medical_record(H)
	var/list/od = get_occupant_data(H)
	dat = format_occupant_data(od, H, known_implants)
	N.fields["last_scan_time"] = od["stationtime"]
	N.fields["last_scan_result"] = dat
	N.fields["autodoc_data"] = generate_autodoc_surgery_list(H)
	visible_message("<span class='notice'>\The [src] pings as it stores the scan report of [H.real_name]</span>")
	playsound(src.loc, 'sound/machines/ping.ogg', 25, 1)
	return dat

/obj/machinery/proc/get_occupant_data(mob/living/carbon/human/H)
	if (!H)
		return
	var/list/occupant_data = list(
		"stationtime" = worldtime2text(),
		"stat" = H.stat,
		"health" = H.health,
		"bruteloss" = H.getBruteLoss(),
		"fireloss" = H.getFireLoss(),
		"oxyloss" = H.getOxyLoss(),
		"toxloss" = H.getToxLoss(),
		"rads" = H.radiation,
		"cloneloss" = H.getCloneLoss(),
		"brainloss" = H.getBrainLoss(),
		"knocked_out" = H.knocked_out,
		"bodytemp" = H.bodytemperature,
		"inaprovaline_amount" = H.reagents.get_reagent_amount("inaprovaline"),
		"dexalin_amount" = H.reagents.get_reagent_amount("dexalin"),
		"sleeptoxin_amount" = H.reagents.get_reagent_amount("sleeptoxin"),
		"bicaridine_amount" = H.reagents.get_reagent_amount("bicaridine"),
		"dermaline_amount" = H.reagents.get_reagent_amount("dermaline"),
		"blood_amount" = H.blood_volume,
		"disabilities" = H.sdisabilities,
		"tg_diseases_list" = H.viruses.Copy(),
		"lung_ruptured" = H.is_lung_ruptured(),
		"external_organs" = H.limbs.Copy(),
		"internal_organs" = H.internal_organs.Copy(),
		"species_organs" = H.species.has_organ //Just pass a reference for this, it shouldn't ever be modified outside of the datum.
		)
	return occupant_data

/obj/machinery/proc/format_occupant_data(var/list/occ, mob/living/carbon/human/H, var/list/known_implants)
	var/dat = "<font color='#487553'><b>Scan performed at [occ["stationtime"]]</b></font><br>"
	dat += "<font color='#487553'><b>Occupant Statistics:</b></font><br>"
	var/aux
	switch (occ["stat"])
		if(0)
			aux = "Conscious"
		if(1)
			aux = "Unconscious"
		else
			aux = "Dead"
	dat += text("[]\tHealth %: [] ([])</font><br>", (occ["health"] > 50 ? "<font color=#487553>" : "<font color=#b54646>"), occ["health"], aux)
	if (occ["virus_present"])
		dat += "<font color=#b54646>Viral pathogen detected in blood stream.</font><br>"
	dat += text("[]\t-Brute Damage %: []</font><br>", (occ["bruteloss"] < 60 ? "<font color='#487553'>" : "<font color=#b54646>"), occ["bruteloss"])
	dat += text("[]\t-Respiratory Damage %: []</font><br>", (occ["oxyloss"] < 60 ? "<font color='#487553'>" : "<font color=#b54646>"), occ["oxyloss"])
	dat += text("[]\t-Toxin Content %: []</font><br>", (occ["toxloss"] < 60 ? "<font color='#487553'>" : "<font color=#b54646>"), occ["toxloss"])
	dat += text("[]\t-Burn Severity %: []</font><br><br>", (occ["fireloss"] < 60 ? "<font color='#487553'>" : "<font color=#b54646>"), occ["fireloss"])

	dat += text("[]\tRadiation Level %: []</font><br>", (occ["rads"] < 10 ?"<font color='#487553'>" : "<font color=#b54646>"), occ["rads"])
	dat += text("[]\tGenetic Tissue Damage %: []</font><br>", (occ["cloneloss"] < 1 ?"<font color=#487553>" : "<font color=#b54646>"), occ["cloneloss"])
	dat += text("[]\tApprox. Brain Damage %: []</font><br>", (occ["brainloss"] < 1 ?"<font color=#487553>" : "<font color=#b54646>"), occ["brainloss"])
	dat += text("Knocked Out Summary %: [] ([] seconds left!)<br>", occ["knocked_out"], round(occ["knocked_out"] / 4))
	dat += text("Body Temperature: [occ["bodytemp"]-T0C]&deg;C ([occ["bodytemp"]*1.8-459.67]&deg;F)<br><HR>")

	dat += text("[]\tBlood Level %: [] ([] units)</FONT><BR>", (occ["blood_amount"] > 448 ?"<font color=#487553>" : "<font color=#b54646>"), occ["blood_amount"]*100 / 560, occ["blood_amount"])

	dat += text("Inaprovaline: [] units<BR>", occ["inaprovaline_amount"])
	dat += text("Soporific: [] units<BR>", occ["sleeptoxin_amount"])
	dat += text("[]\tDermaline: [] units</FONT><BR>", (occ["dermaline_amount"] < 30 ? "<font color='white'>" : "<font color=#b54646>"), occ["dermaline_amount"])
	dat += text("[]\tBicaridine: [] units<BR>", (occ["bicaridine_amount"] < 30 ? "<font color='white'>" : "<font color=#b54646>"), occ["bicaridine_amount"])
	dat += text("[]\tDexalin: [] units<BR>", (occ["dexalin_amount"] < 30 ? "<font color='white'>" : "<font color=#b54646>"), occ["dexalin_amount"])

	for(var/datum/disease/D in occ["tg_diseases_list"])
		if(!D.hidden[SCANNER])
			dat += text("<font color=#b54646><B>Warning: [D.form] Detected</B>\nName: [D.name].\nType: [D.spread].\nStage: [D.stage]/[D.max_stages].\nPossible Cure: [D.cure]</FONT><BR>")

	dat += "<HR><table border='1'>"
	dat += "<tr>"
	dat += "<th>Organ</th>"
	dat += "<th>Burn Damage</th>"
	dat += "<th>Brute Damage</th>"
	dat += "<th>Other Wounds</th>"
	dat += "</tr>"

	for(var/datum/limb/e in occ["external_organs"])
		var/AN = ""
		var/open = ""
		var/infected = ""
		var/necrosis = ""
		var/imp = ""
		var/bled = ""
		var/robot = ""
		var/splint = ""
		var/internal_bleeding = ""
		var/lung_ruptured = ""
		var/stabilized = ""

		dat += "<tr>"

		for(var/datum/wound/W in e.wounds)
			if(W.internal)
				internal_bleeding = "Internal bleeding<br>"
				break
		if(istype(e, /datum/limb/chest) && occ["lung_ruptured"])
			lung_ruptured = "Lung ruptured:<br>"
		if(e.limb_status & LIMB_SPLINTED)
			splint = "Splinted:<br>"
		if(e.limb_status & LIMB_STABILIZED)
			stabilized = "Stabilized:<br>"
		if(e.limb_status & LIMB_BLEEDING)
			bled = "Bleeding:<br>"
		if(e.limb_status & LIMB_BROKEN)
			AN = "[e.broken_description]:<br>"
		if(e.limb_status & LIMB_NECROTIZED)
			necrosis = "Necrotizing:<br>"
		if(e.limb_status & LIMB_ROBOT)
			robot = "Prosthetic:<br>"
		if(e.surgery_open_stage)
			open = "Open:<br>"

		switch (e.germ_level)
			if (INFECTION_LEVEL_ONE to INFECTION_LEVEL_ONE + 200)
				infected = "Mild Infection:<br>"
			if (INFECTION_LEVEL_ONE + 200 to INFECTION_LEVEL_ONE + 300)
				infected = "Mild Infection+:<br>"
			if (INFECTION_LEVEL_ONE + 300 to INFECTION_LEVEL_ONE + 400)
				infected = "Mild Infection++:<br>"
			if (INFECTION_LEVEL_TWO to INFECTION_LEVEL_TWO + 100)
				infected = "Acute Infection:<br>"
			if (INFECTION_LEVEL_TWO + 100 to INFECTION_LEVEL_TWO + 200)
				infected = "Acute Infection+:<br>"
			if (INFECTION_LEVEL_TWO + 200 to INFECTION_LEVEL_TWO + 300)
				infected = "Acute Infection++:<br>"
			if (INFECTION_LEVEL_THREE to INFECTION_LEVEL_THREE + 300)
				infected = "Septic:<br>"
			if (INFECTION_LEVEL_THREE to INFECTION_LEVEL_THREE + 600)
				infected = "Septic+:<br>"
			if (INFECTION_LEVEL_THREE to INFINITY)
				infected = "Septic++:<br>"

		var/unknown_body = 0
		if (e.implants.len)
			for(var/I in e.implants)
				if(is_type_in_list(I,known_implants))
					imp += "[I] implanted:<br>"
				else
					unknown_body++
		if(e.hidden)
			unknown_body++
		if(e.body_part == CHEST) //embryo in chest?
			if(locate(/obj/item/alien_embryo) in H)
				imp += "Larva present; extract immediately:<br>"
		if(unknown_body)
			if(unknown_body > 1)
				imp += "Unknown bodies present:<br>"
			else
				imp += "Unknown body present:<br>"

		if(!AN && !open && !infected & !imp && !necrosis && !bled && !internal_bleeding && !lung_ruptured)
			AN = "None:"
		if(!(e.limb_status & LIMB_DESTROYED))
			dat += "<td>[e.display_name]</td><td>[e.burn_dam]</td><td>[e.brute_dam]</td><td>[robot][bled][AN][splint][stabilized][open][infected][necrosis][imp][internal_bleeding][lung_ruptured]</td>"
		else
			dat += "<td>[e.display_name]</td><td>-</td><td>-</td><td>Not Found</td>"
		dat += "</tr>"

	for(var/datum/internal_organ/i in occ["internal_organs"])

		var/mech = ""
		if(i.robotic == ORGAN_ASSISTED)
			mech = "Assisted:<br>"
		if(i.robotic == ORGAN_ROBOT)
			mech = "Mechanical:<br>"

		var/infection = "None"
		switch (i.germ_level)
			if (1 to INFECTION_LEVEL_ONE + 200)
				infection = "Mild Infection:<br>"
			if (INFECTION_LEVEL_ONE + 200 to INFECTION_LEVEL_ONE + 300)
				infection = "Mild Infection+:<br>"
			if (INFECTION_LEVEL_ONE + 300 to INFECTION_LEVEL_ONE + 400)
				infection = "Mild Infection++:<br>"
			if (INFECTION_LEVEL_TWO to INFECTION_LEVEL_TWO + 100)
				infection = "Acute Infection:<br>"
			if (INFECTION_LEVEL_TWO + 100 to INFECTION_LEVEL_TWO + 200)
				infection = "Acute Infection+:<br>"
			if (INFECTION_LEVEL_TWO + 200 to INFECTION_LEVEL_TWO + 300)
				infection = "Acute Infection++:<br>"
			if (INFECTION_LEVEL_THREE to INFECTION_LEVEL_THREE + 300)
				infection = "Septic:<br>"
			if (INFECTION_LEVEL_THREE to INFECTION_LEVEL_THREE + 600)
				infection = "Septic+:<br>"
			if (INFECTION_LEVEL_THREE to INFINITY)
				infection = "Septic++:<br>"

		dat += "<tr>"
		dat += "<td>[i.name]</td><td>N/A</td><td>[i.damage]</td><td>[infection]:[mech]</td><td></td>"
		dat += "</tr>"
	dat += "</table>"

	var/list/species_organs = occ["species_organs"]
	for(var/organ_name in species_organs)
		if(!locate(species_organs[organ_name]) in occ["internal_organs"])
			dat += text("<font color=#b54646>No [organ_name] detected.</font><BR>")

	if(occ["sdisabilities"] & BLIND)
		dat += text("<font color=#b54646>Cataracts detected.</font><BR>")
	if(occ["sdisabilities"] & NEARSIGHTED)
		dat += text("<font color=#b54646>Retinal misalignment detected.</font><BR>")
	return dat


//Damage
/obj/machinery/proc/take_damage(dam)
	if(!dam || CHECK_BITFIELD(resistance_flags, INDESTRUCTIBLE|UNACIDABLE))
		return

	damage = max(0, damage + dam)

	if(damage >= damage_cap)
		playsound(src, 'sound/effects/metal_crash.ogg', 35)
		qdel(src)
	else
		update_icon()