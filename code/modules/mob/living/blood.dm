/****************************************************
				BLOOD SYSTEM
****************************************************/

/mob/living/proc/handle_blood()
	return


// Takes care blood loss and regeneration
/mob/living/carbon/human/handle_blood()
	if(species.species_flags & NO_BLOOD)
		return

	if(stat != DEAD && bodytemperature >= 170)	//Dead or cryosleep people do not pump the blood.



		//Blood regeneration if there is some space
		if(blood_volume < BLOOD_VOLUME_NORMAL)
			blood_volume += 0.1 // regenerate blood VERY slowly
		if(blood_volume > BLOOD_VOLUME_MAXIMUM) //Warning: contents under pressure.
			var/spare_blood = blood_volume - ((BLOOD_VOLUME_MAXIMUM + BLOOD_VOLUME_NORMAL) / 2) //Knock you to the midpoint between max and normal to not spam.
			if(drip(spare_blood))
				var/bleed_range = 0
				switch(spare_blood)
					if(0 to 30) //20 is the functional minimum due to midpoint calc
						to_chat(src, span_notice("Some spare blood leaks out of your nose."))
					if(30 to 100)
						to_chat(src, span_notice("Spare blood gushes out of your ears and mouth. Must've had too much."))
						bleed_range = 1
					if(100 to INFINITY)
						visible_message(span_notice("Several jets of blood open up across [src]'s body and paint the surroundings red. How'd [p_they()] do that?"), \
							span_notice("Several jets of blood open up across your body and paint your surroundings red. You feel like you aren't under as much pressure any more."))
						bleed_range = 3
				if(bleed_range)
					for(var/turf/canvas in RANGE_TURFS(bleed_range, src))
						add_splatter_floor(canvas)
					for(var/mob/canvas in viewers(bleed_range, src))
						canvas.add_blood(species.blood_color) //Splash zone
					playsound(loc, 'sound/effects/splat.ogg', 25, TRUE, 7)

	//Effects of bloodloss
		switch(blood_volume)

			if(BLOOD_VOLUME_OKAY to BLOOD_VOLUME_SAFE)
				if(prob(1))
					var/word = pick("dizzy","woozy","faint")
					to_chat(src, span_warning("You feel [word]"))
				if(oxyloss < 20)
					adjustOxyLoss(3)
			if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY)
				if(eye_blurry < 50)
					adjust_blurriness(5)
				if(oxyloss < 40)
					adjustOxyLoss(6)
				else
					adjustOxyLoss(3)
				if(prob(10) && stat == UNCONSCIOUS)
					adjustToxLoss(1)
				if(prob(15))
					Unconscious(rand(20,60))
					var/word = pick("dizzy","woozy","faint")
					to_chat(src, span_warning("You feel extremely [word]"))
			if(BLOOD_VOLUME_SURVIVE to BLOOD_VOLUME_BAD)
				adjustOxyLoss(5)
				adjustToxLoss(2)
				if(prob(15))
					var/word = pick("dizzy","woozy","faint")
					to_chat(src, span_warning("You feel extremely [word]"))
			if(0 to BLOOD_VOLUME_SURVIVE)
				death()


		// Without enough blood you slowly go hungry.
		if(blood_volume < BLOOD_VOLUME_SAFE)
			switch(nutrition)
				if(300 to INFINITY)
					adjust_nutrition(-10)
				if(200 to 300)
					adjust_nutrition(-3)

		//Bleeding out
		var/blood_max = 0
		for(var/l in limbs)
			var/datum/limb/temp = l
			if(!(temp.limb_status & LIMB_BLEEDING) || temp.limb_status & LIMB_ROBOT)
				continue
			blood_max += temp.brute_dam / 60
			if (temp.surgery_open_stage)
				blood_max += 0.6  //Yer stomach is cut open

		if(blood_max)
			drip(blood_max)




//Makes a blood drop, leaking amt units of blood from the mob
/mob/living/carbon/proc/drip(amt)

	if(reagents.get_reagent_amount(/datum/reagent/medicine/quickclot)) //Quickclot stops bleeding, magic!
		return

	if(blood_volume)
		blood_volume = max(blood_volume - amt, 0)
		if(isturf(src.loc)) //Blood loss still happens in locker, floor stays clean
			if(amt >= 10)
				add_splatter_floor(loc)
			else
				add_splatter_floor(loc, 1)
		return TRUE

/mob/living/carbon/human/drip(amt)
	if(HAS_TRAIT(src, TRAIT_STASIS)) // stasis now stops bloodloss
		return
	if(species.species_flags & NO_BLOOD)
		return
	return ..()



/mob/living/proc/restore_blood()
	blood_volume = initial(blood_volume)

/mob/living/carbon/human/restore_blood()
	blood_volume = BLOOD_VOLUME_NORMAL




/****************************************************
				BLOOD TRANSFERS
****************************************************/
/*
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

	var/list/blood_data = get_blood_data()

	if(iscarbon(AM))
		var/mob/living/carbon/C = AM
		if(blood_id == C.get_blood_id())//both mobs have the same blood substance
			if(blood_id == "blood") //normal blood
				if(!(blood_data["blood_type"] in get_safe_blood(C.dna.b_type)))
					C.reagents.add_reagent(/datum/reagent/toxin, amount * 0.5)
					return 1

			C.blood_volume = min(C.blood_volume + round(amount, 0.1), BLOOD_VOLUME_MAXIMUM)
			return 1

	AM.reagents.add_reagent(blood_id, amount, blood_data, bodytemperature)
	return 1
*/


