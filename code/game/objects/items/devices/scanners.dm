/*
CONTAINS:
T-RAY
DETECTIVE SCANNER
HEALTH ANALYZER
GAS ANALYZER
PLANT ANALYZER
MASS SPECTROMETER
REAGENT SCANNER
*/
/obj/item/device/t_scanner
	name = "\improper T-ray scanner"
	desc = "A terahertz-ray emitter and scanner used to detect underfloor objects such as cables and pipes."
	icon_state = "t-ray0"
	var/on = 0
	flags_atom = FPRINT|CONDUCT
	flags_equip_slot = SLOT_WAIST
	w_class = 2
	item_state = "electronic"

	matter = list("metal" = 150)

	origin_tech = "magnets=1;engineering=1"

/obj/item/device/t_scanner/attack_self(mob/user)

	on = !on
	icon_state = "t-ray[on]"

	if(on)
		processing_objects.Add(src)


/obj/item/device/t_scanner/process()
	if(!on)
		processing_objects.Remove(src)
		return null

	for(var/turf/T in range(1, src.loc) )

		if(!T.intact)
			continue

		for(var/obj/O in T.contents)

			if(O.level != 1)
				continue

			if(O.invisibility == 101)
				O.invisibility = 0
				O.alpha = 128
				spawn(10)
					if(O)
						var/turf/U = O.loc
						if(U.intact)
							O.invisibility = 101
							O.alpha = 255

		var/mob/living/M = locate() in T
		if(M && M.invisibility == 2)
			M.invisibility = 0
			spawn(2)
				if(M)
					M.invisibility = INVISIBILITY_LEVEL_TWO


/obj/item/device/healthanalyzer
	name = "\improper HF2 health analyzer"
	icon_state = "health"
	item_state = "analyzer"
	desc = "A hand-held body scanner able to distinguish vital signs of the subject. The front panel is able to provide the basic readout of the subject's status."
	flags_atom = FPRINT|CONDUCT
	flags_equip_slot = SLOT_WAIST
	throwforce = 3
	w_class = 2.0
	throw_speed = 5
	throw_range = 10
	matter = list("metal" = 200)
	origin_tech = "magnets=1;biotech=1"
	var/mode = 1

