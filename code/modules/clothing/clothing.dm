/obj/item/clothing
	name = "clothing"

	// Resets the armor on clothing since by default /objs get 100 bio armor
	soft_armor = list()
	inventory_flags = NOQUICKEQUIP

	///Assoc list of available slots. Since this keeps track of all currently equiped attachments per object, this cannot be a string_list()
	var/list/attachments_by_slot = list()
	///Typepath list of allowed attachment types.
	var/list/attachments_allowed = list()

	///Pixel offsets for specific attachment slots. Is not used currently.
	var/list/attachment_offsets = list()
	///List of attachment types that is attached to the object on initialize.
	var/list/starting_attachments = list()

	/// Bitflags used to determine the state of the armor (light on, overlay used, or reinfornced), currently support flags are in [equipment.dm:100]
	var/armor_features_flags = NONE

	/// used for headgear, masks, and glasses, to see how much they protect eyes from bright lights.
	var/eye_protection = 0

	/// Used by headgear mostly to affect accuracy
	var/accuracy_mod = 0

/obj/item/clothing/Initialize(mapload)
	. = ..()
	attachments_allowed = string_list(attachments_allowed)
	starting_attachments = string_list(starting_attachments)
	if(!length(attachments_allowed) || !length(attachments_by_slot))
		return
	AddComponent(/datum/component/attachment_handler, attachments_by_slot, attachments_allowed, attachment_offsets, starting_attachments, null, null, null)


/obj/item/clothing/equipped(mob/user, slot)
	. = ..()
	if(!(equip_slot_flags & slotdefine2slotbit(slot)))
		return
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human_user = user
	if(accuracy_mod)
		human_user.adjust_mob_accuracy(accuracy_mod)
	if(armor_features_flags & ARMOR_FIRE_RESISTANT)
		ADD_TRAIT(human_user, TRAIT_NON_FLAMMABLE, src)


/obj/item/clothing/unequipped(mob/unequipper, slot)
	if(!(equip_slot_flags & slotdefine2slotbit(slot)))
		return ..()
	if(!ishuman(unequipper))
		return ..()
	var/mob/living/carbon/human/human_unequipper = unequipper
	if(accuracy_mod)
		human_unequipper.adjust_mob_accuracy(-accuracy_mod)
	if(armor_features_flags & ARMOR_FIRE_RESISTANT)
		REMOVE_TRAIT(human_unequipper, TRAIT_NON_FLAMMABLE, src)
	return ..()

/obj/item/clothing/vendor_equip(mob/user)
	..()
	return user.equip_to_appropriate_slot(src)

//Updates the icons of the mob wearing the clothing item, if any.
/obj/item/clothing/proc/update_clothing_icon()
	return

/obj/item/clothing/examine_descriptor(mob/user)
	return "clothing item"

/obj/item/clothing/update_greyscale()
	. = ..()
	if(!greyscale_config)
		return
	for(var/key in worn_icon_list)
		if(key == slot_l_hand_str || key == slot_r_hand_str)
			continue
		worn_icon_list[key] = icon

/obj/item/clothing/apply_blood(mutable_appearance/standing)
	if(blood_overlay && blood_sprite_state)
		var/image/bloodsies = mutable_appearance('icons/effects/blood.dmi', blood_sprite_state)
		bloodsies.color = blood_color
		standing.add_overlay(bloodsies)

/obj/item/clothing/suit/apply_blood(mutable_appearance/standing)
	if(blood_overlay && blood_sprite_state)
		blood_sprite_state = "[blood_overlay_type]blood"
		var/image/bloodsies = mutable_appearance('icons/effects/blood.dmi', blood_sprite_state)
		bloodsies.color = blood_color
		standing.add_overlay(bloodsies)

/obj/item/clothing/color_item(obj/item/facepaint/paint, mob/user)
	.=..()
	update_clothing_icon()

/obj/item/clothing/alternate_color_item(obj/item/facepaint/paint, mob/user)
	. = ..()
	update_clothing_icon()

///////////////////////////////////////////////////////////////////////
// Ears: headsets, earmuffs and tiny objects
/obj/item/clothing/ears
	name = "ears"
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/clothing/ears_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/clothing/ears_right.dmi',
	)
	w_class = WEIGHT_CLASS_TINY
	throwforce = 2
	equip_slot_flags = ITEM_SLOT_EARS

/obj/item/clothing/ears/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_ears()


/obj/item/clothing/ears/earmuffs
	name = "earmuffs"
	desc = "Protects your hearing from loud noises, and quiet ones as well."
	icon_state = "earmuffs"
	worn_icon_state = "earmuffs"
	equip_slot_flags = ITEM_SLOT_EARS

/obj/item/clothing/ears/earmuffs/green
	icon_state = "earmuffs2"

/obj/item/clothing/ears/earmuffs/gold
	icon_state = "earmuffs3"

