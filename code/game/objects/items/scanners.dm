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
/obj/item/t_scanner
	name = "\improper T-ray scanner"
	desc = "A terahertz-ray emitter and scanner used to detect underfloor objects such as cables and pipes."
	icon_state = "t-ray0"
	var/on = 0
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	w_class = 2
	item_state = "electronic"

	matter = list("metal" = 150)

	origin_tech = "magnets=1;engineering=1"

/obj/item/t_scanner/attack_self(mob/user)

	on = !on
	icon_state = "t-ray[on]"

	if(on)
		START_PROCESSING(SSobj, src)


/obj/item/t_scanner/process()
	if(!on)
		STOP_PROCESSING(SSobj, src)
		return null

	for(var/turf/T in range(1, src.loc) )

		if(!T.intact_tile)
			continue

		for(var/obj/O in T.contents)

			if(O.level != 1)
				continue

			if(O.invisibility == INVISIBILITY_MAXIMUM)
				O.invisibility = 0
				O.alpha = 128
				spawn(10)
					if(O && !O.gc_destroyed)
						var/turf/U = O.loc
						if(U.intact_tile)
							O.invisibility = INVISIBILITY_MAXIMUM
							O.alpha = 255


/obj/item/healthanalyzer
	name = "\improper HF2 health analyzer"
	icon_state = "health"
	item_state = "analyzer"
	desc = "A hand-held body scanner able to distinguish vital signs of the subject. The front panel is able to provide the basic readout of the subject's status."
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	throwforce = 3
	w_class = 2.0
	throw_speed = 5
	throw_range = 10
	matter = list("metal" = 200)
	origin_tech = "magnets=1;biotech=1"
	var/mode = 1
	var/hud_mode = 1
	var/skill_threshold = SKILL_MEDICAL_PRACTICED

