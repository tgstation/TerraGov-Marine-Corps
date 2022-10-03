/obj/item/clothing
	name = "clothing"

	/// Resets the armor on clothing since by default /objs get 100 bio armor
	soft_armor = list()

	///Assoc list of available slots. Since this keeps track of all currently equiped attachments per object, this cannot be a string_list()
	var/list/attachments_by_slot = list()
	///Typepath list of allowed attachment types.
	var/list/attachments_allowed = list()

	///Pixel offsets for specific attachment slots. Is not used currently.
	var/list/attachment_offsets = list()
	///List of attachment types that is attached to the object on initialize.
	var/list/starting_attachments = list()

	/// Bitflags used to determine the state of the armor (light on, overlay used, or reinfornced), currently support flags are in [equipment.dm:100]
	var/flags_armor_features = NONE

	/// used for headgear, masks, and glasses, to see how much they protect eyes from bright lights.
	var/eye_protection = 0

	/// Used by headgear mostly to affect accuracy
	var/accuracy_mod = 0
	flags_inventory = NOQUICKEQUIP

/obj/item/clothing/Initialize()
	. = ..()
	attachments_allowed = string_list(attachments_allowed)
	starting_attachments = string_list(starting_attachments)
	if(!length(attachments_allowed) || !length(attachments_by_slot))
		return
	AddComponent(/datum/component/attachment_handler, attachments_by_slot, attachments_allowed, attachment_offsets, starting_attachments, null, null, null)


/obj/item/clothing/equipped(mob/user, slot)
	. = ..()
	if(!(flags_equip_slot & slotdefine2slotbit(slot)))
		return
	if(!ishuman(user))
		return
	if(accuracy_mod)
		var/mob/living/carbon/human/human_user = user
		human_user.adjust_mob_accuracy(accuracy_mod)


/obj/item/clothing/unequipped(mob/unequipper, slot)
	if(!(flags_equip_slot & slotdefine2slotbit(slot)))
		return ..()
	if(!ishuman(unequipper))
		return ..()
	if(accuracy_mod)
		var/mob/living/carbon/human/human_unequipper = unequipper
		human_unequipper.adjust_mob_accuracy(-accuracy_mod)
	return ..()


//Updates the icons of the mob wearing the clothing item, if any.
/obj/item/clothing/proc/update_clothing_icon()
	return

/obj/item/clothing/apply_blood(mutable_appearance/standing)
	if(blood_overlay && blood_sprite_state)
		var/image/bloodsies	= mutable_appearance('icons/effects/blood.dmi', blood_sprite_state)
		bloodsies.color	= blood_color
		standing.add_overlay(bloodsies)

/obj/item/clothing/suit/apply_blood(mutable_appearance/standing)
	if(blood_overlay && blood_sprite_state)
		blood_sprite_state = "[blood_overlay_type]blood"
		var/image/bloodsies	= mutable_appearance('icons/effects/blood.dmi', blood_sprite_state)
		bloodsies.color = blood_color
		standing.add_overlay(bloodsies)

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

/obj/item/clothing/ears/earmuffs/green
	icon_state = "earmuffs2"

/obj/item/clothing/ears/earmuffs/gold
	icon_state = "earmuffs3"

///////////////////////////////////////////////////////////////////////
//Suit
/obj/item/clothing/suit
	icon = 'icons/obj/clothing/suits.dmi'
	name = "suit"
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS
	allowed = list(/obj/item/tank/emergency_oxygen)
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, "rad" = 0, FIRE = 0, ACID = 0)
	flags_equip_slot = ITEM_SLOT_OCLOTHING
	siemens_coefficient = 0.9
	w_class = WEIGHT_CLASS_NORMAL
	attachments_by_slot = list(ATTACHMENT_SLOT_BADGE)
	attachments_allowed = list(/obj/item/armor_module/armor/badge)
	var/supporting_limbs = NONE
	var/blood_overlay_type = "suit"
	var/shield_state = "shield-blue"

	// Strength of the armor light used by [proc/set_light()]
	light_power = 3
	light_range = 4
	light_system = MOVABLE_LIGHT

/obj/item/clothing/suit/Initialize()
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
	flags_armor_features ^= ARMOR_LAMP_ON
	playsound(src, 'sound/items/flashlight.ogg', 15, TRUE)
	update_icon(user)
	update_action_button_icons()

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
	item_state_worn = TRUE
	siemens_coefficient = 0.50
	var/wired = 0
	var/obj/item/cell/cell = 0
	var/clipped = 0
	var/transfer_prints = TRUE
	blood_sprite_state = "bloodyhands"
	flags_armor_protection = HANDS
	flags_equip_slot = ITEM_SLOT_GLOVES
	attack_verb = list("challenged")


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
			to_chat(user, span_notice("The [src] have already been clipped!"))
			update_icon()
			return

		playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
		user.visible_message(span_warning(" [user] cuts the fingertips off of the [src]."),span_warning(" You cut the fingertips off of the [src]."))

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
	blood_sprite_state = "maskblood"
	var/anti_hug = 0
	var/toggleable = FALSE
	active = TRUE

/obj/item/clothing/mask/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_wear_mask()

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
	blood_sprite_state = "shoeblood"


/obj/item/clothing/shoes/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_shoes()
