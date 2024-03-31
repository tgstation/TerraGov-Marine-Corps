/****************************************************
				BLOOD SYSTEM
****************************************************/

/mob/living/proc/suppress_bloodloss(amount)
	if(bleedsuppress)
		return
	else
		bleedsuppress = TRUE
		addtimer(CALLBACK(src, .proc/resume_bleeding), amount)

/mob/living/proc/resume_bleeding()
	bleedsuppress = 0
	if(stat != DEAD && bleed_rate)
		to_chat(src, "<span class='warning'>The blood soaks through my bandage.</span>")

/mob/living/carbon/monkey/handle_blood()
	if(bodytemperature >= TCRYO && !(HAS_TRAIT(src, TRAIT_HUSK))) //cryosleep or husked people do not pump the blood.
		//Blood regeneration if there is some space
		if(blood_volume < BLOOD_VOLUME_NORMAL)
			blood_volume += 0.1 // regenerate blood VERY slowly
			if(blood_volume < BLOOD_VOLUME_OKAY)
				adjustOxyLoss(round((BLOOD_VOLUME_NORMAL - blood_volume) * 0.02, 1))

/mob/living/proc/update_bleed_rate()
	var/newbr = 0
	for(var/datum/wound/W in simple_wounds)
		newbr += W.bleed_rate
	for(var/obj/item/I in simple_embedded_objects)
		if(I.embedding)
			newbr += I.embedding.embedded_bloodloss
	return newbr

/mob/living/proc/handle_blood()
	blood_volume = min(blood_volume, BLOOD_VOLUME_MAXIMUM)

	bleed_rate = min(update_bleed_rate(), 10)

	if(blood_volume < BLOOD_VOLUME_NORMAL && blood_volume && !bleed_rate)
		blood_volume = min(blood_volume+0.5, BLOOD_VOLUME_MAXIMUM)

	//Effects of bloodloss
	switch(blood_volume)
		if(BLOOD_VOLUME_OKAY to BLOOD_VOLUME_SAFE)
			remove_status_effect(/datum/status_effect/debuff/bleedingworse)
			remove_status_effect(/datum/status_effect/debuff/bleedingworst)
			apply_status_effect(/datum/status_effect/debuff/bleeding)
		if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY)
			if(prob(3))
				blur_eyes(6)
				to_chat(src, "<span class='warning'>I feel faint.</span>")
			remove_status_effect(/datum/status_effect/debuff/bleeding)
			remove_status_effect(/datum/status_effect/debuff/bleedingworst)
			apply_status_effect(/datum/status_effect/debuff/bleedingworse)
		if(BLOOD_VOLUME_SURVIVE to BLOOD_VOLUME_BAD)
			if(prob(3) && !IsUnconscious())
				Unconscious(rand(5 SECONDS,10 SECONDS))
				to_chat(src, "<span class='warning'>I feel drained.</span>")
			remove_status_effect(/datum/status_effect/debuff/bleedingworse)
			remove_status_effect(/datum/status_effect/debuff/bleeding)
			apply_status_effect(/datum/status_effect/debuff/bleedingworst)
	if(bleed_rate)
		bleed(bleed_rate)

	if(blood_volume in -INFINITY to BLOOD_VOLUME_SURVIVE)
		adjustOxyLoss(1.6)

// Takes care blood loss and regeneration
/mob/living/carbon/handle_blood()
	blood_volume = min(blood_volume, BLOOD_VOLUME_MAXIMUM)
	if(dna)
		if(dna.species)
			if(NOBLOOD in dna.species.species_traits)
				blood_volume = BLOOD_VOLUME_NORMAL
				return

	if(bodytemperature >= TCRYO && !(HAS_TRAIT(src, TRAIT_HUSK))) //cryosleep or husked people do not pump the blood.

		//Blood regeneration if there is some space
		if(blood_volume < BLOOD_VOLUME_NORMAL && blood_volume)
			var/nutrition_ratio = 1
//			switch(nutrition)
//				if(0 to NUTRITION_LEVEL_STARVING)
//					nutrition_ratio = 0.2
//				if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
//					nutrition_ratio = 0.4
//				if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
//					nutrition_ratio = 0.6
//				if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
//					nutrition_ratio = 0.8
//				else
//					nutrition_ratio = 1
//			if(satiety > 80)
//				nutrition_ratio *= 1.25
//			adjust_hydration(-nutrition_ratio * HUNGER_FACTOR) //get thirsty twice as fast when regenning blood
			blood_volume = min(BLOOD_VOLUME_NORMAL, blood_volume + 0.5 * nutrition_ratio)

		//Effects of bloodloss
		switch(blood_volume)
			if(BLOOD_VOLUME_OKAY to BLOOD_VOLUME_SAFE)
				remove_status_effect(/datum/status_effect/debuff/bleedingworse)
				remove_status_effect(/datum/status_effect/debuff/bleedingworst)
				apply_status_effect(/datum/status_effect/debuff/bleeding)
			if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY)
				if(prob(3))
					blur_eyes(6)
					to_chat(src, "<span class='warning'>I feel faint.</span>")
				remove_status_effect(/datum/status_effect/debuff/bleeding)
				remove_status_effect(/datum/status_effect/debuff/bleedingworst)
				apply_status_effect(/datum/status_effect/debuff/bleedingworse)
			if(BLOOD_VOLUME_SURVIVE to BLOOD_VOLUME_BAD)
				if(prob(3) && !IsUnconscious())
					Unconscious(rand(5 SECONDS,10 SECONDS))
					to_chat(src, "<span class='warning'>I feel drained.</span>")
				remove_status_effect(/datum/status_effect/debuff/bleedingworse)
				remove_status_effect(/datum/status_effect/debuff/bleeding)
				apply_status_effect(/datum/status_effect/debuff/bleedingworst)