/obj/item/healthanalyzer/attack(mob/living/carbon/M, mob/living/user) //Integrated analyzers don't need special training to be used quickly.
	var/dat = ""
	if((user.getBrainLoss() >= 60) && prob(50))
		to_chat(user, "<span class='warning'>You try to analyze the floor's vitals!</span>")
		for(var/mob/O in viewers(M, null))
			O.show_message("<span class='warning'>[user] has analyzed the floor's vitals!</span>", 1)
		user.show_message("<span class='notice'>Health Analyzer results for The floor:\n\t Overall Status: Healthy</span>", 1)
		user.show_message("<span class='notice'>\t Damage Specifics: [0]-[0]-[0]-[0]</span>", 1)
		user.show_message("<span class='notice'>Key: Suffocation/Toxin/Burns/Brute</span>", 1)
		user.show_message("<span class='notice'>Body Temperature: ???</span>", 1)
		return
	if(user.mind?.cm_skills && user.mind.cm_skills.medical < skill_threshold)
		to_chat(user, "<span class='warning'>You start fumbling around with [src]...</span>")
		var/fduration = max(SKILL_TASK_AVERAGE - (user.mind.cm_skills.medical * 10), 0)
		if(!do_after(user, fduration, TRUE, M, BUSY_ICON_UNSKILLED))
			return
	if(isxeno(M))
		to_chat(user, "<span class='warning'>[src] can't make sense of this creature.</span>")
		return
	to_chat(user, "<span class='notice'>[user] has analyzed [M]'s vitals.")
	playsound(src.loc, 'sound/items/healthanalyzer.ogg', 50)

	// Doesn't work on non-humans and synthetics
	if(!iscarbon(M) || (ishuman(M) && (M:species.species_flags & IS_SYNTHETIC)))
		user.show_message("\n<span class='notice'> Health Analyzer results for ERROR:\n\t Overall Status: ERROR</span>")
		user.show_message("\tType: <font color='blue'>Oxygen</font>-<font color='green'>Toxin</font>-<font color='#FFA500'>Burns</font>-<font color='red'>Brute</font>", 1)
		user.show_message("\tDamage: <font color='blue'>?</font> - <font color='green'>?</font> - <font color='#FFA500'>?</font> - <font color='red'>?</font>")
		user.show_message("<span class='notice'> Body Temperature: [M.bodytemperature-T0C]&deg;C ([M.bodytemperature*1.8-459.67]&deg;F)</span>", 1)
		user.show_message("<span class='warning'> <b>Warning: Blood Level ERROR: --% --cl.<span class='notice'> Type: ERROR</span>")
		user.show_message("<span class='notice'> Subject's pulse: <font color='red'>-- bpm.</font></span>")
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
		dat += "\n<span class='notice'> Health Analyzer for [M]:\n\tOverall Status: <b>DEAD</b>\n</span>"
	else
		dat += "\nHealth Analyzer results for [M]:\n\tOverall Status: [M.stat > 1 ? "<b>DEAD</b>" : "<b>[M.health - M.halloss]% healthy"]</b>\n"
	dat += "\tType:    <font color='blue'>Oxygen</font>-<font color='green'>Toxin</font>-<font color='#FFA500'>Burns</font>-<font color='red'>Brute</font>\n"
	dat += "\tDamage: \t<font color='blue'>[OX]</font> - <font color='green'>[TX]</font> - <font color='#FFA500'>[BU]</font> - <font color='red'>[BR]</font>\n"
	dat += "\tUntreated: {B}=Burns,{T}=Trauma,{F}=Fracture,{I}=Infection\n"

	var/infection_present = 0
	var/unrevivable = 0
	var/rad = M.radiation
	var/overdosed = 0

	// Show specific limb damage
	if(ishuman(M) && mode == 1)
		var/mob/living/carbon/human/H = M
		for(var/datum/limb/org in H.limbs)
			var/brute_treated = 0
			var/burn_treated = 0
			var/open_incision = 1
			if(org.surgery_open_stage == 0)
				open_incision = 0
			var/bandaged = org.is_bandaged()
			var/disinfected = org.is_disinfected()
			if(!(bandaged || disinfected ) || open_incision)
				brute_treated = 1
			if(!org.is_salved() || org.burn_dam == 0)
				burn_treated = 1

			if(org.limb_status & LIMB_DESTROYED)
				dat += "\t\t [capitalize(org.display_name)]: <span class='scannerb'>Missing!</span>\n"
				continue

			var/show_limb = (org.burn_dam > 0 || org.brute_dam > 0 || (org.limb_status & (LIMB_BLEEDING | LIMB_NECROTIZED | LIMB_SPLINTED | LIMB_STABILIZED)) || open_incision)
			var/org_name = "[capitalize(org.display_name)][org.limb_status & LIMB_ROBOT ? " (Cybernetic)" : ""]"
			var/burn_info = org.burn_dam > 0 ? "<span class='scannerburnb'> [round(org.burn_dam)]</span>" : "<span class='scannerburn'>0</span>"
			burn_info += "[((burn_treated)?"":"{B}")]"
			var/brute_info =  org.brute_dam > 0 ? "<span class='scannerb'> [round(org.brute_dam)]</span>" : "<span class='scanner'>0</span>"
			brute_info += "[(brute_treated && org.brute_dam >= 1?"":"{T}")]"
			var/fracture_info = ""
			if((org.limb_status & LIMB_BROKEN) && !(org.limb_status & LIMB_SPLINTED) && !(org.limb_status & LIMB_STABILIZED))
				fracture_info = "{F}"
				show_limb = 1
			var/infection_info = ""
			if(org.has_infected_wound())
				infection_info = "{I}"
				show_limb = 1
			var/org_bleed = (org.limb_status & LIMB_BLEEDING) ? "<span class='scannerb'>(Bleeding)</span>" : ""
			var/org_necro = ""
			if(org.limb_status & LIMB_NECROTIZED)
				org_necro = "<span class='scannerb'>(Necrotizing)</span>"
				infection_present = 10
			var/org_incision = (open_incision?" <span class='scanner'>Open surgical incision</span>":"")
			var/org_advice = ""
			switch(org.body_part)
				if(HEAD)
					fracture_info = ""
					if(org.brute_dam > 40 || M.getBrainLoss() >= 20)
						org_advice = " Possible Skull Fracture."
						show_limb = 1
				if(CHEST)
					fracture_info = ""
					if(org.brute_dam > 40 || M.getOxyLoss() > 50)
						org_advice = " Possible Chest Fracture."
						show_limb = 1
				if(GROIN)
					fracture_info = ""
					if(org.brute_dam > 40 || M.getToxLoss() > 50)
						org_advice = " Possible Groin Fracture."
						show_limb = 1
			if(show_limb)
				dat += "\t\t [org_name]: \t [burn_info] - [brute_info] [fracture_info][infection_info][org_bleed][org_necro][org_incision][org_advice]"
				if(org.limb_status & LIMB_SPLINTED)
					dat += "(Splinted)"
				else if(org.limb_status & LIMB_STABILIZED)
					dat += "(Stabilized)"
				dat += "\n"

	// Show red messages - broken bokes, infection, etc
	if (rad)
		if(rad > 5)
			dat += "\t<span class='scanner'> *Dangerous levels of ionizing radiation detected.</span>\n"
		else
			dat += "\t<span class='scanner'> *Ionizing radiation detected.</span>\n"
	if (M.getCloneLoss())
		dat += "\t<span class='scanner'> *Subject appears to have been imperfectly cloned.</span>\n"
	if (M.getBrainLoss() >= 100 || !M.has_brain())
		dat += "\t<span class='scanner'> *Subject is <b>brain dead</b></span>.\n"
	else if (M.getBrainLoss() >= 60)
		dat += "\t<span class='scanner'> *<b>Severe brain damage</b> detected. Subject likely to have mental retardation.</span>\n"
	else if (M.getBrainLoss() >= 10)
		dat += "\t<span class='scanner'> *<b>Significant brain damage</b> detected. Subject may have had a concussion.</span>\n"

	if(M.has_brain() && M.stat != DEAD && ishuman(M))
		if(!M.key)
			dat += "<span class='warning'>\tNo soul detected.</span>\n" // they ghosted
		else if(!M.client)
			dat += "<span class='warning'>\tSSD detected.</span>\n" // SSD

	var/internal_bleed_detected = FALSE
	var/fracture_detected = FALSE
	var/unknown_body = 0
	//var/infected = FALSE
	var/known_implants = list(/obj/item/implant/chem, /obj/item/implant/death_alarm, /obj/item/implant/loyalty, /obj/item/implant/tracking, /obj/item/implant/neurostim)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/core_fracture = FALSE
		for(var/X in H.limbs)
			var/datum/limb/e = X
			var/limb = e.display_name
			var/can_amputate = ""
			for(var/datum/wound/W in e.wounds)
				if(W.internal)
					internal_bleed_detected = TRUE
					break
			if(e.body_part != CHEST && e.body_part != GROIN && e.body_part != HEAD)
				can_amputate = "or amputation"
				if((e.limb_status & LIMB_BROKEN) && !(e.limb_status & LIMB_SPLINTED) && !(e.limb_status & LIMB_STABILIZED))
					if(!fracture_detected)
						fracture_detected = TRUE
					dat += "\t<span class='scanner'> *<b>Bone Fracture:</b> Unsecured fracture in subject's <b>[limb]</b>. Splinting recommended.</span>\n"
			else
				if((e.limb_status & LIMB_BROKEN) && !(e.limb_status & LIMB_SPLINTED) && !(e.limb_status & LIMB_STABILIZED))
					if(!fracture_detected)
						fracture_detected = TRUE
					core_fracture = TRUE
			if(e.germ_level >= INFECTION_LEVEL_THREE)
				dat += "\t<span class='scanner'> *Subject's <b>[limb]</b> is in the last stage of infection. < 30u of antibiotics [can_amputate] recommended.</span>\n"
				infection_present = 25
			if(e.germ_level >= INFECTION_LEVEL_ONE && e.germ_level < INFECTION_LEVEL_THREE)
				dat += "\t<span class='scanner'> *Subject's <b>[limb]</b> has an infection. Antibiotics recommended.</span>\n"
				infection_present = 5
			if(e.has_infected_wound())
				dat += "\t<span class='scanner'> *Infected wound detected in subject's <b>[limb]</b>. Disinfection recommended.</span>\n"
			if (e.implants.len)
				for(var/I in e.implants)
					if(!is_type_in_list(I,known_implants))
						unknown_body++
			if(e.hidden)
				unknown_body++
			if(e.body_part == CHEST) //embryo in chest?
				if(locate(/obj/item/alien_embryo) in H)
					unknown_body++

		if(unknown_body)
			if(unknown_body > 1)
				dat += "\t<span class='scanner'> *<b>Foreign objects</b> detected in body. Advanced scanner required for location.</span>\n"
			else
				dat += "\t<span class='scanner'> *<b>Foreign object</b> detected in body. Advanced scanner required for location.</span>\n"
		if(core_fracture)
			dat += "\t<span class='scanner'> *<b>Bone fractures</b> detected. Advanced scanner required for location.</span>\n"
		if(internal_bleed_detected)
			dat += "\t<span class='scanner'> *<b>Internal bleeding</b> detected. Advanced scanner required for location.</span>\n"

	var/reagents_in_body[0] // yes i know -spookydonut
	if(iscarbon(M))
		// Show helpful reagents
		if(M.reagents.total_volume > 0)
			var/unknown = 0
			var/reagentdata[0]
			for(var/A in M.reagents.reagent_list)
				var/datum/reagent/R = A
				reagents_in_body["[R.id]"] = R.volume
				if(R.scannable)
					if(R.overdosed)
						reagentdata["[R.id]"] = "<span class='warning'><b>OD: </b></span> <font color='#9773C4'><b>[round(R.volume, 0.01)]u [R.name]</b></font>"
						overdosed++
					else
						reagentdata["[R.id]"] =	"<font color='#9773C4'><b>[round(R.volume, 0.01)]u [R.name]</b></font>"
				else
					unknown++
			if(reagentdata.len)
				dat += "\n\tBeneficial reagents:\n"
				for(var/d in reagentdata)
					dat += "\t\t [reagentdata[d]]\n"
			if(unknown)
				dat += "\t<span class='scanner'> Warning: Unknown substance[(unknown>1)?"s":""] detected in subject's blood.</span>\n"

	// Show body temp
	dat += "\n\tBody Temperature: [M.bodytemperature-T0C]&deg;C ([M.bodytemperature*1.8-459.67]&deg;F)\n"
	if (ishuman(M))
		var/mob/living/carbon/human/H = M
		// Show blood level
		var/blood_volume = BLOOD_VOLUME_NORMAL
		var/is_dead = FALSE
		if(!(H.species.species_flags & NO_BLOOD))
			blood_volume = round(H.blood_volume)

			var/blood_percent =  blood_volume / 560
			var/blood_type = H.blood_type
			blood_percent *= 100
			if(blood_volume <= 500 && blood_volume > 336)
				dat += "\t<span class='scanner'> <b>Warning: Blood Level LOW: [blood_percent]% [blood_volume]cl.</span><font color='blue;'> Type: [blood_type]</font>\n"
			else if(blood_volume <= 336)
				dat += "\t<span class='scanner'> <b>Warning: Blood Level CRITICAL: [blood_percent]% [blood_volume]cl.</span><font color='blue;'> Type: [blood_type]</font>\n"
			else
				dat += "\tBlood Level normal: [blood_percent]% [blood_volume]cl. Type: [blood_type]\n"
		// Show pulse
		dat += "\tPulse: <font color='[H.pulse == PULSE_THREADY || H.pulse == PULSE_NONE ? "red" : ""]'>[H.get_pulse(GETPULSE_TOOL)] bpm.</font>\n"
		if(H.stat == DEAD)
			is_dead = TRUE
			//check to see if the target is revivable
			if(!H.is_revivable())
				unrevivable = TRUE
		if(!unrevivable)
			//Chems that conflict with others:
			var/synaptizine_amount = reagents_in_body["synaptizine"]
			var/hyperzine_amount = reagents_in_body["hyperzine"]
			var/paracetamol_amount = reagents_in_body["paracetamol"]
			var/neurotoxin_amount = reagents_in_body["xeno_toxin"]
			var/growthtoxin_amount = reagents_in_body["xeno_growthtoxin"]
			//Recurring chems:
			var/peridaxon = ""
			var/tricordrazine = ""
			//The actual medical advice summary:
			var/advice = ""
			//We start checks for ailments here:
			if(is_dead)
				var/death_message = ""
				//Check for whether there's an appropriate ghost
				if(H.client)
					//Calculate revival status/time left
					var/revive_timer = round((H.timeofdeath + CONFIG_GET(number/revive_grace_period) - world.time) * 0.1)
					if(revive_timer < 60) //Almost out of time; urgency required.
						death_message = "<b>CRITICAL: Brain death imminent.</b> Reduce total injury value to sub-200 and administer defibrillator to unarmoured chest <b>immediately</b>."
					else if(revive_timer < 120) //Running out of time; increase urgency of message.
						death_message = "<b>URGENT: Brain death occurring soon.</b> Reduce total injury value to sub-200 and administer defibrillator to unarmoured chest to revive."
					else //Freshly dead.
						death_message = "Brain death will occur if patient is left untreated. Reduce total injury value to sub-200 and administer defibrillator to unarmoured chest to revive."
				else //No soul? Change the death message.
					death_message = "No soul detected. Cannot revive."
				advice += "<span class='scanner'><b>Patient Dead:</b> [death_message]</span>\n"
			if(M.on_fire)
				advice += "<span class='scanner'><b>Patient Combusting:</b> Administer fire extinguisher, pat out or submerge patient in water, or employ other fire suppressant.</span>\n"
			if(blood_volume <= 500 && !reagents_in_body["nutriment"])
				var/iron = "."
				if(reagents_in_body["iron"] < 5)
					iron = " or one dose of iron."
				advice += "<span class='scanner'><b>Low Blood:</b> Administer or recommend consumption of food[iron]</span>\n"
			if(overdosed && reagents_in_body["hypervene"] < 3)
				advice += "<span class='scanner'><b>Overdose:</b> Administer one dose of hypervene or perform dialysis on patient via sleeper.</span>\n"
			if(rad > 5)
				var/arithrazine = ""
				var/hyronalin = ""
				//var/hypervene = ""
				//if(reagents_in_body["hypervene"] < 3)
				//	hypervene = "hypervene"
				if(reagents_in_body["arithrazine"] < 3)
					arithrazine = "arithrazine"
				if(reagents_in_body["hyronalin"] < 3)
					hyronalin = "hyronalin"
				advice += "<span class='scanner'><b>Radiation:</b> Administer one dose of: [arithrazine] | [hyronalin]</span>\n"
			if(unknown_body)
				advice += "<span class='scanner'><b>Shrapnel/Embedded Object(s):</b> Seek surgical remedy to remove embedded object(s).</span>\n"
			//if(infected)
			//	advice += "<span class='scanner'><b>Larval Infection:</b> !!URGENT: Place patient in cryobag and seek surgical remedy immediately!!</span>\n"
			if(fracture_detected)
				advice += "<span class='scanner'><b>Unsecured Fracture:</b> Administer splints to specified areas.</span>\n"
			if(internal_bleed_detected)
				var/internal_bleed_advice = "Administer one dose of quick-clot then seek surgical remedy."
				if(reagents_in_body["quickclot"] > 4)
					internal_bleed_advice = "Quick-Clot has been administered to patient. Seek surgical remedy."
				advice += "<span class='scanner'><b>Internal Bleeding:</b> [internal_bleed_advice]</span>\n"
			if(H.getToxLoss() > 10)
				var/dylovene = ""
				//var/hypervene = ""
				var/dylo_recommend = ""
				//if(reagents_in_body["hypervene"] < 3)
				//	hypervene = "hypervene"
				if(reagents_in_body["dylovene"] < 5)
					if(synaptizine_amount)
						dylo_recommend = "Addendum: Dylovene recommended, but conflicting synaptizine present."
					else
						dylovene = "dylovene"
				if(reagents_in_body["tricordrazine"] < 5)
					tricordrazine = "tricordrazine"
				if(H.getToxLoss() > 50) //Serious toxin damage that is likely to threaten liver damage or be caused by it
					peridaxon = "Administer one dose of peridaxon and: "
					if(hyperzine_amount) //Need to make sure no conflicting chems are present; if so, warn the operator
						peridaxon = "Purge hyperzine in patient or wait for it to metabolize, then administer one dose of peridaxon and:"
					advice += "<span class='scanner'><b>Extreme Toxin Damage/Probable or Imminent Liver Damage:</b> [peridaxon] [dylovene] | [tricordrazine]. [dylo_recommend]</span>\n"
				else
					advice += "<span class='scanner'><b>Toxin Damage:</b> Administer one dose of: [tricordrazine] | [dylovene].</span>\n"
			if(((H.getOxyLoss() > 50 && blood_volume > 400) || H.getBrainLoss() >= 10) && reagents_in_body["peridaxon"] < 5)
				peridaxon = "Administer one dose of peridaxon."
				if(hyperzine_amount) //Need to make sure no conflicting chems are present; if so, warn the operator
					peridaxon = "Purge hyperzine in patient or wait for it to metabolize, then administer one dose of peridaxon."
				advice += "<span class='scanner'><b>Brain Damage/Probable Organ Damage:</b> [peridaxon]</span>\n"
			if(infection_present && reagents_in_body["spaceacillin"] < infection_present)
				advice += "<span class='scanner'><b>Infection:</b> Administer one dose of spaceacillin.</span>\n"
			if(H.getOxyLoss() > 10)
				var/dexalin = ""
				var/dexplus = ""
				if(reagents_in_body["dexalin"] < 5)
					dexalin = "dexalin"
				if(reagents_in_body["dexalinplus"] < 1)
					dexplus = "dexalin plus"
				advice += "<span class='scanner'><b>Oxygen Deprivation:</b> Administer one dose of: [dexalin] | [dexplus].</span>\n"
			if(H.getFireLoss(1)  > 10)
				var/kelotane = ""
				var/dermaline = ""
				if(reagents_in_body["kelotane"] < 5)
					kelotane = "kelotane"
				if(reagents_in_body["dermaline"] < 1)
					dermaline = "dermaline"
				if(reagents_in_body["tricordrazine"] < 5)
					tricordrazine = "tricordrazine"
				advice += "<span class='scanner'><b>Burn Damage:</b> Administer burn kit to affected areas and one dose of: [kelotane] | [dermaline] | [tricordrazine].</span>\n"
			if(H.getBruteLoss(1) > 10)
				var/bicaridine = ""
				if (reagents_in_body["bicaridine"] < 5)
					bicaridine = "bicaridine"
				if(reagents_in_body["tricordrazine"] < 5)
					tricordrazine = "tricordrazine"
				advice += "<span class='scanner'><b>Physical Trauma:</b> Administer trauma kit to affected areas and one dose of: [bicaridine] | [tricordrazine].</span>\n"
			if(H.health < 0 && reagents_in_body["inaprovaline"] < 5)
				advice += "<span class='scanner'><b>Patient Critical:</b> Administer one dose of inaprovaline.</span>\n"
			var/shock_number = H.traumatic_shock
			if(shock_number > 30)
				var/painlevel = "Significant"
				var/tramadol = ""
				var/oxycodone = ""
				var/oxy_recommend = "N/A"
				var/trama_recommend = "N/A"
				if (reagents_in_body["tramadol"] < 3)
					if(paracetamol_amount)
						trama_recommend = "Tramadol recommended, but conflicting paracetamol present."
					else
						tramadol = "tramadol"
				if (reagents_in_body["oxycodone"] < 3)
					oxycodone = "oxycodone"
				if(shock_number > 120)
					painlevel = "Extreme"
					if(oxycodone)
						oxy_recommend = "Oxycodone recommended."
				advice += "<span class='scanner'><b>[painlevel] Pain:</b> Administer one dose of: [tramadol] | [oxycodone]. Addendum: [oxy_recommend] | [trama_recommend].</span>\n"
			if(advice != "")
				dat += "\t<span class='scanner'> <b>Medication Advice:</b></span>\n"
				dat += advice
			advice = ""
			if(synaptizine_amount)
				advice += "<span class='scanner'><b>Synaptizine Detected:</b> DO NOT administer dylovene until synaptizine is purged or metabolized.</span>\n"
			if(paracetamol_amount)
				advice += "<span class='scanner'><b>Paracetamol Detected:</b> DO NOT administer tramadol until paracetamol is purged or metabolized.</span>\n"
			if(neurotoxin_amount)
				advice += "<span class='scanner'><b>Xenomorph Neurotoxin Detected:</b> Administer hypervene to purge.</span>\n"
			if(growthtoxin_amount)
				advice += "<span class='scanner'><b>Xenomorph Growth Toxin Detected:</b> Administer hypervene to purge.</span>\n"
			if(advice != "")
				dat += "\t<span class='scanner'> <b>Contraindications:</b></span>\n"
				dat += advice

	if(hud_mode)
		dat = replacetext(dat, "\n", "<br>")
		dat = replacetext(dat, "\t", "&emsp;")
		dat = replacetext(dat, "class='warning'", "style='color:red;'")
		dat = replacetext(dat, "class='scanner'", "style='color:red;'")
		dat = replacetext(dat, "class='scannerb'", "style='color:red; font-weight: bold;'")
		dat = replacetext(dat, "class='scannerburn'", "style='color:#FFA500;'")
		dat = replacetext(dat, "class='scannerburnb'", "style='color:#FFA500; font-weight: bold;'")
		user << browse(dat, "window=handscanner;size=500x400")
	else
		user.show_message(dat, 1)
	return

