/****************************************************
				BLOOD SYSTEM
****************************************************/


/mob/living
	var/blood_volume = 0 //how much blood the mob has

/mob/living/carbon
	blood_volume = BLOOD_VOLUME_NORMAL




/mob/living/proc/handle_blood()
	return

/mob/living/carbon/monkey/handle_blood()
	if(bodytemperature >= 225) //cryosleep people do not pump the blood.
		//Blood regeneration if there is some space
		if(blood_volume < BLOOD_VOLUME_NORMAL)
			blood_volume += 0.1 // regenerate blood VERY slowly


// Takes care blood loss and regeneration
/mob/living/carbon/human/handle_blood()

	if(NO_BLOOD in species.flags)
		return

	if(stat != DEAD && bodytemperature >= 170)	//Dead or cryosleep people do not pump the blood.



		//Blood regeneration if there is some space
		if(blood_volume < BLOOD_VOLUME_NORMAL)
			blood_volume += 0.1 // regenerate blood VERY slowly

		var/b_volume = blood_volume

		// Damaged heart virtually reduces the blood volume, as the blood isn't
		// being pumped properly anymore.
		if(species && species.has_organ["heart"])
			var/datum/internal_organ/heart/heart = internal_organs_by_name["heart"]

			if(!heart)
				b_volume = 0
			else if(reagents.get_reagent_amount("peridaxon") >= 0.05)
				b_volume *= 1
			else if(heart.damage > 1 && heart.damage < heart.min_bruised_damage)
				b_volume *= 0.8
			else if(heart.damage >= heart.min_bruised_damage && heart.damage < heart.min_broken_damage)
				b_volume *= 0.6
			else if(heart.damage >= heart.min_broken_damage && heart.damage < INFINITY)
				b_volume *= 0.3





	//Effects of bloodloss
		switch(blood_volume)

			if(BLOOD_VOLUME_OKAY to BLOOD_VOLUME_SAFE)
				if(prob(1))
					var/word = pick("dizzy","woozy","faint")
					src << "\red You feel [word]"
				if(oxyloss < 20)
					oxyloss += 3
			if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY)
				if(eye_blurry < 50)
					eye_blurry += 6
				if(oxyloss < 50)
					oxyloss += 10
				oxyloss += 2
				if(prob(15))
					KnockOut(rand(1,3))
					var/word = pick("dizzy","woozy","faint")
					src << "\red You feel extremely [word]"
			if(BLOOD_VOLUME_SURVIVE to BLOOD_VOLUME_BAD)
				oxyloss += 5
				toxloss += 3
				if(prob(15))
					var/word = pick("dizzy","woozy","faint")
					src << "\red You feel extremely [word]"
			if(0 to BLOOD_VOLUME_SURVIVE)
				death()


		// Without enough blood you slowly go hungry.
		if(blood_volume < BLOOD_VOLUME_SAFE)
			if(nutrition >= 300)
				nutrition -= 10
			else if(nutrition >= 200)
				nutrition -= 3

		//Bleeding out
		var/blood_max = 0
		for(var/datum/limb/temp in limbs)
			if(!(temp.status & LIMB_BLEEDING) || temp.status & LIMB_ROBOT)
				continue
			for(var/datum/wound/W in temp.wounds)
				if(W.bleeding())
					blood_max += (W.damage / 40)
			if(temp.status & LIMB_DESTROYED && !(temp.status & LIMB_AMPUTATED))
				blood_max += 5 //Yer missing a fucking limb.
			if (temp.surgery_open_stage)
				blood_max += 0.6  //Yer stomach is cut open

		if(blood_max)
			drip(blood_max)




//Makes a blood drop, leaking amt units of blood from the mob
/mob/living/carbon/proc/drip(amt)

	if(reagents.get_reagent_amount("quickclot")) //Quickclot stops bleeding, magic!
		return

	if(blood_volume)
		blood_volume = max(blood_volume - amt, 0)
		if(isturf(src.loc)) //Blood loss still happens in locker, floor stays clean
			if(amt >= 10)
				add_splatter_floor(loc)
			else
				add_splatter_floor(loc, 1)

/mob/living/carbon/human/drip(amt)
	if(in_stasis) // stasis now stops bloodloss
		return
	if(NO_BLOOD in species.flags)
		return
	..()



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
					C.reagents.add_reagent("toxin", amount * 0.5)
					return 1

			C.blood_volume = min(C.blood_volume + round(amount, 0.1), BLOOD_VOLUME_MAXIMUM)
			return 1

	AM.reagents.add_reagent(blood_id, amount, blood_data, bodytemperature)
	return 1
*/


//Transfers blood from container to mob
/mob/living/carbon/proc/inject_blood(obj/item/reagent_container/container, amount)

	var/b_id = get_blood_id()
	if(!b_id)
		return

	for(var/datum/reagent/blood/B in container.reagents.reagent_list)
		if(B.id == b_id)

			if(b_id == "blood" && B.data && !(B.data["blood_type"] in get_safe_blood(dna.b_type)))
				reagents.add_reagent("toxin", amount * 0.5)
			else
				blood_volume = min(blood_volume + round(amount, 0.1), BLOOD_VOLUME_MAXIMUM)

		else
			reagents.add_reagent(B.id, amount, B.data)
			reagents.update_total()

		container.reagents.remove_reagent(B.id, amount)
		return