//		var/temp_bleed = 0
		//Bleeding out
		bleed_rate = get_bleed_rate()
//		bleed_rate = max(bleed_rate - 0.5, temp_bleed)//if no wounds, other bleed effects (heparin) naturally decreases

		if(bleed_rate)
			add_stress(/datum/stressevent/bleeding)
			bleed(bleed_rate)
		else
			remove_stress(/datum/stressevent/bleeding)

//	if(blood_volume in -INFINITY to BLOOD_VOLUME_SURVIVE)
//		adjustOxyLoss(1.6)
	//handled in life

/mob/living/carbon/proc/get_bleed_rate()
	var/bleedrate = 0
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		//We want an accurate reading of .len
		listclearnulls(BP.embedded_objects)
		bleedrate += BP.get_bleedrate()
//			temp_bleed += 0.5*BP.embedded_objects.len
		for(var/obj/item/I in BP.embedded_objects)
			if(I.embedding && I.embedding.embedded_bloodloss)
				bleedrate += I.embedding.embedded_bloodloss
	if(bleedrate)
		return bleedrate

//Makes a blood drop, leaking amt units of blood from the mob
/mob/living/proc/bleed(amt)
	if(!iscarbon(src))
		if(!HAS_TRAIT(src, TRAIT_SIMPLE_WOUNDS))
			return
	if(blood_volume)
		blood_volume = max(blood_volume - amt, 0)
		SSticker.blood_lost += amt
		if(isturf(src.loc)) //Blood loss still happens in locker, floor stays clean
			add_drip_floor(src.loc, amt)
		var/vol2use
		if(amt > 1)
			vol2use = 'sound/misc/bleed (1).ogg'
		if(amt > 2)
			vol2use = 'sound/misc/bleed (2).ogg'
		if(amt > 3)
			vol2use = 'sound/misc/bleed (3).ogg'
		if(lying || stat)
			vol2use = null
		if(vol2use)
			playsound(get_turf(src), vol2use, 100, FALSE)

	updatehealth()

/mob/living/carbon/human/bleed(amt)
	amt *= physiology.bleed_mod
	if(!(NOBLOOD in dna.species.species_traits))
		if(!mind || !mind.has_antag_datum(/datum/antagonist/zombie))
			..()



/mob/living/proc/restore_blood()
	blood_volume = initial(blood_volume)

/mob/living/carbon/human/restore_blood()
	blood_volume = BLOOD_VOLUME_NORMAL
	bleed_rate = 0

/****************************************************
				BLOOD TRANSFERS
****************************************************/

//Gets blood from mob to a container or other mob, preserving all data in it.
/mob/living/proc/transfer_blood_to(atom/movable/AM, amount, forced)
	if(!blood_volume || !AM.reagents)
		return 0
	if(blood_volume < BLOOD_VOLUME_BAD && !forced)
		return 0

	if(blood_volume < amount)
		amount = blood_volume

	var/blood_id = get_blood_id()
	if(!blood_id)
		return 0

	blood_volume -= amount

	var/list/blood_data = get_blood_data(blood_id)

	if(iscarbon(AM))
		var/mob/living/carbon/C = AM
		if(blood_id == C.get_blood_id())//both mobs have the same blood substance
			if(blood_id == /datum/reagent/blood) //normal blood
				if(blood_data["viruses"])
					for(var/thing in blood_data["viruses"])
						var/datum/disease/D = thing
						if((D.spread_flags & DISEASE_SPREAD_SPECIAL) || (D.spread_flags & DISEASE_SPREAD_NON_CONTAGIOUS))
							continue
						C.ForceContractDisease(D)
				if(!(blood_data["blood_type"] in get_safe_blood(C.dna.blood_type)))
					C.reagents.add_reagent(/datum/reagent/toxin, amount * 0.5)
					return 1

			C.blood_volume = min(C.blood_volume + round(amount, 0.1), BLOOD_VOLUME_MAXIMUM)
			return 1

	AM.reagents.add_reagent(blood_id, amount, blood_data, bodytemperature)
	return 1


/mob/living/proc/get_blood_data(blood_id)
	return

