//MEDBOT
//MEDBOT PATHFINDING
//MEDBOT ASSEMBLY


/obj/machinery/bot/medbot
	name = "Medibot"
	desc = "A little medical robot. He looks somewhat underwhelmed."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "medibot0"
	density = 0
	anchored = 0
	max_integrity = 20
	req_access =list(ACCESS_MARINE_MEDBAY)
	var/stunned = 0 //It can be stunned by tasers. Delicate circuits.
//var/DISABLE_BITFIELD(obj_flags, EMAGGED)
	var/list/botcard_access = list(ACCESS_MARINE_MEDBAY)
	var/obj/item/reagent_container/glass/reagent_glass = null //Can be set to draw from this for reagents.
	var/skin = null //Set to "tox", "ointment" or "o2" for the other two firstaid kits.
	var/frustration = 0
	var/path[] = new()
	var/mob/living/carbon/patient = null
	var/mob/living/carbon/oldpatient = null
	var/oldloc = null
	var/last_found = 0
	var/last_newpatient_speak = 0 //Don't spam the "HEY I'M COMING" messages
	var/currently_healing = 0
	var/safety_checks = 1
	var/injection_amount = 15 //How much reagent do we inject at a time?
	var/heal_threshold = 10 //Start healing when they have this much damage in a category
	var/use_beaker = 0 //Use reagents in beaker instead of default treatment agents.
	//Setting which reagents to use to treat what by default. By id.
	var/treatment_brute = "tricordrazine"
	var/treatment_oxy = "tricordrazine"
	var/treatment_fire = "tricordrazine"
	var/treatment_tox = "tricordrazine"
	var/declare_treatment = 0 //When attempting to treat a patient, should it notify everyone wearing medhuds?
	var/shut_up = 0 //self explanatory :)

/obj/machinery/bot/medbot/mysterious
	name = "Mysterious Medibot"
	desc = "International Medibot of mystery."
	skin = "bezerk"
	treatment_oxy = "dexalinplus"
	treatment_brute = "bicaridine"
	treatment_fire = "kelotane"
	treatment_tox = "dylovene"




/obj/machinery/bot/medbot/Initialize()
	. = ..()
	src.icon_state = "medibot[src.on]"

	if(src.skin)
		src.overlays += image('icons/obj/aibots.dmi', "medskin_[src.skin]")

	src.botcard = new /obj/item/card/id(src)
	botcard.access = ALL_MARINE_ACCESS
	start_processing()

/obj/machinery/bot/medbot/turn_on()
	. = ..()
	src.icon_state = "medibot[src.on]"
	src.updateUsrDialog()

/obj/machinery/bot/medbot/turn_off()
	..()
	src.patient = null
	src.oldpatient = null
	src.oldloc = null
	src.path = new()
	src.currently_healing = 0
	src.last_found = world.time
	src.icon_state = "medibot[src.on]"
	src.updateUsrDialog()

