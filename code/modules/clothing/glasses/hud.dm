/obj/item/clothing/glasses/hud
	name = "HUD"
	desc = "A heads-up display that provides important info in (almost) real time."
	flags_atom = null //doesn't protect eyes because it's a monocle, duh
	origin_tech = "magnets=3;biotech=2"
	var/hud_type


/obj/item/clothing/glasses/hud/equipped(mob/living/carbon/human/user, slot)
	if(slot == WEAR_EYES && active)
		var/datum/mob_hud/H = huds[hud_type]
		H.add_hud_to(user)
	..()

/obj/item/clothing/glasses/hud/dropped(mob/living/carbon/human/user)
	if(istype(user) && active)
		if(src == user.glasses) //dropped is called before the inventory reference is updated.
			var/datum/mob_hud/H = huds[hud_type]
			H.remove_hud_from(user)
	..()

/obj/item/clothing/glasses/hud/attack_self(mob/user)
	..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(toggleable && H.glasses == src) //toggleable and worn
			var/datum/mob_hud/MH = huds[hud_type]
			if(active)
				MH.add_hud_to(user)
			else
				MH.remove_hud_from(user)


/obj/item/clothing/glasses/hud/health
	name = "\improper HealthMate HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their health status."
	icon_state = "healthhud"
	flags_armor_protection = 0
	toggleable = 1
	hud_type = MOB_HUD_MEDICAL_ADVANCED
	actions_types = list(/datum/action/item_action/toggle)


/obj/item/clothing/glasses/hud/health/attack_self(mob/living/user)
	if(!user.mind || !user.mind.cm_skills || user.mind.cm_skills.medical >= SKILL_MEDICAL_MEDIC)
		..()
	else
		user << "<span class='warning'>You have no idea what any of the data means and power it off before it makes you nauseated.</span>"
		active = 0

/obj/item/clothing/glasses/hud/health/equipped(mob/living/carbon/human/user, slot)
	if(!user.mind || !user.mind.cm_skills || user.mind.cm_skills.medical >= SKILL_MEDICAL_MEDIC)
		..()
	else
		user << "<span class='warning'>You have no idea what any of the data means and power it off before it makes you nauseated.</span>"
		active = 0

/obj/item/clothing/glasses/hud/security
	name = "\improper PatrolMate HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their ID status and security records."
	icon_state = "securityhud"
	toggleable = 1
	flags_armor_protection = 0
	hud_type = MOB_HUD_SECURITY_ADVANCED
	actions_types = list(/datum/action/item_action/toggle)
	var/global/list/jobs[0]

/obj/item/clothing/glasses/hud/security/jensenshades
	name = "augmented shades"
	desc = "Polarized bioneural eyewear, designed to augment your vision."
	icon_state = "jensenshades"
	item_state = "jensenshades"
	vision_flags = SEE_MOBS
	invisa_view = 2
	toggleable = 0
	actions_types = list()