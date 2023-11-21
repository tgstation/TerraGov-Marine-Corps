/datum/mutant_accessory/moth_antennae
	generic = "Moth Antennae"
	key = "moth_antennae"
	relevent_layers = list(BODY_BEHIND_LAYER, BODY_FRONT_LAYER)
	icon = 'icons/mob/mutant_accessory/moth_antennae.dmi'
	default_color = "FFFFFF"

/datum/mutant_accessory/moth_antennae/is_hidden(mob/living/carbon/human/H)
	if(H.head && (H.head.flags_inv_hide & HIDETOPHAIR) || (H.wear_mask && (H.wear_mask.flags_inv_hide & HIDETOPHAIR)))
		return TRUE
	return FALSE

/datum/mutant_accessory/moth_antennae/none
	name = "None"
	icon_state = "none"
	color_src = null

/datum/mutant_accessory/moth_antennae/plain
	name = "Plain"
	icon_state = "plain"

/datum/mutant_accessory/moth_antennae/reddish
	name = "Reddish"
	icon_state = "reddish"

/datum/mutant_accessory/moth_antennae/royal
	name = "Royal"
	icon_state = "royal"

/datum/mutant_accessory/moth_antennae/gothic
	name = "Gothic"
	icon_state = "gothic"

/datum/mutant_accessory/moth_antennae/whitefly
	name = "White Fly"
	icon_state = "whitefly"

/datum/mutant_accessory/moth_antennae/lovers
	name = "Lovers"
	icon_state = "lovers"

/datum/mutant_accessory/moth_antennae/burnt_off
	name = "Burnt Off"
	icon_state = "burnt_off"

/datum/mutant_accessory/moth_antennae/firewatch
	name = "Firewatch"
	icon_state = "firewatch"

/datum/mutant_accessory/moth_antennae/deathhead
	name = "Deathshead"
	icon_state = "deathhead"

/datum/mutant_accessory/moth_antennae/poison
	name = "Poison"
	icon_state = "poison"

/datum/mutant_accessory/moth_antennae/ragged
	name = "Ragged"
	icon_state = "ragged"

/datum/mutant_accessory/moth_antennae/moonfly
	name = "Moon Fly"
	icon_state = "moonfly"

/datum/mutant_accessory/moth_antennae/oakworm
	name = "Oak Worm"
	icon_state = "oakworm"

/datum/mutant_accessory/moth_antennae/jungle
	name = "Jungle"
	icon_state = "jungle"

/datum/mutant_accessory/moth_antennae/witchwing
	name = "Witch Wing"
	icon_state = "witchwing"

/datum/mutant_accessory/moth_antennae/regal
	name = "Regal"
	icon_state = "regal"