/obj/item/healthanalyzer/verb/toggle_mode()
	set name = "Switch Verbosity"
	set category = "Object"
	mode = !mode
	switch (mode)
		if(1)
			to_chat(usr, "The scanner now shows specific limb damage.")
		if(0)
			to_chat(usr, "The scanner no longer shows limb damage.")

/obj/item/healthanalyzer/verb/toggle_hud_mode()
	set name = "Switch Hud"
	set category = "Object"
	hud_mode = !hud_mode
	switch (hud_mode)
		if(1)
			to_chat(usr, "The scanner now shows results on the hud.")
		if(0)
			to_chat(usr, "The scanner no longer shows results on the hud.")

/obj/item/healthanalyzer/integrated
	name = "\improper HF2 integrated health analyzer"
	desc = "A body scanner able to distinguish vital signs of the subject. This model has been integrated into another object, and is simpler to use."
	skill_threshold = SKILL_MEDICAL_UNTRAINED

/obj/item/analyzer
	desc = "A hand-held environmental scanner which reports current gas levels."
	name = "analyzer"
	icon_state = "atmos"
	item_state = "analyzer"
	w_class = 2.0
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	throwforce = 5
	throw_speed = 4
	throw_range = 20

	matter = list("metal" = 30,"glass" = 20)

	origin_tech = "magnets=1;engineering=1"

