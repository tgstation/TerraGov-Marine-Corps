/obj/item/clothing/glasses/hud
	name = "HUD"
	desc = "A heads-up display that provides important info in (almost) real time."
	flags_atom = null //doesn't protect eyes because it's a monocle, duh
	var/hud_type


/obj/item/clothing/glasses/hud/equipped(mob/living/carbon/human/user, slot)
	if(slot == SLOT_GLASSES && active)
		var/datum/atom_hud/H = GLOB.huds[hud_type]
		H.add_hud_to(user)
	..()

/obj/item/clothing/glasses/hud/dropped(mob/living/carbon/human/user)
	if(istype(user) && active)
		if(src == user.glasses) //dropped is called before the inventory reference is updated.
			var/datum/atom_hud/H = GLOB.huds[hud_type]
			H.remove_hud_from(user)
	..()

/obj/item/clothing/glasses/hud/attack_self(mob/user)
	..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(toggleable && H.glasses == src) //toggleable and worn
			var/datum/atom_hud/MH = GLOB.huds[hud_type]
			if(active)
				MH.add_hud_to(user)
			else
				MH.remove_hud_from(user)


/obj/item/clothing/glasses/hud/health
	name = "\improper HealthMate HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their health status."
	icon_state = "healthhud"
	deactive_state = "degoggles_med"
	flags_armor_protection = 0
	toggleable = 1
	hud_type = DATA_HUD_MEDICAL_ADVANCED
	actions_types = list(/datum/action/item_action/toggle)

/obj/item/clothing/glasses/hud/security
	name = "\improper PatrolMate HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their ID status and security records."
	icon_state = "securityhud"
	deactive_state = "degoggles_sec"
	toggleable = 1
	flags_armor_protection = 0
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
	actions_types = list()

/obj/item/clothing/glasses/hud/xenohud
	name = "XenoMate HUD"
	desc = "A heads-up display that scans any nearby xenomorph's data."
	icon_state = "securityhud"
	deactive_state = "degoggles_sec"
	flags_armor_protection = 0
	toggleable = TRUE
	hud_type = DATA_HUD_XENO_STATUS
	actions_types = list(/datum/action/item_action/toggle)

/obj/item/clothing/glasses/hud/painhud
	name = "Pain HUD"
	desc = "A heads-up display that scans human pain and perceived health."
	icon_state = "securityhud"
	deactive_state = "degoggles_sec"
	toggleable = TRUE
	hud_type = DATA_HUD_MEDICAL_PAIN
	actions_types = list(/datum/action/item_action/toggle)