/obj/machinery/bot/medbot/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/bot/medbot/attack_hand(mob/user as mob)
	. = ..()
	if (.)
		return
	var/dat
	dat += "<TT><B>Automatic Medical Unit v1.0</B></TT><BR><BR>"
	dat += "Status: <A href='?src=\ref[src];power=1'>[src.on ? "On" : "Off"]</A><BR>"
	dat += "Maintenance panel is [src.open ? "opened" : "closed"]<BR>"
	dat += "Beaker: "
	if (src.reagent_glass)
		dat += "<A href='?src=\ref[src];eject=1'>Loaded \[[src.reagent_glass.reagents.total_volume]/[src.reagent_glass.reagents.maximum_volume]\]</a>"
	else
		dat += "None Loaded"
	dat += "<br>Behaviour controls are [src.locked ? "locked" : "unlocked"]<hr>"
	if(!src.locked || issilicon(user))
		dat += "<TT>Healing Threshold: "
		dat += "<a href='?src=\ref[src];adj_threshold=-10'>--</a> "
		dat += "<a href='?src=\ref[src];adj_threshold=-5'>-</a> "
		dat += "[src.heal_threshold] "
		dat += "<a href='?src=\ref[src];adj_threshold=5'>+</a> "
		dat += "<a href='?src=\ref[src];adj_threshold=10'>++</a>"
		dat += "</TT><br>"

		dat += "<TT>Injection Level: "
		dat += "<a href='?src=\ref[src];adj_inject=-5'>-</a> "
		dat += "[src.injection_amount] "
		dat += "<a href='?src=\ref[src];adj_inject=5'>+</a> "
		dat += "</TT><br>"

		dat += "<TT>OD Protection: "
		dat += "<b>[safety_checks ? "On" : "Off"]</b> : "
		dat += "<a href='?src=\ref[src];togglesafety=1'>Toggle?</a>"
		dat += "</TT><br>"

		dat += "Reagent Source: "
		dat += "<a href='?src=\ref[src];use_beaker=1'>[src.use_beaker ? "Loaded Beaker (When available)" : "Internal Synthesizer"]</a><br>"

		dat += "Treatment report is [src.declare_treatment ? "on" : "off"]. <a href='?src=\ref[src];declaretreatment=[1]'>Toggle</a><br>"

		dat += "The speaker switch is [src.shut_up ? "off" : "on"]. <a href='?src=\ref[src];togglevoice=[1]'>Toggle</a><br>"

	user << browse("<HEAD><TITLE>Medibot v1.0 controls</TITLE></HEAD>[dat]", "window=automed")
	onclose(user, "automed")
	return

/obj/machinery/bot/medbot/Topic(href, href_list)
	. = ..()
	if(.)
		return
	usr.set_interaction(src)
	if ((href_list["power"]) && (src.allowed(usr)))
		if (src.on)
			turn_off()
		else
			turn_on()

	else if((href_list["adj_threshold"]) && (!src.locked || issilicon(usr)))
		var/adjust_num = text2num(href_list["adj_threshold"])
		src.heal_threshold += adjust_num
		if(src.heal_threshold < 5)
			src.heal_threshold = 5
		if(src.heal_threshold > 75)
			src.heal_threshold = 75

	else if((href_list["adj_inject"]) && (!src.locked || issilicon(usr)))
		var/adjust_num = text2num(href_list["adj_inject"])
		src.injection_amount += adjust_num
		if(src.injection_amount < 5)
			src.injection_amount = 5
		if(src.injection_amount > 15)
			src.injection_amount = 15

	else if((href_list["togglesafety"]) && (!src.locked || issilicon(usr)))
		safety_checks = !safety_checks

	else if((href_list["use_beaker"]) && (!src.locked || issilicon(usr)))
		src.use_beaker = !src.use_beaker

	else if (href_list["eject"] && (!isnull(src.reagent_glass)))
		if(!src.locked)
			src.reagent_glass.loc = get_turf(src)
			src.reagent_glass = null
		else
			to_chat(usr, "<span class='notice'>You cannot eject the beaker because the panel is locked.</span>")

	else if ((href_list["togglevoice"]) && (!src.locked || issilicon(usr)))
		src.shut_up = !src.shut_up

	else if ((href_list["declaretreatment"]) && (!src.locked || issilicon(usr)))
		src.declare_treatment = !src.declare_treatment

	src.updateUsrDialog()
	return