/obj/item/analyzer/attack_self(mob/user as mob)

	if (user.stat)
		return

	var/turf/location = user.loc
	if (!( istype(location, /turf) ))
		return

	var/env_pressure = location.return_pressure()
	var/env_gas = location.return_gas()
	var/env_temp = location.return_temperature()

	user.show_message("<span class='boldnotice'>Results:</span>", 1)
	if(abs(env_pressure - ONE_ATMOSPHERE) < 10)
		user.show_message("<span class='notice'> Pressure: [round(env_pressure,0.1)] kPa</span>", 1)
	else
		user.show_message("<span class='warning'> Pressure: [round(env_pressure,0.1)] kPa</span>", 1)
	if(env_pressure > 0)
		user.show_message("<span class='notice'> Gas Type: [env_gas]</span>", 1)
		user.show_message("<span class='notice'> Temperature: [round(env_temp-T0C)]&deg;C</span>", 1)

	return

/obj/item/mass_spectrometer
	desc = "A hand-held mass spectrometer which identifies trace chemicals in a blood sample."
	name = "mass-spectrometer"
	icon_state = "spectrometer"
	item_state = "analyzer"
	w_class = 2
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	throwforce = 5
	throw_speed = 4
	throw_range = 20

	matter = list("metal" = 30,"glass" = 20)

	origin_tech = "magnets=2;biotech=2"
	var/details = 0
	var/recent_fail = 0

