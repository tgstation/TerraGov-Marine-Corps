/obj/item/clothing/glasses/hud
	name = "HUD"
	desc = "A heads-up display that provides important info in (almost) real time."
	flags_atom = null //doesn't protect eyes because it's a monocle, duh
	var/hud_type
	var/mob/living/carbon/human/affected_user


/obj/item/clothing/glasses/hud/Destroy()
	if(affected_user)
		deactivate_hud()
	return ..()


/obj/item/clothing/glasses/hud/equipped(mob/user, slot)
	if(!ishuman(user))
		return ..()
	if(slot == SLOT_GLASSES)
		if(active)
			activate_hud(user)
	else if(affected_user)
		deactivate_hud()
	return ..()


/obj/item/clothing/glasses/hud/dropped(mob/user)
	if(affected_user)
		deactivate_hud()
	return ..()


/obj/item/clothing/glasses/hud/activate_glasses(mob/user, silent = FALSE)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/hud_user = user
	if(hud_user.glasses != src)
		return
	activate_hud(hud_user)


/obj/item/clothing/glasses/hud/deactivate_glasses(mob/user, silent = FALSE)
	. = ..()
	if(QDELETED(affected_user))
		return
	deactivate_hud()


/obj/item/clothing/glasses/hud/proc/activate_hud(mob/living/carbon/human/user)
	var/datum/atom_hud/hud_datum = GLOB.huds[hud_type]
	hud_datum.add_hud_to(user)
	affected_user = user


/obj/item/clothing/glasses/hud/proc/deactivate_hud()
	var/datum/atom_hud/hud_datum = GLOB.huds[hud_type]
	hud_datum.remove_hud_from(affected_user)
	affected_user = null


/obj/item/clothing/glasses/hud/health
	name = "\improper HealthMate HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their health status. The projector can be attached to compatable eyewear."
	icon_state = "healthhud"
	deactive_state = "degoggles_med"
	flags_armor_protection = NONE
	toggleable = TRUE
	hud_type = DATA_HUD_MEDICAL_ADVANCED
	actions_types = list(/datum/action/item_action/toggle)
	species_exception = list(/datum/species/robot)
	sprite_sheets = list("Combat Robot" = 'icons/mob/species/robot/glasses.dmi')
	prescription = TRUE

/obj/item/clothing/glasses/hud/medgoggles
	name = "\improper HealthMate ballistic goggles"
	desc = "Standard issue TGMC goggles. This pair has been fitted with an internal HealthMate HUD projector."
	icon_state = "medgoggles"
	item_state = "medgoggles"
	deactive_state = "degoggles_medgoggles"
	toggleable = TRUE
	hud_type = DATA_HUD_MEDICAL_ADVANCED
	actions_types = list(/datum/action/item_action/toggle)
	species_exception = list(/datum/species/robot)
	sprite_sheets = list("Combat Robot" = 'icons/mob/species/robot/glasses.dmi')
	soft_armor = list("melee" = 40, "bullet" = 40, "laser" = 0, "energy" = 15, "bomb" = 35, "bio" = 10, "rad" = 10, "fire" = 30, "acid" = 30)
	flags_equip_slot = ITEM_SLOT_EYES
	goggles = TRUE

/obj/item/clothing/glasses/hud/medgoggles/prescription
	name = "\improper HealthMate prescription ballistic goggles"
	desc = "Standard issue TGMC prescription goggles. This pair has been fitted with an internal HealthMate HUD projector."
	prescription = TRUE

/obj/item/clothing/glasses/hud/medpatch
	name = "\improper Medpatch HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their health status. For the disabled and/or edgy Corpsman."
	icon_state = "medpatchhud"
	deactive_state = "degoggles_medpatch"
	species_exception = list(/datum/species/robot)
	sprite_sheets = list("Combat Robot" = 'icons/mob/species/robot/glasses.dmi')
	toggleable = TRUE
	hud_type = DATA_HUD_MEDICAL_ADVANCED
	actions_types = list(/datum/action/item_action/toggle)

/obj/item/clothing/glasses/hud/medglasses
	name = "\improper HealthMate regulation prescription glasses"
	desc = "Standard issue TGMC Regulation Prescription Glasses. This pair has been fitted with an internal HealthMate HUD projector."
	icon_state = "medglasses"
	item_state = "medglasses"
	deactive_state = "degoggles_medglasses"
	species_exception = list(/datum/species/robot)
	sprite_sheets = list("Combat Robot" = 'icons/mob/species/robot/glasses.dmi')
	prescription = TRUE
	toggleable = TRUE
	hud_type = DATA_HUD_MEDICAL_ADVANCED
	actions_types = list(/datum/action/item_action/toggle)

/obj/item/clothing/glasses/hud/security
	name = "\improper PatrolMate HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their ID status and security records."
	species_exception = list(/datum/species/robot)
	sprite_sheets = list("Combat Robot" = 'icons/mob/species/robot/glasses.dmi')
	icon_state = "securityhud"
	deactive_state = "degoggles_sec"
	toggleable = 1
	flags_armor_protection = NONE
	hud_type = DATA_HUD_SECURITY_ADVANCED
	actions_types = list(/datum/action/item_action/toggle)
	var/global/list/jobs[0]

/obj/item/clothing/glasses/hud/security/jensenshades
	name = "augmented shades"
	desc = "Polarized bioneural eyewear, designed to augment your vision."
	icon_state = "jensenshades"
	item_state = "jensenshades"
	vision_flags = SEE_MOBS
	toggleable = 0
	actions_types = null

/obj/item/clothing/glasses/hud/xenohud
	name = "XenoMate HUD"
	desc = "A heads-up display that scans any nearby xenomorph's data."
	icon_state = "securityhud"
	deactive_state = "degoggles_sec"
	species_exception = list(/datum/species/robot)
	sprite_sheets = list("Combat Robot" = 'icons/mob/species/robot/glasses.dmi')
	flags_armor_protection = NONE
	toggleable = TRUE
	hud_type = DATA_HUD_XENO_STATUS
	actions_types = list(/datum/action/item_action/toggle)

/obj/item/clothing/glasses/hud/painhud
	name = "Pain HUD"
	desc = "A heads-up display that scans human pain and perceived health."
	icon_state = "securityhud"
	deactive_state = "degoggles_sec"
	species_exception = list(/datum/species/robot)
	sprite_sheets = list("Combat Robot" = 'icons/mob/species/robot/glasses.dmi')
	toggleable = TRUE
	hud_type = DATA_HUD_MEDICAL_PAIN
	actions_types = list(/datum/action/item_action/toggle)
