////SS13 DONATOR CUSTOM ITEM STORAGE ZONE OF CRINGE AND DEGENRACY
//LAST UPDATE 13AUG2018 - FRANCINUM

//  EXO-SUITS/ARMORS COSMETICS  ////////////////////////////////////////////////

//SUIT TEMPLATE (for armor/exosuit)  ONLY TAKE NAME, DESC, ICON_STATE, AND ITEM_STATE.  Make a copy of those, and put the ckey of the person at the end after fluff
/obj/item/clothing/suit/storage/marine/fluff/
	name = "ITEM NAME"
	desc = "ITEM DESCRIPTION.  DONOR ITEM" //Add UNIQUE if Unique
	icon_state = "state"
	item_state = "state"
	//DON'T GRAB STUFF BETWEEN THIS LINE
	icon = 'icons/obj/clothing/suits.dmi'
	icon_override = 'icons/mob/suit_0.dmi'  //Don't fuck with this in the future please.
	flags_inventory = BLOCKSHARPOBJ
	flags_marine_armor = NOFLAGS

/obj/item/clothing/suit/storage/marine/fluff/verb/toggle_squad_markings()
	if(!ishuman(usr)) return

	if(!usr.canmove || usr.stat || usr.is_mob_restrained() || !usr.loc || !isturf(usr.loc))
		usr << "<span class='warning'>Not right now!</span>"
		return

	usr << "<span class='notice'>You [flags_marine_armor & ARMOR_SQUAD_OVERLAY? "hide" : "show"] the squad markings.</span>"
	flags_marine_armor ^= ARMOR_SQUAD_OVERLAY
	usr.update_inv_wear_suit()

/obj/item/clothing/suit/storage/marine/fluff/verb/toggle_shoulder_lamp()
	if(!ishuman(usr)) return

	if(!usr.canmove || usr.stat || usr.is_mob_restrained() || !usr.loc || !isturf(usr.loc))
		usr << "<span class='warning'>Not right now!</span>"
		return

	usr << "<span class='notice'>You [flags_marine_armor & ARMOR_LAMP_OVERLAY? "hide" : "show"] the shoulder lamp.</span>"
	flags_marine_armor ^= ARMOR_LAMP_OVERLAY
	update_icon(usr)


	//AND THIS LINE
//END SUIT TEMPLATE

//	HELMETS/HATS/BERETS COSMETICS  ////////////////////////////////////////////////

//HEAD TEMPLATE (for Helmets/Hats/Berets)  ONLY TAKE NAME, DESC, ICON_STATE, AND ITEM_STATE.  Make a copy of those, and put the ckey of the person at the end after fluff
/obj/item/clothing/head/helmet/marine/fluff
	name = "ITEM NAME"
	desc = "ITEM DESCRIPTION.  DONOR ITEM" //Add UNIQUE if Unique
	icon_state = "state"
	item_state = "state"
	//DON'T GRAB STUFF BETWEEN THIS LINE
	icon = 'icons/obj/clothing/hats.dmi'
	icon_override = 'icons/mob/head_0.dmi'
	flags_inventory = BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS
	min_cold_protection_temperature = ICE_PLANET_min_cold_protection_temperature
	flags_marine_helmet = HELMET_STORE_GARB

/obj/item/clothing/head/helmet/marine/fluff/verb/toggle_squad_markings()
	if(!ishuman(usr)) return

	if(!usr.canmove || usr.stat || usr.is_mob_restrained() || !usr.loc || !isturf(usr.loc))
		usr << "<span class='warning'>Not right now!</span>"
		return

	usr << "<span class='notice'>You [flags_marine_helmet & HELMET_SQUAD_OVERLAY? "hide" : "show"] the squad markings.</span>"
	flags_marine_helmet ^= HELMET_SQUAD_OVERLAY
	usr.update_inv_head()

/obj/item/clothing/head/helmet/marine/fluff/verb/toggle_garb_overlay()
	if(!ishuman(usr)) return

	if(!usr.canmove || usr.stat || usr.is_mob_restrained() || !usr.loc || !isturf(usr.loc))
		usr << "<span class='warning'>Not right now!</span>"
		return

	usr << "<span class='notice'>You [flags_marine_helmet & HELMET_GARB_OVERLAY? "hide" : "show"] the helmet garb.</span>"
	flags_marine_helmet ^= HELMET_GARB_OVERLAY
	update_icon(usr, flags_marine_helmet & HELMET_GARB_OVERLAY? 0 : 2)

	//AND THIS LINE
//END HEAD TEMPLATE

//	UNIFORM/JUMPSUIT COSMETICS  ////////////////////////////////////////////////

//UNIFORM TEMPLATE (for uniforms/jumpsuits)  ONLY TAKE NAME, DESC, ICON_STATE, ITEM_STATE,  AND ITEM_COLOR.  Make a copy of those, and put the ckey of the person at the end after fluff
/obj/item/clothing/under/marine/fluff
	name = "ITEM NAME"
	desc = "ITEM DESCRIPTION.  DONOR ITEM" //Add UNIQUE if Unique
	icon_state = "state"
	item_state = null
	min_cold_protection_temperature = ICE_PLANET_min_cold_protection_temperature
	//DON'T GRAB STUFF BETWEEN THIS LINE
	//AND THIS LINE
//END UNIFORM TEMPLATE

//	MASK COSMETICS  ////////////////////////////////////////////////

//MASK TEMPLATE (for masks)  ONLY TAKE NAME, DESC, ICON_STATE, ITEM_STATE,  AND ITEM_COLOR.  Make a copy of those, and put the ckey of the person at the end after fluff
/obj/item/clothing/mask/fluff
	name = "ITEM NAME"
	desc = "ITEM DESCRIPTION.  DONOR ITEM" //Add UNIQUE if Unique
	icon_state = "state"
	item_state = "state"
	//DON'T GRAB STUFF BETWEEN THIS LINE
	flags_inventory = ALLOWREBREATH
	flags_inv_hide = HIDEEARS|HIDEEYES|HIDEFACE
	//AND THIS LINE

//END MASK TEMPLATE

//	BOOTS/SHOES COSMETICS  ////////////////////////////////////////////////

//FEET TEMPLATE (for masks)  ONLY TAKE NAME, DESC, ICON_STATE, ITEM_STATE,  AND ITEM_COLOR.  Make a copy of those, and put the ckey of the person at the end after fluff
/obj/item/clothing/shoes/marine/fluff/
	name = "ITEM NAME"
	desc = "ITEM DESCRIPTION.  DONOR ITEM" //Add UNIQUE if Unique
	icon_state = "state"
	item_state = "state"
//END FEET TEMPLATE

//GENERIC GLASSES, GLOVES, AND MISC ////////////////////

/obj/item/clothing/gloves/marine/fluff   //MARINE GLOVES TEMPLATE
	name = "ITEM NAME"
	desc = "ITEM DESCRIPTION.  DONOR ITEM" //Add UNIQUE if Unique
	icon_state = "state"
	item_state = "state"

/obj/item/clothing/glasses/fluff
	flags_inventory = COVEREYES

//CUSTOM ITEMS - NO TEMPLATES - ALL UNIQUE ////////////////////////