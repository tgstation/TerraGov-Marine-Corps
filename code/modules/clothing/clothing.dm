/obj/item/clothing
	name = "clothing"
	var/eye_protection = 0 //used for headgear, masks, and glasses, to see how much they protect eyes from bright lights.
	var/tint = TINT_NONE // headgear, mask and glasses, forvision impairment overlays

//Updates the icons of the mob wearing the clothing item, if any.
/obj/item/clothing/proc/update_clothing_icon()
	return


///////////////////////////////////////////////////////////////////////
// Ears: headsets, earmuffs and tiny objects
/obj/item/clothing/ears
	name = "ears"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 2
	flags_equip_slot = ITEM_SLOT_EARS

/obj/item/clothing/ears/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_ears()

/obj/item/clothing/ears/earmuffs
	name = "earmuffs"
	desc = "Protects your hearing from loud noises, and quiet ones as well."
	icon_state = "earmuffs"
	item_state = "earmuffs"
	flags_equip_slot = ITEM_SLOT_EARS


///////////////////////////////////////////////////////////////////////
//Suit
/obj/item/clothing/suit
	icon = 'icons/obj/clothing/suits.dmi'
	name = "suit"
	var/fire_resist = T0C+100
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS
	allowed = list(/obj/item/tank/emergency_oxygen)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	flags_equip_slot = ITEM_SLOT_OCLOTHING
	var/blood_overlay_type = "suit"
	var/list/supporting_limbs = null
	siemens_coefficient = 0.9
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/clothing/suit/update_clothing_icon()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_wear_suit()


/////////////////////////////////////////////////////////
//Gloves
/obj/item/clothing/gloves
	name = "gloves"
	gender = PLURAL //Carn: for grammarically correct text-parsing
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/clothing/gloves.dmi'
	siemens_coefficient = 0.50
	var/wired = 0
	var/obj/item/cell/cell = 0
	var/clipped = 0
	var/transfer_prints = TRUE
	flags_armor_protection = HANDS
	flags_equip_slot = ITEM_SLOT_GLOVES
	attack_verb = list("challenged")
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
/obj/item/clothing/gloves/proc/Touch(atom/A, proximity)
	return 0 // return 1 to cancel attack_hand()

/obj/item/clothing/gloves/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(iswirecutter(I) || istype(I, /obj/item/tool/surgery/scalpel))
		if(clipped)
			to_chat(user, "<span class='notice'>The [src] have already been clipped!</span>")
			update_icon()
			return

		playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
		user.visible_message("<span class='warning'> [user] cuts the fingertips off of the [src].</span>","<span class='warning'> You cut the fingertips off of the [src].</span>")

		clipped = TRUE
		name = "mangled [name]"
		desc = "[desc]<br>They have had the fingertips cut off of them."




//////////////////////////////////////////////////////////////////
//Mask
/obj/item/clothing/mask
	name = "mask"
	icon = 'icons/obj/clothing/masks.dmi'
	flags_equip_slot = ITEM_SLOT_MASK
	flags_armor_protection = FACE|EYES
	sprite_sheets = list("Vox" = 'icons/mob/species/vox/masks.dmi')
	var/anti_hug = 0
	var/toggleable = FALSE
	var/active = TRUE

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
	flags_equip_slot = ITEM_SLOT_FEET
	permeability_coefficient = 0.50
	slowdown = SHOES_SLOWDOWN
	sprite_sheets = list("Vox" = 'icons/mob/species/vox/shoes.dmi')


/obj/item/clothing/shoes/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_shoes()
