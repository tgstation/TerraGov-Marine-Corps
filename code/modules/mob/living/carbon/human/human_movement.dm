/mob/living/carbon/human/get_movespeed_modifiers()
	var/list/considering = ..()
	. = considering
	if(HAS_TRAIT(src, TRAIT_IGNORESLOWDOWN))
		for(var/id in .)
			var/list/data = .[id]
			if(data[MOVESPEED_DATA_INDEX_FLAGS] & IGNORE_NOSLOW)
				.[id] = data

/mob/living/carbon/human/slip(knockdown_amount, obj/O, lube, paralyze, forcedrop)
	if(HAS_TRAIT(src, TRAIT_NOSLIPALL))
		return 0
	if (!(lube&GALOSHES_DONT_HELP))
		if(HAS_TRAIT(src, TRAIT_NOSLIPWATER))
			return 0
		if(shoes && istype(shoes, /obj/item/clothing))
			var/obj/item/clothing/CS = shoes
			if (CS.clothing_flags & NOSLIP)
				return 0
	return ..()

/mob/living/carbon/human/experience_pressure_difference()
	playsound(src, 'sound/blank.ogg', 50, TRUE)
	if(shoes && istype(shoes, /obj/item/clothing))
		var/obj/item/clothing/S = shoes
		if (S.clothing_flags & NOSLIP)
			return 0
	return ..()

/mob/living/carbon/human/mob_has_gravity()
	. = ..()
	if(!.)
		if(mob_negates_gravity())
			. = 1

/mob/living/carbon/human/mob_negates_gravity()
	return ((shoes && shoes.negates_gravity()) || (dna.species.negates_gravity(src)))

/mob/living/carbon/human/Move(NewLoc, direct)
/*	if(fixedeye || tempfixeye)
		switch(dir)
			if(NORTH)
				if(direct == WEST|EAST)
					OffBalance(30)
			if(SOUTH)
				if(direct == WEST|EAST)
					OffBalance(30)
			if(EAST)
				if(direct == NORTH|SOUTH)
					OffBalance(30)
			if(WEST)
				if(direct == NORTH|SOUTH)
					OffBalance(30)*/

	. = ..()
	if(loc == NewLoc)
		if(!has_gravity(loc))
			return

		if(wear_armor)
			if(mobility_flags & MOBILITY_STAND)
				var/obj/item/clothing/C = wear_armor
				C.step_action()

		if(wear_shirt)
			if(mobility_flags & MOBILITY_STAND)
				var/obj/item/clothing/C = wear_shirt
				C.step_action()

		if(cloak)
			if(mobility_flags & MOBILITY_STAND)
				var/obj/item/clothing/C = cloak
				C.step_action()

		if(shoes)
			if(mobility_flags & MOBILITY_STAND)
				var/obj/item/clothing/shoes/S = shoes

				//Bloody footprints
				var/turf/T = get_turf(src)
				if(S.bloody_shoes && S.bloody_shoes[S.blood_state])
					for(var/obj/effect/decal/cleanable/blood/footprints/oldFP in T)
						if (oldFP.blood_state == S.blood_state)
							return
					//No oldFP or they're all a different kind of blood
					S.bloody_shoes[S.blood_state] = max(0, S.bloody_shoes[S.blood_state] - BLOOD_LOSS_PER_STEP)
					if (S.bloody_shoes[S.blood_state] > BLOOD_LOSS_IN_SPREAD)
						var/obj/effect/decal/cleanable/blood/footprints/FP = new /obj/effect/decal/cleanable/blood/footprints(T)
						FP.blood_state = S.blood_state
						FP.entered_dirs |= dir
						FP.bloodiness = S.bloody_shoes[S.blood_state] - BLOOD_LOSS_IN_SPREAD
						FP.add_blood_DNA(S.return_blood_DNA())
						FP.update_icon()
					update_inv_shoes()
				//End bloody footprints
				S.step_action()
		if(mouth)
			if(mouth.spitoutmouth && prob(5))
				visible_message("<span class='warning'>[src] spits out [mouth].</span>")
				dropItemToGround(mouth, silent = FALSE)
		if(held_items.len)
			for(var/obj/item/I in held_items)
				if(I.minstr)
					var/effective = I.minstr
					if(I.wielded)
						effective = max(I.minstr / 2, 1)
					if(effective > STASTR)
						if(prob(effective))
							dropItemToGround(I, silent = FALSE)

/mob/living/carbon/human/Process_Spacemove(movement_dir = 0) //Temporary laziness thing. Will change to handles by species reee.
	if(dna.species.space_move(src))
		return TRUE
	return ..()
