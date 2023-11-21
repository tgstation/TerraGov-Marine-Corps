/datum/mutant_accessory/frills
	key = "frills"
	generic = "Frills"
	icon = 'icons/mob/mutant_accessory/frills.dmi'
	default_color = DEFAULT_SECONDARY
	relevent_layers = list(BODY_ADJ_LAYER)

/datum/mutant_accessory/frills/is_hidden(mob/living/carbon/human/H)
	if(H.head && (H.try_hide_mutant_parts || (H.head.flags_inv_hide & HIDEEARS)))
		return TRUE
	return FALSE

/datum/mutant_accessory/frills/none
	name = "None"
	icon_state = "none"

/datum/mutant_accessory/frills/simple
	name = "Simple"
	icon_state = "simple"

/datum/mutant_accessory/frills/short
	name = "Short"
	icon_state = "short"

/datum/mutant_accessory/frills/aquatic
	name = "Aquatic"
	icon_state = "aqua"

/datum/mutant_accessory/frills/divinity
	name = "Divinity"
	icon_state = "divinity"

/datum/mutant_accessory/frills/horns
	name = "Horns"
	icon_state = "horns"

/datum/mutant_accessory/frills/hornsdouble
	name = "Horns Double"
	icon_state = "hornsdouble"

/datum/mutant_accessory/frills/big
	name = "Big"
	icon_state = "big"

/datum/mutant_accessory/frills/cobrahood
	name = "Cobra Hood"
	icon_state = "cobrahood"
	color_src = USE_MATRIXED_COLORS

/datum/mutant_accessory/frills/cobrahoodears
	name = "Cobra Hood (Ears)"
	icon_state = "cobraears"
	color_src = USE_MATRIXED_COLORS