/obj/machinery/bot/medbot/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/card/id))
		if(allowed(user) && !open && !CHECK_BITFIELD(obj_flags, EMAGGED))
			locked = !locked
			to_chat(user, "<span class='notice'>Controls are now [src.locked ? "locked." : "unlocked."]</span>")
			updateUsrDialog()
		else if(CHECK_BITFIELD(obj_flags, EMAGGED))
			to_chat(user, "<span class='warning'>ERROR</span>")
		else if(open)
			to_chat(user, "<span class='warning'>Please close the access panel before locking it.</span>")
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")

	else if(istype(I, /obj/item/reagent_container/glass))
		if(locked)
			to_chat(user, "<span class='notice'>You cannot insert a beaker because the panel is locked.</span>")
			return
		if(!isnull(reagent_glass))
			to_chat(user, "<span class='notice'>There is already a beaker loaded.</span>")
			return
		if(user.transferItemToLoc(I, src))
			reagent_glass = I
			to_chat(user, "<span class='notice'>You insert [I].</span>")
			updateUsrDialog()

	if(obj_integrity < max_integrity && !isscrewdriver(I) && I.force)
		step_to(src, (get_step_away(src, user)))

/obj/machinery/bot/medbot/Emag(mob/user as mob)
	..()
	if(open && !locked)
		if(user) to_chat(user, "<span class='warning'>You short out [src]'s reagent synthesis circuits.</span>")
		spawn(0)
			for(var/mob/O in hearers(src, null))
				O.show_message("<span class='danger'>[src] buzzes oddly!</span>", 1)
		flick("medibot_spark", src)
		src.patient = null
		if(user) src.oldpatient = user
		src.currently_healing = 0
		src.last_found = world.time
		src.anchored = 0
		ENABLE_BITFIELD(obj_flags, EMAGGED)
		src.safety_checks = 0
		src.on = 1
		src.icon_state = "medibot[src.on]"

/obj/machinery/bot/medbot/process()
	set background = 1

	if(!src.on)
		src.stunned = 0
		return

	if(src.stunned)
		src.icon_state = "medibota"
		src.stunned--

		src.oldpatient = src.patient
		src.patient = null
		src.currently_healing = 0

		if(src.stunned <= 0)
			src.icon_state = "medibot[src.on]"
			src.stunned = 0
		return

	if(src.frustration > 8)
		src.oldpatient = src.patient
		src.patient = null
		src.currently_healing = 0
		src.last_found = world.time
		src.path = new()

	if(!src.patient)
		if(!src.shut_up && prob(1))
			var/message = pick("Radar, put a mask on!","There's always a catch, and it's the best there is.","I knew it, I should've been a plastic surgeon.","What kind of medbay is this? Everyone's dropping like dead flies.","Delicious!")
			src.speak(message)

		for (var/mob/living/carbon/C in view(7,src)) //Time to find a patient!
			if ((C.stat == 2) || !ishuman(C))
				continue

			if ((C == src.oldpatient) && (world.time < src.last_found + 100))
				continue

			if(src.assess_patient(C))
				src.patient = C
				src.oldpatient = C
				src.last_found = world.time
				if((src.last_newpatient_speak + 300) < world.time) //Don't spam these messages!
					var/message = pick("Hey, [C.name]! Hold on, I'm coming.","Wait [C.name]! I want to help!","[C.name], you appear to be injured!")
					src.speak(message)
					src.visible_message("<b>[src]</b> points at [C.name]!")
					src.last_newpatient_speak = world.time
//					if(declare_treatment)
//						var/area/location = get_area(src)
//						broadcast_medical_hud_message("[src.name] is treating <b>[C]</b> in <b>[location]</b>", src)
				break
			else
				continue


	if(src.patient && Adjacent(patient))
		if(!src.currently_healing)
			src.currently_healing = 1
			src.frustration = 0
			src.medicate_patient(src.patient)
		return

	else if(src.patient && (src.path.len) && (get_dist(src.patient,src.path[src.path.len]) > 2))
		src.path = new()
		src.currently_healing = 0
		src.last_found = world.time

	if(src.patient && src.path.len == 0 && (get_dist(src,src.patient) > 1))
		spawn(0)
			src.path = AStar(src.loc, get_turf(src.patient), /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance, 0, 30,id=botcard)
			if (!path) path = list()
			if(src.path.len == 0)
				src.oldpatient = src.patient
				src.patient = null
				src.currently_healing = 0
				src.last_found = world.time
		return

	if(src.path.len > 0 && src.patient)
		step_to(src, src.path[1])
		src.path -= src.path[1]
		spawn(3)
			if(src.path.len)
				step_to(src, src.path[1])
				src.path -= src.path[1]

	if(src.path.len > 8 && src.patient)
		src.frustration++

	return