/obj/item/mass_spectrometer/Initialize(mapload)
	. = ..()
	create_reagents(5, OPENCONTAINER)

/obj/item/mass_spectrometer/on_reagent_change()
	if(reagents.total_volume)
		icon_state = initial(icon_state) + "_s"
	else
		icon_state = initial(icon_state)

/obj/item/mass_spectrometer/attack_self(mob/user as mob)
	if (user.stat)
		return
	if (crit_fail)
		to_chat(user, "<span class='warning'>This device has critically failed and is no longer functional!</span>")
		return
	if(reagents.total_volume)
		var/list/blood_traces = list()
		for(var/datum/reagent/R in reagents.reagent_list)
			if(R.id != "blood")
				reagents.clear_reagents()
				to_chat(user, "<span class='warning'>The sample was contaminated! Please insert another sample</span>")
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
		to_chat(user, "[dat]")
		reagents.clear_reagents()
	return


/obj/item/mass_spectrometer/adv
	name = "advanced mass-spectrometer"
	icon_state = "adv_spectrometer"
	details = 1
	origin_tech = "magnets=4;biotech=2"

/obj/item/reagent_scanner
	name = "reagent scanner"
	desc = "A hand-held reagent scanner which identifies chemical agents."
	icon_state = "spectrometer"
	item_state = "analyzer"
	w_class = 2.0
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	throwforce = 5
	throw_speed = 4
	throw_range = 20
	matter = list("metal" = 30,"glass" = 20)

	origin_tech = "magnets=2;biotech=2"
	var/details = 0
	var/recent_fail = 0

