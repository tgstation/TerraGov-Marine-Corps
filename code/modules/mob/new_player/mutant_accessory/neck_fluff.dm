/datum/mutant_accessory/neck_fluff
	icon = 'icons/mob/mutant_accessory/moth_fluff.dmi'
	default_color = "FFFFFF"
	key = "neck_fluff"
	generic = "Neck Fluff"
	relevent_layers = list(BODY_ADJ_LAYER)

/datum/mutant_accessory/neck_fluff/none
	name = "None"
	icon_state = "none"
	color_src = null

/datum/mutant_accessory/neck_fluff/is_hidden(mob/living/carbon/human/H)
	if(H.head && (H.head.flags_inv_hide & HIDELOWHAIR) || (H.wear_mask && (H.wear_mask.flags_inv_hide & HIDELOWHAIR)))
		return TRUE
	return FALSE

/datum/mutant_accessory/neck_fluff/moth

/datum/mutant_accessory/neck_fluff/moth/plain
	name = "Plain"
	icon_state = "plain"

/datum/mutant_accessory/neck_fluff/moth/monarch
	name = "Monarch"
	icon_state = "monarch"

/datum/mutant_accessory/neck_fluff/moth/luna
	name = "Luna"
	icon_state = "luna"

/datum/mutant_accessory/neck_fluff/moth/atlas
	name = "Atlas"
	icon_state = "atlas"

/datum/mutant_accessory/neck_fluff/moth/reddish
	name = "Reddish"
	icon_state = "redish"

/datum/mutant_accessory/neck_fluff/moth/royal
	name = "Royal"
	icon_state = "royal"

/datum/mutant_accessory/neck_fluff/moth/gothic
	name = "Gothic"
	icon_state = "gothic"

/datum/mutant_accessory/neck_fluff/moth/lovers
	name = "Lovers"
	icon_state = "lovers"

/datum/mutant_accessory/neck_fluff/moth/whitefly
	name = "White Fly"
	icon_state = "whitefly"

/datum/mutant_accessory/neck_fluff/moth/punished
	name = "Burnt Off"
	icon_state = "punished"
	locked = TRUE

/datum/mutant_accessory/neck_fluff/moth/firewatch
	name = "Firewatch"
	icon_state = "firewatch"

/datum/mutant_accessory/neck_fluff/moth/deathhead
	name = "Deathshead"
	icon_state = "deathhead"

/datum/mutant_accessory/neck_fluff/moth/poison
	name = "Poison"
	icon_state = "poison"

/datum/mutant_accessory/neck_fluff/moth/ragged
	name = "Ragged"
	icon_state = "ragged"

/datum/mutant_accessory/neck_fluff/moth/moonfly
	name = "Moon Fly"
	icon_state = "moonfly"

/datum/mutant_accessory/neck_fluff/moth/snow
	name = "Snow"
	icon_state = "snow"

/datum/mutant_accessory/neck_fluff/moth/oakworm
	name = "Oak Worm"
	icon_state = "oakworm"

/datum/mutant_accessory/neck_fluff/moth/jungle
	name = "Jungle"
	icon_state = "jungle"

/datum/mutant_accessory/neck_fluff/moth/witchwing
	name = "Witch Wing"
	icon_state = "witchwing"

/datum/mutant_accessory/neck_fluff/moth/insectm
	name = "Insect male"
	icon_state = "insectm"
	default_color = DEFAULT_TERTIARY

/datum/mutant_accessory/neck_fluff/moth/insectf
	name = "Insect female"
	icon_state = "insectf"
	default_color = DEFAULT_TERTIARY

/datum/mutant_accessory/neck_fluff/moth/fsnow
	name = "Snow (Top)"
	icon_state = "fsnow"
	relevent_layers = list(BODY_FRONT_LAYER)