/obj/item/device/healthanalyzer/attack(mob/living/M, mob/living/user)
	if(( (CLUMSY in user.mutations) || user.getBrainLoss() >= 60) && prob(50))
		user << "<span class='warning'>You try to analyze the floor's vitals!</span>"
		for(var/mob/O in viewers(M, null))
			O.show_message("<span class='warning'>[user] has analyzed the floor's vitals!</span>", 1)
		user.show_message("<span class='notice'>Health Analyzer results for The floor:\n\t Overall Status: Healthy</span>", 1)
		user.show_message("<span class='notice'>\t Damage Specifics: [0]-[0]-[0]-[0]</span>", 1)
		user.show_message("<span class='notice'>Key: Suffocation/Toxin/Burns/Brute</span>", 1)
		user.show_message("<span class='notice'>Body Temperature: ???</span>", 1)
		return
	if(!(istype(user, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		usr << "<span class='warning'>You don't have the dexterity to do this!</span>"
		return
	if(user.mind && user.mind.skills_list && user.mind.skills_list["medical"] < SKILL_MEDICAL_MEDIC)
		user << "<span class='warning'>You start fumbling around with [src]...</span>"
		if(!do_after(user, 100, TRUE, 5, BUSY_ICON_CLOCK) || !user.Adjacent(M))
			return
	if(isXeno(M))
		user << "<span class='warning'>[src] can't make sense of this creature.</span>"
		return
	user << "<span class='notice'>[user] has analyzed [M]'s vitals."
	playsound(src.loc, 'sound/items/healthanalyzer.ogg', 50)

	// Doesn't work on non-humans and synthetics
	if(!istype(M, /mob/living/carbon) || (ishuman(M) && (M:species.flags & IS_SYNTHETIC)))
		user.show_message("\n\blue Health Analyzer results for ERROR:\n\t Overall Status: ERROR")
		user.show_message("\tType: <font color='blue'>Oxygen</font>-<font color='green'>Toxin</font>-<font color='#FFA500'>Burns</font>-<font color='red'>Brute</font>", 1)
		user.show_message("\tDamage: <font color='blue'>?</font> - <font color='green'>?</font> - <font color='#FFA500'>?</font> - <font color='red'>?</font>")
		user.show_message("\blue Body Temperature: [M.bodytemperature-T0C]&deg;C ([M.bodytemperature*1.8-459.67]&deg;F)", 1)
		user.show_message("\red <b>Warning: Blood Level ERROR: --% --cl.\blue Type: ERROR")
		user.show_message("\blue Subject's pulse: <font color='red'>-- bpm.</font>")
		return

	// Calculate damage amounts
	var/fake_oxy = max(rand(1,40), M.getOxyLoss(), (300 - (M.getToxLoss() + M.getFireLoss() + M.getBruteLoss())))
	var/OX = M.getOxyLoss() > 50 	? 	"<b>[M.getOxyLoss()]</b>" 		: M.getOxyLoss()
	var/TX = M.getToxLoss() > 50 	? 	"<b>[M.getToxLoss()]</b>" 		: M.getToxLoss()
	var/BU = M.getFireLoss() > 50 	? 	"<b>[M.getFireLoss()]</b>" 		: M.getFireLoss()
	var/BR = M.getBruteLoss() > 50 	? 	"<b>[M.getBruteLoss()]</b>" 	: M.getBruteLoss()

	// Show overall
	if(M.status_flags & FAKEDEATH)
		OX = fake_oxy > 50 			? 	"<b>[fake_oxy]</b>" 			: fake_oxy
		user.show_message("\n\blue Health Analyzer for [M]:\n\tOverall Status: <b>DEAD</b>")
	else
		user.show_message("\nHealth Analyzer results for [M]:\n\tOverall Status: [M.stat > 1 ? "<b>DEAD</b>" : "<b>[M.health - M.halloss]% healthy"]</b>")
	user.show_message("\tType:    <font color='blue'>Oxygen</font>-<font color='green'>Toxin</font>-<font color='#FFA500'>Burns</font>-<font color='red'>Brute</font>", 1)
	user.show_message("\tDamage: \t<font color='blue'>[OX]</font> - <font color='green'>[TX]</font> - <font color='#FFA500'>[BU]</font> - <font color='red'>[BR]</font>")

	// Show specific limb damage
	if(istype(M, /mob/living/carbon/human) && mode == 1)
		var/mob/living/carbon/human/H = M
		var/list/damaged = H.get_damaged_limbs(1,1)
		if(length(damaged))
			for(var/datum/limb/org in damaged)
				var/brute_treated = 0
				var/burn_treated = 0
				var/open_incision = 1
				if(org.surgery_open_stage == 0)
					open_incision = 0
					var/bandaged = org.is_bandaged()
					var/disinfected = org.is_disinfected()
					if(!(bandaged || disinfected))
						brute_treated = 1
					if(!org.salve())
						burn_treated = 1

				var/org_nam = "[capitalize(org.display_name)][org.status & LIMB_ROBOT ? " (Cybernetic)" : ""]"
				var/burn_info = org.burn_dam > 0 ? "<font color='#FFA500'><b>[org.burn_dam]</b></font>" : "<font color='#FFA500'>0</font>"
				var/brute_info =  org.brute_dam > 0 ? "\red <b>[org.brute_dam]</b>" : "<font color='red'>0</font>"
				var/org_bleed = (org.status & LIMB_BLEEDING) ? "\red <b>(Bleeding)</b>" : ""
				var/org_necro = (org.status & LIMB_NECROTIZED) ? "\red <b>(Necrotizing)</b>" : ""
				user.show_message("\t\t [org_nam]: [burn_info][(burn_treated?"":"*")] - [brute_info][(brute_treated?"":"*")] [org_bleed][org_necro][(open_incision?" <span class='warning'>Open surgical incision</span>":"")]",1)
		for(var/datum/limb/temp in H.limbs) // display missing limbs
			if(temp)
				if(temp.status & LIMB_DESTROYED)
					user.show_message("\t\t [capitalize(temp.display_name)]: <span class='warning'><b>Missing!</b></span>",1)
					continue

	// Show red messages - broken bokes, infection, etc
	if (M.getCloneLoss())
		user.show_message("\t\red *Subject appears to have been imperfectly cloned.")
	for(var/datum/disease/D in M.viruses)
		if(!D.hidden[SCANNER])
			user.show_message(text("\t\red <b>*Warning: [D.form] Detected</b>\nName: [D.name].\nType: [D.spread].\nStage: [D.stage]/[D.max_stages].\nPossible Cure: [D.cure]"))
	if (M.getBrainLoss() >= 100 || !M.has_brain())
		user.show_message("\t\red *Subject is <b>brain dead</b>.")
	else if (M.getBrainLoss() >= 60)
		user.show_message("\t\red *<b>Severe brain damage</b> detected. Subject likely to have mental retardation.")
	else if (M.getBrainLoss() >= 10)
		user.show_message("\t\red *<b>Significant brain damage</b> detected. Subject may have had a concussion.")

	if(M.has_brain() && M.stat != DEAD && ishuman(M))
		if(!M.key)
			user.show_message("<span class='deadsay'>\tNo soul detected.</span>\n") // they ghosted
		else if(!M.client)
			user.show_message("<span class='warning'>\tSSD detected.</span>\n") // SSD

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		for(var/X in H.limbs)
			var/datum/limb/e = X
			var/limb = e.display_name
			var/can_amputate = ""
			if(e.status & LIMB_BROKEN)
				if(((e.name == "l_arm") || (e.name == "r_arm") || (e.name == "l_leg") || (e.name == "r_leg") || (e.name == "l_hand") || (e.name == "r_hand") || (e.name == "l_foot") || (e.name == "r_foot")) && (!(e.status & LIMB_SPLINTED)))
					user << "\t\red *Unsecured fracture in subject's <b>[limb]</b>. Splinting recommended."
			if((e.name == "l_arm") || (e.name == "r_arm") || (e.name == "l_leg") || (e.name == "r_leg") || (e.name == "l_hand") || (e.name == "r_hand") || (e.name == "l_foot") || (e.name == "r_foot"))
				can_amputate = "or amputation"
			if(e.germ_level >= INFECTION_LEVEL_THREE)
				user << "\t\red *Subject's <b>[limb]</b> is in the last stage of infection. < 30u of antibiotics [can_amputate] recommended."
			if(e.germ_level >= INFECTION_LEVEL_ONE && e.germ_level < INFECTION_LEVEL_THREE)
				user << "\t\red *Subject's <b>[limb]</b> has an infection. Antibiotics recommended."
			if(e.has_infected_wound())
				user << "\t\red *Infected wound detected in subject's <b>[limb]</b>. Disinfection recommended."
		for(var/X in H.limbs)
			var/datum/limb/e = X
			if(e.status & LIMB_BROKEN)
				if(!((e.name == "l_arm") || (e.name == "r_arm") || (e.name == "l_leg") || (e.name == "r_leg") || (e.name == "l_hand") || (e.name == "r_hand") || (e.name == "l_foot") || (e.name == "r_foot")))
					user.show_message(text("\t\red *<b>Bone fractures</b> detected. Advanced scanner required for location."), 1)
					break
		for(var/X in H.limbs)
			var/datum/limb/e = X
			for(var/datum/wound/W in e.wounds) if(W.internal)
				user.show_message(text("\t\red *<b>Internal bleeding</b> detected. Advanced scanner required for location."), 1)
				break

	if(istype(M, /mob/living/carbon))
		// Show helpful reagents
		if(M:reagents.total_volume > 0)
			var/unknown = 0
			var/reagentdata[0]
			for(var/A in M.reagents.reagent_list)
				var/datum/reagent/R = A
				if(R.scannable)
					reagentdata["[R.id]"] = "[R.overdose != 0 && M.reagents.get_reagent_amount(R.id) >= R.overdose ? "\red <b>OD: </b>" : ""] <font color='#9773C4'><b>[round(M.reagents.get_reagent_amount(R.id), 1)]u [R.name]</b></font>"
				else
					unknown++
			if(reagentdata.len)
				user.show_message("\n\tBeneficial reagents:")
				for(var/d in reagentdata)
					user.show_message("\t\t [reagentdata[d]]")
			if(unknown)
				user.show_message(text("\t\red Warning: Unknown substance[(unknown>1)?"s":""] detected in subject's blood."))

	// Show body temp
	user.show_message("\n\tBody Temperature: [M.bodytemperature-T0C]&deg;C ([M.bodytemperature*1.8-459.67]&deg;F)", 1)

	if (ishuman(M))
		var/mob/living/carbon/human/H = M
		// Show blood level
		if(H.vessel)
			var/blood_volume = round(H.vessel.get_reagent_amount("blood"))
			var/blood_percent =  blood_volume / 560
			var/blood_type = H.dna.b_type
			blood_percent *= 100
			if(blood_volume <= 500 && blood_volume > 336)
				user.show_message("\t\red <b>Warning: Blood Level LOW: [blood_percent]% [blood_volume]cl.\blue Type: [blood_type]")
			else if(blood_volume <= 336)
				user.show_message("\t\red <b>Warning: Blood Level CRITICAL: [blood_percent]% [blood_volume]cl.\blue Type: [blood_type]")
			else
				user.show_message("\tBlood Level normal: [blood_percent]% [blood_volume]cl. Type: [blood_type]")
		// Show pulse
		user.show_message("\tPulse: <font color='[H.pulse == PULSE_THREADY || H.pulse == PULSE_NONE ? "red" : ""]'>[H.get_pulse(GETPULSE_TOOL)] bpm.</font>")

	src.add_fingerprint(user)
	return

/obj/item/device/healthanalyzer/verb/toggle_mode()
	set name = "Switch Verbosity"
	set category = "Object"
	mode = !mode
	switch (mode)
		if(1)
			usr << "The scanner now shows specific limb damage."
		if(0)
			usr << "The scanner no longer shows limb damage."



/obj/item/device/analyzer
	desc = "A hand-held environmental scanner which reports current gas levels."
	name = "analyzer"
	icon_state = "atmos"
	item_state = "analyzer"
	w_class = 2.0
	flags_atom = FPRINT|CONDUCT
	flags_equip_slot = SLOT_WAIST
	throwforce = 5
	throw_speed = 4
	throw_range = 20

	matter = list("metal" = 30,"glass" = 20)

	origin_tech = "magnets=1;engineering=1"

/obj/item/device/analyzer/attack_self(mob/user as mob)

	if (user.stat)
		return
	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		usr << "\red You don't have the dexterity to do this!"
		return

	var/turf/location = user.loc
	if (!( istype(location, /turf) ))
		return

	var/datum/gas_mixture/environment = location.return_air()

	var/pressure = environment.return_pressure()
	var/total_moles = environment.total_moles

	user.show_message("\blue <B>Results:</B>", 1)
	if(abs(pressure - ONE_ATMOSPHERE) < 10)
		user.show_message("\blue Pressure: [round(pressure,0.1)] kPa", 1)
	else
		user.show_message("\red Pressure: [round(pressure,0.1)] kPa", 1)
	if(total_moles)
		for(var/g in environment.gas)
			user.show_message("\blue [gas_data.name[g]]: [round((environment.gas[g] / total_moles)*100)]%", 1)

		user.show_message("\blue Temperature: [round(environment.temperature-T0C)]&deg;C", 1)

	src.add_fingerprint(user)
	return

/obj/item/device/mass_spectrometer
	desc = "A hand-held mass spectrometer which identifies trace chemicals in a blood sample."
	name = "mass-spectrometer"
	icon_state = "spectrometer"
	item_state = "analyzer"
	w_class = 2.0
	flags_atom = FPRINT|CONDUCT|OPENCONTAINER
	flags_equip_slot = SLOT_WAIST
	throwforce = 5
	throw_speed = 4
	throw_range = 20

	matter = list("metal" = 30,"glass" = 20)

	origin_tech = "magnets=2;biotech=2"
	var/details = 0
	var/recent_fail = 0

/obj/item/device/mass_spectrometer/New()
	..()
	var/datum/reagents/R = new/datum/reagents(5)
	reagents = R
	R.my_atom = src

/obj/item/device/mass_spectrometer/on_reagent_change()
	if(reagents.total_volume)
		icon_state = initial(icon_state) + "_s"
	else
		icon_state = initial(icon_state)

/obj/item/device/mass_spectrometer/attack_self(mob/user as mob)
	if (user.stat)
		return
	if (crit_fail)
		user << "\red This device has critically failed and is no longer functional!"
		return
	if (!(istype(user, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		user << "\red You don't have the dexterity to do this!"
		return
	if(reagents.total_volume)
		var/list/blood_traces = list()
		for(var/datum/reagent/R in reagents.reagent_list)
			if(R.id != "blood")
				reagents.clear_reagents()
				user << "\red The sample was contaminated! Please insert another sample"
				return
			else
				blood_traces = params2list(R.data["trace_chem"])
				break
		var/dat = "Trace Chemicals Found: "
		for(var/R in blood_traces)
			if(prob(reliability))
				if(details)
					dat += "[R] ([blood_traces[R]] units) "
				else
					dat += "[R] "
				recent_fail = 0
			else
				if(recent_fail)
					crit_fail = 1
					reagents.clear_reagents()
					return
				else
					recent_fail = 1
		user << "[dat]"
		reagents.clear_reagents()
	return


/obj/item/device/mass_spectrometer/adv
	name = "advanced mass-spectrometer"
	icon_state = "adv_spectrometer"
	details = 1
	origin_tech = "magnets=4;biotech=2"

/obj/item/device/reagent_scanner
	name = "reagent scanner"
	desc = "A hand-held reagent scanner which identifies chemical agents."
	icon_state = "spectrometer"
	item_state = "analyzer"
	w_class = 2.0
	flags_atom = FPRINT|CONDUCT
	flags_equip_slot = SLOT_WAIST
	throwforce = 5
	throw_speed = 4
	throw_range = 20
	matter = list("metal" = 30,"glass" = 20)

	origin_tech = "magnets=2;biotech=2"
	var/details = 0
	var/recent_fail = 0

/obj/item/device/reagent_scanner/afterattack(obj/O, mob/user as mob, proximity)
	if(!proximity)
		return
	if (user.stat)
		return
	if (!(istype(user, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		user << "\red You don't have the dexterity to do this!"
		return
	if(!istype(O))
		return
	if (crit_fail)
		user << "\red This device has critically failed and is no longer functional!"
		return

	if(!isnull(O.reagents))
		var/dat = ""
		if(O.reagents.reagent_list.len > 0)
			var/one_percent = O.reagents.total_volume / 100
			for (var/datum/reagent/R in O.reagents.reagent_list)
				if(prob(reliability))
					dat += "\n \t \blue [R][details ? ": [R.volume / one_percent]%" : ""]"
					recent_fail = 0
				else if(recent_fail)
					crit_fail = 1
					dat = null
					break
				else
					recent_fail = 1
		if(dat)
			user << "\blue Chemicals found: [dat]"
		else
			user << "\blue No active chemical agents found in [O]."
	else
		user << "\blue No significant chemical agents found in [O]."

	return

/obj/item/device/reagent_scanner/adv
	name = "advanced reagent scanner"
	icon_state = "adv_spectrometer"
	details = 1
	origin_tech = "magnets=4;biotech=2"