/mob/living/carbon/get_blood_data(blood_id)
	if(blood_id == /datum/reagent/blood) //actual blood reagent
		var/blood_data = list()
		//set the blood data
		blood_data["donor"] = src
		blood_data["viruses"] = list()

		for(var/thing in diseases)
			var/datum/disease/D = thing
			blood_data["viruses"] += D.Copy()

		blood_data["blood_DNA"] = copytext(dna.unique_enzymes,1,0)
		if(disease_resistances && disease_resistances.len)
			blood_data["resistances"] = disease_resistances.Copy()
		var/list/temp_chem = list()
		for(var/datum/reagent/R in reagents.reagent_list)
			temp_chem[R.type] = R.volume
		blood_data["trace_chem"] = list2params(temp_chem)
		if(mind)
			blood_data["mind"] = mind
		else if(last_mind)
			blood_data["mind"] = last_mind
		if(ckey)
			blood_data["ckey"] = ckey
		else if(last_mind)
			blood_data["ckey"] = ckey(last_mind.key)

		if(!suiciding)
			blood_data["cloneable"] = 1
		blood_data["blood_type"] = copytext(dna.blood_type,1,0)
		blood_data["gender"] = gender
		blood_data["real_name"] = real_name
		blood_data["features"] = dna.features
		blood_data["factions"] = faction
		blood_data["quirks"] = list()
		for(var/V in roundstart_quirks)
			var/datum/quirk/T = V
			blood_data["quirks"] += T.type
		return blood_data

//get the id of the substance this mob use as blood.
/mob/proc/get_blood_id()
	return

/mob/living/simple_animal/get_blood_id()
	if(blood_volume)
		return /datum/reagent/blood

/mob/living/carbon/monkey/get_blood_id()
	if(!(HAS_TRAIT(src, TRAIT_HUSK)))
		return /datum/reagent/blood

/mob/living/carbon/human/get_blood_id()
	if(HAS_TRAIT(src, TRAIT_HUSK))
		return
	if(dna?.species)
		if(dna.species.exotic_blood)
			return dna.species.exotic_blood
		if((NOBLOOD in dna.species.species_traits))
			return
	return /datum/reagent/blood

// This is has more potential uses, and is probably faster than the old proc.
/proc/get_safe_blood(bloodtype)
	. = list()
	if(!bloodtype)
		return

	var/static/list/bloodtypes_safe = list(
		"A-" = list("A-", "O-"),
		"A+" = list("A-", "A+", "O-", "O+"),
		"B-" = list("B-", "O-"),
		"B+" = list("B-", "B+", "O-", "O+"),
		"AB-" = list("A-", "B-", "O-", "AB-"),
		"AB+" = list("A-", "A+", "B-", "B+", "O-", "O+", "AB-", "AB+"),
		"O-" = list("O-"),
		"O+" = list("O-", "O+"),
		"L" = list("L"),
		"U" = list("A-", "A+", "B-", "B+", "O-", "O+", "AB-", "AB+", "L", "U")
	)

	var/safe = bloodtypes_safe[bloodtype]
	if(safe)
		. = safe

//to add a splatter of blood or other mob liquid.
/mob/living/proc/add_splatter_floor(turf/T)
	if(!iscarbon(src))
		if(!HAS_TRAIT(src, TRAIT_SIMPLE_WOUNDS))
			return
	if(!get_blood_id())
		return
	if(!T)
		T = get_turf(src)

	if(istype(T, /turf/open/water))
		var/turf/open/water/W = T
		W.water_reagent = /datum/reagent/water/gross
		W.water_color = "#c43c3c"
		W.update_icon()
		return
	new /obj/effect/decal/cleanable/blood/splatter(T, get_static_viruses())

/mob/living/proc/add_drip_floor(turf/T, amt)
	if(!iscarbon(src))
		if(!HAS_TRAIT(src, TRAIT_SIMPLE_WOUNDS))
			return
	if(!get_blood_id())
		return
	if(!T)
		T = get_turf(src)

	if(amt > 3)
		if(istype(T, /turf/open/water))
			var/turf/open/water/W = T
			W.water_reagent = /datum/reagent/water/gross
			W.water_color = "#c43c3c"
			W.update_icon()
			return
	var/obj/effect/decal/cleanable/blood/puddle/P = locate() in T
	if(P)
		P.blood_vol += amt
		P.update_icon()
	else
		var/obj/effect/decal/cleanable/blood/drip/D = locate() in T
		if(D)
			D.blood_vol += amt
			D.drips++
			D.update_icon()
		else
			new /obj/effect/decal/cleanable/blood/drip(T, get_static_viruses())

/mob/living/carbon/human/add_splatter_floor(turf/T, small_drip)
	if(!(NOBLOOD in dna.species.species_traits))
		..()

/mob/living/carbon/alien/add_splatter_floor(turf/T, small_drip)
	if(!T)
		T = get_turf(src)
	var/obj/effect/decal/cleanable/xenoblood/B = locate() in T.contents
	if(!B)
		B = new(T)
	B.add_blood_DNA(list("UNKNOWN DNA" = "X*"))

/mob/living/silicon/robot/add_splatter_floor(turf/T, small_drip)
	if(!T)
		T = get_turf(src)
	var/obj/effect/decal/cleanable/oil/B = locate() in T.contents
	if(!B)
		B = new(T)