/obj/machinery/bot/medbot/proc/assess_patient(mob/living/carbon/C as mob)
	//Time to see if they need medical help!
	if(C.stat == 2)
		return 0 //welp too late for them!

	if(C.suiciding)
		return 0 //Kevorkian school of robotic medical assistants.

	if(CHECK_BITFIELD(obj_flags, EMAGGED)) //Everyone needs our medicine. (Our medicine is toxins)
		return 1

	if(safety_checks)
		if(C.reagents.total_volume > 0)
			for(var/datum/reagent/R in C.reagents.reagent_list)
				if((src.injection_amount + R.volume) >= R.overdose_threshold)
					return 0 //Don't medicate if it will kill them --MadSnailDisease

	//If they're injured, we're using a beaker, and don't have one of our WONDERCHEMS.
	if((src.reagent_glass) && (src.use_beaker) && ((C.getBruteLoss() >= heal_threshold) || (C.getToxLoss() >= heal_threshold) || (C.getToxLoss() >= heal_threshold) || (C.getOxyLoss() >= (heal_threshold + 15))))
		for(var/datum/reagent/R in src.reagent_glass.reagents.reagent_list)
			if(!C.reagents.has_reagent(R))
				return 1
			continue

	//They're injured enough for it!
	if((C.getBruteLoss() >= heal_threshold) && (!C.reagents.has_reagent(src.treatment_brute)))
		return 1 //If they're already medicated don't bother!

	if((C.getOxyLoss() >= (15 + heal_threshold)) && (!C.reagents.has_reagent(src.treatment_oxy)))
		return 1

	if((C.getFireLoss() >= heal_threshold) && (!C.reagents.has_reagent(src.treatment_fire)))
		return 1

	if((C.getToxLoss() >= heal_threshold) && (!C.reagents.has_reagent(src.treatment_tox)))
		return 1

	return 0

/obj/machinery/bot/medbot/proc/medicate_patient(mob/living/carbon/C as mob)
	if(!src.on)
		return

	if(!istype(C))
		src.oldpatient = src.patient
		src.patient = null
		src.currently_healing = 0
		src.last_found = world.time
		return

	if(C.stat == 2)
		var/death_message = pick("No! NO!","Live, damnit! LIVE!","I...I've never lost a patient before. Not today, I mean.")
		src.speak(death_message)
		src.oldpatient = src.patient
		src.patient = null
		src.currently_healing = 0
		src.last_found = world.time
		return

	var/reagent_id = null

	//Use whatever is inside the loaded beaker. If there is one.
	if(use_beaker && reagent_glass && reagent_glass.reagents.total_volume)
		var/safety_fail = 0
		for(var/datum/reagent/R in reagent_glass.reagents.reagent_list)
			if(C.reagents.has_reagent(R.id))
				safety_fail = 1
				break
		if(!safety_fail)
			reagent_id = "internal_beaker"

	if(CHECK_BITFIELD(obj_flags, EMAGGED) == 2) //Emagged! Time to poison everybody.
		reagent_id = "toxin"

	if (!reagent_id && (C.getBruteLoss() >= heal_threshold))
		if(!C.reagents.has_reagent(src.treatment_brute))
			reagent_id = src.treatment_brute

	if (!reagent_id && (C.getOxyLoss() >= (15 + heal_threshold)))
		if(!C.reagents.has_reagent(src.treatment_oxy))
			reagent_id = src.treatment_oxy

	if (!reagent_id && (C.getFireLoss() >= heal_threshold))
		if(!C.reagents.has_reagent(src.treatment_fire))
			reagent_id = src.treatment_fire

	if (!reagent_id && (C.getToxLoss() >= heal_threshold))
		if(!C.reagents.has_reagent(src.treatment_tox))
			reagent_id = src.treatment_tox

	if(!reagent_id) //If they don't need any of that they're probably cured!
		src.oldpatient = src.patient
		src.patient = null
		src.currently_healing = 0
		src.last_found = world.time
		var/message = pick("All patched up!","An apple a day keeps me away.","Feel better soon!")
		src.speak(message)
		return
	else
		src.icon_state = "medibots"
		visible_message("<span class='danger'>[src] is trying to inject [src.patient]!</span>")
		spawn(30)
			if ((get_dist(src, src.patient) <= 1) && (src.on))
				if(reagent_id == "internal_beaker" && reagent_glass && reagent_glass.reagents.total_volume)
					src.reagent_glass.reagents.trans_to(src.patient,src.injection_amount) //Inject from beaker instead.
					src.reagent_glass.reagents.reaction(src.patient, 2)
				else
					src.patient.reagents.add_reagent(reagent_id,src.injection_amount)
				visible_message("<span class='danger'>[src] injects [src.patient] with the syringe!</span>")

			src.icon_state = "medibot[src.on]"
			src.currently_healing = 0
			return