//Transfers blood from container to human, respecting blood types compatability.
/mob/living/carbon/human/inject_blood(obj/item/reagent_container/container, amount)

	var/datum/reagent/blood/B = locate() in container.reagents.reagent_list

	if(species && species.flags & NO_BLOOD)
		reagents.add_reagent(B.id, amount, B.data)
		reagents.update_total()
		container.reagents.remove_reagent(B.id, amount)
		return


	..()



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
		temp_chem += R.id
		temp_chem[R.id] = R.volume
	data["trace_chem"] = list2params(temp_chem)

	O.reagents.add_reagent(b_id, amount, data)

	blood_volume = max(0, blood_volume - amount) // Removes blood if human
	return 1


/mob/living/carbon/human/take_blood(obj/O, var/amount)

	if(species && species.flags & NO_BLOOD)
		return

	. = ..()




//////////////////////////////

//returns the data to give to the blood reagent this mob gives
/mob/living/proc/get_blood_data()
	if(!get_blood_id())
		return

	var/list/blood_data = list()

	var/list/b_dna = get_blood_dna_list()
	for(var/i in b_dna)
		blood_data["blood_DNA"] = i
		blood_data["blood_type"] = b_dna[i]

	blood_data["blood_colour"] = get_blood_color()

	blood_data["viruses"] = list()

	return blood_data


/mob/living/carbon/get_blood_data()
	var/list/blood_data = ..()
	if(!blood_data)
		return

	for(var/datum/disease/D in viruses)
		blood_data["viruses"] += D.Copy()

	if(resistances && resistances.len)
		blood_data["resistances"] = resistances.Copy()

	return blood_data






//returns the mob's dna info as a list, to be inserted in an object's blood_DNA list
/mob/living/proc/get_blood_dna_list()
	if(!get_blood_id())
		return
	return list("ANIMAL DNA" = "C-")

/mob/living/carbon/get_blood_dna_list()
	var/b_id = get_blood_id()
	if(!b_id)
		return

	switch(b_id)
		if("blood")
			if(dna)
				return list(dna.unique_enzymes = dna.b_type)
			else
				return list("UNKNOWN DNA" = "X*")
		if("whiteblood")
			return list("SYNTHETIC BLOOD" = "S*")
		if("greyblood")
			return list(dna.unique_enzymes = "Z*")
		if("greenblood")
			return list("UNKNOWN DNA" = "Y*")
		if("xenoblood")
			return list("UNKNOWN DNA" = "X*")




//returns the color of the mob's blood
/mob/living/proc/get_blood_color()
	return "#A10808"

/mob/living/carbon/Xenomorph/get_blood_color()
	return "#dffc00"

/mob/living/carbon/human/get_blood_color()
	return species.blood_color



//get the id of the substance this mob uses as blood.
/mob/proc/get_blood_id()
	return

/mob/living/carbon/monkey/get_blood_id()
	return "blood"

/mob/living/carbon/Xenomorph/get_blood_id()
	return "xenoblood"

/mob/living/carbon/human/get_blood_id()
	if((NO_BLOOD in species.flags))
		return
	if(species.name == "Yautja")
		return "greenblood"
	if(species.name == "Synthetic" || species.name == "Early Synthetic")
		return "whiteblood"
	if(species.name == "Zombie")
		return "greyblood"
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

	var/list/temp_blood_DNA

	if(small_drip)
		// Only a certain number of drips (or one large splatter) can be on a given turf.
		var/obj/effect/decal/cleanable/blood/drip/drop = locate() in T
		if(drop)
			if(drop.drips < 3)
				drop.drips++
				drop.overlays |= pick(drop.random_icon_states)
				drop.transfer_mob_blood_dna(src)
				return
			else
				temp_blood_DNA = list()
				temp_blood_DNA |= drop.blood_DNA.Copy() //we transfer the dna from the drip to the splatter
				cdel(drop)//the drip is replaced by a bigger splatter
		else
			drop = new(T)
			drop.transfer_mob_blood_dna(src)
			if(b_color)
				drop.basecolor = b_color
				drop.color = b_color
			return


	// Find a blood decal or create a new one.
	var/obj/effect/decal/cleanable/blood/B = locate() in T
	if(!B)
		B = new /obj/effect/decal/cleanable/blood/splatter(T)
		if(b_color)
			B.basecolor = b_color
			B.color = b_color
	B.transfer_mob_blood_dna(src) //give blood info to the blood decal.
	if(temp_blood_DNA)
		B.blood_DNA |= temp_blood_DNA


/mob/living/carbon/human/add_splatter_floor(turf/T, small_drip, b_color)
	if(NO_BLOOD in species.flags)
		return

	b_color = species.blood_color

	..()

/mob/living/carbon/Xenomorph/add_splatter_floor(turf/T, small_drip, b_color)
	if(!T)
		T = get_turf(src)

	if(!T.can_bloody)
		return

	var/obj/effect/decal/cleanable/blood/xeno/XB = locate() in T.contents
	if(!XB)
		XB = new(T)
	XB.blood_DNA["UNKNOWN DNA"] = "X*"



/mob/living/silicon/robot/add_splatter_floor(turf/T, small_drip, b_color)
	if(!T)
		T = get_turf(src)

	if(!T.can_bloody)
		return

	var/obj/effect/decal/cleanable/blood/oil/O = locate() in T.contents
	if(!O)
		O = new(T)