/obj/item/reagent_scanner/afterattack(obj/O, mob/user as mob, proximity)
	if(!proximity)
		return
	if (user.stat)
		return
	if(!istype(O))
		return
	if (crit_fail)
		to_chat(user, "<span class='warning'>This device has critically failed and is no longer functional!</span>")
		return

	if(!isnull(O.reagents))
		var/dat = ""
		if(O.reagents.reagent_list.len > 0)
			var/one_percent = O.reagents.total_volume / 100
			for (var/datum/reagent/R in O.reagents.reagent_list)
				if(prob(reliability))
					dat += "\n \t <span class='notice'> [R][details ? ": [R.volume / one_percent]%" : ""]</span>"
					recent_fail = 0
				else if(recent_fail)
					crit_fail = 1
					dat = null
					break
				else
					recent_fail = 1
		if(dat)
			to_chat(user, "<span class='notice'>Chemicals found: [dat]</span>")
		else
			to_chat(user, "<span class='notice'>No active chemical agents found in [O].</span>")
	else
		to_chat(user, "<span class='notice'>No significant chemical agents found in [O].</span>")

	return

/obj/item/reagent_scanner/adv
	name = "advanced reagent scanner"
	icon_state = "adv_spectrometer"
	details = 1
	origin_tech = "magnets=4;biotech=2"