//	src.speak(reagent_id)
	reagent_id = null
	return


/obj/machinery/bot/medbot/proc/speak(var/message)
	if((!src.on) || (!message))
		return
	visible_message("[src] beeps, \"[message]\"")
	return

/obj/machinery/bot/medbot/explode()
	src.on = 0
	visible_message("<span class='danger'>[src] blows apart!</span>", 1)
	var/turf/Tsec = get_turf(src)

	new /obj/item/storage/firstaid(Tsec)

	new /obj/item/assembly/prox_sensor(Tsec)

	new /obj/item/healthanalyzer(Tsec)

	if(src.reagent_glass)
		src.reagent_glass.loc = Tsec
		src.reagent_glass = null

	if (prob(50))
		new /obj/item/robot_parts/l_arm(Tsec)

	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	qdel(src)
	return

/obj/machinery/bot/medbot/Bump(M as mob|obj) //Leave no door unopened!
	if ((istype(M, /obj/machinery/door)) && (!isnull(src.botcard)))
		var/obj/machinery/door/D = M
		if (!istype(D, /obj/machinery/door/firedoor) && D.check_access(src.botcard) && !istype(D,/obj/machinery/door/poddoor))
			D.open()
			src.frustration = 0
	else if ((istype(M, /mob/living/)) && (!src.anchored))
		src.loc = M:loc
		src.frustration = 0
	return

/* terrible
/obj/machinery/bot/medbot/Bumped(atom/movable/M as mob|obj)
	spawn(0)
		if (M)
			var/turf/T = get_turf(src)
			M:loc = T
*/



/*
 *	Medbot Assembly -- Can be made out of all three medkits.
 */

/obj/item/storage/firstaid/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/robot_parts/l_arm) && !istype(I, /obj/item/robot_parts/r_arm))
		return ..()

	//Making a medibot!
	if(length(contents) >= 1)
		to_chat(user, "<span class='notice'>You need to empty [src] out first.</span>")
		return

	var/obj/item/frame/firstaid_arm_assembly/A = new

	if(istype(src, /obj/item/storage/firstaid/fire))
		A.skin = "ointment"
	else if(istype(src, /obj/item/storage/firstaid/toxin))
		A.skin = "tox"
	else if(istype(src, /obj/item/storage/firstaid/o2))
		A.skin = "o2"

	qdel(I)
	user.put_in_hands(A)
	to_chat(user, "<span class='notice'>You add the robot arm to the first aid kit.</span>")
	user.temporarilyRemoveItemFromInventory(src)
	qdel(src)