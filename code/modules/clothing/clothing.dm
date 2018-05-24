/obj/item/clothing
	name = "clothing"
	var/list/species_restricted = null //Only these species can wear this kit.

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

		//some clothes can only be worn when wearing specific uniforms
		if(uniform_restricted && (!is_type_in_list(U, uniform_restricted) || !U))
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

/obj/item/clothing/ears/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_ears()

/obj/item/clothing/ears/earmuffs
	name = "earmuffs"
	desc = "Protects your hearing from loud noises, and quiet ones as well."
	icon_state = "earmuffs"
	item_state = "earmuffs"
	flags_equip_slot = SLOT_EAR


///////////////////////////////////////////////////////////////////////
//Suit
/obj/item/clothing/suit
	icon = 'icons/obj/clothing/suits.dmi'
	name = "suit"
	var/fire_resist = T0C+100
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	allowed = list(/obj/item/tank/emergency_oxygen)
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	flags_equip_slot = SLOT_OCLOTHING
	var/blood_overlay_type = "suit"
	siemens_coefficient = 0.9
	w_class = 3

/obj/item/clothing/suit/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_wear_suit()

/obj/item/clothing/suit/mob_can_equip(mob/M, slot, disable_warning = 0)
	//if we can't equip the item anyway, don't bother with other checks.
	if (!..())
		return 0

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/clothing/under/U = H.w_uniform
		//some uniforms prevent you from wearing any suits but certain types
		if(U && U.suit_restricted && !is_type_in_list(src, U.suit_restricted))
			H << "<span class='warning'>[src] can't be worn with [U].</span>"
			return 0
	return 1


/////////////////////////////////////////////////////////
//Gloves
/obj/item/clothing/gloves
	name = "gloves"
	gender = PLURAL //Carn: for grammarically correct text-parsing
	w_class = 2.0
	icon = 'icons/obj/clothing/gloves.dmi'
	siemens_coefficient = 0.50
	var/wired = 0
	var/obj/item/cell/cell = 0
	var/clipped = 0
	flags_armor_protection = HANDS
	flags_equip_slot = SLOT_HANDS
	attack_verb = list("challenged")
	species_restricted = list("exclude","Yautja")
	sprite_sheets = list("Vox" = 'icons/mob/species/vox/gloves.dmi')


/obj/item/clothing/gloves/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_gloves()

/obj/item/clothing/gloves/emp_act(severity)
	if(cell)
		//why is this not part of the powercell code?
		cell.charge -= 1000 / severity
		if (cell.charge < 0)
			cell.charge = 0
		if(cell.reliability != 100 && prob(50/severity))
			cell.reliability -= 10 / severity
	..()

// Called just before an attack_hand(), in mob/UnarmedAttack()
/obj/item/clothing/gloves/proc/Touch(var/atom/A, var/proximity)
	return 0 // return 1 to cancel attack_hand()

/obj/item/clothing/gloves/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/tool/wirecutters) || istype(W, /obj/item/tool/surgery/scalpel))
		if (clipped)
			user << "<span class='notice'>The [src] have already been clipped!</span>"
			update_icon()
			return

		playsound(src.loc, 'sound/items/Wirecutter.ogg', 25, 1)
		user.visible_message("\red [user] cuts the fingertips off of the [src].","\red You cut the fingertips off of the [src].")

		clipped = 1
		name = "mangled [name]"
		desc = "[desc]<br>They have had the fingertips cut off of them."
		if("exclude" in species_restricted)
			species_restricted -= "Yautja"




//////////////////////////////////////////////////////////////////
//Mask
/obj/item/clothing/mask
	name = "mask"
	icon = 'icons/obj/clothing/masks.dmi'
	flags_armor_protection = HEAD
	flags_pass = PASSTABLE
	flags_equip_slot = SLOT_FACE
	flags_armor_protection = FACE|EYES
	sprite_sheets = list("Vox" = 'icons/mob/species/vox/masks.dmi')
	var/anti_hug = 0

/obj/item/clothing/mask/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_wear_mask()


//some gas masks modify the air that you breathe in.
/obj/item/clothing/mask/proc/filter_air(list/air_info)
	if(flags_inventory & ALLOWREBREATH)
		air_info[2] = T20C //heats/cools air to be breathable

	return air_info



////////////////////////////////////////////////////////////////////////
//Shoes
/obj/item/clothing/shoes
	name = "shoes"
	icon = 'icons/obj/clothing/shoes.dmi'
	desc = "Comfortable-looking shoes."
	gender = PLURAL //Carn: for grammarically correct text-parsing
	siemens_coefficient = 0.9
	flags_armor_protection = FEET
	flags_equip_slot = SLOT_FEET
	permeability_coefficient = 0.50
	slowdown = SHOES_SLOWDOWN
	species_restricted = list("exclude","Yautja")
	sprite_sheets = list("Vox" = 'icons/mob/species/vox/shoes.dmi')


/obj/item/clothing/shoes/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_shoes()
