/obj/item/organ/cyberimp/eyes
	name = "cybernetic eye implant"
	desc = ""
	icon_state = "eye_implant"
	implant_overlay = "eye_implant_overlay"
	slot = ORGAN_SLOT_EYES
	zone = BODY_ZONE_PRECISE_R_EYE
	w_class = WEIGHT_CLASS_TINY

// HUD implants
/obj/item/organ/cyberimp/eyes/hud
	name = "HUD implant"
	desc = ""
	slot = ORGAN_SLOT_HUD
	var/HUD_type = 0
	var/HUD_trait = null

/obj/item/organ/cyberimp/eyes/hud/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = FALSE)
	..()
	if(HUD_type)
		var/datum/atom_hud/H = GLOB.huds[HUD_type]
		H.add_hud_to(M)
	if(HUD_trait)
		ADD_TRAIT(M, HUD_trait, ORGAN_TRAIT)

/obj/item/organ/cyberimp/eyes/hud/Remove(mob/living/carbon/M, special = 0)
	if(HUD_type)
		var/datum/atom_hud/H = GLOB.huds[HUD_type]
		H.remove_hud_from(M)
	if(HUD_trait)
		REMOVE_TRAIT(M, HUD_trait, ORGAN_TRAIT)
	..()

/obj/item/organ/cyberimp/eyes/hud/medical
	name = "Medical HUD implant"
	desc = ""
	HUD_type = DATA_HUD_MEDICAL_ADVANCED
	HUD_trait = TRAIT_MEDICAL_HUD

/obj/item/organ/cyberimp/eyes/hud/security
	name = "Security HUD implant"
	desc = ""
	HUD_type = DATA_HUD_SECURITY_ADVANCED
	HUD_trait = TRAIT_SECURITY_HUD

/obj/item/organ/cyberimp/eyes/hud/diagnostic
	name = "Diagnostic HUD implant"
	desc = ""
	HUD_type = DATA_HUD_DIAGNOSTIC_ADVANCED

/obj/item/organ/cyberimp/eyes/hud/security/syndicate
	name = "Contraband Security HUD Implant"
	desc = ""
	syndicate_implant = TRUE