//Transfers blood from container to mob
/mob/living/carbon/proc/inject_blood(obj/item/reagent_containers/container, amount)
	for(var/datum/reagent/R in container.reagents.reagent_list)
		reagents.add_reagent(R.type, amount, R.data)
		reagents.update_total()
		container.reagents.remove_reagent(R.type, amount)


//Transfers blood from container to human, respecting blood types compatability.
/mob/living/carbon/human/inject_blood(obj/item/reagent_containers/container, amount)
	var/b_id = get_blood_id()
	for(var/datum/reagent/R in container.reagents.reagent_list)
		// If its blood, lets check its compatible or not and cause some toxins.
		if(istype(R, /datum/reagent/blood) && b_id)
			if(b_id == "blood" && R.data && !(R.data["blood_type"] in get_safe_blood(blood_type)))
				reagents.add_reagent(/datum/reagent/toxin, amount * 0.5)
			else
				blood_volume += round(amount, 0.1)
		else
			reagents.add_reagent(R.type, amount, R.data)
			reagents.update_total()
		container.reagents.remove_reagent(R.type, amount)


//Gets blood from mob to the container, preserving all data in it.
/mob/living/carbon/proc/take_blood(obj/O, amount)
	if(!O.reagents)
		return

	if(blood_volume < amount)
		return

	var/b_id = get_blood_id()
	if(!b_id)
		return

	var/list/data = get_blood_data()

	var/list/temp_chem = list()
	for(var/datum/reagent/R in reagents.reagent_list)
		temp_chem += R.type
		temp_chem[R.type] = R.volume
	data["trace_chem"] = list2params(temp_chem)

	O.reagents.add_reagent(/datum/reagent/blood, amount, data)

	blood_volume = max(0, blood_volume - amount) // Removes blood if human
	return 1


/mob/living/carbon/human/take_blood(obj/O, amount)

	if(species && species.species_flags & NO_BLOOD)
		return

	. = ..()




//////////////////////////////

//returns the data to give to the blood reagent this mob gives
/mob/living/proc/get_blood_data()
	if(!get_blood_id())
		return

	var/list/blood_data = list()

	blood_data["blood_colour"] = get_blood_color()

	return blood_data

// Add blood type to carbons that may have one
/mob/living/carbon/get_blood_data()
	. = ..()

	if(blood_type)
		.["blood_type"] = blood_type


//returns the color of the mob's blood
/mob/living/proc/get_blood_color()
	return "#A10808"

/mob/living/carbon/xenomorph/get_blood_color()
	return "#dffc00"

/mob/living/carbon/human/get_blood_color()
	return species.blood_color


//todo make these return values defines
//get the id of the substance this mob uses as blood.
/mob/proc/get_blood_id()
	return

/mob/living/carbon/xenomorph/get_blood_id()
	return "xenoblood"

/mob/living/carbon/human/get_blood_id()
	if((species.species_flags & NO_BLOOD))
		return
	if(issynth(src))
		return "whiteblood"
	return "blood"

/mob/living/simple_animal/mouse/get_blood_id()
	return "blood"

/mob/living/simple_animal/cat/get_blood_id()
	return "blood"

/mob/living/simple_animal/cow/get_blood_id()
	return "blood"

/mob/living/simple_animal/parrot/get_blood_id()
	return "blood"

/mob/living/simple_animal/corgi/get_blood_id()
	return "blood"

/mob/living/simple_animal/hostile/retaliate/goat/get_blood_id()
	return "blood"




// This is has more potential uses, and is probably faster than the old proc.
/proc/get_safe_blood(bloodtype)
	. = list()
	if(!bloodtype)
		return
	switch(bloodtype)
		if("A-")
			return list("A-", "O-")
		if("A+")
			return list("A-", "A+", "O-", "O+")
		if("B-")
			return list("B-", "O-")
		if("B+")
			return list("B-", "B+", "O-", "O+")
		if("AB-")
			return list("A-", "B-", "O-", "AB-")
		if("AB+")
			return list("A-", "A+", "B-", "B+", "O-", "O+", "AB-", "AB+")
		if("O-")
			return list("O-")
		if("O+")
			return list("O-", "O+")





/////////////////// add_splatter_floor ////////////////////////////////////////


//to add a splatter of blood or other mob liquid.
/mob/living/proc/add_splatter_floor(turf/T, small_drip, b_color)
	if(get_blood_id() != "blood")
		return
	if(!T)
		T = get_turf(src)

	if(!T.can_bloody)
		return

	if(small_drip)
		// Only a certain number of drips (or one large splatter) can be on a given turf.
		var/obj/effect/decal/cleanable/blood/drip/drop = locate() in T
		if(drop)
			if(drop.drips < 3)
				drop.drips++
				drop.overlays |= pick(drop.random_icon_states)
				return
			else
				qdel(drop)//the drip is replaced by a bigger splatter
		else
			drop = new(T)
			if(b_color)
				drop.basecolor = b_color
				drop.color = b_color
			return


	// Find a blood decal or create a new one.
	var/obj/effect/decal/cleanable/blood/B = locate() in T
	if(B)
		return
	B = new /obj/effect/decal/cleanable/blood/splatter(T)
	if(b_color)
		B.basecolor = b_color
		B.color = b_color


/mob/living/carbon/human/add_splatter_floor(turf/T, small_drip, b_color)
	if(species.species_flags & NO_BLOOD)
		return

	b_color = species.blood_color

	..()

/mob/living/carbon/xenomorph/add_splatter_floor(turf/T, small_drip, b_color)
	if(!T)
		T = get_turf(src)

	if(!T.can_bloody)
		return

	var/obj/effect/decal/cleanable/blood/xeno/XB = locate() in T.contents
	if(!XB)
		XB = new(T)
