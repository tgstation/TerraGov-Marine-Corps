/obj/item/clothing
	name = "clothing"
	var/list/species_restricted = null //Only these species can wear this kit.
	var/list/uniform_restricted = list() //Need to wear this uniform to equip this

	/*
		Sprites used when the clothing item is refit. This is done by setting icon_override.
		For best results, if this is set then sprite_sheets should be null and vice versa, but that is by no means necessary.
		Ideally, sprite_sheets_refit should be used for "hard" clothing items that can't change shape very well to fit the wearer (e.g. helmets, hardsuits),
		while sprite_sheets should be used for "flexible" clothing items that do not need to be refitted (e.g. vox wearing jumpsuits).
	*/
	var/list/sprite_sheets_refit = null
	var/eye_protection = 0 //used for headgear, masks, and glasses, to see how much they protect eyes from bright lights.

//Updates the icons of the mob wearing the clothing item, if any.
/obj/item/clothing/proc/update_clothing_icon()
	return

//BS12: Species-restricted clothing check.
//CM Update : Restricting armor to specific uniform
/obj/item/clothing/mob_can_equip(M as mob, slot)

	//if we can't equip the item anyway, don't bother with species_restricted (cuts down on spam)
	if (!..())
		return 0

	if(ishuman(M))

		var/mob/living/carbon/human/H = M
		var/obj/item/clothing/under/U = H.w_uniform

		if(uniform_restricted.len && (!is_type_in_list(U, uniform_restricted) || !U))
			H << "<span class='warning'>Your [U ? "[U.name]":"naked body"] doesn't allow you to wear this [name].</span>" //Note : Duplicate warning, commenting
			return 0

		if(species_restricted)

			var/wearable = null
			var/exclusive = null

			if("exclude" in species_restricted)
				exclusive = 1

			if(H.species)
				if(exclusive)
					if(!(H.species.name in species_restricted))
						wearable = 1
				else
					if(H.species.name in species_restricted)
						wearable = 1

				if(!wearable && (slot != 15 && slot != 16)) //Pockets.
					M << "\red Your species cannot wear [src]."
					return 0

	return 1

/obj/item/clothing/proc/refit_for_species(var/target_species)
	//Set species_restricted list
	switch(target_species)
		if("Human", "Skrell")	//humanoid bodytypes
			species_restricted = list("exclude","Unathi","Tajara","Vox")
		else
			species_restricted = list(target_species)

	//Set icon
	if (sprite_sheets_refit && (target_species in sprite_sheets_refit))
		icon_override = sprite_sheets_refit[target_species]
	else
		icon_override = initial(icon_override)

	if (sprite_sheets_obj && (target_species in sprite_sheets_obj))
		icon = sprite_sheets_obj[target_species]
	else
		icon = initial(icon)

/obj/item/clothing/head/helmet/refit_for_species(var/target_species)
	//Set species_restricted list
	switch(target_species)
		if("Skrell")
			species_restricted = list("exclude","Unathi","Tajara","Vox")
		if("Human")
			species_restricted = list("exclude","Skrell","Unathi","Tajara","Vox")
		else
			species_restricted = list(target_species)

	//Set icon
	if (sprite_sheets_refit && (target_species in sprite_sheets_refit))
		icon_override = sprite_sheets_refit[target_species]
	else
		icon_override = initial(icon_override)

	if (sprite_sheets_obj && (target_species in sprite_sheets_obj))
		icon = sprite_sheets_obj[target_species]
	else
		icon = initial(icon)

///////////////////////////////////////////////////////////////////////
// Ears: headsets, earmuffs and tiny objects
/obj/item/clothing/ears
	name = "ears"
	w_class = 1.0
	throwforce = 2
	flags_equip_slot = SLOT_EAR
	var/obj/item/clothing/ears/linked_ear //used by ear pieces that cover both ears.

	equipped(var/mob/M, var/slot)
		if((slot == WEAR_R_EAR || slot == WEAR_L_EAR) && (flags_equip_slot & SLOT_EARS) && ishuman(M))
			var/mob/living/carbon/human/H = M
			var/obj/item/clothing/ears/offear/O = new(null, src)
			if(slot == WEAR_R_EAR)
				H.equip_to_slot(O, WEAR_L_EAR)
			else
				H.equip_to_slot(O, WEAR_R_EAR)

		..()

	Dispose()
		. = ..()
		if(linked_ear)
			cdel(linked_ear)

	dropped(mob/user)
		if(linked_ear && ishuman(user))
			var/mob/living/carbon/human/H = user
			if(linked_ear == H.l_ear || linked_ear == H.r_ear)//is the associated earpiece still in the other ear slot?
				var/obj/item/clothing/ears/E = linked_ear
				linked_ear = null
				E.linked_ear = null
				H.temp_drop_inv_item(E)
				if(!istype(E, /obj/item/clothing/ears/offear)) //the linked ear was the real one
					E.forceMove(H.loc)
		..()

/obj/item/clothing/ears/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_ears()

/obj/item/clothing/ears/offear
	name = "Other ear"
	w_class = 5.0
	icon = 'icons/mob/screen1_Midnight.dmi'
	icon_state = "block"
	flags_equip_slot = SLOT_EAR
	flags_atom = DELONDROP

	New(loc, obj/item/clothing/ears/E)
		if(istype(E))
			name = E.name
			desc = E.desc
			icon = E.icon
			icon_state = E.icon_state
			dir = E.dir
			E.linked_ear = src
			linked_ear = E
		..()

	attack_hand(mob/user) //clicking the offear makes you click the real ear.
		if(linked_ear)
			linked_ear.attack_hand(user)


/obj/item/clothing/ears/earmuffs
	name = "earmuffs"
	desc = "Protects your hearing from loud noises, and quiet ones as well."
	icon_state = "earmuffs"
	item_state = "earmuffs"
	flags_equip_slot = SLOT_EAR|SLOT_EARS



///////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////
//Suit
/obj/item/clothing/suit
	icon = 'icons/obj/clothing/suits.dmi'
	name = "suit"
	var/fire_resist = T0C+100
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	allowed = list(/obj/item/weapon/tank/emergency_oxygen)
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	flags_equip_slot = SLOT_OCLOTHING
	var/blood_overlay_type = "suit"
	siemens_coefficient = 0.9
	w_class = 3

/obj/item/clothing/suit/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_wear_suit()