///////////////////////////////////////////////////////////////////////
//Suit
/obj/item/clothing/suit
	icon = 'icons/obj/clothing/suits/suits.dmi'
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/clothing/suits_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/clothing/suits_right.dmi',
	)
	name = "suit"
	armor_protection_flags = CHEST|GROIN|ARMS|LEGS
	allowed = list(/obj/item/tank/emergency_oxygen)
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	equip_slot_flags = ITEM_SLOT_OCLOTHING
	siemens_coefficient = 0.9
	w_class = WEIGHT_CLASS_NORMAL
	attachments_by_slot = list(ATTACHMENT_SLOT_BADGE)
	attachments_allowed = list(/obj/item/armor_module/armor/badge)
	light_power = 3
	light_range = 4
	light_system = MOVABLE_LIGHT
	///Blood overlay icon_state
	var/blood_overlay_type = "suit"

/obj/item/clothing/suit/Initialize(mapload)
	. = ..()
	GLOB.nightfall_toggleable_lights += src

/obj/item/clothing/suit/Destroy()
	GLOB.nightfall_toggleable_lights -= src
	return ..()

/obj/item/clothing/suit/dropped(mob/user)
	turn_light(user, FALSE)
	return ..()

/obj/item/clothing/suit/turn_light(mob/user, toggle_on)
	. = ..()
	if(. != CHECKS_PASSED)
		return
	set_light_on(toggle_on)
	armor_features_flags ^= ARMOR_LAMP_ON
	playsound(src, 'sound/items/flashlight.ogg', 15, TRUE)
	update_icon()

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
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/clothing/gloves_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/clothing/gloves_right.dmi',
	)
	item_state_worn = TRUE
	siemens_coefficient = 0.50
	var/wired = 0
	var/obj/item/cell/cell = 0
	var/clipped = 0
	var/transfer_prints = TRUE
	blood_sprite_state = "bloodyhands"
	armor_protection_flags = HANDS
	equip_slot_flags = ITEM_SLOT_GLOVES
	attack_verb = list("challenges")


/obj/item/clothing/gloves/update_greyscale(list/colors, update)
	. = ..()
	if(!greyscale_config)
		return
	worn_icon_list = list(slot_gloves_str = icon)

/obj/item/clothing/gloves/emp_act(severity)
	. = ..()
	if(cell)
		//why is this not part of the powercell code?
		cell.charge -= 1000 / severity
		if (cell.charge < 0)
			cell.charge = 0

// Called just before an attack_hand(), in mob/UnarmedAttack()
/obj/item/clothing/gloves/proc/Touch(atom/A, proximity)
	return 0 // return 1 to cancel attack_hand()

/obj/item/clothing/gloves/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return
	if(iswirecutter(I) || istype(I, /obj/item/tool/surgery/scalpel))
		if(clipped)
			to_chat(user, span_notice("The [src] have already been clipped!"))
			update_icon()
			return

		playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
		user.visible_message(span_warning("[user] cuts the fingertips off of the [src]."),span_warning("You cut the fingertips off of the [src]."))

		clipped = TRUE
		name = "mangled [name]"
		desc = "[desc]<br>They have had the fingertips cut off of them."




//////////////////////////////////////////////////////////////////
//Mask
/obj/item/clothing/mask
	name = "mask"
	icon = 'icons/obj/clothing/masks.dmi'
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/clothing/masks_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/clothing/masks_right.dmi',
	)
	equip_slot_flags = ITEM_SLOT_MASK
	armor_protection_flags = FACE|EYES
	blood_sprite_state = "maskblood"
	var/anti_hug = 0
	var/toggleable = FALSE
	active = TRUE
	/// If defined, what voice should we override with if TTS is active?
	var/voice_override
	/// If set to true, activates the radio effect on TTS.
	var/use_radio_beeps_tts = FALSE

/obj/item/clothing/mask/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_wear_mask()

/obj/item/clothing/mask/examine_descriptor(mob/user)
	return "mask"

/obj/item/clothing/mask/examine_tags(mob/user)
	. = ..()
	if(anti_hug)
		.["larval hugger proof"] = "It will protect the wearer from [anti_hug] larval hugger attack\s."
	else if(initial(anti_hug) > 0 && !anti_hug)
		.[span_warning("not larval hugger protective")] = "It won't protect the wearer from larval hugger attacks anymore. Replace it as soon as possible."

////////////////////////////////////////////////////////////////////////
//Shoes
/obj/item/clothing/shoes
	name = "shoes"
	icon = 'icons/obj/clothing/shoes.dmi'
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/clothing/shoes_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/clothing/shoes_right.dmi',
	)
	desc = "Comfortable-looking shoes."
	gender = PLURAL //Carn: for grammarically correct text-parsing
	siemens_coefficient = 0.9
	armor_protection_flags = FEET
	equip_slot_flags = ITEM_SLOT_FEET
	permeability_coefficient = 0.50
	slowdown = SHOES_SLOWDOWN
	blood_sprite_state = "shoeblood"
	soft_armor = list(MELEE = 25, BULLET = 15, LASER = 5, ENERGY = 5, BOMB = 5, BIO = 5, FIRE = 5, ACID = 20)

/obj/item/clothing/shoes/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_shoes()
