/datum/mutant_accessory/skrell_hair
	icon = 'icons/mob/mutant_accessory/skrell_hair.dmi'
	generic = "Skrell Headtails"
	key = "skrell_hair"
	color_src = USE_ONE_COLOR
	relevent_layers = list(BODY_ADJ_LAYER, BODY_FRONT_LAYER)

/datum/mutant_accessory/skrell_hair/is_hidden(mob/living/carbon/human/H)
	if(H.head && (H.head.flags_inv_hide & HIDETOPHAIR) || (H.wear_mask && (H.wear_mask.flags_inv_hide & HIDETOPHAIR)))
		return TRUE
	return FALSE

/datum/mutant_accessory/skrell_hair/long
	name = "Female"
	icon_state = "long"

/datum/mutant_accessory/skrell_hair/short
	name = "Male"
	icon_state = "short"
