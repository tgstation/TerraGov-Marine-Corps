/datum/mutant_accessory/horns
	key = "horns"
	generic = "Horns"
	relevent_layers = list(BODY_FRONT_LAYER)
	icon = 'icons/mob/mutant_accessory/horns.dmi'
	default_color = "555555"

/datum/mutant_accessory/horns/is_hidden(mob/living/carbon/human/H)
	if(H.head && (H.try_hide_mutant_parts || (H.head.flags_inv_hide & HIDETOPHAIR) || (H.wear_mask && (H.wear_mask.flags_inv_hide & HIDETOPHAIR))))
		return TRUE
	return FALSE

/datum/mutant_accessory/horns/none
	name = "None"
	icon_state = "none"
	color_src = null

/datum/mutant_accessory/horns/simple
	name = "Simple"
	icon_state = "simple"

/datum/mutant_accessory/horns/short
	name = "Short"
	icon_state = "short"

/datum/mutant_accessory/horns/curled
	name = "Curled"
	icon_state = "curled"

/datum/mutant_accessory/horns/ram
	name = "Ram"
	icon_state = "ram"

/datum/mutant_accessory/horns/angler
	name = "Angeler"
	icon_state = "angler"
	default_color = DEFAULT_SECONDARY

/datum/mutant_accessory/horns/guilmon
	name = "Guilmon"
	icon_state = "guilmon"

/datum/mutant_accessory/horns/drake
	name = "Drake"
	icon_state = "drake"

/datum/mutant_accessory/horns/knight
	name = "Knight"
	icon_state = "knight"
